//========================================================================
// Muxes
//========================================================================

`ifndef MUXES_SV
`define MUXES_SV

//------------------------------------------------------------------------
// 2 Input Mux
//------------------------------------------------------------------------

module Mux2 #(
    parameter N_BITS = 32
) (
    input  logic [N_BITS-1:0] in0,
    input  logic [N_BITS-1:0] in1,
    input  logic              sel,
    output logic [N_BITS-1:0] out
);

    always_comb begin
        case (sel)
            1'b0:    out = in0;
            1'b1:    out = in1;
            default: out = '0;
        endcase
    end

endmodule

//------------------------------------------------------------------------
// 3 Input Mux
//------------------------------------------------------------------------

module Mux3 #(
    parameter N_BITS = 32
) (
    input  logic [N_BITS-1:0] in0,
    input  logic [N_BITS-1:0] in1,
    input  logic [N_BITS-1:0] in2,
    input  logic [1:0]        sel,
    output logic [N_BITS-1:0] out
);

    always_comb begin
        case (sel)
            2'b00:   out = in0;
            2'b01:   out = in1;
            2'b10:   out = in2;
            default: out = '0;
        endcase
    end
endmodule

//------------------------------------------------------------------------
// 4 Input Mux
//------------------------------------------------------------------------

module Mux4 #(
    parameter N_BITS = 32
) (
    input  logic [N_BITS-1:0] in0,
    input  logic [N_BITS-1:0] in1,
    input  logic [N_BITS-1:0] in2,
    input  logic [N_BITS-1:0] in3,
    input  logic [1:0]        sel,
    output logic [N_BITS-1:0] out
);

    always_comb begin
        case (sel)
            2'b00:   out = in0;
            2'b01:   out = in1;
            2'b10:   out = in2;
            2'b11:   out = in3;
            default: out = '0;
        endcase
    end
endmodule

//------------------------------------------------------------------------
// 5 Input Mux
//------------------------------------------------------------------------

module Mux5 #(
    parameter N_BITS = 32
) (
    input  logic [N_BITS-1:0] in0,
    input  logic [N_BITS-1:0] in1,
    input  logic [N_BITS-1:0] in2,
    input  logic [N_BITS-1:0] in3,
    input  logic [N_BITS-1:0] in4,
    input  logic [2:0]        sel,
    output logic [N_BITS-1:0] out
);

    always_comb begin
        case (sel)
            3'b000:   out = in0;
            3'b001:   out = in1;
            3'b010:   out = in2;
            3'b011:   out = in3;
            3'b100:   out = in4;
            default: out = '0;
        endcase
    end
endmodule

//------------------------------------------------------------------------
// 6 Input Mux
//------------------------------------------------------------------------

module Mux6 #(
    parameter N_BITS = 32
) (
    input  logic [N_BITS-1:0] in0,
    input  logic [N_BITS-1:0] in1,
    input  logic [N_BITS-1:0] in2,
    input  logic [N_BITS-1:0] in3,
    input  logic [N_BITS-1:0] in4,
    input  logic [N_BITS-1:0] in5,
    input  logic [2:0]        sel,
    output logic [N_BITS-1:0] out
);

    always_comb begin
        case (sel)
            3'b000:   out = in0;
            3'b001:   out = in1;
            3'b010:   out = in2;
            3'b011:   out = in3;
            3'b100:   out = in4;
            3'b101:   out = in5;
            default: out = '0;
        endcase
    end
endmodule

//------------------------------------------------------------------------
// 7 Input Mux
//------------------------------------------------------------------------

module Mux7 #(
    parameter N_BITS = 32
) (
    input  logic [N_BITS-1:0] in0,
    input  logic [N_BITS-1:0] in1,
    input  logic [N_BITS-1:0] in2,
    input  logic [N_BITS-1:0] in3,
    input  logic [N_BITS-1:0] in4,
    input  logic [N_BITS-1:0] in5,
    input  logic [N_BITS-1:0] in6,
    input  logic [2:0]        sel,
    output logic [N_BITS-1:0] out
);

    always_comb begin
        case (sel)
            3'b000:   out = in0;
            3'b001:   out = in1;
            3'b010:   out = in2;
            3'b011:   out = in3;
            3'b100:   out = in4;
            3'b101:   out = in5;
            3'b110:   out = in6;
            default: out = '0;
        endcase
    end
endmodule

//------------------------------------------------------------------------
// 8 Input Mux
//------------------------------------------------------------------------

module Mux8 #(
    parameter N_BITS = 32
) (
    input  logic [N_BITS-1:0] in0,
    input  logic [N_BITS-1:0] in1,
    input  logic [N_BITS-1:0] in2,
    input  logic [N_BITS-1:0] in3,
    input  logic [N_BITS-1:0] in4,
    input  logic [N_BITS-1:0] in5,
    input  logic [N_BITS-1:0] in6,
    input  logic [N_BITS-1:0] in7,
    input  logic [2:0]        sel,
    output logic [N_BITS-1:0] out
);

    always_comb begin
        case (sel)
            3'b000:   out = in0;
            3'b001:   out = in1;
            3'b010:   out = in2;
            3'b011:   out = in3;
            3'b100:   out = in4;
            3'b101:   out = in5;
            3'b110:   out = in6;
            3'b111:   out = in7;
            default: out = '0;
        endcase
    end
endmodule

`endif /* MUXES_SV */
