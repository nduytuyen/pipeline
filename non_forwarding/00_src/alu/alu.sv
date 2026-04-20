module alu(
  input  wire   [31:0] i_operand_a,
  input  wire   [31:0] i_operand_b,
  input  wire   [3:0]  i_alu_op,
  output reg    [31:0] o_alu_data
); 
  wire [31:0] add_res, sub_res, and_res, or_res, xor_res, sll_res, srl_res, sra_res, slt_res, sltu_res;
  
  wire        c_out_res;

  adder                adder_unit  (                   .a(i_operand_a),
                                                       .b(i_operand_b),
                                                       .c_in(1'b0),
                                                       .c_out(c_out_res),
                                                       .sum(add_res)
                       );
  
  and_32bit            and_unit    (                   .a(i_operand_a),
                                                       .b(i_operand_b), 
                                                       .result(and_res)
                       );

  or_32bit             or_unit     (                   .a(i_operand_a),
                                                       .b(i_operand_b), 
                                                       .result(or_res)
                       );
 
  sll                  sll_unit    (                   .a(i_operand_a),
                                                       .b(i_operand_b[4:0]),
                                                       .result(sll_res)
                       );

  srl                  srl_unit    (                   .a(i_operand_a), 
                                                       .b(i_operand_b[4:0]), 
                                                       .result(srl_res)
                       );

  slt                  slt_unit    (                   .a(i_operand_a), 
                                                       .b(i_operand_b),    
                                                       .result(slt_res)
                       );

  sltu                 sltu_unit   (                   .a(i_operand_a),
                                                       .b(i_operand_b),      
                                                       .result(sltu_res)
                       );

  sra                  sra_unit    (                   .a(i_operand_a),
                                                       .b(i_operand_b[4:0]),
                                                       .result(sra_res)
                       );

  subtractor           sub_unit    (                   .a(i_operand_a),
                                                       .b(i_operand_b),
                                                       .c_in(1'b1),    
                                                       .sub(sub_res), 
                                                       .c_out(c_out_res) 
                       );

  xor_32bit            xor_unit    (                   .a(i_operand_a), 
                                                       .b(i_operand_b),    
                                                       .result(xor_res) 
                       );
   //alu_op
    localparam [3:0] 
   	                                           OP_ADD  = 4'b0000,
					           OP_SUB  = 4'b0001,
					           OP_SLT  = 4'b0010,
					           OP_SLTU = 4'b0011,
					           OP_XOR  = 4'b0100,
					           OP_OR   = 4'b0101,
					           OP_AND  = 4'b0110,
                                                   OP_SLL  = 4'b0111,
					           OP_SRL  = 4'b1000,
					           OP_SRA  = 4'b1001,
					           OP_OPB  = 4'b1010;
					                     
  always @(*) begin 
    case(i_alu_op) 
            OP_ADD:  o_alu_data = add_res;
            OP_SUB:  o_alu_data = sub_res;
            OP_SLT:  o_alu_data = slt_res; 
            OP_SLTU: o_alu_data = sltu_res;
            OP_XOR:  o_alu_data = xor_res;
            OP_OR:   o_alu_data = or_res;
            OP_AND:  o_alu_data = and_res;
            OP_SLL:  o_alu_data = sll_res;
            OP_SRL:  o_alu_data = srl_res;    
            OP_SRA:  o_alu_data = sra_res;
            OP_OPB:  o_alu_data = i_operand_b;
            default: o_alu_data = 32'b0;
    endcase
  end

endmodule  
