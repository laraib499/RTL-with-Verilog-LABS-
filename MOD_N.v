module mod_n_counter #(
    parameter N = 6
)(
    input clk,
    input rst,
    output reg [2:0] q
);

always @(posedge clk or posedge rst)
begin
    if (rst)
        q <= 0;
    else if (q == N-1)
        q <= 0;
    else
        q <= q + 1;
end

endmodule