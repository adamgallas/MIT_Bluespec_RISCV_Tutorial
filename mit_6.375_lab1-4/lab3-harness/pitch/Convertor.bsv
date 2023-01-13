import Real::*;
import ClientServer::*;
import FIFO::*;
import GetPut::*;
import FixedPoint::*;
import Vector::*;
import ComplexMP::*;
import Complex::*;
import Cordic::*;

typedef Server#(
    Vector#(nbins,Complex#(FixedPoint#(isize, fsize))),
    Vector#(nbins,ComplexMP#(isize, fsize, psize))
) ToMP#(numeric type nbins, numeric type isize, numeric type fsize, numeric type psize);

typedef Server#(
    Vector#(nbins,ComplexMP#(isize, fsize, psize)),
    Vector#(nbins,Complex#(FixedPoint#(isize, fsize)))
) FromMP#(numeric type nbins, numeric type isize, numeric type fsize, numeric type psize);

module mkToMP(ToMP#(nbins,isize,fsize,psize) ifc);
    Vector#(nbins,ToMagnitudePhase#(isize,fsize,psize)) cordToMp<-replicateM(mkCordicToMagnitudePhase());
    FIFO#(Vector#(nbins,ComplexMP#(isize, fsize, psize))) outfifo <- mkFIFO();

    rule get_data;
        Integer i =0;
        Vector#(nbins,ComplexMP#(isize, fsize, psize)) out;
        for(i=0;i<valueOf(nbins);i=i+1) begin
            out[i]<-cordToMp[i].response.get();
        end
        outfifo.enq(out);
    endrule

    interface Put request;
        method Action put(Vector#(nbins, Complex#(FixedPoint#(isize, fsize))) x);
            Integer i =0;
            for(i=0;i<valueOf(nbins);i=i+1) begin
                cordToMp[i].request.put(x[i]);
            end
        endmethod
    endinterface

    interface Get response = toGet(outfifo);

endmodule

module mkFromMP(FromMP#(nbins,isize,fsize,psize) ifc);
    Vector#(nbins,FromMagnitudePhase#(isize,fsize,psize)) cordFromMp<-replicateM(mkCordicFromMagnitudePhase());
    FIFO#(Vector#(nbins,Complex#(FixedPoint#(isize, fsize)))) outfifo <- mkFIFO();

    rule get_data;
        Integer i =0;
        Vector#(nbins,Complex#(FixedPoint#(isize, fsize))) out;
        for(i=0;i<valueOf(nbins);i=i+1) begin
            out[i]<-cordFromMp[i].response.get();
        end
        outfifo.enq(out);
    endrule

    interface Put request;
        method Action put(Vector#(nbins, ComplexMP#(isize, fsize, psize)) x);
            Integer i =0;
            for(i=0;i<valueOf(nbins);i=i+1) begin
                cordFromMp[i].request.put(x[i]);
            end
        endmethod
    endinterface

    interface Get response = toGet(outfifo);

endmodule
