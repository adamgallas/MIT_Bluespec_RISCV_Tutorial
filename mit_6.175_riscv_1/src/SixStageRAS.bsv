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
import Bht::*;
import Ras::*;

typedef struct{
    Addr pc;
    Addr predPc;
    Bool exeEpoch;
    Bool decEpoch;
} Fetch2Decode deriving (Bits,Eq);

typedef struct{
    Addr pc;
    Addr predPc;
    DecodedInst dInst;
    Bool exeEpoch;
} Decode2Register deriving (Bits,Eq);

typedef struct{
    Addr pc;
    Addr predPc;
    DecodedInst dInst;
    Data rVal1;
    Data rVal2;
    Data csrVal;
    Bool exeEpoch;
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

typedef struct{
    Addr nextPc;
} DecRedirect deriving (Bits,Eq);

function Bool isRdX1(Data inst);
    let rd=inst[11:7];
    return rd==5'b00001;
endfunction

function Bool isJalrReturn(Data inst);
    let rd=inst[11:7];
    let rs1=inst[19:15];
    return rd==5'b00000 && rs1==5'b00001;
endfunction

(*synthesize*)
module mkProc(Proc);

    Ehr#(2,Addr)    pcReg<-mkEhr(?);
    RFile           rf<-mkRFile;
    Scoreboard#(10) sb<-mkCFScoreboard;
    FPGAMemory      iMem<-mkFPGAMemory;
    FPGAMemory      dMem<-mkFPGAMemory;
    CsrFile         csrf<-mkCsrFile;
    Btb#(6)         btb<-mkBtb;
    Bht#(8)         bht<-mkBht;
    Ras#(3)         ras<-mkRas;

    Fifo#(2,Fetch2Decode)       f2dFifo     <-  mkCFFifo;
    Fifo#(2,Decode2Register)    d2rFifo     <-  mkCFFifo;
    Fifo#(2,Register2Execute)   r2eFifo     <-  mkCFFifo;
    Fifo#(2,Execute2Memory)     e2mFifo     <-  mkCFFifo;
    Fifo#(2,Memory2WriteBack)   m2wbFifo    <-  mkCFFifo;

    Reg#(Bool)                  exeEpoch    <-mkReg(False);
    Reg#(Bool)                  decEpoch    <-mkReg(False);

    Ehr#(2,Maybe#(ExeRedirect)) exeRedirect <-mkEhr(Invalid);
    Ehr#(2,Maybe#(DecRedirect)) decRedirect <-mkEhr(Invalid);

    Bool memReady=iMem.init.done() && dMem.init.done();

    rule doFetch(csrf.started);

        iMem.req(MemReq{op:?,addr:pcReg[0],data:?});
        Addr predPc=btb.predPc(pcReg[0]);
        Fetch2Decode f2d = Fetch2Decode{
            pc:     pcReg[0],
            predPc: predPc,
            exeEpoch:   exeEpoch,
            decEpoch:   decEpoch
        };

        f2dFifo.enq(f2d);
        pcReg[0]<=predPc;
    endrule

    rule doDecode(csrf.started);
        
        let f2d = f2dFifo.first;
        f2dFifo.deq;

        Data        inst    <- iMem.resp();

        if(f2d.decEpoch==decEpoch && f2d.exeEpoch==exeEpoch) begin

            DecodedInst dInst   = decode(inst);

            if(dInst.iType==Br) begin

                let bhtPred = bht.predPc(f2d.pc,f2d.predPc);
                if(bhtPred!=f2d.predPc) begin

                    decRedirect[0]<=Valid(
                        DecRedirect{
                            nextPc:bhtPred
                        }
                    );
                    f2d.predPc=bhtPred;

                end
            end

            if(dInst.iType==J) begin

                if(isRdX1(inst)) begin
                    ras.push(f2d.pc+4);
                end
            end

            if(dInst.iType==Jr) begin

                if(isRdX1(inst)) begin
                    ras.push(f2d.pc+4);
                end

                if(isJalrReturn(inst)) begin
                    Addr rasPopped <- ras.pop();
                    decRedirect[0]<=Valid(
                        DecRedirect{
                            nextPc:rasPopped
                        }
                    );
                    f2d.predPc=rasPopped;
                end
            end

            Decode2Register d2r=Decode2Register{
                pc:         f2d.pc,
                predPc:     f2d.predPc,
                dInst:      dInst,
                exeEpoch:   f2d.exeEpoch
            };

            d2rFifo.enq(d2r);

        end else begin
            $display("Killing wrong path in Decode");
        end

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
                exeEpoch:  d2r.exeEpoch
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

        if(r2e.exeEpoch!=exeEpoch) begin

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

            if(exeInst.iType==Br) begin

                bht.update(r2e.pc,exeInst.brTaken);

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

        end else if(decRedirect[1] matches tagged Valid .r) begin

            pcReg[1] <= r.nextPc;
            decEpoch <= !decEpoch;
            $display("Fetch: Mispredict, redirected by Decode");

        end

        exeRedirect[1]<=Invalid;
        decRedirect[1]<=Invalid;
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
