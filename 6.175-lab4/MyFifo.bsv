import Vector::*;

interface Fifo#(numeric type n,type t);
    method Bool notFull;
    method Action enq(t x);
    method Bool notEmpty;
    method Action deq;
    method t first;
    method Action clear;
endinterface

module mkMyConflictFifo(Fifo#(n,t)) provisos(Bits#(t,tSz));
    Vector#(n,Reg#(t)) data<-replicateM(mkRegU);
    Reg#(Bit#(TLog#(n))) pushPtr<-mkReg(0);
    Reg#(Bit#(TLog#(n))) popPtr<-mkReg(0);
    Reg#(Bool) empty<-mkReg(True);
    Reg#(Bool) full<-mkReg(False);

    Bit#(TLog#(n)) boundOfPtr=fromInteger(valueOf(n)-1);
    
    method Bool notFull(); return !full; endmethod
    method Action enq(t x) if(!full);
        data[pushPtr]<=x;
        let _pushPtr=pushPtr+1;
        if(_pushPtr>boundOfPtr) begin _pushPtr=0; end
        if(_pushPtr==popPtr) begin full<=True; end
        empty<=False;
        pushPtr<=_pushPtr;
    endmethod

    method Bool notEmpty(); return !empty; endmethod
    method t first() if(!empty); return data[popPtr]; endmethod
    method Action deq() if(!empty);
        let _popPtr=popPtr+1;
        if(_popPtr>boundOfPtr) begin _popPtr=0; end
        if(_popPtr==pushPtr) begin empty<=True; end
        full<=False;
        popPtr<=_popPtr;
    endmethod

    method Action clear();
        pushPtr<=0;
        popPtr<=0;
        empty<=True;
        full<=False;
    endmethod
endmodule

module mkMyPipelineFifo(Fifo#(n,t)) provisos(Bits#(t,tsZ));
    Vector#(n,Reg#(t)) data<-replicateM(mkRegU);
    Reg#(Bit#(TLog#(n))) pushPtr[3]<-mkCReg(3,0);
    Reg#(Bit#(TLog#(n))) popPtr[3]<-mkCReg(3,0);
    Reg#(Bool) empty[3]<-mkCReg(3,True);
    Reg#(Bool) full[3]<-mkCReg(3,False);

    Bit#(TLog#(n)) boundOfPtr=fromInteger(valueOf(n)-1);

    method Bool notFull(); return !full[1]; endmethod
    method Action enq(t x) if(!full[1]);
        data[pushPtr[1]]<=x;
        let _pushPtr=pushPtr[1]+1;
        if(_pushPtr>boundOfPtr) begin _pushPtr=0; end
        if(_pushPtr==popPtr[1]) begin full[1]<=True; end
        empty[1]<=False;
        pushPtr[1]<=_pushPtr;
    endmethod

    method Bool notEmpty(); return !empty[0]; endmethod
    method t first() if(!empty[0]); return data[popPtr[0]]; endmethod
    method Action deq() if(!empty[0]);
        let _popPtr=popPtr[0]+1;
        if(_popPtr>boundOfPtr) begin _popPtr=0; end
        if(_popPtr==pushPtr[0]) begin empty[0]<=True; end
        full[0]<=False;
        popPtr[0]<=_popPtr;
    endmethod

    method Action clear();
        pushPtr[2]<=0;
        popPtr[2]<=0;
        empty[2]<=True;
        full[2]<=False;
    endmethod

endmodule

module mkMyBypassFifo(Fifo#(n,t)) provisos(Bits#(t,tsZ));
    Vector#(n,Array#(Reg#(t))) data <-replicateM(mkCRegU(2));
    Reg#(Bit#(TLog#(n))) pushPtr[3]<-mkCReg(3,0);
    Reg#(Bit#(TLog#(n))) popPtr[3]<-mkCReg(3,0);
    Reg#(Bool) empty[3]<-mkCReg(3,True);
    Reg#(Bool) full[3]<-mkCReg(3,False);

    Bit#(TLog#(n)) boundOfPtr=fromInteger(valueOf(n)-1);

    method Bool notFull(); return !full[0]; endmethod
    method Action enq(t x) if(!full[0]);
        data[pushPtr[0]][0]<=x;
        let _pushPtr=pushPtr[0]+1;
        if(_pushPtr>boundOfPtr) begin _pushPtr=0; end
        if(_pushPtr==popPtr[0]) begin full[0]<=True; end
        empty[0]<=False;
        pushPtr[0]<=_pushPtr;
    endmethod

    method Bool notEmpty(); return !empty[1]; endmethod
    method t first() if(!empty[1]); return data[popPtr[1]][1]; endmethod
    method Action deq() if(!empty[1]);
        let _popPtr=popPtr[1]+1;
        if(_popPtr>boundOfPtr) begin _popPtr=0; end
        if(_popPtr==pushPtr[1]) begin empty[1]<=True; end
        full[1]<=False;
        popPtr[1]<=_popPtr;
    endmethod

    method Action clear();
        pushPtr[2]<=0;
        popPtr[2]<=0;
        empty[2]<=True;
        full[2]<=False;
    endmethod

endmodule

module mkMyCFFifo( Fifo#(n, t) ) provisos (Bits#(t,tSz));
    Vector#(n,Reg#(t)) data<-replicateM(mkRegU());
    Reg#(Bit#(TLog#(n))) pushPtr<-mkReg(0);
    Reg#(Bit#(TLog#(n))) popPtr<-mkReg(0);
    Reg#(Bool) empty<-mkReg(True);
    Reg#(Bool) full<-mkReg(False);

    Reg#(Maybe#(t)) pushEhr[2]<-mkCReg(2,tagged Invalid);
    Reg#(Bool) popEhr[2]<-mkCReg(2,False);
    Reg#(Bool) clrEhr[2]<-mkCReg(2,False);

    Bit#(TLog#(n)) boundOfPtr=fromInteger(valueOf(n)-1);

    (*no_implicit_conditions*)
    (*fire_when_enabled*)
    rule canonicalize;
        if(clrEhr[1]) begin
            pushPtr<=0;
            popPtr<=0;
            empty<=True;
            full<=False;
        end else begin
            let _pushPtr=pushPtr;
            let _popPtr=popPtr;
            
            let pushCond=isValid(pushEhr[1]) && !full;
            let popCond=popEhr[1] && !empty;

            if(pushCond) begin
                data[pushPtr]<=fromMaybe(?,pushEhr[1]);
                _pushPtr=pushPtr+1;
                if(pushPtr==boundOfPtr) _pushPtr=0;
            end
            if(popCond) begin
                _popPtr=popPtr+1;
                if(popPtr==boundOfPtr) _popPtr=0;
            end

            let ptrMatch = _pushPtr==_popPtr;

            if(pushCond) begin
                empty<=False;
                if(popCond) begin
                    full<=False;
                end else begin
                    if(ptrMatch)
                        full<=True;
                end
            end else begin
                if(popCond) begin
                    full<=False;
                    if(ptrMatch)
                        empty<=True;
                end
            end
            pushPtr<=_pushPtr;
            popPtr<=_popPtr;
        end
        pushEhr[1]<=tagged Invalid;
        popEhr[1]<=False;
        clrEhr[1]<=False;
    endrule

    method Bool notFull();
        return !full;
    endmethod

    method Action enq(t x) if(!full);
        pushEhr[0]<=tagged Valid x;
    endmethod

    method Bool notEmpty();
        return !empty;
    endmethod

    method Action deq() if(!empty);
        popEhr[0]<=True;
    endmethod

    method t first() if(!empty);
        return data[popPtr];
    endmethod

    method Action clear();
        clrEhr[0]<=True;
    endmethod

endmodule

