import ClientServer::*;
import FIFO::*;
import GetPut::*;
import FixedPoint::*;
import Vector::*;
import ComplexMP::*;

typedef Server#(
    Vector#(nbins, ComplexMP#(isize, fsize, psize)),
    Vector#(nbins, ComplexMP#(isize, fsize, psize))
) PitchAdjust#(numeric type nbins, numeric type isize, numeric type fsize, numeric type psize);


module mkPitchAdjust(Integer s, FixedPoint#(isize, fsize) factor, PitchAdjust#(nbins, isize, fsize, psize) ifc)
provisos (Add#(psize, a__, isize),Add#(b__, TLog#(nbins), isize),Add#(c__, psize, TAdd#(isize, isize)));

    Vector#(nbins,Reg#(Phase#(psize))) inphases<-replicateM(mkReg(0));
    Vector#(nbins,Reg#(Phase#(psize))) outphases<-replicateM(mkReg(0));

    FIFO#(Vector#(nbins, ComplexMP#(isize, fsize, psize))) outputFIFO <- mkFIFO();

    Reg#(Vector#(nbins, ComplexMP#(isize, fsize, psize))) in_latch  <- mkRegU; 
    Reg#(Vector#(nbins, ComplexMP#(isize, fsize, psize))) out_latch <- mkRegU;

    Reg#(Bit#(TLog#(nbins))) i<-mkReg(0);
    Reg#(FixedPoint#(isize, fsize)) bin<-mkReg(0);
    FixedPoint#(isize, fsize) binp1=bin+(factor);
    
    let bin_int = (fxptGetInt(bin));
    let binp1_int = (fxptGetInt(binp1));
    Bool cond = (bin_int!=binp1_int) && bin_int>=0 && bin_int<fromInteger(valueOf(nbins));
    Bit#(TLog#(nbins)) bin_index=pack(truncate(bin_int));

    let new_input = in_latch[i];
    ComplexMP#(isize, fsize, psize) new_output=?;

    let dphase = new_input.phase - inphases[i];
    FixedPoint#(isize, fsize) dphaseFxpt = fromInt(dphase);
    let shifted_fix = fxptMult((factor),dphaseFxpt);
    Phase#(psize) shifted_int = truncate(fxptGetInt(shifted_fix));

    Phase#(psize) inphases_new = new_input.phase;
    Phase#(psize) outphases_old = outphases[bin_index];
    Phase#(psize) outphases_new = outphases_old + shifted_int;

    new_output.magnitude=new_input.magnitude;
    new_output.phase=outphases_new;

    Reg#(Bool) done <- mkReg(True);

    rule loop if(!done);
        bin<=binp1;
        if(i==fromInteger(valueOf(nbins)-1)) begin
            done<=True;
        end else begin
            i<=i+1;
        end
        inphases[i]<=inphases_new;
        if(cond) begin
            outphases[bin_index]<=outphases_new;
            out_latch[bin_index]<=new_output;
        end
    endrule

    rule loop_end(i==fromInteger(valueOf(nbins)-1) && done);
		outputFIFO.enq(out_latch);
        i<=0;
    endrule

    interface Put request;
        method Action put(Vector#(nbins, ComplexMP#(isize, fsize, psize)) x) if(done && i!=fromInteger(valueOf(nbins)-1));
            in_latch<=x;
            out_latch<=replicate(cmplxmp(0, 0));
            i<=0;
            bin<=0;
            done<=False;
        endmethod
    endinterface
    interface Get response = toGet(outputFIFO);

endmodule
