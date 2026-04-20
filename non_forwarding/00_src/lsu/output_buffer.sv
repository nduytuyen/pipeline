module output_buffer (
    input  logic        i_clk,
    input  logic        i_reset,
    input  logic        i_write_en,
    input  logic [2:0]  i_ctrl,
    input  logic [15:0] i_addr,
    input  logic [31:0] i_wdata,
    output logic [31:0] o_rdata,
    output logic [31:0] o_ledr,
    output logic [31:0] o_ledg,
    output logic [6:0]  o_hex0, o_hex1, o_hex2, o_hex3,
    output logic [6:0]  o_hex4, o_hex5, o_hex6, o_hex7,
    output logic [31:0] o_lcd
);

    logic [31:0] reg_red, reg_green, reg_hex3_0, reg_hex7_4, reg_lcd;

    // Aligned address
    logic [15:0] aligned_addr;
    always_comb begin
        case (i_ctrl[1:0])
            2'b00: aligned_addr = i_addr;
            2'b01: aligned_addr = {i_addr[15:1], 1'b0};
            2'b10: aligned_addr = {i_addr[15:2], 2'b00};
            default: aligned_addr = i_addr;
        endcase
    end

    // Write logic
    always_ff @(posedge i_clk or negedge i_reset) begin
        if (!i_reset) begin
            reg_red    <= 32'h0;
            reg_green  <= 32'h0;
            reg_hex3_0 <= 32'h0;
            reg_hex7_4 <= 32'h0;
            reg_lcd    <= 32'h0;
        end 
        else if (i_write_en) begin
            case (aligned_addr[15:12])
                4'h0: // Red LEDs     0x1000_0000
                    if (i_ctrl[1:0] == 2'b00) reg_red[8*aligned_addr[1:0] +: 8]   <= i_wdata[7:0];
                    else if (i_ctrl[1:0] == 2'b01) reg_red[16*aligned_addr[1] +:16] <= i_wdata[15:0];
                    else reg_red <= i_wdata;

                4'h1: // Green LEDs   0x1000_1000
                    if (i_ctrl[1:0] == 2'b00) reg_green[8*aligned_addr[1:0] +: 8]   <= i_wdata[7:0];
                    else if (i_ctrl[1:0] == 2'b01) reg_green[16*aligned_addr[1] +:16] <= i_wdata[15:0];
                    else reg_green <= i_wdata;

                4'h2: // HEX 3-0      0x1000_2000
                    if (i_ctrl[1:0] == 2'b00) reg_hex3_0[8*aligned_addr[1:0] +: 8]   <= i_wdata[7:0];
                    else if (i_ctrl[1:0] == 2'b01) reg_hex3_0[16*aligned_addr[1] +:16] <= i_wdata[15:0];
                    else reg_hex3_0 <= i_wdata;

                4'h3: // HEX 7-4      0x1000_3000
                    if (i_ctrl[1:0] == 2'b00) reg_hex7_4[8*aligned_addr[1:0] +: 8]   <= i_wdata[7:0];
                    else if (i_ctrl[1:0] == 2'b01) reg_hex7_4[16*aligned_addr[1] +:16] <= i_wdata[15:0];
                    else reg_hex7_4 <= i_wdata;

                4'h4: // LCD          0x1000_4000
                    if (i_ctrl[1:0] == 2'b00) reg_lcd[8*aligned_addr[1:0] +: 8]   <= i_wdata[7:0];
                    else if (i_ctrl[1:0] == 2'b01) reg_lcd[16*aligned_addr[1] +:16] <= i_wdata[15:0];
                    else reg_lcd <= i_wdata;
            endcase
        end
    end

    // Read logic
    logic [31:0] target_reg;
    always_comb begin
        case (aligned_addr[15:12])
            4'h0: target_reg = reg_red;
            4'h1: target_reg = reg_green;
            4'h2: target_reg = reg_hex3_0;
            4'h3: target_reg = reg_hex7_4;
            4'h4: target_reg = reg_lcd;
            default: target_reg = 32'h0;
        endcase
    end

    always_comb begin
        case (i_ctrl)
            3'b000: o_rdata = {{24{target_reg[8*aligned_addr[1:0]+7]}}, target_reg[8*aligned_addr[1:0] +: 8]};
            3'b001: o_rdata = {{16{target_reg[16*aligned_addr[1]+15]}}, target_reg[16*aligned_addr[1] +: 16]};
            3'b010: o_rdata = target_reg;
            3'b100: o_rdata = {24'h0, target_reg[8*aligned_addr[1:0] +: 8]};
            3'b101: o_rdata = {16'h0, target_reg[16*aligned_addr[1] +: 16]};
            default: o_rdata = 32'h0;
        endcase
    end

    // Output assignment
    assign o_ledr = reg_red;
    assign o_ledg = reg_green;
    assign o_hex0 = reg_hex3_0[6:0];  assign o_hex1 = reg_hex3_0[14:8];
    assign o_hex2 = reg_hex3_0[22:16]; assign o_hex3 = reg_hex3_0[30:24];
    assign o_hex4 = reg_hex7_4[6:0];  assign o_hex5 = reg_hex7_4[14:8];
    assign o_hex6 = reg_hex7_4[22:16]; assign o_hex7 = reg_hex7_4[30:24];
    assign o_lcd  = reg_lcd;

endmodule
