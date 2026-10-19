//========================================================================
// Arithmetic Components
//========================================================================

`ifndef ARITHMETIC_SV
`define ARITHMETIC_SV

//------------------------------------------------------------------------
// Adders
//------------------------------------------------------------------------

module Adder #(
    parameter N_BITS = 32
) (
    input  logic [N_BITS-1:0] in0,
    input  logic [N_BITS-1:0] in1,
    input  logic              cin,
    output logic              cout,
    output logic [N_BITS-1:0] out
);

    assign {cout, out} = in0 + in1 + {{(N_BITS-1){1'b0}},cin};

endmodule

module SimpleAdder #(
    parameter N_BITS = 32
) (
    input  logic [N_BITS-1:0] in0,
    input  logic [N_BITS-1:0] in1,
    output logic [N_BITS-1:0] out
);

    assign out = in0 + in1;

endmodule

//------------------------------------------------------------------------
// Subtractor
//------------------------------------------------------------------------

module Subtractor #(
    parameter N_BITS = 32
) (
    input  logic [N_BITS-1:0] in0,
    input  logic [N_BITS-1:0] in1,
    output logic [N_BITS-1:0] out
);

    assign out = in0 - in1;

endmodule

//------------------------------------------------------------------------
// Incrementer
//------------------------------------------------------------------------

module Incrementer #(
    parameter N_BITS = 32,
    parameter INC_VAL = 1
) (
    input  logic [N_BITS-1:0] in,
    output logic [N_BITS-1:0] out
);
    assign out = in + INC_VAL;

endmodule

//------------------------------------------------------------------------
// ZeroExtender
//------------------------------------------------------------------------

module ZeroExtender #(
    parameter N_BITS = 32,
    parameter OUT_BITS = 32
) (
    input  logic [N_BITS-1:0]   in,
    output logic [OUT_BITS-1:0] out
);

    assign out = {{(OUT_BITS - N_BITS){1'b0}}, in};

endmodule

//------------------------------------------------------------------------
// SignExtender
//------------------------------------------------------------------------

module SignExtender #(
    parameter N_BITS = 32,
    parameter OUT_BITS = 32
) (
    input  logic [N_BITS-1:0]   in,
    output logic [OUT_BITS-1:0] out
);
    assign out = {{(OUT_BITS - N_BITS){in[N_BITS - 1]}}, in};

endmodule

//------------------------------------------------------------------------
// ZeroComparator
//------------------------------------------------------------------------

module ZeroComparator #(
    parameter N_BITS = 32
) (
    input  logic  [N_BITS-1:0] in,
    output logic               out
);
    assign out = (in == {N_BITS{1'b0}});
endmodule

//------------------------------------------------------------------------
// EqComparator
//------------------------------------------------------------------------

module EqComparator #(
    parameter N_BITS = 32
) (
    input  logic [N_BITS-1:0] in0,
    input  logic [N_BITS-1:0] in1,
    output logic              out
);

    assign out = (in0 == in1);

endmodule

//------------------------------------------------------------------------
// LtComparator
//------------------------------------------------------------------------

module LtComparator #(
    parameter N_BITS = 32
) (
    input  logic [N_BITS-1:0] in0,
    input  logic [N_BITS-1:0] in1,
    output logic              out
);

    assign out = (in0 < in1);

endmodule

//------------------------------------------------------------------------
// GtComparator
//------------------------------------------------------------------------

module GtComparator #(
    parameter N_BITS = 32
) (
    input  logic [N_BITS-1:0] in0,
    input  logic [N_BITS-1:0] in1,
    output logic              out
);

    assign out = (in0 > in1);

endmodule

//------------------------------------------------------------------------
// LeftLogicalShifter
//------------------------------------------------------------------------

module LeftLogicalShifter #(
    parameter N_BITS = 32
) (
    input  logic         [N_BITS-1:0] in,
    input  logic [$clog2(N_BITS)-1:0] sftamt,
    output logic         [N_BITS-1:0] out
);

    assign out = (in << sftamt);

endmodule

//------------------------------------------------------------------------
// RightLogicalShifter
//------------------------------------------------------------------------

module RightLogicalShifter #(
    parameter N_BITS = 32
) (
    input  logic         [N_BITS-1:0] in,
    input  logic [$clog2(N_BITS)-1:0] sftamt,
    output logic         [N_BITS-1:0] out
);

    assign out = (in >> sftamt);

endmodule

`endif /* ARITHMETIC_SV */
