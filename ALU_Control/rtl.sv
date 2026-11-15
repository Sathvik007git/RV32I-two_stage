module alu_control_i (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic [3:0] alu_control
);
    localparam logic [3:0] ALU_ADD  = 4'd0;
    localparam logic [3:0] ALU_SUB  = 4'd1;
    localparam logic [3:0] ALU_SLL  = 4'd2;
    localparam logic [3:0] ALU_SLT  = 4'd3;
    localparam logic [3:0] ALU_SLTU = 4'd4;
    localparam logic [3:0] ALU_XOR  = 4'd5;
    localparam logic [3:0] ALU_SRL  = 4'd6;
    localparam logic [3:0] ALU_SRA  = 4'd7;
    localparam logic [3:0] ALU_OR   = 4'd8;
    localparam logic [3:0] ALU_AND  = 4'd9;

    always_comb begin
        alu_control = ALU_ADD;
        if ((opcode == 7'b0110011) || (opcode == 7'b0010011)) begin
            case (funct3)
                3'b000: begin
                    if ((opcode == 7'b0110011) && funct7[5])
                        alu_control = ALU_SUB;
                    else
                        alu_control = ALU_ADD;
                end
                3'b001: alu_control = ALU_SLL;
                3'b010: alu_control = ALU_SLT;
                3'b011: alu_control = ALU_SLTU;
                3'b100: alu_control = ALU_XOR;
                3'b101: alu_control = funct7[5] ? ALU_SRA : ALU_SRL;
                3'b110: alu_control = ALU_OR;
                3'b111: alu_control = ALU_AND;
                default: alu_control = ALU_ADD;
            endcase
        end
    end
endmodule
