import CacheTypes::*;
import Vector::*;
import MemTypes::*;
import Types::*;
import ProcTypes::*;
import Fifo::*;
import MemUtil::*;
import StQ::*;
import Ehr::*;


typedef enum{Ready, StartMiss, SendFillReq, WaitFillResp} CacheStatus
    deriving(Eq, Bits);
module mkDCache(WideMem mem, DCache ifc);

    Reg#(CacheStatus) status <- mkReg(Ready);

    Vector#(CacheRows, Reg#(CacheLine)) dataArray <- replicateM(mkRegU);
    Vector#(CacheRows, Reg#(Maybe#(CacheTag)))
            tagArray <- replicateM(mkReg(Invalid));
    Vector#(CacheRows, Reg#(Bool)) dirtyArray <- replicateM(mkReg(False));

    Fifo#(2, Data) hitQ <- mkBypassFifo;
    Fifo#(1, MemReq) reqQ <- mkBypassFifo;
    Reg#(MemReq) missReq <- mkRegU;
    Fifo#(2, MemReq) memReqQ <- mkCFFifo;
    Fifo#(2, CacheLine) memRespQ <- mkCFFifo;

    function CacheWordSelect getWord(Addr addr) = truncate(addr >> 2);
    function CacheIndex getIndex(Addr addr) = truncate(addr >> 6);
    function CacheTag getTag(Addr addr) = truncateLSB(addr);

    rule startMiss (status == StartMiss);

        CacheWordSelect sel = getWord(missReq.addr);
        CacheIndex idx = getIndex(missReq.addr);
        let tag = tagArray[idx];

        let dirty = dirtyArray[idx];
        if (isValid(tag) && dirty) begin
            let addr = {fromMaybe(?, tag), idx, sel, 2'b0};
            memReqQ.enq(MemReq {op: St, addr: addr, data:?});
        end

        status <= SendFillReq;

    endrule

    rule sendFillReq (status == SendFillReq);

        memReqQ.enq(MemReq {op: Ld, addr: missReq.addr, data:?});
        status <= WaitFillResp;

    endrule

    rule waitFillResp (status == WaitFillResp);

        CacheWordSelect sel = getWord(missReq.addr);
        CacheIndex idx = getIndex(missReq.addr);
        let tag = getTag(missReq.addr);

        let line = memRespQ.first;
        tagArray[idx] <= Valid(tag);


        if (missReq.op == Ld) begin
            dirtyArray[idx] <= False;
            hitQ.enq(line[sel]);
        end
        else begin

            line[sel] = missReq.data;
            dirtyArray[idx] <= True;
        end
        dataArray[idx] <= line;
        memRespQ.deq;

        status <= Ready;
    endrule

    rule sendToMemory;

        memReqQ.deq;
        let r = memReqQ.first;

        CacheIndex idx = getIndex(r.addr);
        CacheLine line = dataArray[idx];

        Bit#(CacheLineWords) en;
        if (r.op == St) en = '1;
        else en = '0;

        mem.req(WideMemReq{
            write_en: en,
            addr: r.addr,
            data: line
        } );

    endrule

    rule getFromMemory;

        let line <- mem.resp();
        memRespQ.enq(line);

    endrule

    rule doReq (status == Ready);

        MemReq r = reqQ.first;
        reqQ.deq;

        CacheWordSelect sel = getWord(r.addr);
        CacheIndex idx = getIndex(r.addr);
        CacheTag tag = getTag(r.addr);

        let hit = False;
        if (tagArray[idx] matches tagged Valid .currTag
            &&& currTag == tag) hit = True;

        if (r.op == Ld) begin
            if (hit) begin
                hitQ.enq(dataArray[idx][sel]);
            end
            else begin
                missReq <= r;
                status <= StartMiss;
            end
        end
        else begin
            if (hit) begin
                dataArray[idx][sel] <= r.data;
                dirtyArray[idx] <= True;
            end
            else begin
                missReq <= r;
                status <= StartMiss;
            end
        end
    endrule

    method Action req(MemReq r);
        reqQ.enq(r);
    endmethod


    method ActionValue#(Data) resp;
        hitQ.deq;
        return hitQ.first;
    endmethod
endmodule


module mkDCacheStQ(WideMem mem, DCache ifc);

    Reg#(CacheStatus) status <- mkReg(Ready);

    Vector#(CacheRows, Reg#(CacheLine)) dataArray <- replicateM(mkRegU);
    Vector#(CacheRows, Reg#(Maybe#(CacheTag)))
            tagArray <- replicateM(mkReg(Invalid));
    Vector#(CacheRows, Reg#(Bool)) dirtyArray <- replicateM(mkReg(False));

    Fifo#(2, Data) hitQ <- mkBypassFifo;
    Fifo#(1, MemReq) reqQ <- mkBypassFifo;
    Reg#(MemReq) missReq <- mkRegU;
    Fifo#(2, MemReq) memReqQ <- mkCFFifo;
    Fifo#(2, CacheLine) memRespQ <- mkCFFifo;

    StQ#(StQSize) stq <-mkStQ;

    function CacheWordSelect getWord(Addr addr) = truncate(addr >> 2);
    function CacheIndex getIndex(Addr addr) = truncate(addr >> 6);
    function CacheTag getTag(Addr addr) = truncateLSB(addr);

    rule startMiss (status == StartMiss);

        CacheWordSelect sel = getWord(missReq.addr);
        CacheIndex idx = getIndex(missReq.addr);
        let tag = tagArray[idx];

        let dirty = dirtyArray[idx];
        if (isValid(tag) && dirty) begin
            let addr = {fromMaybe(?, tag), idx, sel, 2'b0};
            memReqQ.enq(MemReq {op: St, addr: addr, data:?});
        end

        status <= SendFillReq;

    endrule

    rule sendFillReq (status == SendFillReq);

        memReqQ.enq(MemReq {op: Ld, addr: missReq.addr, data:?});
        status <= WaitFillResp;

    endrule

    rule waitFillResp (status == WaitFillResp);

        CacheWordSelect sel = getWord(missReq.addr);
        CacheIndex idx = getIndex(missReq.addr);
        let tag = getTag(missReq.addr);

        let line = memRespQ.first;
        tagArray[idx] <= Valid(tag);

        if (missReq.op == Ld) begin
            dirtyArray[idx] <= False;
            hitQ.enq(line[sel]);
        end
        else begin

            line[sel] = missReq.data;
            dirtyArray[idx] <= True;
            stq.deq;
        end
        dataArray[idx] <= line;
        memRespQ.deq;
        status <= Ready;

    endrule

    rule sendToMemory;

        memReqQ.deq;
        let r = memReqQ.first;

        CacheIndex idx = getIndex(r.addr);
        CacheLine line = dataArray[idx];

        Bit#(CacheLineWords) en;
        if (r.op == St) en = '1;
        else en = '0;

        mem.req(WideMemReq{
            write_en: en,
            addr: r.addr,
            data: line
        } );

    endrule

    rule getFromMemory;

        let line <- mem.resp();
        memRespQ.enq(line);

    endrule

    rule doLoad (status == Ready && reqQ.first.op == Ld);

        MemReq r = reqQ.first;
        reqQ.deq;

        CacheWordSelect sel = getWord(r.addr);
        CacheIndex idx = getIndex(r.addr);
        CacheTag tag = getTag(r.addr);

        let x = stq.search(r.addr);
        if (isValid(x)) hitQ.enq(fromMaybe(?, x));
        else begin

            if (tagArray[idx] matches tagged Valid .currTag
                &&& currTag == tag) begin

                hitQ.enq(dataArray[idx][sel]);

            end
            else begin
                missReq <= r;
                status <= StartMiss;
            end
        end
    endrule

    rule doStore (reqQ.first.op == St);

        MemReq r = reqQ.first;
        reqQ.deq;
        stq.enq(r);

    endrule

    rule mvStqToCache (status == Ready && (!reqQ.notEmpty || reqQ.first.op != Ld));

        MemReq r <- stq.issue;

        CacheWordSelect sel = getWord(r.addr);
        CacheIndex idx = getIndex(r.addr);
        CacheTag tag = getTag(r.addr);

        if (tagArray[idx] matches tagged Valid .currTag &&& currTag == tag) begin

            dataArray[idx][sel] <= r.data;
            dirtyArray[idx] <= True;
            stq.deq;

        end
        else begin
            missReq <= r;
            status <= StartMiss;
        end
    endrule

    method Action req(MemReq r);
        reqQ.enq(r);
    endmethod

    method ActionValue#(Data) resp;
        hitQ.deq;
        return hitQ.first;
    endmethod

endmodule


module mkDCacheLHUSM(WideMem mem, DCache ifc);

    Reg#(CacheStatus) status <- mkReg(Ready);

    Vector#(CacheRows, Reg#(CacheLine)) dataArray <- replicateM(mkRegU);
    Vector#(CacheRows, Reg#(Maybe#(CacheTag)))
            tagArray <- replicateM(mkReg(Invalid));
    Vector#(CacheRows, Reg#(Bool)) dirtyArray <- replicateM(mkReg(False));

    Fifo#(2, Data) hitQ <- mkBypassFifo;
    Fifo#(1, MemReq) reqQ <- mkBypassFifo;
    Reg#(MemReq) missReq <- mkRegU;
    Fifo#(2, MemReq) memReqQ <- mkBypassFifo;
    Fifo#(2, CacheLine) memRespQ <- mkBypassFifo;

    StQ#(StQSize) stq <-mkStQ;

    function CacheWordSelect getWord(Addr addr) = truncate(addr >> 2);
    function CacheIndex getIndex(Addr addr) = truncate(addr >> 6);
    function CacheTag getTag(Addr addr) = truncateLSB(addr);

    rule startMiss (status == StartMiss);

        CacheWordSelect sel = getWord(missReq.addr);
        CacheIndex idx = getIndex(missReq.addr);
        let tag = tagArray[idx];

        let dirty = dirtyArray[idx];
        if (isValid(tag) && dirty) begin
            let addr = {fromMaybe(?, tag), idx, sel, 2'b0};
            memReqQ.enq(MemReq {op: St, addr: addr, data:?});
        end

        status <= SendFillReq;

    endrule

    rule sendFillReq (status == SendFillReq);

        memReqQ.enq(MemReq {op: Ld, addr: missReq.addr, data:?});
        status <= WaitFillResp;

    endrule

    rule waitFillResp (status == WaitFillResp);

        CacheWordSelect sel = getWord(missReq.addr);
        CacheIndex idx = getIndex(missReq.addr);
        let tag = getTag(missReq.addr);

        let line = memRespQ.first;
        tagArray[idx] <= Valid(tag);

        if (missReq.op == Ld) begin

            dirtyArray[idx] <= False;
            hitQ.enq(line[sel]);
        end
        else begin

            line[sel] = missReq.data;
            dirtyArray[idx] <= True;
            stq.deq;
        end
        dataArray[idx] <= line;

        memRespQ.deq;

        status <= Ready;
    endrule

    rule sendToMemory;

        memReqQ.deq;
        let r = memReqQ.first;

        CacheIndex idx = getIndex(r.addr);
        CacheLine line = dataArray[idx];

        Bit#(CacheLineWords) en;
        if (r.op == St) en = '1;
        else en = '0;

        mem.req(WideMemReq{
            write_en: en,
            addr: r.addr,
            data: line
        } );

    endrule

    rule getFromMemory;

        let line <- mem.resp();
        memRespQ.enq(line);

    endrule

    rule doLoad (reqQ.first.op == Ld);

        MemReq r = reqQ.first;

        CacheWordSelect sel = getWord(r.addr);
        CacheIndex idx = getIndex(r.addr);
        CacheTag tag = getTag(r.addr);

        if (status == Ready) begin

            reqQ.deq;

            let x = stq.search(r.addr);
            if (isValid(x)) hitQ.enq(fromMaybe(?, x));
            else begin

                if (tagArray[idx] matches tagged Valid .currTag &&& currTag == tag) begin
                    hitQ.enq(dataArray[idx][sel]);
                end
                else begin
                    missReq <= r;
                    status <= StartMiss;
                end
            end
        end
        else begin

            if (missReq.op == St && !mem.respValid) begin

                let x = stq.search(r.addr);
                if (isValid(x)) begin
                    hitQ.enq(fromMaybe(?, x));
                    reqQ.deq;
                end
                else if (tagArray[idx] matches tagged Valid .currTag &&& currTag == tag) begin
                    hitQ.enq(dataArray[idx][sel]);
                    reqQ.deq;
                end
            end
        end
    endrule

    rule doStore (reqQ.first.op == St);

        MemReq r = reqQ.first;
        reqQ.deq;
        stq.enq(r);

    endrule

    rule mvStqToCache (status == Ready && (!reqQ.notEmpty || reqQ.first.op != Ld));

        MemReq r <- stq.issue;

        CacheWordSelect sel = getWord(r.addr);
        CacheIndex idx = getIndex(r.addr);
        CacheTag tag = getTag(r.addr);

        if (tagArray[idx] matches tagged Valid .currTag
            &&& currTag == tag) begin

            dataArray[idx][sel] <= r.data;
            dirtyArray[idx] <= True;
            stq.deq;

        end
        else begin
            missReq <= r;
            status <= StartMiss;
        end
    endrule

    method Action req(MemReq r);
        reqQ.enq(r);
    endmethod

    method ActionValue#(Data) resp;
        hitQ.deq;
        return hitQ.first;
    endmethod

endmodule
