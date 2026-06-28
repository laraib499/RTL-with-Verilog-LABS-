module async_down_counter_4bit(
    input clk,
    input rst,
    output reg [3:0] q
);
always @(posedge clk or posedge rst)
begin
    if (rst)
        q[0] <= 1'b1;
    else
        q[0] <= ~q[0];
end
always @(posedge q[0] or posedge rst)
begin
    if (rst)
        q[1] <= 1'b1;
    else
        q[1] <= ~q[1];
end
always @(posedge q[1] or posedge rst)
begin
    if (rst)
        q[2] <= 1'b1;
    else
        q[2] <= ~q[2];
end
always @(posedge q[2] or posedge rst)
begin
    if (rst)
        q[3] <= 1'b1;
    else
        q[3] <= ~q[3];
end
endmodule