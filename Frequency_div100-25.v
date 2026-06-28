module freq_div_100_to_25(
    input clk,
    input rst,
    output reg clk_out
);

reg [1:0] count;

always @(posedge clk or posedge rst)
begin
    if (rst) begin
        count   <= 2'b00;
        clk_out <= 1'b0;
    end
    else begin
        count <= count + 1'b1;

        if(count == 2'b11)
            clk_out <= ~clk_out;
    end
end

endmodule