module input_buffer (
    input  logic [2:0]  i_ctrl,
    input  logic [15:0] i_addr,
    input  logic [31:0] i_switch,
    output logic [31:0] o_in_buf_data
);

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

    // Switches chỉ map ở vùng 0x1001_0000 → [15:12] == 4'h0
    always_comb begin
        if (aligned_addr[15:12] == 4'h0) begin
            case (i_ctrl)
                3'b000: o_in_buf_data = {{24{i_switch[8*aligned_addr[1:0]+7]}}, i_switch[8*aligned_addr[1:0] +: 8]};
                3'b001: o_in_buf_data = {{16{i_switch[16*aligned_addr[1]+15]}}, i_switch[16*aligned_addr[1] +: 16]};
                3'b010: o_in_buf_data = i_switch;
                3'b100: o_in_buf_data = {24'h0, i_switch[8*aligned_addr[1:0] +: 8]};
                3'b101: o_in_buf_data = {16'h0, i_switch[16*aligned_addr[1] +: 16]};
                default: o_in_buf_data = 32'h0;
            endcase
        end else begin
            o_in_buf_data = 32'h0;
        end
    end

endmodule
