module sra(
  input   wire [31:0] a,
  input   wire [4:0]  b,
  output  reg [31:0] result
);

  reg [31:0] stage1, stage2, stage3, stage4;
  wire sign_bit;  

  assign sign_bit = a[31];

  always @(*) begin 
    if( b[4] == 1 )     stage1 = { {16{sign_bit}}, a[31:16] };
    else                stage1 = a;
  
    if( b[3] == 1 )     stage2 = { {8{sign_bit}}, stage1[31:8] };
    else                stage2 = stage1;

    if( b[2] == 1 )     stage3 = { {4{sign_bit}}, stage2[31:4] };
    else                stage3 = stage2;

    if( b[1] == 1 )     stage4 = { {2{sign_bit}}, stage3[31:2] };
    else                stage4 = stage3;

    if( b[0] == 1 )     result = { {1{sign_bit}}, stage4[31:1] };
    else                result = stage4;
  end

endmodule 
