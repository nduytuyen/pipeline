module hazard_unit(
    input  logic [4:0] i_rs1_addr, i_rs2_addr, // Từ tầng ID
    input  logic [4:0] i_rd_addr_ex,           // Từ tầng EX
    input  logic       i_mem_rden_ex,          // Cờ báo lệnh ở EX là Load
    output logic       o_stall
);
    always_comb begin
        o_stall = 1'b0;
        
        // Load-Use Hazard: Stall 1 chu kỳ nếu lệnh EX là LOAD và ID cần dùng data đó
        if (i_mem_rden_ex && (i_rd_addr_ex != 5'd0) &&
           ((i_rd_addr_ex == i_rs1_addr) || (i_rd_addr_ex == i_rs2_addr))) begin
            o_stall = 1'b1;
        end
    end
endmodule