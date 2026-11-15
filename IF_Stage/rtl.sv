module if_stage_i (
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,
    input  logic        redirect,
    input  logic [31:0] redirect_pc,
    output logic [31:0] fetch_address,
    output logic [31:0] fetch_pc_plus4
);
    logic [31:0] pc_register;

    always_comb begin
        fetch_address = pc_register;
        fetch_pc_plus4 = pc_register + 32'd4;
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            pc_register <= 32'h8000_0000;
        else if (!stall) begin
            if (redirect)
                pc_register <= redirect_pc;
            else
                pc_register <= fetch_pc_plus4;
        end
    end
endmodule
