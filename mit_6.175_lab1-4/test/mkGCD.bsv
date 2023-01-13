interface GCD;
    method Action start (Bit#(32) a,Bit#(32) b);
    method ActionValue#(Bit#(32)) getResult;
endinterface

(* synthesize *)
module mkGCD(GCD);
    Reg#(Bit#(32)) x<-mkReg(0);
    Reg#(Bit#(32)) y<-mkReg(0);
    Reg#(Bool) busy <- mkReg(False);

    rule rcd;
        if(x>=y) begin
            x<=x-y;
        end else if (x!=0) begin
            x<=y;
            y<=x;
        end
    endrule

    method Action start(Bit#(32) a,Bit#(32) b) if(!busy);
        x<=a;
        y<=b;
        busy<=True;
    endmethod

    method ActionValue#(Bit#(32)) getResult if(x==0);
        busy<=False;
        return y;
    endmethod

endmodule
