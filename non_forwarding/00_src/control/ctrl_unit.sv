module ctrl_unit(
    input   wire  [31:0]    i_inst,
    output  reg             o_br_un, o_rd_wren, o_mem_wren, o_mem_rden, o_opa_sel, o_opb_sel, o_insn_vld,
    output  reg             o_is_branch, o_is_jump, 
    output  reg  [1:0]      o_wb_sel,
    output  reg  [3:0]      o_alu_op
);
    localparam R_TYPE = 5'b01100, 
               I_TYPE = 5'b00100, 
               I_LOAD = 5'b00000, 
               S_TYPE = 5'b01000, 
               B_TYPE = 5'b11000, 
               JAL    = 5'b11011, 
               JALR   = 5'b11001, 
               LUI    = 5'b01101, 
               AUIPC  = 5'b00101;
         

    localparam [3:0] OP_ADD  = 4'b0000, OP_SUB  = 4'b0001, OP_SLT  = 4'b0010, OP_SLTU = 4'b0011,
                     OP_XOR  = 4'b0100, OP_OR   = 4'b0101, OP_AND  = 4'b0110, OP_SLL  = 4'b0111,
                     OP_SRL  = 4'b1000, OP_SRA  = 4'b1001, OP_OPB  = 4'b1010;

    localparam [2:0] ADD  = 3'b000, SLL  = 3'b001, SLT  = 3'b010, SLTU = 3'b011,
                     XOR  = 3'b100, SRL  = 3'b101, OR   = 3'b110, AND  = 3'b111;
    localparam [2:0] LB   = 3'b000, LH   = 3'b001, LW   = 3'b010, LBU  = 3'b100, LHU  = 3'b101;
    localparam [2:0] SB   = 3'b000, SH   = 3'b001, SW   = 3'b010;

    localparam rs1_sel = 1'b0, pc_sel  = 1'b1, rs2_sel = 1'b0, imm_sel = 1'b1;
    localparam unvalid = 1'b0, valid   = 1'b1, rd_unwr = 1'b0, rd_wr   = 1'b1;
    localparam wb_pc_four = 2'b00, wb_alu_data = 2'b01, wb_lsu_data = 2'b10;
    localparam br_unsign  = 1'b1, br_sign = 1'b0;

    always @(*) begin 
        o_br_un     = br_unsign; o_rd_wren   = rd_unwr; o_mem_wren  = unvalid; o_mem_rden  = unvalid;
        o_opa_sel   = rs1_sel;   o_opb_sel   = rs2_sel; o_insn_vld  = unvalid; o_is_branch = 1'b0;
        o_is_jump   = 1'b0;      o_wb_sel    = wb_alu_data; o_alu_op = OP_ADD;

        case(i_inst[6:2])
            R_TYPE: begin 
                o_rd_wren = rd_wr; o_insn_vld = valid; o_wb_sel = wb_alu_data;
                case(i_inst[14:12])
                    ADD: o_alu_op = (i_inst[30]) ? OP_SUB : OP_ADD;
                    SLT: o_alu_op = OP_SLT; SLTU: o_alu_op = OP_SLTU;
                    XOR: o_alu_op = OP_XOR; OR: o_alu_op = OP_OR; AND: o_alu_op = OP_AND;
                    SRL: o_alu_op = (i_inst[30]) ? OP_SRA : OP_SRL;
                    SLL: o_alu_op = OP_SLL;
                endcase
            end
            I_TYPE: begin 
                o_rd_wren = rd_wr; o_insn_vld = valid; o_opb_sel = imm_sel; o_wb_sel = wb_alu_data;
                case(i_inst[14:12])
                    ADD: o_alu_op = OP_ADD;
                    SLT: o_alu_op = OP_SLT; SLTU: o_alu_op = OP_SLTU;
                    XOR: o_alu_op = OP_XOR; OR: o_alu_op = OP_OR; AND: o_alu_op = OP_AND;
                    SRL: o_alu_op = (i_inst[30]) ? OP_SRA : OP_SRL;
                    SLL: o_alu_op = OP_SLL;
                endcase
            end
            I_LOAD: begin 
                o_rd_wren = rd_wr; o_opb_sel = imm_sel; o_mem_rden = valid; o_wb_sel = wb_lsu_data;
                o_insn_vld = ((i_inst[14:12] == LB)||(i_inst[14:12] == LH)||(i_inst[14:12] == LW)||(i_inst[14:12] == LBU)||(i_inst[14:12] == LHU)) ? valid:unvalid;
            end
            S_TYPE: begin 
                o_opb_sel = imm_sel; o_mem_wren = valid;
                o_insn_vld = ((i_inst[14:12] == SB)||(i_inst[14:12] == SH)||(i_inst[14:12] == SW)) ? valid:unvalid;
            end
            B_TYPE: begin 
                o_opa_sel = pc_sel; o_opb_sel = imm_sel; o_is_branch = 1'b1;
                case(i_inst[14:12])
                    3'b000, 3'b001, 3'b100, 3'b101: begin o_insn_vld = valid; o_br_un = br_sign; end
                    3'b110, 3'b111:                 begin o_insn_vld = valid; o_br_un = br_unsign; end
                    default:                        begin o_insn_vld = unvalid; end
                endcase
            end
            JALR: begin o_rd_wren = rd_wr; o_insn_vld = valid; o_opb_sel = imm_sel; o_is_jump = 1'b1; o_wb_sel = wb_pc_four; end
            JAL:  begin o_rd_wren = rd_wr; o_insn_vld = valid; o_opa_sel = pc_sel; o_opb_sel = imm_sel; o_is_jump = 1'b1; o_wb_sel = wb_pc_four; end
            AUIPC:begin o_rd_wren = rd_wr; o_insn_vld = valid; o_opa_sel = pc_sel; o_opb_sel = imm_sel; o_wb_sel = wb_alu_data; end
            LUI:  begin o_rd_wren = rd_wr; o_insn_vld = valid; o_opb_sel = imm_sel; o_alu_op = OP_OPB; o_wb_sel = wb_alu_data; end
            
        endcase
    end
endmodule