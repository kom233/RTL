//========================================================================
// Registers
//========================================================================

`ifndef REGS_SV
`define REGS_SV

//------------------------------------------------------------------------
// Postive-edge triggered flip-flop
//------------------------------------------------------------------------

module Reg #(
    parameter N_BITS = 32
) (
    input  logic              clk,
    input  logic [N_BITS-1:0] d,
    output logic [N_BITS-1:0] q
);

    always_ff @(posedge clk) begin
        q <= d;
    end

endmodule

//------------------------------------------------------------------------
// Postive-edge triggered flip-flop with reset
//------------------------------------------------------------------------

module RegReset #(
    parameter                    N_BITS      = 32,
    parameter logic [N_BITS-1:0] RESET_VALUE = '0
) (
    input  logic              clk,
    input  logic              reset,
    input  logic [N_BITS-1:0] d,
    output logic [N_BITS-1:0] q
);

    always_ff @(posedge clk) begin
        if (reset) begin
            q <= RESET_VALUE;
        end 
        else begin
            q <= d;
        end
    end

endmodule

//------------------------------------------------------------------------
// Postive-edge triggered flip-flop with enable
//------------------------------------------------------------------------

module RegEn #(
    parameter N_BITS = 32
) (
    input  logic              clk,
    input  logic              en,
    input  logic [N_BITS-1:0] d,
    output logic [N_BITS-1:0] q
);

    always_ff @(posedge clk) begin
        if (en) begin
            q <= d;
        end
    end

endmodule

//------------------------------------------------------------------------
// Postive-edge triggered flip-flop with enable and reset
//------------------------------------------------------------------------

module RegResetEn #(
    parameter                    N_BITS      = 32,
    parameter logic [N_BITS-1:0] RESET_VALUE = '0
) (
    input  logic              clk,
    input  logic              reset,
    input  logic              en,
    input  logic [N_BITS-1:0] d,
    output logic [N_BITS-1:0] q
);

    always_ff @(posedge clk) begin
        if (reset || en) begin
            q <= reset ? RESET_VALUE : d;
        end
    end

endmodule

`endif /* REGS_SV */
