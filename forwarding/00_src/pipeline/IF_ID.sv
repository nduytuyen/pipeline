module IF_ID(
    input  logic        i_clk, i_reset, i_flush, i_stall,
    input  logic [31:0] i_pc, i_instr,
    output logic [31:0] o_pc, o_instr
);
    always_ff @(posedge i_clk or negedge i_reset) begin
        if (!i_reset || i_flush) begin
            o_pc    <= 32'b0;
            o_instr <= 32'h00000013; // NOP
        end else if (!i_stall) begin
            o_pc    <= i_pc;
            o_instr <= i_instr;
        end
    end
endmodule