module mux_2to1(
    input   wire            i_sel,
    input   wire    [31:0]  i_data_0, i_data_1,
    output  wire    [31:0]  o_data
);
  
    assign o_data = (i_sel) ? i_data_1  : i_data_0;

endmodule
