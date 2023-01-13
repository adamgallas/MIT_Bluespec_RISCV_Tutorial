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
import Btb::*;
import GetPut::*;
import FPGAMemory::*;
import Scoreboard::*;

typedef struct{
    Addr pc;
    Addr predPc;
    Bool epoch;
} Fetch2Decode deriving (Bits,Eq);

typedef struct{
    Addr pc;
    Addr predPc;
    DecodedInst dInst;
    Bool epoch;
} Decode2Register deriving (Bits,Eq);

typedef struct{
    Addr pc;
    Addr predPc;
    DecodedInst dInst;
    Data rVal1;
    Data rVal2;
    Data csrVal;
    Bool epoch;
} Register2Execute deriving (Bits,Eq);

typedef struct{
    Addr pc;
    Maybe#(ExecInst) eInst;
} Execute2Memory deriving (Bits,Eq);

typedef struct{
    Addr pc;
    Maybe#(ExecInst) eInst;
} Memory2WriteBack deriving (Bits,Eq);

typedef struct{
    Addr pc;
    Addr nextPc;
} ExeRedirect deriving (Bits,Eq);

(*synthesize*)
module mkProc(Proc);
    
    Ehr#(2,Addr)    pcReg<-mkEhr(?);
    RFile           rf<-mkRFile;
    Scoreboard#(10) sb<-mkCFScoreboard;
    FPGAMemory      iMem<-mkFPGAMemory;
    FPGAMemory      dMem<-mkFPGAMemory;
    CsrFile         csrf<-mkCsrFile;
    Btb#(6)         btb<-mkBtb;

    Fifo#(2,Fetch2Decode)       f2dFifo     <-  mkCFFifo;
    Fifo#(2,Decode2Register)    d2rFifo     <-  mkCFFifo;
    Fifo#(2,Register2Execute)   r2eFifo     <-  mkCFFifo;
    Fifo#(2,Execute2Memory)     e2mFifo     <-  mkCFFifo;
    Fifo#(2,Memory2WriteBack)   m2wbFifo    <-  mkCFFifo;

    Reg#(Bool)                  exeEpoch    <-mkReg(False);
    Ehr#(2,Maybe#(ExeRedirect)) exeRedirect <-mkEhr(Invalid);

    Bool memReady=iMem.init.done() && dMem.init.done();

    rule doFetch(csrf.started);

        iMem.req(MemReq{op:?,addr:pcReg[0],data:?});
        Addr predPc=btb.predPc(pcReg[0]);
        Fetch2Decode f2d = Fetch2Decode{
            pc:     pcReg[0],
            predPc: predPc,
            epoch:  exeEpoch
        };

        f2dFifo.enq(f2d);
        pcReg[0]<=predPc;

        $display("Request instruction: PC = %x, next PC: %x", pcReg[0], predPc);
    endrule

    rule doDecode(csrf.started);
        
        let f2d = f2dFifo.first;
        f2dFifo.deq;

        Data        inst    <- iMem.resp();
        DecodedInst dInst   = decode(inst);

        Decode2Register d2r = Decode2Register{
            pc:         f2d.pc,
            predPc:     f2d.predPc,
            dInst:      dInst,
            epoch:      f2d.epoch
        };

        d2rFifo.enq(d2r);
        $display("Fetch: PC = %x, inst = %x, expanded = ", f2d.pc, inst, showInst(inst));
    endrule

    rule doRegister(csrf.started);

        let d2r = d2rFifo.first;
        let dInst = d2r.dInst;

        Data        rVal1=rf.rd1(fromMaybe(?,dInst.src1));
        Data        rVal2=rf.rd2(fromMaybe(?,dInst.src2));
        Data        csrVal=csrf.rd(fromMaybe(?,dInst.csr));

        if(!sb.search1(dInst.src1) && !sb.search2(dInst.src2)) begin

            d2rFifo.deq;
            sb.insert(dInst.dst);
            
            Register2Execute r2e = Register2Execute{
                pc:     d2r.pc,
                predPc: d2r.predPc,
                dInst:  d2r.dInst,
                rVal1:  rVal1,
                rVal2:  rVal2,
                csrVal: csrVal,
                epoch:  d2r.epoch
            };

            r2eFifo.enq(r2e);
            $display("Read registers: PC = %x", d2r.pc);
        end else begin
            $display("[Stalled] Read registers: PC = %x", d2r.pc);
        end
    endrule

    rule doExecute(csrf.started);

        let r2e = r2eFifo.first;
        r2eFifo.deq;

        Maybe#(ExecInst) eInst;

        if(r2e.epoch!=exeEpoch) begin

            eInst = Invalid;

        end else begin

            ExecInst exeInst = exec(
                r2e.dInst,
                r2e.rVal1,r2e.rVal2,
                r2e.pc,r2e.predPc,
                r2e.csrVal
            );
            eInst = Valid(exeInst);

            if(exeInst.mispredict) begin
                $display("Mispredict!");
                $fflush(stdout);

                Bool jumpHappen =
                    exeInst.iType==J    ||
                    exeInst.iType==Jr   ||
                    exeInst.iType==Br;
                
                let realNextPc = jumpHappen? exeInst.addr:r2e.pc+4;
                exeRedirect[0]<=Valid(ExeRedirect{
                    pc:r2e.pc,
                    nextPc:realNextPc
                });
            end else begin
                $display("Execute!");
                $fflush(stdout);
            end
        end

        Execute2Memory e2m = Execute2Memory{
            pc: r2e.pc,
            eInst:eInst
        };
        e2mFifo.enq(e2m);

    endrule

    rule doMemory(csrf.started);

        let e2m = e2mFifo.first;
        e2mFifo.deq;

        if(isValid(e2m.eInst)) begin

            let exeInst = fromMaybe(?,e2m.eInst);
            if(exeInst.iType==Ld) begin

                dMem.req(MemReq{op:Ld,addr:exeInst.addr,data:?});

            end else if(exeInst.iType==St) begin

                let dummy<-dMem.req(MemReq{op:St,addr:exeInst.addr,data:exeInst.data});

            end

        end else begin
            $display("Memory stage of poisoned instruction");
            $fflush(stdout);
        end

        Memory2WriteBack m2wb = Memory2WriteBack{
            pc: e2m.pc,
            eInst:e2m.eInst
        };
        m2wbFifo.enq(m2wb);

    endrule

    rule doWriteBack(csrf.started);
        
        let m2wb = m2wbFifo.first;
        m2wbFifo.deq;

        if(isValid(m2wb.eInst)) begin

            let exeInst = fromMaybe(?,m2wb.eInst);
            if(exeInst.iType==Ld) begin
                exeInst.data<-dMem.resp();
            end

            if(isValid(exeInst.dst)) begin
                rf.wr(fromMaybe(?,exeInst.dst),exeInst.data);
            end
            csrf.wr(exeInst.iType==Csrw?exeInst.csr:Invalid,exeInst.data);

            $display("Write back stage of instruction: PC = %x", m2wb.pc);
        end else begin
            $display("WriteBack stage of poisoned instruction");
            $fflush(stdout);
        end

        sb.remove;

    endrule

    (* fire_when_enabled *)
    (* no_implicit_conditions *)
    rule canonicalizeRedirect(csrf.started);
        if(exeRedirect[1] matches tagged Valid .r) begin

            pcReg[1] <= r.nextPc;
            exeEpoch <= !exeEpoch;
            btb.update(r.pc,r.nextPc);
            $display("Fetch: Mispredict, redirected by Execute");

        end

        exeRedirect[1]<=Invalid;
    endrule

    method ActionValue#(CpuToHostData) cpuToHost;
        let ret<-csrf.cpuToHost;
        return ret;
    endmethod

    method Action hostToCpu(Bit#(32) startpc) if(!csrf.started&&memReady);
        csrf.start(0);
        $display("STARTING AT PC: %h", startpc);
        $fflush(stdout);
        pcReg[0]<=startpc;
    endmethod

    interface iMemInit=iMem.init;
    interface dMemInit=dMem.init;
endmodule
