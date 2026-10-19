//=========================================================================
// Integer Multiplier Variable-Latency
//=========================================================================

`ifndef INT_MUL_SV
`define INT_MUL_SV

`include "misc/arithmetic.sv"
`include "misc/muxes.sv"
`include "misc/regs.sv"

module IntMulDpath
(
    input  logic        clk,
    input  logic        reset,

    input  logic [63:0] istream_msg,

    input  logic        a_mux_sel,
    input  logic        b_mux_sel,
    input  logic        result_mux_sel,
    input  logic        add_mux_sel,

    input  logic        a_reg_en,
    input  logic        b_reg_en,
    input  logic        result_reg_en,

    output logic        b_lsb,
    output logic        b_is_zero,
    output logic [31:0] ostream_msg

);

    logic [31:0] a_istream_msg;
    logic [31:0] b_istream_msg;

    assign a_istream_msg = istream_msg[63:32];
    assign b_istream_msg = istream_msg[31:0];

    // Output wires for muxes
    logic [31:0] a_mux_out;
    logic [31:0] b_mux_out;
    logic [31:0] result_mux_out;

    Mux2 #(
        .N_BITS(32)
    ) a_mux (
        .in0(a_istream_msg),
        .in1(left_shift_out),
        .sel(a_mux_sel),
        .out(a_mux_out)
    );

    Mux2 #(
        .N_BITS(32)
    ) b_mux (
        .in0(b_istream_msg),
        .in1(right_shift_out),
        .sel(b_mux_sel),
        .out(b_mux_out)
    );

    Mux2 #(
        .N_BITS(32)
    ) result_mux (
        .in0(add_mux_out),
        .in1(32'd0),
        .sel(result_mux_sel),
        .out(result_mux_out)
    );

    // Output wires for registers
    logic [31:0] a_reg_out;
    logic [31:0] b_reg_out;
    logic [31:0] result_reg_out;

    RegResetEn #(
        .N_BITS(32)
    ) a_reg (
        .clk(clk),
        .reset(reset),
        .en(a_reg_en),
        .d(a_mux_out),
        .q(a_reg_out)
    );

    RegResetEn #(
        .N_BITS(32)
    ) b_reg (
        .clk(clk),
        .reset(reset),
        .en(b_reg_en),
        .d(b_mux_out),
        .q(b_reg_out)
    );

    RegResetEn #(
        .N_BITS(32)
    ) result_reg (
        .clk(clk),
        .reset(reset),
        .en(result_reg_en),
        .d(result_mux_out),
        .q(result_reg_out)
    );

    assign b_lsb = b_reg_out[0];
    assign b_is_zero = (right_shift_out == 32'd0);

    // Determines the shift amount for lower cycle count (Worst case is still 32 + 1)
    logic [4:0] shift_amt;
    always_comb begin
        shift_amt = 5'd1;
        if (b_reg_out[15:0] == 16'd0) begin
            shift_amt = 5'd16;
        end
        else if (b_reg_out[7:0] == 8'd0) begin
            shift_amt = 5'd8;
        end
        else if (b_reg_out[3:0] == 4'd0) begin
            shift_amt = 5'd4;
        end
        else if (b_reg_out[1:0] == 2'd0) begin
            shift_amt = 5'd2;
        end
    end

    // Output of shifters and adder
    logic [31:0] right_shift_out;
    logic [31:0] left_shift_out;
    logic [31:0] adder_out;

    RightLogicalShifter #(
        .N_BITS(32)
    ) b_shifter (
        .in(b_reg_out),
        .sftamt(shift_amt),
        .out(right_shift_out)
    );

    LeftLogicalShifter #(
        .N_BITS(32)
    ) a_shifter (
        .in(a_reg_out),
        .sftamt(shift_amt),
        .out(left_shift_out)
    );

    SimpleAdder #(
        .N_BITS(32)
    ) result_adder(
        .in0(a_reg_out),
        .in1(result_reg_out),
        .out(adder_out)
    );

    // Output add mux and output stream
    logic [31:0] add_mux_out;

    Mux2 #(
        .N_BITS(32)
    ) add_mux (
        .in0(adder_out),
        .in1(result_reg_out),
        .sel(add_mux_sel),
        .out(add_mux_out)
    );

    assign ostream_msg = result_reg_out;

endmodule

module IntMulCtrl
(
    input  logic        clk,
    input  logic        reset,

    input  logic        istream_val,
    input  logic        ostream_rdy,

    output logic        istream_rdy,
    output logic        ostream_val,

    input  logic        b_lsb,
    input  logic        b_is_zero,

    output logic        a_mux_sel,
    output logic        b_mux_sel,
    output logic        result_mux_sel,
    output logic        add_mux_sel,

    output logic        a_reg_en,
    output logic        b_reg_en,
    output logic        result_reg_en
);

    // FSM states
    localparam IDLE = 2'd0;
    localparam CALC = 2'd1;
    localparam DONE = 2'd2;

    logic [1:0] state;
    logic [1:0] next_state;

    // State registers
    always_ff @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    // State transitions
    always_comb begin
        next_state = state;
        case(state)
            IDLE: begin
                if (istream_val) begin
                    next_state = CALC;
                end
            end
            CALC: begin
                if (b_is_zero) begin
                    next_state = DONE;
                end
                
            end
            DONE: begin
                if (ostream_rdy) begin
                    next_state = IDLE;
                end
            end
            default: begin
                next_state = state;
            end
        endcase
    end

    // State outputs
    always_comb begin
        istream_rdy    = 1'd0;
        ostream_val    = 1'd0;
        a_mux_sel      = 1'd0;
        b_mux_sel      = 1'd0;
        result_mux_sel = 1'd1;
        add_mux_sel    = 1'd0;
        a_reg_en       = 1'd0;
        b_reg_en       = 1'd0;
        result_reg_en  = 1'd0;

        case(state)
            IDLE: begin
                istream_rdy    = 1'd1;
                ostream_val    = 1'd0;
                a_mux_sel      = 1'd0;
                b_mux_sel      = 1'd0;
                result_mux_sel = 1'd1;
                add_mux_sel    = 1'd0;
                a_reg_en       = istream_val;
                b_reg_en       = istream_val;
                result_reg_en  = istream_val;
                
            end
            CALC: begin
                istream_rdy    = 1'd0;
                ostream_val    = 1'd0;
                a_mux_sel      = 1'd1;
                b_mux_sel      = 1'd1;
                result_mux_sel = 1'd0;
                add_mux_sel    = ~b_lsb;
                a_reg_en       = 1'd1;
                b_reg_en       = 1'd1;
                result_reg_en  = 1'd1;
                
            end
            DONE: begin
                istream_rdy    = 1'd0;
                ostream_val    = 1'd1;
                a_mux_sel      = 1'd0;
                b_mux_sel      = 1'd0;
                result_mux_sel = 1'd1;
                add_mux_sel    = 1'd0;
                a_reg_en       = 1'd0;
                b_reg_en       = 1'd0;
                result_reg_en  = 1'd0;
            end
            default: begin
                istream_rdy    = 1'd0;
                ostream_val    = 1'd0;
                a_mux_sel      = 1'd0;
                b_mux_sel      = 1'd0;
                result_mux_sel = 1'd1;
                add_mux_sel    = 1'd0;
                a_reg_en       = 1'd0;
                b_reg_en       = 1'd0;
                result_reg_en  = 1'd0;
            end
        endcase
    end


endmodule

module IntMul
(
    input  logic        clk,
    input  logic        reset,

    input  logic        istream_val,
    output logic        istream_rdy,
    input  logic [63:0] istream_msg,

    output logic        ostream_val,
    input  logic        ostream_rdy,
    output logic [31:0] ostream_msg
);
    // Wires for dpath and ctrl
    logic a_mux_sel, b_mux_sel, result_mux_sel, add_mux_sel;
    logic a_reg_en, b_reg_en, result_reg_en;
    logic b_lsb, b_is_zero;

    IntMulDpath dpath (
        .clk           (clk),
        .reset         (reset),
        .istream_msg   (istream_msg),
        .a_mux_sel     (a_mux_sel),
        .b_mux_sel     (b_mux_sel),
        .result_mux_sel(result_mux_sel),
        .add_mux_sel   (add_mux_sel),
        .a_reg_en      (a_reg_en),
        .b_reg_en      (b_reg_en),
        .result_reg_en (result_reg_en),
        .b_lsb         (b_lsb),
        .b_is_zero     (b_is_zero),
        .ostream_msg   (ostream_msg)
    );

    IntMulCtrl ctrl (
        .clk           (clk),
        .reset         (reset),
        .istream_val   (istream_val),
        .ostream_rdy   (ostream_rdy),
        .istream_rdy   (istream_rdy),
        .ostream_val   (ostream_val),
        .b_lsb         (b_lsb),
        .b_is_zero     (b_is_zero),
        .a_mux_sel     (a_mux_sel),
        .b_mux_sel     (b_mux_sel),
        .result_mux_sel(result_mux_sel),
        .add_mux_sel   (add_mux_sel),
        .a_reg_en      (a_reg_en),
        .b_reg_en      (b_reg_en),
        .result_reg_en (result_reg_en)
    );

endmodule

`endif /* INT_MUL_SV */
