import Vector::*;
import Complex::*;
import Real::*;
import Randomizable::*;

import FftCommon::*;
import Fft::*;

import FIFO::*;

module mkTestBench(Fft fft, Empty ifc);
    let fft_comb <- mkFftCombinational;

    Vector#(FftPoints, Randomize#(Data)) randomVal1 <- replicateM(mkGenericRandomizer);
    Vector#(FftPoints, Randomize#(Data)) randomVal2 <- replicateM(mkGenericRandomizer);

    Reg#(Bool) init <- mkReg(False);
    Reg#(Bit#(32)) cycle_count <- mkReg(0);
    Reg#(Bit#(32)) in_count <- mkReg(0);
    Reg#(Bit#(32)) out_count <- mkReg(0);

    FIFO#(Vector#(FftPoints, ComplexData)) reference_fifo <- mkSizedFIFO(8);

    rule initialize( !init );
        for (Integer i = 0; i < fftPoints; i = i + 1 ) begin
            randomVal1[i].cntrl.init;
            randomVal2[i].cntrl.init;
        end
        init <= True;
    endrule

    rule feed( in_count < 128 && init );
        // $display("input %0d in cycle %0d", in_count, cycle_count);
        Vector#(FftPoints, ComplexData) d;
        for (Integer i = 0; i < fftPoints; i = i + 1 ) begin
            let rv <- randomVal1[i].next;
            let iv <- randomVal2[i].next;
            d[i] = cmplx(rv, iv);
        end
        fft_comb.enq(d);
        fft.enq(d);
        in_count <= in_count + 1;
    endrule

    rule stream_reference;
        let x <- fft_comb.deq();
        reference_fifo.enq(x);
    endrule

    rule stream( init );
        // $display("output %0d in cycle %0d", out_count, cycle_count);
        out_count <= out_count + 1;
        let rc = reference_fifo.first;
        reference_fifo.deq;
        let rf <- fft.deq;
        if ( rc != rf ) begin
            $display("FAILED!");
            for (Integer i = 0; i < fftPoints; i = i + 1) begin
                $display ("\t(%x, %x) != (%x, %x)", rc[i].rel, rc[i].img, rf[i].rel, rf[i].img);
            end
            $finish;
        end
    endrule

    rule pass( out_count == 128 && init );
        $display("PASSED");
        $finish;
    endrule

    rule timeout( cycle_count == 128 * 128 * 128 );
        $display("FAILED: Only saw %0d out of 128 outputs after %0d cycles", out_count, cycle_count);
        $finish;
    endrule

    rule increment( init );
        cycle_count <= cycle_count + 1;
    endrule
endmodule

(* synthesize *)
module mkTbFftFoldedFunc();
    let fft <- mkFftFolded;
    mkTestBench(fft);
endmodule

(* synthesize *)
module mkTbFftInelasticPipelineFunc();
    let fft <- mkFftInelasticPipeline;
    mkTestBench(fft);
endmodule

(* synthesize *)
module mkTbFftElasticPipelineFunc();
    let fft <- mkFftElasticPipeline;
    mkTestBench(fft);
endmodule

// (* synthesize *)
// module mkTbFftSuperFoldedFunc();
//     let fft <- mkFftSuperFolded4;
//     mkTestBench(fft);
// endmodule



typedef enum {RunningFeed, RunningDontFeed, NotRunning} FeedState deriving (Bits, Eq);
typedef enum {NotStarted, CheckingNoGap, CheckingFoundGap, CheckingFoundDoubleGap} CheckState deriving (Bits, Eq);
typedef enum {Folded, Inelastic, Elastic} FftType deriving (Bits, Eq);

