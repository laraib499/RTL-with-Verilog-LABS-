module pipelined_multiplier(
    input clk,
    input rst,
    input [3:0] A,
    input [3:0] B,
    output reg [7:0] P
);

reg [3:0] A_reg, B_reg;
reg [7:0] mult_reg;

// Stage 1: Register inputs
always @(posedge clk or posedge rst)
begin
    if(rst) begin
        A_reg <= 0;
        B_reg <= 0;
    end
    else begin
        A_reg <= A;
        B_reg <= B;
    end
end

// Stage 2: Multiply and register output
always @(posedge clk or posedge rst)
begin
    if(rst) begin
        mult_reg <= 0;
        P <= 0;
    end
    else begin
        mult_reg <= A_reg * B_reg;
        P <= mult_reg;
    end
end

endmodule

