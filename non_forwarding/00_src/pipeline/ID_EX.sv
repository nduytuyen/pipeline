module ID_EX(
    input  logic        i_clk, i_reset, i_flush, i_stall,
    input  logic [31:0] i_pc, i_rs1_data, i_rs2_data, i_imm,
    input  logic [4:0]  i_rd_addr,
    input  logic [2:0]  i_func3,
    input  logic        i_rd_wren, i_mem_wren, i_opa_sel, i_opb_sel, i_br_un, i_insn_vld,
    input  logic        i_is_jump, i_is_branch,
    input  logic [3:0]  i_alu_op,
    input  logic [1:0]  i_wb_sel,
    
    output logic [31:0] o_pc, o_rs1_data, o_rs2_data, o_imm,
    output logic [4:0]  o_rd_addr,
    output logic [2:0]  o_func3,
    output logic        o_rd_wren, o_mem_wren, o_opa_sel, o_opb_sel, o_br_un, o_insn_vld,
    output logic        o_is_jump, o_is_branch,
    output logic [3:0]  o_alu_op,
    output logic [1:0]  o_wb_sel
);
    always_ff @(posedge i_clk or negedge i_reset) begin
        if (!i_reset || i_flush || i_stall) begin
            o_rd_wren <= 1'b0; o_mem_wren <= 1'b0; o_insn_vld <= 1'b0; o_is_jump <= 1'b0; o_is_branch <= 1'b0;
        end else begin
            o_pc <= i_pc; o_rs1_data <= i_rs1_data; o_rs2_data <= i_rs2_data; o_imm <= i_imm;
            o_rd_addr <= i_rd_addr; o_func3 <= i_func3; o_rd_wren <= i_rd_wren; o_mem_wren <= i_mem_wren;
            o_opa_sel <= i_opa_sel; o_opb_sel <= i_opb_sel; o_br_un <= i_br_un; o_insn_vld <= i_insn_vld;
            o_is_jump <= i_is_jump; o_is_branch <= i_is_branch; o_alu_op <= i_alu_op; o_wb_sel <= i_wb_sel;
        end
    end
endmodule