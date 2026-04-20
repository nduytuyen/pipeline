module adder(
  input wire    [31:0] a,
  input wire    [31:0] b,
  input wire           c_in,    //cin = 0
  output wire   [31:0] sum,
  output wire          c_out
);
  wire [31:0] carry;
  
  generate
 
    genvar i;
    
    //full_adder dau tien

    full_adder fa0(
      .a(a[0]),
      .b(b[0]),
      .c_in(c_in),
      .sum(sum[0]),
      .c_out(carry[0])
      );
    
    // full_adder_final

    for( i = 1; i < 32; i = i + 1) begin :name
      full_adder fa( 
        .a(a[i]),
        .b(b[i]),
        .c_in(carry[i-1]),
        .sum(sum[i]),
        .c_out(carry[i])
       );
    end
  endgenerate 
  
  assign c_out = carry[31];

endmodule
