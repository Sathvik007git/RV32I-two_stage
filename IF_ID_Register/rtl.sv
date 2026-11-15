module if_id_register_i (
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,
    input  logic        flush,
    input  logic [31:0] instruction_in,
    input  logic [31:0] pc_in,
    output logic [31:0] instruction_out,
    output logic [31:0] pc_out,
    output logic        valid_out
);
    localparam logic [31:0] NOP = 32'h0000_0013;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            instruction_out <= NOP;
            pc_out <= 32'b0;
            valid_out <= 1'b0;
        end else if (!stall) begin
            if (flush) begin
                instruction_out <= NOP;
                pc_out <= 32'b0;
                valid_out <= 1'b0;
            end else begin
                instruction_out <= instruction_in;
                pc_out <= pc_in;
                valid_out <= 1'b1;
            end
        end
    end
endmodule
