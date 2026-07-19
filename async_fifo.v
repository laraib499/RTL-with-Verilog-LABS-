module async_fifo ( 
input wr_clk, 
input rd_clk, 
input wr_rst, 
input rd_rst, 
input wr, 
input rd, 
input [7:0] data_in, 
output reg [7:0] data_out, 
output reg full, 
output reg empty 
); 
reg [7:0] mem [0:15]; 
reg [2:0] wr_ptr; 
reg [2:0] rd_ptr; 
reg [3:0] cnt; 
// WRITE SIDE 
always @(posedge wr_clk) begin 
if (wr_rst) begin 
wr_ptr <= 0; 
cnt    <= 0; 
full   <= 0; 
end 
else if (wr && !full) begin 
mem[wr_ptr] <= data_in; 
wr_ptr <= wr_ptr + 1; 
cnt <= cnt + 1; 
end 
end 
// READ SIDE 
always @(posedge rd_clk) begin 
if (rd_rst) begin 
rd_ptr   <= 0; 
data_out <= 0; 
empty    <= 1; 
end 
else if (rd && !empty) begin 
data_out <= mem[rd_ptr]; 
rd_ptr <= rd_ptr + 1; 
cnt <= cnt - 1; 
end 
end 
endmodule




