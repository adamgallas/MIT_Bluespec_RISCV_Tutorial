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
    
    Reg#(Addr) pc<-mkRegU;
    Reg#(Bool) fEpoch<-mkReg(False);
    Reg#(Bool) eEpoch<-mkReg(False);
    
    RFile       rf<-mkRFile;
    IMemory     iMem<-mkIMemory;
    DMemory     dMem<-mkDMemory;
    CsrFile     csrf<-mkCsrFile;

    Fifo#(2,F2D) f2d <- mkCFFifo;
    Fifo#(2,Addr) redir <- mkCFFifo;

    Bool memReady=iMem.init.done() && dMem.init.done();

    rule doFetch(csrf.started);
        Data inst = iMem.req(pc);

        if(!redir.notEmpty) begin
            let predPc = pc + 4;
            pc<=predPc;
            f2d.enq(F2D{inst:inst,pc:pc,predPc:predPc,epoch:fEpoch});
        end else begin
            fEpoch<=!fEpoch;
            pc<=redir.first;
            redir.deq;
        end

    endrule

    rule doExecute(csrf.started);
        let x=f2d.first;
        f2d.deq();

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

        if(x.epoch==eEpoch) begin
        
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
                redir.enq(eInst.addr);
                eEpoch<=!eEpoch;
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
        pc<=startpc;
    endmethod

    interface iMemInit=iMem.init;
    interface dMemInit=dMem.init;
endmodule
