
import Complex::*;
import FixedPoint::*;
import Vector::*;

typedef Int#(16) Sample;

interface AudioProcessor;
    method Action putSampleInput(Sample in);
    method ActionValue#(Sample) getSampleOutput();
endinterface


typedef Complex#(FixedPoint#(16, 16)) ComplexSample;

// Turn a real Sample into a ComplexSample.
function ComplexSample tocmplx(Sample x);
    return cmplx(fromInt(x), 0);
endfunction

// Extract the real component from complex.
function Sample frcmplx(ComplexSample x);
    return unpack(truncate(x.rel.i));
endfunction

function Vector#(n,ComplexSample) tocmplxVec(Vector#(n,Sample) x);
    Vector#(n,ComplexSample) ret;
    Integer i;
    for(i=0;i<valueOf(n);i=i+1) begin
        ret[i]=tocmplx(x[i]);
    end
    return ret;
endfunction

function Vector#(n,Sample) frcmplxVec(Vector#(n,ComplexSample) x);
    Vector#(n,Sample) ret;
    Integer i;
    for(i=0;i<valueOf(n);i=i+1) begin
        ret[i]=frcmplx(x[i]);
    end
    return ret;
endfunction


typedef 8 FFT_POINTS;
typedef TLog#(FFT_POINTS) FFT_LOG_POINTS;

