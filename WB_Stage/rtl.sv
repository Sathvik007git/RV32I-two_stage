module wb_stage_i (
    input  logic [31:0] alu_result,
    input  logic [31:0] mem_out,
    input  logic [31:0] pc_plus4,
    input  logic [31:0] immediate,
    input  logic [1:0]  wb_select,
    output logic [31:0] writeback_data
);
    always_comb begin
        case (wb_select)
            2'b00: writeback_data = alu_result;
            2'b01: writeback_data = mem_out;
            2'b10: writeback_data = pc_plus4;
            2'b11: writeback_data = immediate;
            default: writeback_data = alu_result;
        endcase
    end
endmodule
