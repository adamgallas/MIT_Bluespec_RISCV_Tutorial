//
// Generated by Bluespec Compiler, version 2022.01 (build 066c7a8)
//
// On Sat Nov 12 19:01:48 PST 2022
//
//
// Ports:
// Name                         I/O  size props
// bfly4                          O    64
// RDY_bfly4                      O     1 const
// CLK                            I     1 unused
// RST_N                          I     1 unused
// bfly4_t                        I    64
// bfly4_x                        I    64
//
// Combinational paths from inputs to outputs:
//   (bfly4_t, bfly4_x) -> bfly4
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module mkBfly4(CLK,
	       RST_N,

	       bfly4_t,
	       bfly4_x,
	       bfly4,
	       RDY_bfly4);
  input  CLK;
  input  RST_N;

  // value method bfly4
  input  [63 : 0] bfly4_t;
  input  [63 : 0] bfly4_x;
  output [63 : 0] bfly4;
  output RDY_bfly4;

  // signals for module outputs
  wire [63 : 0] bfly4;
  wire RDY_bfly4;

  // remaining internal signals
  wire [15 : 0] bfly4_x_BITS_15_TO_8_MUL_bfly4_t_BITS_15_TO_8___d3,
		bfly4_x_BITS_15_TO_8_MUL_bfly4_t_BITS_7_TO_0___d40,
		bfly4_x_BITS_23_TO_16_4_MUL_bfly4_t_BITS_23_TO_ETC___d26,
		bfly4_x_BITS_23_TO_16_4_MUL_bfly4_t_BITS_31_TO_ETC___d53,
		bfly4_x_BITS_31_TO_24_0_MUL_bfly4_t_BITS_23_TO_ETC___d51,
		bfly4_x_BITS_31_TO_24_0_MUL_bfly4_t_BITS_31_TO_ETC___d22,
		bfly4_x_BITS_39_TO_32_4_MUL_bfly4_t_BITS_39_TO_ETC___d16,
		bfly4_x_BITS_39_TO_32_4_MUL_bfly4_t_BITS_47_TO_ETC___d47,
		bfly4_x_BITS_47_TO_40_0_MUL_bfly4_t_BITS_39_TO_ETC___d45,
		bfly4_x_BITS_47_TO_40_0_MUL_bfly4_t_BITS_47_TO_ETC___d12,
		bfly4_x_BITS_55_TO_48_3_MUL_bfly4_t_BITS_55_TO_ETC___d35,
		bfly4_x_BITS_55_TO_48_3_MUL_bfly4_t_BITS_63_TO_ETC___d58,
		bfly4_x_BITS_63_TO_56_9_MUL_bfly4_t_BITS_55_TO_ETC___d56,
		bfly4_x_BITS_63_TO_56_9_MUL_bfly4_t_BITS_63_TO_ETC___d31,
		bfly4_x_BITS_7_TO_0_MUL_bfly4_t_BITS_15_TO_8___d42,
		bfly4_x_BITS_7_TO_0_MUL_bfly4_t_BITS_7_TO_0___d7;
  wire [7 : 0] x__h1492,
	       x__h1493,
	       x__h1495,
	       x__h1509,
	       x__h1556,
	       x__h1586,
	       x__h1618,
	       x__h1666,
	       x__h1685,
	       x__h1686,
	       x__h1725,
	       x__h1755,
	       x__h1774,
	       x__h1810,
	       x__h1859,
	       x__h239,
	       y__h1494,
	       y__h1496,
	       y__h1510,
	       y__h1587,
	       y__h1619,
	       y__h1667,
	       y__h1687,
	       y__h1756;

  // value method bfly4
  assign bfly4 =
	     { x__h239,
	       x__h1492,
	       x__h1556,
	       x__h1685,
	       x__h1725,
	       x__h1774,
	       x__h1810,
	       x__h1859 } ;
  assign RDY_bfly4 = 1'd1 ;

  // remaining internal signals
  assign bfly4_x_BITS_15_TO_8_MUL_bfly4_t_BITS_15_TO_8___d3 =
	     bfly4_x[15:8] * bfly4_t[15:8] ;
  assign bfly4_x_BITS_15_TO_8_MUL_bfly4_t_BITS_7_TO_0___d40 =
	     bfly4_x[15:8] * bfly4_t[7:0] ;
  assign bfly4_x_BITS_23_TO_16_4_MUL_bfly4_t_BITS_23_TO_ETC___d26 =
	     bfly4_x[23:16] * bfly4_t[23:16] ;
  assign bfly4_x_BITS_23_TO_16_4_MUL_bfly4_t_BITS_31_TO_ETC___d53 =
	     bfly4_x[23:16] * bfly4_t[31:24] ;
  assign bfly4_x_BITS_31_TO_24_0_MUL_bfly4_t_BITS_23_TO_ETC___d51 =
	     bfly4_x[31:24] * bfly4_t[23:16] ;
  assign bfly4_x_BITS_31_TO_24_0_MUL_bfly4_t_BITS_31_TO_ETC___d22 =
	     bfly4_x[31:24] * bfly4_t[31:24] ;
  assign bfly4_x_BITS_39_TO_32_4_MUL_bfly4_t_BITS_39_TO_ETC___d16 =
	     bfly4_x[39:32] * bfly4_t[39:32] ;
  assign bfly4_x_BITS_39_TO_32_4_MUL_bfly4_t_BITS_47_TO_ETC___d47 =
	     bfly4_x[39:32] * bfly4_t[47:40] ;
  assign bfly4_x_BITS_47_TO_40_0_MUL_bfly4_t_BITS_39_TO_ETC___d45 =
	     bfly4_x[47:40] * bfly4_t[39:32] ;
  assign bfly4_x_BITS_47_TO_40_0_MUL_bfly4_t_BITS_47_TO_ETC___d12 =
	     bfly4_x[47:40] * bfly4_t[47:40] ;
  assign bfly4_x_BITS_55_TO_48_3_MUL_bfly4_t_BITS_55_TO_ETC___d35 =
	     bfly4_x[55:48] * bfly4_t[55:48] ;
  assign bfly4_x_BITS_55_TO_48_3_MUL_bfly4_t_BITS_63_TO_ETC___d58 =
	     bfly4_x[55:48] * bfly4_t[63:56] ;
  assign bfly4_x_BITS_63_TO_56_9_MUL_bfly4_t_BITS_55_TO_ETC___d56 =
	     bfly4_x[63:56] * bfly4_t[55:48] ;
  assign bfly4_x_BITS_63_TO_56_9_MUL_bfly4_t_BITS_63_TO_ETC___d31 =
	     bfly4_x[63:56] * bfly4_t[63:56] ;
  assign bfly4_x_BITS_7_TO_0_MUL_bfly4_t_BITS_15_TO_8___d42 =
	     bfly4_x[7:0] * bfly4_t[15:8] ;
  assign bfly4_x_BITS_7_TO_0_MUL_bfly4_t_BITS_7_TO_0___d7 =
	     bfly4_x[7:0] * bfly4_t[7:0] ;
  assign x__h1492 = x__h1493 - y__h1494 ;
  assign x__h1493 = x__h1495 - y__h1496 ;
  assign x__h1495 =
	     bfly4_x_BITS_15_TO_8_MUL_bfly4_t_BITS_7_TO_0___d40[7:0] +
	     bfly4_x_BITS_7_TO_0_MUL_bfly4_t_BITS_15_TO_8___d42[7:0] ;
  assign x__h1509 =
	     bfly4_x_BITS_31_TO_24_0_MUL_bfly4_t_BITS_23_TO_ETC___d51[7:0] +
	     bfly4_x_BITS_23_TO_16_4_MUL_bfly4_t_BITS_31_TO_ETC___d53[7:0] ;
  assign x__h1556 = x__h1586 - y__h1587 ;
  assign x__h1586 = x__h1618 + y__h1619 ;
  assign x__h1618 =
	     bfly4_x_BITS_15_TO_8_MUL_bfly4_t_BITS_15_TO_8___d3[7:0] -
	     bfly4_x_BITS_7_TO_0_MUL_bfly4_t_BITS_7_TO_0___d7[7:0] ;
  assign x__h1666 =
	     bfly4_x_BITS_31_TO_24_0_MUL_bfly4_t_BITS_31_TO_ETC___d22[7:0] -
	     bfly4_x_BITS_23_TO_16_4_MUL_bfly4_t_BITS_23_TO_ETC___d26[7:0] ;
  assign x__h1685 = x__h1686 - y__h1687 ;
  assign x__h1686 = x__h1495 + y__h1496 ;
  assign x__h1725 = x__h1755 + y__h1756 ;
  assign x__h1755 = x__h1618 - y__h1619 ;
  assign x__h1774 = x__h1493 + y__h1494 ;
  assign x__h1810 = x__h1586 + y__h1587 ;
  assign x__h1859 = x__h1686 + y__h1687 ;
  assign x__h239 = x__h1755 - y__h1756 ;
  assign y__h1494 = x__h1509 - y__h1510 ;
  assign y__h1496 =
	     bfly4_x_BITS_47_TO_40_0_MUL_bfly4_t_BITS_39_TO_ETC___d45[7:0] +
	     bfly4_x_BITS_39_TO_32_4_MUL_bfly4_t_BITS_47_TO_ETC___d47[7:0] ;
  assign y__h1510 =
	     bfly4_x_BITS_63_TO_56_9_MUL_bfly4_t_BITS_55_TO_ETC___d56[7:0] +
	     bfly4_x_BITS_55_TO_48_3_MUL_bfly4_t_BITS_63_TO_ETC___d58[7:0] ;
  assign y__h1587 = x__h1666 + y__h1667 ;
  assign y__h1619 =
	     bfly4_x_BITS_47_TO_40_0_MUL_bfly4_t_BITS_47_TO_ETC___d12[7:0] -
	     bfly4_x_BITS_39_TO_32_4_MUL_bfly4_t_BITS_39_TO_ETC___d16[7:0] ;
  assign y__h1667 =
	     bfly4_x_BITS_63_TO_56_9_MUL_bfly4_t_BITS_63_TO_ETC___d31[7:0] -
	     bfly4_x_BITS_55_TO_48_3_MUL_bfly4_t_BITS_55_TO_ETC___d35[7:0] ;
  assign y__h1687 = x__h1509 + y__h1510 ;
  assign y__h1756 = x__h1666 - y__h1667 ;
endmodule  // mkBfly4
