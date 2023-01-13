import Types::*;
import ProcTypes::*;
import MemTypes::*;
import MemInit::*;
import RFile::*;
import DelayedMemory::*;
import Decode::*;
import Exec::*;
import CsrFile::*;
import Vector::*;
import Fifo::*;
import Ehr::*;
import GetPut::*;

typedef enum{
    Fetch,
    Decode,
    Execute,
    WriteBack
} Stage deriving(Bits,Eq,FShow);

typedef struct{
    DecodedInst dInst;
    Data rd1;
    Data rd2;
    Data csrVal;
} Decode2Exec deriving(Bits,Eq);

(*synthesize*)
module mkProc(Proc);
    Reg#(Addr)      pc<-mkRegU;
    RFile           rf<-mkRFile;
    DelayedMemory   mem<-mkDelayedMemory;
    let             dummyInit<-mkDummyMemInit;
    CsrFile         csrf<-mkCsrFile;

    Reg#(Stage)     state<-mkRegU;
    Reg#(Decode2Exec) d2e<-mkRegU;
    Reg#(ExecInst)  e2w<-mkRegU;

    Bool memReady = mem.init.done && dummyInit.done;

    rule doFetch(csrf.started && state == Fetch);
        mem.req(MemReq{op:?,addr:pc,data:?});
        state<=Decode;
    endrule

    rule doDecode(csrf.started && state == Decode);
        Data        inst<-mem.resp;
        DecodedInst dInst=decode(inst);

        Decode2Exec dec2exe;
        dec2exe.dInst   =dInst;
        dec2exe.rd1     =rf.rd1(fromMaybe(?,dInst.src1));
        dec2exe.rd2     =rf.rd2(fromMaybe(?,dInst.src2));
        dec2exe.csrVal  =csrf.rd(fromMaybe(?,dInst.csr));

        d2e<=dec2exe;
        state<=Execute;
    endrule

    rule doExecute(csrf.started && state==Execute);
        ExecInst eInst = exec(d2e.dInst,d2e.rd1,d2e.rd2,pc,?,d2e.csrVal);

        if(eInst.iType == Unsupported) begin
            $fwrite(stderr, "ERROR: Executing unsupported instruction at pc: %x. Exiting\n", pc);
            $finish;
        end

        if(eInst.iType==Ld) begin
            mem.req(MemReq{op:Ld,addr:eInst.addr,data:?});
        end else if(eInst.iType==St) begin
            let dummy <- mem.req(MemReq{op:St,addr:eInst.addr,data:eInst.data});
        end

        e2w<=eInst;
        state<=WriteBack;
    endrule

    rule doWriteBack(csrf.started&&state==WriteBack);

        if(isValid(e2w.dst)) begin
            if(e2w.iType==Ld) begin
                Data loadData<-mem.resp;
                rf.wr(fromMaybe(?,e2w.dst),loadData);
            end else begin
                rf.wr(fromMaybe(?,e2w.dst),e2w.data);
            end
        end else begin
            if(e2w.iType==Ld) begin
                Data dummy<-mem.resp;
            end
        end

        pc<=e2w.brTaken?e2w.addr:pc+4;
        csrf.wr(e2w.iType==Csrw?e2w.csr:Invalid,e2w.data);

        state<=Fetch;
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
        state<=Fetch;
    endmethod

    interface iMemInit=dummyInit;
    interface dMemInit=mem.init;
endmodule