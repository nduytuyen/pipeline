module EX_MEM(
    input  logic        i_clk, i_reset,
    input  logic [31:0] i_alu_data, i_rs2_data, i_pc,
    input  logic [4:0]  i_rd_addr,
    input  logic [2:0]  i_func3,
    input  logic        i_rd_wren, i_mem_wren, i_insn_vld, i_mispred, i_ctrl,
    input  logic [1:0]  i_wb_sel,
    
    output logic [31:0] o_alu_data, o_rs2_data, o_pc,
    output logic [4:0]  o_rd_addr,
    output logic [2:0]  o_func3,
    output logic        o_rd_wren, o_mem_wren, o_insn_vld, o_mispred, o_ctrl,
    output logic [1:0]  o_wb_sel
);
    always_ff @(posedge i_clk or negedge i_reset) begin
        if (!i_reset) begin
            o_rd_wren <= 1'b0; o_mem_wren <= 1'b0; o_insn_vld <= 1'b0; o_mispred <= 1'b0; o_ctrl <= 1'b0;
        end else begin
            o_alu_data <= i_alu_data; o_rs2_data <= i_rs2_data; o_pc <= i_pc; o_rd_addr <= i_rd_addr;
            o_func3 <= i_func3; o_rd_wren <= i_rd_wren; o_mem_wren <= i_mem_wren; o_insn_vld <= i_insn_vld;
            o_mispred <= i_mispred; o_ctrl <= i_ctrl; o_wb_sel <= i_wb_sel;
        end
    end
endmodule