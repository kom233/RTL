//========================================================================
// Immediate Generation
//========================================================================

`ifndef IMM_GEN_SV
`define IMM_GEN_SV

module ImmGen
(
    input  logic [ 2:0] imm_type,
    input  logic [31:0] inst,
    output logic [31:0] imm
);

    always_comb begin
        case(imm_type)
            3'd0: imm = {{21{inst[31]}}, inst[30:20]};                                            // I-type
            3'd1: imm = {{21{inst[31]}}, inst[30:25], inst[11:7]};                                // S-type
            3'd2: imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};                 // B-type
            3'd3: imm = {inst[31:12], 12'b0};                                                     // U-type
            3'd4: imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};               // J-type
            default: imm = 32'dx;
        endcase
    end

endmodule

`endif /* IMM_GEN_SV */
