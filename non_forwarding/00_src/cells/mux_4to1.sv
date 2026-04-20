module mux_4to1(
    input   wire  [1:0]   i_sel,
    input   wire  [31:0]  i_data_0, i_data_1, i_data_2,  i_data_3,
    output  reg   [31:0]  o_data
);

    always  @(*)  begin : proc_mux_4to1
        case(i_sel)
            2'b00 : o_data  = i_data_0;
            2'b01 : o_data  = i_data_1;
            2'b10 : o_data  = i_data_2;
            2'b11 : o_data  = i_data_3;
        endcase
    end

endmodule

