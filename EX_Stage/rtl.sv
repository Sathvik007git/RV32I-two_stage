module ex_stage_i (
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,
    input  logic [31:0] immediate,
    input  logic [31:0] instruction_pc,
    input  logic [2:0]  funct3,
    input  logic        alu_src_imm,
    input  logic        operand_a_pc,
    input  logic        branch,
    input  logic        jump,
    input  logic        jump_register,
    input  logic [3:0]  alu_control,
    output logic [31:0] alu_result,
    output logic [31:0] pc_target,
    output logic        redirect
);
    logic [31:0] alu_operand_a;
    logic [31:0] alu_operand_b;
    logic branch_condition;

    always_comb begin
        alu_operand_a = operand_a_pc ? instruction_pc : rs1_data;
        alu_operand_b = alu_src_imm ? immediate : rs2_data;

        branch_condition = 1'b0;
        case (funct3)
            3'b000: branch_condition = (rs1_data == rs2_data);
            3'b001: branch_condition = (rs1_data != rs2_data);
            3'b100: branch_condition = ($signed(rs1_data) < $signed(rs2_data));
            3'b101: branch_condition = ($signed(rs1_data) >= $signed(rs2_data));
            3'b110: branch_condition = (rs1_data < rs2_data);
            3'b111: branch_condition = (rs1_data >= rs2_data);
            default: branch_condition = 1'b0;
        endcase

        pc_target = jump_register ? ((rs1_data + immediate) & 32'hffff_fffe)
                                  : (instruction_pc + immediate);
        redirect = jump || (branch && branch_condition);
    end

    alu_i execute_alu (
        .operand_a(alu_operand_a),
        .operand_b(alu_operand_b),
        .alu_control(alu_control),
        .result(alu_result)
    );
endmodule
