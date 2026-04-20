module sll(
  input   wire  [31:0] a,
  input   wire  [4:0]  b,
  output  reg   [31:0] result
);
  reg [31:0] stage1,stage2,stage3,stage4;

  always @(*) begin
 
    if(!(b[4] ^ 1)) stage1 = {a[15:0],16'b0};
    else            stage1 = a;
    
    if(!(b[3] ^ 1)) stage2 = {stage1[23:0],8'b0};
    else            stage2 = stage1;

    if(!(b[2] ^ 1)) stage3 = {stage2[27:0],4'b0};
    else            stage3 = stage2;
  
    if(!(b[1] ^ 1)) stage4 = { stage3[29:0],2'b0 };
    else            stage4 = stage3;

    if(!(b[0] ^ 1)) result = {stage4[30:0],1'b0};
    else            result = stage4;
  end
endmodule   
      
