module bcd_counter(
    input clk,
    input rst,
    output reg [3:0] q
);

always @(posedge clk or posedge rst)
begin
    if (rst)
        q <= 4'd0;
    else if (q == 4'd9)
        q <= 4'd0;
    else
        q <= q + 1'b1;
end

endmodule