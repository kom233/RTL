//========================================================================
// ALU
//========================================================================

`ifndef ALU_SV
`define ALU_SV

`include "misc/arithmetic.sv"

module Alu
(
    input  logic [31:0] in0,
    input  logic [31:0] in1,
    input  logic [ 3:0] fn,
    output logic [31:0] out,
    output logic        eq,
    output logic        lt,
    output logic        ltu,
    output logic        bge
);

    always_comb begin
        case(fn) 
            4'd0: out = in0 + in1;
            4'd1: out = in0 - in1;
            4'd2: out = in0 & in1;
            4'd3: out = in0 | in1;
            4'd4: out = in0 ^ in1;
            4'd5: out = ($signed(in0) < $signed(in1)) ? 32'd1: 32'd0;
            4'd6: out = ($signed(in0)) >>> (in1[4:0]);
            4'd7: out = in0 >> (in1[4:0]);
            4'd8: out = in0 << (in1[4:0]);
            default: out = 32'd0;
        endcase
    end

    EqComparator #(
        .N_BITS(32)
    ) eq_comparator (
        .in0(in0),
        .in1(in1),
        .out(eq)
    );

    assign lt = $signed(in0) < $signed(in1);

    LtComparator #(
        .N_BITS(32)
    ) lt_comparator (
        .in0(in0),
        .in1(in1),
        .out(ltu)
    );

    assign bge = $signed(in0) >= $signed(in1);

endmodule

`endif /* ALU_SV */
