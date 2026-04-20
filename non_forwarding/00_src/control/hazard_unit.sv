module hazard_unit(
    input  logic [4:0] i_rs1_addr, i_rs2_addr,
    input  logic [4:0] i_rd_addr_ex, i_rd_addr_mem, i_rd_addr_wb,
    input  logic       i_rd_wren_ex, i_rd_wren_mem, i_rd_wren_wb,
    output logic       o_stall
);

    always_comb begin
        o_stall = 1'b0;

        // Chỉ stall khi producer còn ở EX hoặc MEM (chưa write-back)
        // KHÔNG stall khi producer đã ở WB → tránh infinite stall
        if (i_rs1_addr != 5'd0) begin
            if ((i_rs1_addr == i_rd_addr_ex && i_rd_wren_ex) ||
                (i_rs1_addr == i_rd_addr_mem && i_rd_wren_mem))
                o_stall = 1'b1;
        end

        if (i_rs2_addr != 5'd0) begin
            if ((i_rs2_addr == i_rd_addr_ex && i_rd_wren_ex) ||
                (i_rs2_addr == i_rd_addr_mem && i_rd_wren_mem))
                o_stall = 1'b1;
        end
    end
endmodule