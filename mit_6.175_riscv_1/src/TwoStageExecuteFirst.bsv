import Types::*;
import ProcTypes::*;
import MemTypes::*;
import RFile::*;
import IMemory::*;
import DMemory::*;
import Decode::*;
import Exec::*;
import CsrFile::*;
import Vector::*;
import Fifo::*;
import Ehr::*;
import GetPut::*;

typedef struct{
    Data inst;
    Addr pc;
    Addr predPc;
    Bool epoch;
} F2D deriving (Bits,Eq);

(*synthesize*)
module mkProc(Proc);
    
    Ehr#(2,Addr) pc<-mkEhrU;
    Ehr#(2,Bool) epoch<-mkEhr(False);
    
    RFile       rf<-mkRFile;
    IMemory     iMem<-mkIMemory;
    DMemory     dMem<-mkDMemory;
    CsrFile     csrf<-mkCsrFile;

    Reg#(Maybe#(F2D)) f2d<-mkReg(tagged Invalid);
    Bool memReady=iMem.init.done() && dMem.init.done();

    rule doFetch(csrf.started);
        Data inst = iMem.req(pc[1]);
        let predPc = pc[1]+4;
        pc[1] <= predPc;
        f2d <= tagged Valid F2D {inst:inst,pc:pc[1],predPc:predPc,epoch:epoch[1]};
    endrule

    rule doExecute(csrf.started &&& f2d matches tagged Valid .x);

        let dInst = decode(x.inst);

        Data rVal1=rf.rd1(fromMaybe(?,dInst.src1));
        Data rVal2=rf.rd2(fromMaybe(?,dInst.src2));
        Data csrVal=csrf.rd(fromMaybe(?,dInst.csr));

        ExecInst eInst=exec(
            dInst,
            rVal1,rVal2,
            x.pc,x.predPc,
            csrVal
            );

        if(x.epoch==epoch[0]) begin
        
            if(eInst.iType==Ld) begin
                eInst.data<-dMem.req(MemReq{op:Ld,addr:eInst.addr,data:?});    
            end else if(eInst.iType==St) begin
                let dummy<-dMem.req(MemReq{op:St,addr:eInst.addr,data:eInst.data});
            end

            if(isValid(eInst.dst)) begin
                rf.wr(fromMaybe(?,eInst.dst),eInst.data);
            end

            csrf.wr(eInst.iType==Csrw?eInst.csr:Invalid,eInst.data);

            if(eInst.mispredict) begin
                $display("Mispredict!");
                $fflush(stdout);
                pc[0]       <=  eInst.addr;
                epoch[0]    <=  !epoch[0];
            end
        end
    endrule

    method ActionValue#(CpuToHostData) cpuToHost;
        let ret<-csrf.cpuToHost;
        return ret;
    endmethod

    method Action hostToCpu(Bit#(32) startpc) if(!csrf.started&&memReady);
        csrf.start(0);
        $display("STARTING AT PC: %h", startpc);
	    $fflush(stdout);
        pc[0]<=startpc;
    endmethod

    interface iMemInit=iMem.init;
    interface dMemInit=dMem.init;
endmodule
