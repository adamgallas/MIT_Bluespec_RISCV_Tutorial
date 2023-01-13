
import ClientServer::*;
import GetPut::*;
import FixedPoint::*;

import AudioProcessorTypes::*;
import Chunker::*;
import FFT::*;
import FIRFilter::*;
import Splitter::*;
import FilterCoefficients::*;

import OverSampler::*;
import Overlayer::*;
import Convertor::*;
import PitchAdjust::*;
import Complex::*;
import Vector::*;

// N=8,S=2,factor=2,psize=16

typedef 8 N;
typedef 2 S;
typedef 16 I_SIZE;
typedef 16 F_SIZE;
typedef 16 P_SIZE;

(*synthesize*)
module mkAudioPipeline(AudioProcessor);

    FixedPoint#(isize, fsize) factor = 2;
    Vector#(N, Sample) oversample_init = replicate(0);
    Vector#(N, Sample) overlayer_init = replicate(0);

    AudioProcessor fir <- mkFIRFilter(c);

    Chunker#(S, Sample) chunker <- mkChunker();
    
    OverSampler#(S, N, Sample) oversample <- mkOverSampler(oversample_init);
    
    FFT#(N,FixedPoint#(I_SIZE, F_SIZE)) fft <- mkFFT();
    
    ToMP#(N,I_SIZE,F_SIZE,P_SIZE) toMp<-mkToMP();
    
    PitchAdjust#(N,I_SIZE,F_SIZE,P_SIZE) adjust<-mkPitchAdjust(valueOf(S),factor);
    
    FromMP#(N,I_SIZE,F_SIZE,P_SIZE) fromMp<-mkFromMP();
    
    FFT#(N,FixedPoint#(I_SIZE, F_SIZE)) ifft <- mkIFFT();
    
    Overlayer#(N, S, Sample) overlayer <- mkOverlayer(overlayer_init);

    Splitter#(S, Sample) splitter <- mkSplitter();

    rule fir_to_chunker (True);
        let x <- fir.getSampleOutput();
        chunker.request.put(x);
    endrule

    rule chunker_to_oversample (True);
        let x <- chunker.response.get();
        oversample.request.put(x);
    endrule

    rule oversample_to_fft (True);
        let x <- oversample.response.get();
        fft.request.put(tocmplxVec(x));
    endrule

    rule fft_to_tomp (True);
        let x <- fft.response.get();
        toMp.request.put(x);
    endrule

    rule tomp_to_adjust (True);
        let x <- toMp.response.get();
        adjust.request.put(x);
    endrule

    rule adjust_to_frommp (True);
        let x <- adjust.response.get();
        fromMp.request.put(x);
    endrule

    rule frommp_to_ifft (True);
        let x <- fromMp.response.get();
        ifft.request.put(x);
    endrule

    rule ifft_to_overlayer (True);
        let x <- ifft.response.get();
        overlayer.request.put(frcmplxVec(x));
    endrule

    rule overlayer_to_splitter (True);
        let x <- overlayer.response.get();
        splitter.request.put(x);
    endrule
    
    method Action putSampleInput(Sample x);
        fir.putSampleInput(x);
    endmethod

    method ActionValue#(Sample) getSampleOutput();
        let x <- splitter.response.get();
        return x;
    endmethod

endmodule
