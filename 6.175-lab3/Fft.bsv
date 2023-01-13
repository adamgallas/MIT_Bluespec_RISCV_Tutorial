import FftCommon::*;
import Vector::*;
import Complex::*;
import FIFOF::*;

interface Fft;
    method Action enq(Vector#(FftPoints, ComplexData) in);
    method ActionValue#(Vector#(FftPoints, ComplexData)) deq();
endinterface

(*synthesize*)
module mkFftCombinational(Fft);
    FIFOF#(Vector#(FftPoints,ComplexData)) inFifo<-mkFIFOF;
    FIFOF#(Vector#(FftPoints,ComplexData)) outFifo<-mkFIFOF;
    Vector#(NumStages,Vector#(BflysPerStage,Bfly4)) bfly<-replicateM(replicateM(mkBfly4));

    function Vector#(FftPoints,ComplexData) stage_f(StageIdx stage,Vector#(FftPoints,ComplexData) stage_in);
        Vector#(FftPoints,ComplexData) stage_tmp,stage_out;
        for(FftIdx i=0;i<fromInteger(valueOf(BflysPerStage));i=i+1) begin
            FftIdx idx=i*4;
            Vector#(4,ComplexData) x;
            Vector#(4,ComplexData) twid;
            for(FftIdx j=0;j<4;j=j+1) begin
                x[j]=stage_in[idx+j];
                twid[j]=getTwiddle(stage,idx+j);
            end
            let y=bfly[stage][i].bfly4(twid,x);
            for(FftIdx j=0;j<4;j=j+1) begin
                stage_tmp[idx+j]=y[j];
            end
        end
        stage_out=permute(stage_tmp);
        return stage_out;
    endfunction

    rule doFft;
        if(inFifo.notEmpty&&outFifo.notFull) begin
            inFifo.deq;
            Vector#(4,Vector#(FftPoints,ComplexData)) stage_data;
            stage_data[0]=inFifo.first;
            for(StageIdx stage=0;stage<3;stage=stage+1) begin
                stage_data[stage+1]=stage_f(stage,stage_data[stage]);
            end
            outFifo.enq(stage_data[3]);
        end
    endrule

    method Action enq(Vector#(FftPoints,ComplexData) in);
        inFifo.enq(in);
    endmethod

    method ActionValue#(Vector#(FftPoints,ComplexData)) deq;
        outFifo.deq;
        return outFifo.first;
    endmethod
endmodule

(*synthesize*)
module mkFftInelasticPipeline(Fft);
    FIFOF#(Vector#(FftPoints,ComplexData)) inFifo<-mkFIFOF;
    FIFOF#(Vector#(FftPoints,ComplexData)) outFifo<-mkFIFOF;
    Vector#(NumStages,Vector#(BflysPerStage,Bfly4)) bfly<-replicateM(replicateM(mkBfly4));

    Reg #(Maybe #(Vector#(FftPoints,ComplexData))) sReg1 <- mkRegU;
    Reg #(Maybe #(Vector#(FftPoints,ComplexData))) sReg2 <- mkRegU;

    function Vector#(FftPoints,ComplexData) stage_f(StageIdx stage,Vector#(FftPoints,ComplexData) stage_in);
        Vector#(FftPoints,ComplexData) stage_tmp,stage_out;
        for(FftIdx i=0;i<fromInteger(valueOf(BflysPerStage));i=i+1) begin
            FftIdx idx=i*4;
            Vector#(4,ComplexData) x;
            Vector#(4,ComplexData) twid;
            for(FftIdx j=0;j<4;j=j+1) begin
                x[j]=stage_in[idx+j];
                twid[j]=getTwiddle(stage,idx+j);
            end
            let y=bfly[stage][i].bfly4(twid,x);
            for(FftIdx j=0;j<4;j=j+1) begin
                stage_tmp[idx+j]=y[j];
            end
        end
        stage_out=permute(stage_tmp);
        return stage_out;
    endfunction

    rule doFft;
        if(inFifo.notEmpty) begin
            sReg1<=tagged Valid (stage_f(0,inFifo.first));
            inFifo.deq;
        end else begin
            sReg1<=tagged Invalid;
        end
        case (sReg1) matches
            tagged Invalid : sReg2 <= tagged Invalid;
            tagged Valid .x: sReg2 <= tagged Valid stage_f(1,x);
        endcase
        case (sReg2) matches
            tagged Valid .x: outFifo.enq(stage_f(2,x));
        endcase
    endrule

    method Action enq(Vector#(FftPoints,ComplexData) in);
        inFifo.enq(in);
    endmethod

    method ActionValue#(Vector#(FftPoints,ComplexData)) deq;
        outFifo.deq;
        return outFifo.first;
    endmethod
endmodule

(*synthesize*)
module mkFftElasticPipeline(Fft);
    FIFOF#(Vector#(FftPoints,ComplexData)) inFifo<-mkFIFOF;
    FIFOF#(Vector#(FftPoints,ComplexData)) outFifo<-mkFIFOF;
    Vector#(NumStages,Vector#(BflysPerStage,Bfly4)) bfly<-replicateM(replicateM(mkBfly4));

    FIFOF#(Vector#(FftPoints,ComplexData)) fifo1<-mkFIFOF;
    FIFOF#(Vector#(FftPoints,ComplexData)) fifo2<-mkFIFOF;

    function Vector#(FftPoints,ComplexData) stage_f(StageIdx stage,Vector#(FftPoints,ComplexData) stage_in);
        Vector#(FftPoints,ComplexData) stage_tmp,stage_out;
        for(FftIdx i=0;i<fromInteger(valueOf(BflysPerStage));i=i+1) begin
            FftIdx idx=i*4;
            Vector#(4,ComplexData) x;
            Vector#(4,ComplexData) twid;
            for(FftIdx j=0;j<4;j=j+1) begin
                x[j]=stage_in[idx+j];
                twid[j]=getTwiddle(stage,idx+j);
            end
            let y=bfly[stage][i].bfly4(twid,x);
            for(FftIdx j=0;j<4;j=j+1) begin
                stage_tmp[idx+j]=y[j];
            end
        end
        stage_out=permute(stage_tmp);
        return stage_out;
    endfunction

    rule stage1 /*(fifo1.notFull&&inFifo.notEmpty)*/;
        fifo1.enq(stage_f(0,inFifo.first));
        inFifo.deq;
    endrule
    rule stage2 /*(fifo2.notFull&&fifo1.notEmpty)*/;
        fifo2.enq(stage_f(1,fifo1.first));
        fifo1.deq;
    endrule
    rule stage3 /*(outFifo.notFull&&fifo2.notEmpty)*/;
        outFifo.enq(stage_f(2,fifo2.first));
        fifo2.deq;
    endrule

    // rule doFft;
    //     fifo1.enq(stage_f(0,inFifo.first));
    //     inFifo.deq;
    //     fifo2.enq(stage_f(1,fifo1.first));
    //     fifo1.deq;
    //     outFifo.enq(stage_f(2,fifo2.first));
    //     fifo2.deq;
    // endrule

    method Action enq(Vector#(FftPoints,ComplexData) in);
        inFifo.enq(in);
    endmethod

    method ActionValue#(Vector#(FftPoints,ComplexData)) deq;
        outFifo.deq;
        return outFifo.first;
    endmethod
endmodule

(*synthesize*)
module mkFftFolded(Fft);
    FIFOF#(Vector#(FftPoints,ComplexData)) inFifo<-mkFIFOF;
    FIFOF#(Vector#(FftPoints,ComplexData)) outFifo<-mkFIFOF;
    Vector#(BflysPerStage,Bfly4) bfly<-replicateM(mkBfly4);

    Reg#(StageIdx) stage<-mkReg(0);
    Reg#(Vector#(FftPoints,ComplexData)) sReg<-mkRegU;

    function Vector#(FftPoints,ComplexData) stage_f(Vector#(FftPoints,ComplexData) stage_in);
        Vector#(FftPoints,ComplexData) stage_tmp,stage_out;
        for(FftIdx i=0;i<fromInteger(valueOf(BflysPerStage));i=i+1) begin
            FftIdx idx=i*4;
            Vector#(4,ComplexData) x;
            Vector#(4,ComplexData) twid;
            for(FftIdx j=0;j<4;j=j+1) begin
                x[j]=stage_in[idx+j];
                twid[j]=getTwiddle(stage,idx+j);
            end
            let y=bfly[i].bfly4(twid,x);
            for(FftIdx j=0;j<4;j=j+1) begin
                stage_tmp[idx+j]=y[j];
            end
        end
        stage_out=permute(stage_tmp);
        return stage_out;
    endfunction

    // rule doFft;
    //     let fft_in=?;
    //     let fft_out=stage_f(fft_in);
    //     if(stage==0) begin
    //         inFifo.deq;
    //         fft_in=inFifo.first;
    //     end else begin
    //         fft_in=stage_data;
    //     end
    //     if(stage==2) begin
    //         outFifo.enq(fft_out);
    //         stage<=0;
    //     end else begin
    //         stage_data<=fft_out;
    //         stage<=stage+1;
    //     end
    // endrule

    Vector#(FftPoints,ComplexData) fft_in;
    if(stage==0) begin
        fft_in=inFifo.first;
    end else begin
        fft_in=sReg;
    end
    let fft_out=stage_f(fft_in);

    rule foldedEntry (stage==0);
        sReg <= fft_out;
        stage <= stage+1;
        inFifo.deq();
    endrule
    rule foldedCirculate ((stage!=0) && (stage != fromInteger(valueOf(NumStages)-1)));
        sReg <= fft_out;
        stage <= stage+1;
    endrule
    rule foldedExit (stage==fromInteger(valueOf(NumStages)-1));
        outFifo.enq (fft_out);
        stage <= 0;
    endrule

    method Action enq(Vector#(FftPoints,ComplexData) in) if(inFifo.notFull);
        inFifo.enq(in);
    endmethod

    method ActionValue#(Vector#(FftPoints,ComplexData)) deq if(outFifo.notEmpty);
        outFifo.deq;
        return outFifo.first;
    endmethod
endmodule