module mkTestBenchAdvanced(Fft fft, FftType fft_type, Empty ifc);
    Vector#(FftPoints, Randomize#(Data)) randomVal1 <- replicateM(mkGenericRandomizer);
    Vector#(FftPoints, Randomize#(Data)) randomVal2 <- replicateM(mkGenericRandomizer);

    Reg#(Bool) init <- mkReg(False);
    Reg#(Bit#(32)) cycle <- mkReg(0);
    Reg#(Bit#(32)) feed_count <- mkReg(0);
    Reg#(Bit#(32)) check_count <- mkReg(0);
    Reg#(Bit#(32)) first_gap <- mkReg(0);
    Reg#(Bit#(32)) last_gap <- mkReg(0);
    Reg#(Bool) done <- mkReg(False);

    Reg#(FeedState) feed_state <- mkReg(RunningDontFeed);
    Reg#(CheckState) check_state <- mkReg(NotStarted);

    rule initialize( !init && !done );
        for (Integer i = 0; i < fftPoints; i = i + 1 ) begin
            randomVal1[i].cntrl.init;
            randomVal2[i].cntrl.init;
        end
        init <= True;
    endrule

    rule inc_cycle( init );
        cycle <= cycle + 1;
    endrule

    // For the folded implementation, feed until the unit can't take anymore samples
    // For pipelines, alternates feeding and not feeding until the unit can't take anymore samples
    (* descending_urgency = "feed,feed_stop" *)
    (* preempts = "feed,feed_stop" *)
    rule feed(feed_count < 128 && feed_state == RunningFeed && init && !done);
        Vector#(FftPoints, ComplexData) d;
        for (Integer i = 0; i < fftPoints; i = i + 1 ) begin
            let rv <- randomVal1[i].next;
            let iv <- randomVal2[i].next;
            d[i] = cmplx(rv, iv);
        end
        fft.enq(d);
        feed_count <= feed_count + 1;
        if( fft_type != Folded ) begin
            feed_state <= RunningDontFeed;
        end
    endrule
    rule feed_break(feed_state == RunningDontFeed && init && !done);
        feed_state <= RunningFeed;
    endrule
    // This rule only fires if feed can't fire
    rule feed_stop(feed_state == RunningFeed && init && !done);
        feed_state <= NotRunning;
    endrule

    // reads output until check_count == feed_count and checks if there are gaps
    (* descending_urgency = "check,check_gap" *)
    (* preempts = "check,check_gap" *)
    rule check(check_count != feed_count && feed_state == NotRunning && init && !done);
        if( check_state == NotStarted ) begin
            check_state <= CheckingNoGap;
        end
        check_count <= check_count + 1;
        let rf <- fft.deq;
    endrule
    rule check_gap(check_count != feed_count && check_state != NotStarted && init && !done);
        if( check_state == CheckingNoGap ) begin
            check_state <= CheckingFoundGap;
        end else if( last_gap == cycle-1 ) begin
            check_state <= CheckingFoundDoubleGap;
        end
        if( first_gap == 0 ) begin
            first_gap <= cycle;
        end
        last_gap <= cycle;
    endrule

    rule pass(check_count == feed_count && feed_count > 1 && init && !done);
        if( fft_type == Folded ) begin
            if( check_state == CheckingFoundGap || check_state == CheckingFoundDoubleGap ) begin
                $display("PASSED");
            end else begin
                $display("FAILED!");
                $display("\tFolded implementation created a stream of outputs without gaps.");
            end
        end else if( check_state == CheckingFoundDoubleGap ) begin
            $display("FAILED!");
            $display("\tFound a gap in the output stream that was larger than the gap in inputs.");
        end else if( check_state == CheckingFoundGap ) begin
            if( fft_type == Inelastic ) begin
                $display("PASSED");
            end else begin
                $display("FAILED!");
                $display("\tElastic pipeline implementation produced a gap in the output stream.");
            end
        end else begin
            if( fft_type == Elastic ) begin
                $display("PASSED");
            end else begin
                $display("FAILED!");
                $display("\tInelastic pipeline implementation didn't produce a gap in the output stream.");
            end
        end
        done <= True;
        $finish;
    endrule

    rule timeout;
        if( cycle > 100000 ) begin
            if(!done) begin
                $display("FAILED!");
                $display("\tMaximum cycle reached");
            end
            $finish;
        end
    endrule
endmodule

(* synthesize *)
module mkTbFftFoldedImpl();
    let fft <- mkFftFolded;
    mkTestBenchAdvanced(fft, Folded);
endmodule

(* synthesize *)
module mkTbFftInelasticPipelineImpl();
    let fft <- mkFftInelasticPipeline;
    mkTestBenchAdvanced(fft, Inelastic);
endmodule

(* synthesize *)
module mkTbFftElasticPipelineImpl();
    let fft <- mkFftElasticPipeline;
    mkTestBenchAdvanced(fft, Elastic);
endmodule
