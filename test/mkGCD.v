//
// Generated by Bluespec Compiler, version 2022.01 (build 066c7a8)
//
// On Sat Nov 12 17:22:28 PST 2022
//
//
// Ports:
// Name                         I/O  size props
// RDY_start                      O     1
// getResult                      O    32 reg
// RDY_getResult                  O     1
// CLK                            I     1 clock
// RST_N                          I     1 reset
// start_a                        I    32
// start_b                        I    32
// EN_start                       I     1
// EN_getResult                   I     1
//
// No combinational paths from inputs to outputs
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

module mkGCD(CLK,
	     RST_N,

	     start_a,
	     start_b,
	     EN_start,
	     RDY_start,

	     EN_getResult,
	     getResult,
	     RDY_getResult);
  input  CLK;
  input  RST_N;

  // action method start
  input  [31 : 0] start_a;
  input  [31 : 0] start_b;
  input  EN_start;
  output RDY_start;

  // actionvalue method getResult
  input  EN_getResult;
  output [31 : 0] getResult;
  output RDY_getResult;

  // signals for module outputs
  wire [31 : 0] getResult;
  wire RDY_getResult, RDY_start;

  // register busy
  reg busy;
  wire busy$D_IN, busy$EN;

  // register x
  reg [31 : 0] x;
  wire [31 : 0] x$D_IN;
  wire x$EN;

  // register y
  reg [31 : 0] y;
  wire [31 : 0] y$D_IN;
  wire y$EN;

  // inputs to muxes for submodule ports
  wire [31 : 0] MUX_x$write_1__VAL_2;

  // remaining internal signals
  wire [31 : 0] x__h135;
  wire x_ULT_y___d5;

  // action method start
  assign RDY_start = !busy ;

  // actionvalue method getResult
  assign getResult = y ;
  assign RDY_getResult = x == 32'd0 ;

  // inputs to muxes for submodule ports
  assign MUX_x$write_1__VAL_2 = x_ULT_y___d5 ? y : x__h135 ;

  // register busy
  assign busy$D_IN = !EN_getResult ;
  assign busy$EN = EN_getResult || EN_start ;

  // register x
  assign x$D_IN = EN_start ? start_a : MUX_x$write_1__VAL_2 ;
  assign x$EN = x != 32'd0 || !x_ULT_y___d5 || EN_start ;

  // register y
  assign y$D_IN = EN_start ? start_b : x ;
  assign y$EN = x_ULT_y___d5 && x != 32'd0 || EN_start ;

  // remaining internal signals
  assign x_ULT_y___d5 = x < y ;
  assign x__h135 = x - y ;

  // handling of inlined registers

  always@(posedge CLK)
  begin
    if (RST_N == `BSV_RESET_VALUE)
      begin
        busy <= `BSV_ASSIGNMENT_DELAY 1'd0;
	x <= `BSV_ASSIGNMENT_DELAY 32'd0;
	y <= `BSV_ASSIGNMENT_DELAY 32'd0;
      end
    else
      begin
        if (busy$EN) busy <= `BSV_ASSIGNMENT_DELAY busy$D_IN;
	if (x$EN) x <= `BSV_ASSIGNMENT_DELAY x$D_IN;
	if (y$EN) y <= `BSV_ASSIGNMENT_DELAY y$D_IN;
      end
  end

  // synopsys translate_off
  `ifdef BSV_NO_INITIAL_BLOCKS
  `else // not BSV_NO_INITIAL_BLOCKS
  initial
  begin
    busy = 1'h0;
    x = 32'hAAAAAAAA;
    y = 32'hAAAAAAAA;
  end
  `endif // BSV_NO_INITIAL_BLOCKS
  // synopsys translate_on
endmodule  // mkGCD
