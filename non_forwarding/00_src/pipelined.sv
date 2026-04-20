module pipelined(
    input   logic           i_clk, i_reset,
    input   logic   [31:0]  i_io_sw,
    output  logic           o_insn_vld, o_ctrl, o_mispred,
    output  logic   [31:0]  o_pc_debug, o_io_ledr, o_io_ledg, o_io_lcd,
    output  logic   [6:0]   o_io_hex0, o_io_hex1, o_io_hex2, o_io_hex3, o_io_hex4, o_io_hex5, o_io_hex6, o_io_hex7
);

    // ========================================================================
    // GLOABL HAZARD & CONTROL
    // ========================================================================
    logic stall, flush, pc_sel_ex;
    logic [31:0] alu_data_ex;

    // ========================================================================
    // TẦNG 1: IF (Fetch)
    // ========================================================================
    logic [31:0] pc_if, pc_next_if, pc_four_if, instr_if;

 // pipelined.sv
always_ff @(posedge i_clk or negedge i_reset) begin
    if (!i_reset) 
        pc_if <= 32'b0;
    else if (flush || !stall) 
        pc_if <= {pc_next_if[31:1], 1'b0};   // ← SỬA Ở ĐÂY
end
    // Dùng pc_plus4
    pc_plus4 PC_FOUR_IF (.pc(pc_if), .pc_four(pc_four_if));
    
    // Dùng Mux để chọn PC Next
    mux_2to1 MUX_PC_NEXT (
        .i_data_0(pc_four_if), 
        .i_data_1(alu_data_ex), 
        .i_sel(pc_sel_ex), 
        .o_data(pc_next_if)
    );

    imem IMEM_INST (.i_clk(i_clk), .i_imem_addr(pc_if), .o_imem_data(instr_if));

    logic [31:0] pc_id, instr_id;
    IF_ID REG_IF_ID (
        .i_clk(i_clk), .i_reset(i_reset), .i_flush(flush), .i_stall(stall),
        .i_pc(pc_if), .i_instr(instr_if),
        .o_pc(pc_id), .o_instr(instr_id)
    );

    // ========================================================================
    // TẦNG 2: ID (Decode)
    // ========================================================================
    logic [31:0] rs1_data_id, rs2_data_id, imm_id, wb_data_wb;
    logic [4:0]  rd_addr_wb;
    logic        rd_wren_wb;
    
    logic br_un_id, rd_wren_id, mem_wren_id, mem_rden_id, opa_sel_id, opb_sel_id, insn_vld_id;
    logic is_branch_id, is_jump_id;
    logic [1:0] wb_sel_id;
    logic [3:0] alu_op_id;

    ctrl_unit CONTROL (
        .i_inst(instr_id),
        .o_br_un(br_un_id), .o_rd_wren(rd_wren_id), .o_mem_wren(mem_wren_id), .o_mem_rden(mem_rden_id),
        .o_opa_sel(opa_sel_id), .o_opb_sel(opb_sel_id), .o_insn_vld(insn_vld_id), 
        .o_is_branch(is_branch_id), .o_is_jump(is_jump_id), .o_wb_sel(wb_sel_id), .o_alu_op(alu_op_id)
    );

    regfile REG_FILE (
        .i_clk(i_clk), .i_rst_n(i_reset), .i_rs1_addr(instr_id[19:15]), .i_rs2_addr(instr_id[24:20]),
        .i_rd_addr(rd_addr_wb), .i_rd_wren(rd_wren_wb), .i_rd_data(wb_data_wb),
        .o_rs1_data(rs1_data_id), .o_rs2_data(rs2_data_id)
    );

    ImmGen IMM_GEN (.i_inst(instr_id), .o_imm(imm_id));

    logic [4:0] rd_addr_ex, rd_addr_mem;
    logic       rd_wren_ex, rd_wren_mem;

    hazard_unit HAZARD (
        .i_rs1_addr(instr_id[19:15]), .i_rs2_addr(instr_id[24:20]),
        .i_rd_addr_ex(rd_addr_ex), .i_rd_addr_mem(rd_addr_mem), .i_rd_addr_wb(rd_addr_wb),
        .i_rd_wren_ex(rd_wren_ex), .i_rd_wren_mem(rd_wren_mem), .i_rd_wren_wb(rd_wren_wb),
        .o_stall(stall)
    );

    logic [31:0] pc_ex, rs1_data_ex, rs2_data_ex, imm_ex;
    logic        mem_wren_ex, opa_sel_ex, opb_sel_ex, br_un_ex, insn_vld_ex, is_jump_ex, is_branch_ex;
    logic [3:0]  alu_op_ex;
    logic [1:0]  wb_sel_ex;
    logic [2:0]  func3_ex;

    ID_EX REG_ID_EX (
        .i_clk(i_clk), .i_reset(i_reset), .i_flush(flush), .i_stall(stall),
        .i_pc(pc_id), .i_rs1_data(rs1_data_id), .i_rs2_data(rs2_data_id), .i_imm(imm_id),
        .i_rd_addr(instr_id[11:7]), .i_func3(instr_id[14:12]),
        .i_rd_wren(rd_wren_id), .i_mem_wren(mem_wren_id), .i_opa_sel(opa_sel_id), .i_opb_sel(opb_sel_id),
        .i_br_un(br_un_id), .i_insn_vld(insn_vld_id), .i_is_jump(is_jump_id), .i_is_branch(is_branch_id),
        .i_alu_op(alu_op_id), .i_wb_sel(wb_sel_id),
        
        .o_pc(pc_ex), .o_rs1_data(rs1_data_ex), .o_rs2_data(rs2_data_ex), .o_imm(imm_ex),
        .o_rd_addr(rd_addr_ex), .o_func3(func3_ex),
        .o_rd_wren(rd_wren_ex), .o_mem_wren(mem_wren_ex), .o_opa_sel(opa_sel_ex), .o_opb_sel(opb_sel_ex),
        .o_br_un(br_un_ex), .o_insn_vld(insn_vld_ex), .o_is_jump(is_jump_ex), .o_is_branch(is_branch_ex),
        .o_alu_op(alu_op_ex), .o_wb_sel(wb_sel_ex)
    );

    // ========================================================================
    // TẦNG 3: EX (Execute)
    // ========================================================================
    logic [31:0] opa, opb;
    logic br_less, br_equal, branch_taken;

    // Dùng Mux cho đầu vào ALU
    mux_2to1 MUX_OPA (.i_data_0(rs1_data_ex), .i_data_1(pc_ex), .i_sel(opa_sel_ex), .o_data(opa));
    mux_2to1 MUX_OPB (.i_data_0(rs2_data_ex), .i_data_1(imm_ex), .i_sel(opb_sel_ex), .o_data(opb));

    alu ALU_UNIT (.i_operand_a(opa), .i_operand_b(opb), .i_alu_op(alu_op_ex), .o_alu_data(alu_data_ex));
    brc BRC_UNIT (.i_br_un(br_un_ex), .i_rs1_data(rs1_data_ex), .i_rs2_data(rs2_data_ex), .o_br_less(br_less), .o_br_equal(br_equal));

    always_comb begin
        case (func3_ex)
            3'b000: branch_taken = br_equal;   
            3'b001: branch_taken = !br_equal;  
            3'b100: branch_taken = br_less;    
            3'b101: branch_taken = !br_less;   
            3'b110: branch_taken = br_less;    
            3'b111: branch_taken = !br_less;   
            default: branch_taken = 1'b0;
        endcase
    end
    
    assign pc_sel_ex = is_jump_ex | (is_branch_ex & branch_taken);
    assign flush     = pc_sel_ex; 

    logic is_ctrl_inst_ex;
    assign is_ctrl_inst_ex = is_jump_ex | is_branch_ex;

    logic [31:0] alu_data_mem, rs2_data_mem, pc_mem;
    logic        mem_wren_mem, insn_vld_mem, mispred_mem, ctrl_mem;
    logic [1:0]  wb_sel_mem;
    logic [2:0]  func3_mem;

    EX_MEM REG_EX_MEM (
        .i_clk(i_clk), .i_reset(i_reset),
        .i_alu_data(alu_data_ex), .i_rs2_data(rs2_data_ex), .i_pc(pc_ex),
        .i_rd_addr(rd_addr_ex), .i_func3(func3_ex),
        .i_rd_wren(rd_wren_ex), .i_mem_wren(mem_wren_ex), .i_insn_vld(insn_vld_ex),
        .i_mispred(flush), .i_ctrl(is_ctrl_inst_ex), .i_wb_sel(wb_sel_ex),
        
        .o_alu_data(alu_data_mem), .o_rs2_data(rs2_data_mem), .o_pc(pc_mem),
        .o_rd_addr(rd_addr_mem), .o_func3(func3_mem),
        .o_rd_wren(rd_wren_mem), .o_mem_wren(mem_wren_mem), .o_insn_vld(insn_vld_mem),
        .o_mispred(mispred_mem), .o_ctrl(ctrl_mem), .o_wb_sel(wb_sel_mem)
    );

    // ========================================================================
    // TẦNG 4: MEM (Memory)
    // ========================================================================
    logic [31:0] ld_data_mem;
    
    lsu LSU_INST (
        .i_clk(i_clk), .i_reset(i_reset), .i_lsu_addr(alu_data_mem), .i_st_data(rs2_data_mem),
        .i_lsu_wren(mem_wren_mem), .i_control(func3_mem), .o_ld_data(ld_data_mem),
        .o_io_ledr(o_io_ledr), .o_io_ledg(o_io_ledg), .o_io_hex0(o_io_hex0), .o_io_hex1(o_io_hex1),
        .o_io_hex2(o_io_hex2), .o_io_hex3(o_io_hex3), .o_io_hex4(o_io_hex4), .o_io_hex5(o_io_hex5),
        .o_io_hex6(o_io_hex6), .o_io_hex7(o_io_hex7), .o_io_lcd(o_io_lcd), .i_io_sw(i_io_sw)
    );

    logic [31:0] alu_data_wb, ld_data_wb, pc_wb;
    logic [1:0]  wb_sel_wb;

    MEM_WB REG_MEM_WB (
        .i_clk(i_clk), .i_reset(i_reset),
        .i_alu_data(alu_data_mem), .i_ld_data(ld_data_mem), .i_pc(pc_mem),
        .i_rd_addr(rd_addr_mem), .i_rd_wren(rd_wren_mem), .i_insn_vld(insn_vld_mem),
        .i_mispred(mispred_mem), .i_ctrl(ctrl_mem), .i_wb_sel(wb_sel_mem),
        
        .o_alu_data(alu_data_wb), .o_ld_data(ld_data_wb), .o_pc(pc_wb),
        .o_rd_addr(rd_addr_wb), .o_rd_wren(rd_wren_wb), .o_insn_vld(o_insn_vld),
        .o_mispred(o_mispred), .o_ctrl(o_ctrl), .o_wb_sel(wb_sel_wb)
    );

    // ========================================================================
    // TẦNG 5: WB (Write Back)
    // ========================================================================
    assign o_pc_debug = pc_wb; // Debug PC
    
    logic [31:0] pc_four_wb;
    pc_plus4 PC_FOUR_WB (.pc(pc_wb), .pc_four(pc_four_wb)); // Cho JAL, JALR

    // Dùng Mux 4 to 1 cho Write Back
    mux_4to1 MUX_WB (
        .i_data_0(pc_four_wb),  
        .i_data_1(alu_data_wb), 
        .i_data_2(ld_data_wb),  
        .i_data_3(32'b0),       
        .i_sel(wb_sel_wb),
        .o_data(wb_data_wb)
    );
endmodule