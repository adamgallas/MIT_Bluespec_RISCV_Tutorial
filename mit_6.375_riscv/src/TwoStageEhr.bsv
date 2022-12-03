import Types::*;
import ProcTypes::*;
import MemTypes::*;
import RFile::*;
import Decode::*;
import Exec::*;
import CsrFile::*;
import Vector::*;
import FIFO::*;
import MemUtil::*;
import ClientServer::*;
import Ehr::*;
import GetPut::*;

import Cache::*;
import Fifo::*;
import MemInit::*;
import CacheTypes::*;

typedef struct {
   Word pc;
   Word ppc;
   Bool epoch;
   } F2E deriving(Bits, Eq);

typedef enum {Execute, LoadWait } State deriving (Bits, Eq);

module mkProc#(Fifo#(2, DDR3_Req) ddr3ReqFifo, Fifo#(2, DDR3_Resp) ddr3RespFifo)(Proc);
////////////////////////////////////////////////////////////////////////////////
/// Processor module instantiation
////////////////////////////////////////////////////////////////////////////////
   Ehr#(2,Word)  pc <- mkEhr(?);
   Ehr#(2,Bool)  epoch <- mkEhr(?);
   RFile      rf <- mkRFile;
   CsrFile  csrf <- mkCsrFile;
   
   Fifo#(2,F2E) f2e <- mkCFFifo;

   Reg#(Bool)  loadWaitReg <- mkReg(False);
   Reg#(RIndx) dstLoad <- mkReg(0);
   
   Reg#(State) state <- mkReg(Execute);
    

////////////////////////////////////////////////////////////////////////////////
/// Section: Memory Subsystem
////////////////////////////////////////////////////////////////////////////////

    Bool                        memReady    =  True;
    let                         wideMem     <- mkWideMemFromDDR3(ddr3ReqFifo,ddr3RespFifo);
    Vector#(2, WideMem)         splitMem    <- mkSplitWideMem(memReady && csrf.started, wideMem);

    Cache iMem <- mkCache( splitMem[1] );
    Cache dMem <- mkCache( splitMem[0] );

    rule drainMemResponses( !csrf.started );
        $display("drain!");
        ddr3RespFifo.deq;
    endrule
////////////////////////////////////////////////////////////////////////////////
/// End of Section: Memory Subsystem
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
/// Begin of Section: Processor
////////////////////////////////////////////////////////////////////////////////
   rule doFetch(csrf.started);
      iMem.req(MemReq{op: Ld, addr: pc[0], data: ?});
      let ppc = pc[0] + 4;
      pc[0] <= ppc;
      f2e.enq(F2E {pc: pc[0], ppc: ppc, epoch: epoch[0]});    
   endrule

   rule doExecute(state==Execute);
      let inst <- iMem.resp();
      let x = f2e.first;          
      let pcE = x.pc; let ppc = x.ppc; let epochE = x.epoch; 
      f2e.deq;
       
      DecodedInst dInst = decode(inst);
       
      if (epochE == epoch[1]) begin  // right-path instruction
         if(dInst.iType == Unsupported) begin
            $fwrite(stderr, "ERROR: Executing unsupported instruction at pc: %x. Exiting\n", pcE);
            $finish;
         end
      
         // read general purpose register values 
         Word rVal1 = rf.rd1(fromMaybe(?, dInst.src1));
         Word rVal2 = rf.rd2(fromMaybe(?, dInst.src2));

         // read CSR values (for CSRR inst)
         Word csrVal = csrf.rd(fromMaybe(?, dInst.csr));

         // execute
         ExecInst eInst = exec(dInst, rVal1, rVal2, pcE, csrVal);  
         
         // misprediction 
         let misprediction = eInst.nextPC != ppc;
         if ( misprediction ) begin
            pc[1] <= eInst.nextPC;
            epoch[1] <= !epoch[1];
         end

         if(eInst.iType == Ld) begin
            dMem.req(MemReq{op: Ld, addr: eInst.addr, data: ?});
            dstLoad <= fromMaybe(?, eInst.dst);
            state <= LoadWait;
         end
         else if(eInst.iType == St) begin
            dMem.req(MemReq{op: St, addr: eInst.addr, data: eInst.data});
         end
         else begin
            if(isValid(eInst.dst)) begin
               rf.wr(fromMaybe(?, eInst.dst), eInst.data);
            end
         end
         
         // this needed to be called on every instruction even
         // for non-Csrw itype for counting correct number of instructions

         csrf.wr(eInst.iType == Csrw ? eInst.csr : Invalid, eInst.data);
       end
    endrule
   
   
   rule doLoadWait(state == LoadWait);
      let data <- dMem.resp();
      rf.wr(dstLoad, data);
      state <= Execute;
   endrule
////////////////////////////////////////////////////////////////////////////////
/// End of Section: Processor
////////////////////////////////////////////////////////////////////////////////

   
   method ActionValue#(CpuToHostData) cpuToHost;
      let ret <- csrf.cpuToHost;
      return ret;
   endmethod

   method Action hostToCpu(Bit#(32) startpc) if ( !csrf.started && memReady );
      csrf.start(0); // only 1 core, id = 0
	  $display("Start at pc 200\n");
	  $fflush(stdout);
      pc[0] <= startpc;
   endmethod

endmodule