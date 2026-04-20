module forwarding_unit (
    input  logic [4:0] i_rs1_addr_ex, i_rs2_addr_ex,
    input  logic [4:0] i_rd_addr_mem, i_rd_addr_wb,
    input  logic       i_rd_wren_mem, i_rd_wren_wb,
    output logic [1:0] o_forward_a, o_forward_b
);
    always_comb begin
        // Forward A (cho rs1)
        if (i_rd_wren_mem && (i_rd_addr_mem != 5'd0) && (i_rd_addr_mem == i_rs1_addr_ex))
            o_forward_a = 2'b10; // Lấy từ tầng MEM
        else if (i_rd_wren_wb && (i_rd_addr_wb != 5'd0) && (i_rd_addr_wb == i_rs1_addr_ex))
            o_forward_a = 2'b01; // Lấy từ tầng WB
        else
            o_forward_a = 2'b00; // Lấy từ Register File (mặc định)

        // Forward B (cho rs2)
        if (i_rd_wren_mem && (i_rd_addr_mem != 5'd0) && (i_rd_addr_mem == i_rs2_addr_ex))
            o_forward_b = 2'b10; // Lấy từ tầng MEM
        else if (i_rd_wren_wb && (i_rd_addr_wb != 5'd0) && (i_rd_addr_wb == i_rs2_addr_ex))
            o_forward_b = 2'b01; // Lấy từ tầng WB
        else
            o_forward_b = 2'b00; // Lấy từ Register File (mặc định)
    end
endmodule