
module imem (
    input  logic        i_clk, // Giữ lại cho đúng interface
    input  logic [31:0] i_imem_addr,
    output logic [31:0] o_imem_data
);
    logic [31:0] memory [0:16383]; // 64KiB
    
    initial begin
         $readmemh("../02_test/isa_4b.hex", memory);
    end 
    
    // ĐỌC BẤT ĐỒNG BỘ
    always_comb begin
        o_imem_data = memory[i_imem_addr[15:2]];
    end
endmodule