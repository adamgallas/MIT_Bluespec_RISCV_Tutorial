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

(*synthesize*)
module mkProc(Proc);
    Reg#(Addr)  pc<-mkRegU;
    RFile       rf<-mkRFile;
    IMemory     iMem<-mkIMemory;
    DMemory     dMem<-mkDMemory;
    CsrFile     csrf<-mkCsrFile;

    Bool memReady=iMem.init.done() && dMem.init.done();
/*
    rule test(!memReady);
        let e=tagged InitDone;
        iMem.init.request.put(e);
        dMem.init.request.put(e);
    endrule
*/

    rule doProc(csrf.started);
        Data        inst=iMem.req(pc);
        DecodedInst dInst=decode(inst);
        Data        rVal1=rf.rd1(fromMaybe(?,dInst.src1));
        Data        rVal2=rf.rd2(fromMaybe(?,dInst.src2));
        Data        csrVal=csrf.rd(fromMaybe(?,dInst.csr));
        ExecInst    eInst=exec(
            dInst,
            rVal1,rVal2,
            pc,?,
            csrVal
            );

        $display("pc:%h inst:(%h) expanded: ",pc,inst,showInst(inst));
        $fflush(stdout);

        if(eInst.iType==Unsupported) begin
            $fwrite(stderr, "ERROR: Executing unsupported instruction at pc: %x. Exiting\n", pc);
            $finish;
        end

        if(eInst.iType==Ld) begin
            eInst.data<-dMem.req(MemReq{op:Ld,addr:eInst.addr,data:?});    
        end else if(eInst.iType==St) begin
            let dummy<-dMem.req(MemReq{op:St,addr:eInst.addr,data:eInst.data});
        end

        if(isValid(eInst.dst)) begin
            rf.wr(fromMaybe(?,eInst.dst),eInst.data);
        end

        pc<=eInst.brTaken?eInst.addr:pc+4;

        csrf.wr(eInst.iType==Csrw?eInst.csr:Invalid,eInst.data);

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
