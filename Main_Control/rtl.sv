module main_control_i (
    input  logic [6:0] opcode,
    output logic       reg_write,
    output logic       mem_read,
    output logic       mem_write,
    output logic       alu_src_imm,
    output logic       operand_a_pc,
    output logic       branch,
    output logic       jump,
    output logic       jump_register,
    output logic [1:0] wb_select
);
    always_comb begin
        reg_write    = 1'b0;
        mem_read     = 1'b0;
        mem_write    = 1'b0;
        alu_src_imm  = 1'b0;
        operand_a_pc = 1'b0;
        branch       = 1'b0;
        jump         = 1'b0;
        jump_register = 1'b0;
        wb_select    = 2'b00;

        case (opcode)
            7'b0110011: begin
                reg_write = 1'b1;
            end
            7'b0010011: begin
                reg_write = 1'b1;
                alu_src_imm = 1'b1;
            end
            7'b0000011: begin
                reg_write = 1'b1;
                mem_read = 1'b1;
                alu_src_imm = 1'b1;
                wb_select = 2'b01;
            end
            7'b0100011: begin
                mem_write = 1'b1;
                alu_src_imm = 1'b1;
            end
            7'b1100011: begin
                branch = 1'b1;
            end
            7'b1101111: begin
                reg_write = 1'b1;
                jump = 1'b1;
                wb_select = 2'b10;
            end
            7'b1100111: begin
                reg_write = 1'b1;
                jump = 1'b1;
                jump_register = 1'b1;
                alu_src_imm = 1'b1;
                wb_select = 2'b10;
            end
            7'b0110111: begin
                reg_write = 1'b1;
                wb_select = 2'b11;
            end
            7'b0010111: begin
                reg_write = 1'b1;
                operand_a_pc = 1'b1;
                alu_src_imm = 1'b1;
            end
            default: begin
            end
        endcase
    end
endmodule
