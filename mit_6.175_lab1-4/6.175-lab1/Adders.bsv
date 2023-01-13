import Multiplexer::*;

function Bit#(2) ha_add(Bit#(1) a,Bit#(1) b);
    Bit#(1) s=a^b;
    Bit#(1) c=a&b;
    return {c,s};
endfunction

function Bit#(2) fa_add(Bit#(1) a,Bit#(1) b,Bit#(1) c);
    Bit#(2) ab=ha_add(a,b);
    Bit#(2) abc=ha_add(ab[0],c);
    Bit#(1) cout=ab[1]|abc[1];
    return {cout,abc[0]};
endfunction

function Bit#(5) add4(Bit#(4) a, Bit#(4) b,Bit#(1) c0);
    Bit#(4) s;
    Bit#(5) c=0;
    c[0]=c0;
    for(Integer i=0;i<4;i=i+1) begin
        let cs=fa_add(a[i],b[i],c[i]);
        c[i+1]=cs[1];
        s[i]=cs[0];
    end
    return {c[4],s};
endfunction

interface Adder8;
    method ActionValue#(Bit#(9)) sum(Bit#(8) a,Bit#(8) b,Bit#(1) c_in);
endinterface

module mkRCAdder(Adder8);
    method ActionValue#(Bit#(9)) sum(Bit#(8) a,Bit#(8) b,Bit#(1) c_in);
        Bit#(5) low=add4(a[3:0],b[3:0],c_in);
        Bit#(5) high=add4(a[7:4],b[7:4],low[4]);
        return {high,low[3:0]};
    endmethod
endmodule

module mkCSAdder(Adder8);
    method ActionValue#(Bit#(9)) sum(Bit#(8) a,Bit#(8) b,Bit#(1) c_in);
        Bit#(5) low=add4(a[3:0],b[3:0],c_in);
        Bit#(5) high0=add4(a[7:4],b[7:4],1'b0);
        Bit#(5) high1=add4(a[7:4],b[7:4],1'b1);
        Bit#(1) sel=low[4];
        let high=multiplexer_n(sel,high0,high1);
        return {high,low[3:0]};
    endmethod
endmodule