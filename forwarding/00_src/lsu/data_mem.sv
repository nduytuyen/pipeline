module data_memory (
    input  logic        i_clk,
    input  logic [15:0] i_addr,      // 64KBs
    input  logic [31:0] i_st_data,
    input  logic        i_write_enable,
    input  logic [2:0]  i_ctrl,      // funct3
    output logic [31:0] o_memory_data
);

    localparam SIZE = 65536;         // 64 KB 
    logic [7:0] memory_reg [SIZE-1:0];  
      
    // Initialize down to 0  
    initial begin  
        for (int i = 0; i < SIZE; i++) begin  
            memory_reg[i] = 8'h00;  
        end  
    end

    // Write logic (RAW address - không align)
    always_ff @(posedge i_clk) begin 
        if (i_write_enable) begin 
            case (i_ctrl[1:0]) 
                2'b00: // SB 
                    memory_reg[i_addr] <= i_st_data[7:0];

                2'b01: begin // SH  
                    memory_reg[i_addr]   <= i_st_data[7:0];  
                    memory_reg[i_addr+1] <= i_st_data[15:8];  
                end  
      
                2'b10: begin // SW  
                    memory_reg[i_addr]   <= i_st_data[7:0];  
                    memory_reg[i_addr+1] <= i_st_data[15:8];  
                    memory_reg[i_addr+2] <= i_st_data[23:16];  
                    memory_reg[i_addr+3] <= i_st_data[31:24];  
                end  
            endcase  
        end  
    end  
      
    // Read logic (RAW address)
    logic [31:0] raw_read_data;  
   
    always_comb begin  
        raw_read_data[7:0]   = memory_reg[i_addr];
        raw_read_data[15:8]  = memory_reg[i_addr + 1];  
        raw_read_data[23:16] = memory_reg[i_addr + 2];  
        raw_read_data[31:24] = memory_reg[i_addr + 3];
    end
      
    // Format output theo funct3  
    always_comb begin  
        case (i_ctrl)  
            3'b000: o_memory_data = {{24{raw_read_data[7]}},  raw_read_data[7:0]};   // LB  
            3'b001: o_memory_data = {{16{raw_read_data[15]}}, raw_read_data[15:0]};  // LH  
            3'b010: o_memory_data = raw_read_data;                                   // LW  
            3'b100: o_memory_data = {24'h0, raw_read_data[7:0]};                     // LBU  
            3'b101: o_memory_data = {16'h0, raw_read_data[15:0]};                    // LHU  
            default: o_memory_data = 32'h0;  
        endcase  
    end

endmodule