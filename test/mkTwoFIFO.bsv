import FIFOF::*;
import FIFO::*;

interface Fifo#(type t);
    method Action enq(t x);
    method Action deq;
    method t first;
endinterface

// module mkFIFO(Fifo#(2,t)) provisos (Bits#(t, tSz));
//     Reg#(t) da<-mkRegU;
//     Reg#(Bool) va<-mkReg(False);
//     Reg#(t) db<-mkRegU;
//     Reg#(Bool) vb<-mkReg(False);

//     method Action enq(t x) if(!vb);
//         if(va) begin
//             db<=x;
//             vb<=True;
//         end else begin
//             da<=x;
//             va<=True;
//         end
//     endmethod

//     method Action deq if(va);
//         if(vb) begin
//             da<=db;
//             vb<=False;
//         end else begin
//             va<=False;
//         end
//     endmethod
//     method t first if(va);
//         return da;
//     endmethod
// endmodule

(*synthesize*)
module mkTwoFIFO(Fifo#(Bit#(8)));
    FIFO#(Bit#(8)) fifo1 <-mkFIFO;
    FIFO#(Bit#(8)) fifo2 <-mkFIFO;

    method Action enq(Bit#(8) x);
        fifo1.enq(x);
        fifo2.enq(x);
    endmethod

    method Action deq;
        fifo1.deq;
        fifo2.deq;
    endmethod

    method Bit#(8) first;
        return fifo1.first^fifo2.first;
    endmethod
endmodule
