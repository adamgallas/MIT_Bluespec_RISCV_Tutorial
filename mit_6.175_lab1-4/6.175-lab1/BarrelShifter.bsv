import Multiplexer::*;
import Vector::*;

function Bit#(32) shifRightPow2(Bit#(1) en, Bit#(32) unshifted, Integer i);
    Integer j=2**i;
    Bit#(32) shifted = 0;
    for(Integer k=0; k < 32 ; k=k+1) begin
        if(k<=31-j) begin
           shifted[k]=unshifted[j+k];
        end else begin
           //shifted[k]=unshifted[j+k-32];
           shifted[k]=0;
        end
    end
    return multiplexer_n(en,unshifted,shifted);
endfunction

function Bit#(32) barrelShifterRight(Bit#(32) in, Bit#(5) shiftBy);
    Vector#(6,Bit#(32)) casc;
    casc[5]=in;
    for(Integer i=4;i>=0;i=i-1) begin
        casc[i]=shifRightPow2(shiftBy[i],casc[i+1],i);
    end
    return casc[0];
endfunction
