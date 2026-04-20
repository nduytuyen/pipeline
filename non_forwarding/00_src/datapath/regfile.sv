module regfile(
    input   wire  [4:0]     i_rs1_addr,i_rs2_addr,i_rd_addr,
    input   wire            i_rd_wren,i_clk,i_rst_n,
    input   wire  [31:0]    i_rd_data,
    output  wire  [31:0]    o_rs1_data,o_rs2_data
);
  
    reg [31:0]  register[31:0];
  
    integer i;
    
    always @(posedge  i_clk or negedge  i_rst_n)  begin 
          if(!i_rst_n) begin 
              for(i = 0; i < 32; i = i + 1) begin 
                register[i] <= 32'b0;
              end
          end else if(i_rd_wren && i_rd_addr != 5'd0) begin 
              register[i_rd_addr] <= i_rd_data;
          end
    end

    // === THÊM WB BYPASS Ở ĐÂY (quan trọng nhất) ===
    assign o_rs1_data = (i_rs1_addr != 0) ? 
                        ((i_rs1_addr == i_rd_addr && i_rd_wren) ? i_rd_data : register[i_rs1_addr]) : 
                        32'b0;

    assign o_rs2_data = (i_rs2_addr != 0) ? 
                        ((i_rs2_addr == i_rd_addr && i_rd_wren) ? i_rd_data : register[i_rs2_addr]) : 
                        32'b0;

endmodule 