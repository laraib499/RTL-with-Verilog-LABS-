timescale 1ns / 1ps 
module axi4_lite_master #( 
parameter ADDR_WIDTH = 32, 
parameter DATA_WIDTH = 32 
) 
( 
input wire ACLK, 
input wire ARESETN, 
input wire START_READ, 
input wire START_WRITE, 
input wire [ADDR_WIDTH-1:0] address, 
input wire [DATA_WIDTH-1:0] W_data, 
output wire [DATA_WIDTH-1:0] R_data, 
output wire READ_COMPLETE, 
output wire WRITE_COMPLETE, 
input wire M_ARREADY, 
output reg [ADDR_WIDTH-1:0] M_ARADDR, 
output reg M_ARVALID, 
input wire [DATA_WIDTH-1:0] M_RDATA, 
input wire [1:0] M_RRESP, 
input wire M_RVALID, 
output reg M_RREADY, 
input wire M_AWREADY, 
output reg [ADDR_WIDTH-1:0] M_AWADDR, 
output reg M_AWVALID, 
input wire M_WREADY, 
output reg [DATA_WIDTH-1:0] M_WDATA, 
output reg [3:0] M_WSTRB, 
output reg M_WVALID, 
input wire [1:0] M_BRESP, 
input wire M_BVALID, 
output reg M_BREADY 
); 
localparam IDLE = 3'b000; 
localparam WRITE_ADDR = 3'b001; 
localparam WRITE_DATA = 3'b010; 
localparam WRITE_RESP = 3'b011; 
localparam READ_ADDR = 3'b100; 
localparam READ_DATA = 3'b101; 
reg [2:0] state, next_state; 
reg read_start_reg, write_start_reg; 
reg [DATA_WIDTH-1:0] rdata_reg; 
assign R_data = rdata_reg; 
assign READ_COMPLETE = (state == READ_DATA) && M_RVALID && M_RREADY; 
    assign WRITE_COMPLETE = (state == WRITE_RESP) && M_BVALID && M_BREADY; 
     
    always @(posedge ACLK or negedge ARESETN) begin 
        if (!ARESETN) begin 
            state <= IDLE; 
        end else begin 
            state <= next_state; 
        end 
    end 
     
    always @(posedge ACLK or negedge ARESETN) begin 
        if (!ARESETN) begin 
            read_start_reg <= 1'b0; 
            write_start_reg <= 1'b0; 
        end else begin 
            read_start_reg <= START_READ; 
            write_start_reg <= START_WRITE; 
        end 
    end 
     
    always @(posedge ACLK or negedge ARESETN) begin 
        if (!ARESETN) begin 
            rdata_reg <= {DATA_WIDTH{1'b0}}; 
        end else if (state == READ_DATA && M_RVALID && M_RREADY) begin 
            rdata_reg <= M_RDATA; 
        end 
    end 
     
    always @(*) begin 
        next_state = state; 
        case (state) 
            IDLE: begin 
                if (write_start_reg) begin 
                    next_state = WRITE_ADDR; 
                end else if (read_start_reg) begin 
                    next_state = READ_ADDR; 
                end else begin 
                    next_state = IDLE; 
                end 
            end 
            WRITE_ADDR: begin 
                if (M_AWVALID && M_AWREADY) begin 
                    next_state = WRITE_DATA; 
                end else begin 
                    next_state = WRITE_ADDR; 
                end 
            end 
            WRITE_DATA: begin 
                if (M_WVALID && M_WREADY) begin 
                    next_state = WRITE_RESP; 
                end else begin 
                    next_state = WRITE_DATA; 
                end 
            end 
            WRITE_RESP: begin 
                if (M_BVALID && M_BREADY) begin 
                    next_state = IDLE; 
                end else begin 
                    next_state = WRITE_RESP; 
                end 
            end 
            READ_ADDR: begin 
                if (M_ARVALID && M_ARREADY) begin 
                    next_state = READ_DATA; 
                end else begin 
                    next_state = READ_ADDR; 
                end 
            end 
            READ_DATA: begin 
                if (M_RVALID && M_RREADY) begin 
                    next_state = IDLE; 
                end else begin 
                    next_state = READ_DATA; 
                end 
            end 
            default: next_state = IDLE; 
        endcase 
    end 
     
    always @(*) begin 
        M_ARADDR = {ADDR_WIDTH{1'b0}}; 
        M_ARVALID = 1'b0; 
        M_RREADY = 1'b0; 
        M_AWADDR = {ADDR_WIDTH{1'b0}}; 
        M_AWVALID = 1'b0; 
        M_WDATA = {DATA_WIDTH{1'b0}}; 
        M_WSTRB = 4'b0000; 
        M_WVALID = 1'b0; 
        M_BREADY = 1'b0; 
         
        case (state) 
            WRITE_ADDR: begin 
                M_AWADDR = address; 
                M_AWVALID = 1'b1; 
                M_BREADY = 1'b1; 
            end 
            WRITE_DATA: begin 
                M_WDATA = W_data; 
                M_WSTRB = 4'b1111; 
                M_WVALID = 1'b1; 
                M_BREADY = 1'b1; 
            end 
            WRITE_RESP: begin 
                M_BREADY = 1'b1; 
            end 
            READ_ADDR: begin 
                M_ARADDR = address; 
                M_ARVALID = 1'b1; 
                M_RREADY = 1'b1; 
            end 
            READ_DATA: begin 
                M_RREADY = 1'b1; 
            end 
            default: begin 
            end 
        endcase 
    end 
 
endmodule 