module pipelined_alu(
    input clk,
    input rst,
    input [31:0] A,
    input [31:0] B,
    input [2:0] ALU_Sel,
    output reg [31:0] Result
);

    
    reg [31:0] A_reg, B_reg;
    reg [2:0] ALU_Sel_reg;


    reg [31:0] alu_result;

    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            A_reg <= 0;
            B_reg <= 0;
            ALU_Sel_reg <= 0;
        end
        else begin
            A_reg <= A;
            B_reg <= B;
            ALU_Sel_reg <= ALU_Sel;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            alu_result <= 0;
        else begin
            case(ALU_Sel_reg)
                3'b000: alu_result <= A_reg + B_reg;
                3'b001: alu_result <= A_reg - B_reg;
                3'b010: alu_result <= A_reg & B_reg;
                3'b011: alu_result <= A_reg | B_reg;
                3'b100: alu_result <= A_reg ^ B_reg;
                3'b101: alu_result <= ~(A_reg | B_reg);
                3'b110: alu_result <= (A_reg < B_reg) ? 32'd1 : 32'd0;
                default: alu_result <= 32'd0;
            endcase
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            Result <= 0;
        else
            Result <= alu_result;
    end
endmodule