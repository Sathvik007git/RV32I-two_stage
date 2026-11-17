module two_stage_riscv_i (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instruction,
    input  logic [31:0] mem_out,
    output logic [31:0] rs2_data,
    output logic [31:0] alu_out,
    output logic        mem_write,
    output logic        mem_read,
    output logic [2:0]  fn3,
    output logic [31:0] address
);
    logic        stall;
    logic [6:0]  opcode;
    logic [31:0] fetch_pc_plus4;
    logic [31:0] instruction_q;
    logic [31:0] instruction_pc_q;
    logic        instruction_valid_q;

    logic [6:0] opcode_q;
    logic [4:0] rd_q;
    logic [2:0] funct3_q;
    logic [4:0] rs1_q;
    logic [4:0] rs2_q;
    logic [6:0] funct7_q;
    logic [31:0] immediate;

    logic [31:0] rs1_value;
    logic [31:0] rs2_value;
    logic [31:0] alu_result;
    logic [31:0] pc_target;
    logic        redirect_from_execute;
    logic        redirect_to_fetch;

    logic        reg_write_control;
    logic        mem_read_control;
    logic        mem_write_control;
    logic        alu_src_imm;
    logic        operand_a_pc;
    logic        branch;
    logic        jump;
    logic        jump_register;
    logic [1:0]  wb_select;
    logic [3:0]  alu_control;
    logic [31:0] writeback_data;
    
    assign stall = 1'b0;
    assign redirect_to_fetch = instruction_valid_q && !stall && redirect_from_execute;
    assign opcode = instruction_valid_q ? opcode_q : 7'b0;
    assign fn3 = instruction_valid_q ? funct3_q : 3'b0;
    assign rs2_data = rs2_value;
    assign alu_out = alu_result;
    assign mem_read = instruction_valid_q && !stall && mem_read_control;
    assign mem_write = instruction_valid_q && !stall && mem_write_control;

    if_stage_i fetch_stage (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .redirect(redirect_to_fetch),
        .redirect_pc(pc_target),
        .fetch_address(address),
        .fetch_pc_plus4(fetch_pc_plus4)
    );

    if_id_register_i if_id_pipeline_register (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .flush(redirect_to_fetch),
        .instruction_in(instruction),
        .pc_in(address),
        .instruction_out(instruction_q),
        .pc_out(instruction_pc_q),
        .valid_out(instruction_valid_q)
    );

    decoder_i decode_stage (
        .instruction(instruction_q),
        .opcode(opcode_q),
        .rd(rd_q),
        .funct3(funct3_q),
        .rs1(rs1_q),
        .rs2(rs2_q),
        .funct7(funct7_q)
    );

    immediate_generator_i immediate_stage (
        .instruction(instruction_q),
        .opcode(opcode_q),
        .immediate(immediate)
    );

    main_control_i control_stage (
        .opcode(opcode_q),
        .reg_write(reg_write_control),
        .mem_read(mem_read_control),
        .mem_write(mem_write_control),
        .alu_src_imm(alu_src_imm),
        .operand_a_pc(operand_a_pc),
        .branch(branch),
        .jump(jump),
        .jump_register(jump_register),
        .wb_select(wb_select)
    );

    register_file_i integer_register_file (
        .clk(clk),
        .reset(reset),
        .write_enable(instruction_valid_q && !stall && reg_write_control),
        .rs1_sel(rs1_q),
        .rs2_sel(rs2_q),
        .rd_sel(rd_q),
        .write_data(writeback_data),
        .rs1_data(rs1_value),
        .rs2_data(rs2_value)
    );

    alu_control_i alu_decode (
        .opcode(opcode_q),
        .funct3(funct3_q),
        .funct7(funct7_q),
        .alu_control(alu_control)
    );

    ex_stage_i execute_stage (
        .rs1_data(rs1_value),
        .rs2_data(rs2_value),
        .immediate(immediate),
        .instruction_pc(instruction_pc_q),
        .funct3(funct3_q),
        .alu_src_imm(alu_src_imm),
        .operand_a_pc(operand_a_pc),
        .branch(branch),
        .jump(jump),
        .jump_register(jump_register),
        .alu_control(alu_control),
        .alu_result(alu_result),
        .pc_target(pc_target),
        .redirect(redirect_from_execute)
    );

    wb_stage_i writeback_stage (
        .alu_result(alu_result),
        .mem_out(mem_out),
        .pc_plus4(instruction_pc_q + 32'd4),
        .immediate(immediate),
        .wb_select(wb_select),
        .writeback_data(writeback_data)
    );
endmodule
