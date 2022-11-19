import TestBenchTemplates::*;
import Multipliers::*;

(* synthesize *)
module mkTbDumb();
    function Bit#(16) test_function( Bit#(8) a, Bit#(8) b ) = multiply_unsigned( a, b );
    Empty tb <- mkTbMulFunction(test_function, multiply_unsigned, True);
    return tb;
endmodule

(* synthesize *)
module mkTbSignedVsUnsigned();
    function Bit#(16) signed_func( Bit#(8) a, Bit#(8) b ) = multiply_signed( a, b );
    function Bit#(16) unsigned_func( Bit#(8) a, Bit#(8) b ) = multiply_unsigned( a, b );
    Empty tb <- mkTbMulFunction(signed_func, unsigned_func, True);
    return tb;
endmodule

(* synthesize *)
module mkTbEx3();
    function Bit#(16) test_function( Bit#(8) a, Bit#(8) b ) = multiply_by_adding( a, b );
    Empty tb <- mkTbMulFunction(test_function, multiply_unsigned, True);
    return tb;
endmodule

(* synthesize *)
module mkTbEx5();
    Multiplier#(8) dut<-mkFoldedMultiplier();
    Empty tb<-mkTbMulModule(dut,multiply_by_adding,False);
    return tb;
endmodule


(* synthesize *)
module mkTbEx7a();
    Multiplier#(2) dut<-mkBoothMultiplier();
    Empty tb<-mkTbMulModule(dut,multiply_signed,False);
    return tb;
endmodule

(* synthesize *)
module mkTbEx7b();
    Multiplier#(32) dut<-mkBoothMultiplier();
    Empty tb<-mkTbMulModule(dut,multiply_signed,False);
    return tb;
endmodule

(* synthesize *)
module mkTbEx9a();
    Multiplier#(2) dut<-mkBoothMultiplierRadix4();
    Empty tb<-mkTbMulModule(dut,multiply_signed,False);
    return tb;
endmodule

(* synthesize *)
module mkTbEx9b();
    Multiplier#(64) dut<-mkBoothMultiplierRadix4();
    Empty tb<-mkTbMulModule(dut,multiply_signed,False);
    return tb;
endmodule