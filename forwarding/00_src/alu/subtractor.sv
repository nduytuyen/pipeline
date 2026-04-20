module subtractor(
  input  wire [31:0] a,
  input  wire [31:0] b,
  input  wire        c_in, //cin = 1
  output wire [31:0] sub,
  output wire        c_out
);

  wire  [31:0]  b_neg;
  
  assign b_neg = ~b;

  adder subtract(
    .a(a),
    .b(b_neg),
    .c_in(c_in),
    .sum(sub),
    .c_out(c_out)
  );

endmodule 
