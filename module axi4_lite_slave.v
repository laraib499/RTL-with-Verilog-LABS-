module axi4_lite_slave #( 
    parameter ADDR_WIDTH = 32, 
    parameter DATA_WIDTH = 32, 
    parameter NUM_REGISTERS = 32 
) 
( 
input wire ACLK, 
input wire ARESETN, 
input wire [ADDR_WIDTH-1:0] S_ARADDR, 
input wire S_ARVALID, 
output reg S_ARREADY, 
input wire S_RREADY, 
output reg [DATA_WIDTH-1:0] S_RDATA, 
output reg [1:0] S_RRESP, 
output reg S_RVALID, 
input wire [ADDR_WIDTH-1:0] S_AWADDR, 
input wire S_AWVALID, 
output reg S_AWREADY, 
input wire [DATA_WIDTH-1:0] S_WDATA, 
input wire [3:0] S_WSTRB, 
input wire S_WVALID, 
output reg S_WREADY, 
input wire S_BREADY, 
output reg [1:0] S_BRESP, 
output reg S_BVALID 
); 
localparam IDLE = 3'b000; 
localparam WRITE_ADDR = 3'b001; 
localparam WRITE_DATA = 3'b010; 
localparam WRITE_RESP = 3'b011; 
localparam READ_ADDR = 3'b100; 
localparam READ_DATA = 3'b101; 
reg [2:0] state, next_state; 
reg [ADDR_WIDTH-1:0] addr_reg; 
reg [DATA_WIDTH-1:0] registers [0:NUM_REGISTERS-1]; 
wire write_addr_handshake; 
wire write_data_handshake; 
wire read_addr_handshake; 
wire read_data_handshake; 
assign write_addr_handshake = S_AWVALID && S_AWREADY; 
assign write_data_handshake = S_WVALID && S_WREADY; 
assign read_addr_handshake = S_ARVALID && S_ARREADY; 
assign read_data_handshake = S_RVALID && S_RREADY; 
     
    always @(posedge ACLK or negedge ARESETN) begin 
        if (!ARESETN) begin 
            state <= IDLE; 
        end else begin 
            state <= next_state; 
        end 
    end 
     
    always @(posedge ACLK or negedge ARESETN) begin 
        if (!ARESETN) begin 
            addr_reg <= {ADDR_WIDTH{1'b0}}; 
        end else if (state == READ_ADDR && read_addr_handshake) begin 
            addr_reg <= S_ARADDR; 
        end 
    end 
     
    integer i; 
    always @(posedge ACLK or negedge ARESETN) begin 
        if (!ARESETN) begin 
            for (i = 0; i < NUM_REGISTERS; i = i + 1) begin 
                registers[i] <= {DATA_WIDTH{1'b0}}; 
            end 
        end else begin 
            if (state == WRITE_DATA && write_data_handshake) begin 
                if (S_WSTRB[0]) registers[S_AWADDR][7:0] <= S_WDATA[7:0]; 
                if (S_WSTRB[1]) registers[S_AWADDR][15:8] <= S_WDATA[15:8]; 
                if (S_WSTRB[2]) registers[S_AWADDR][23:16] <= S_WDATA[23:16]; 
                if (S_WSTRB[3]) registers[S_AWADDR][31:24] <= S_WDATA[31:24]; 
            end 
        end 
    end 
     
    always @(*) begin 
        next_state = state; 
        case (state) 
            IDLE: begin 
                if (S_AWVALID) begin 
                    next_state = WRITE_ADDR; 
                end else if (S_ARVALID) begin 
                    next_state = READ_ADDR; 
                end else begin 
                    next_state = IDLE; 
                end 
            end 
            WRITE_ADDR: begin 
                if (write_addr_handshake) begin 
                    next_state = WRITE_DATA; 
                end else begin 
                    next_state = WRITE_ADDR; 
                end 
            end 
            WRITE_DATA: begin 
                if (write_data_handshake) begin 
                    next_state = WRITE_RESP; 
                end else begin 
                    next_state = WRITE_DATA; 
                end 
            end 
            WRITE_RESP: begin 
                if (S_BVALID && S_BREADY) begin 
                    next_state = IDLE; 
                end else begin 
                    next_state = WRITE_RESP; 
                end 
            end 
            READ_ADDR: begin 
                if (read_addr_handshake) begin 
                    next_state = READ_DATA; 
                end else begin 
                    next_state = READ_ADDR; 
                end 
            end 
            READ_DATA: begin 
                if (read_data_handshake) begin 
                    next_state = IDLE; 
                end else begin 
                    next_state = READ_DATA; 
                end 
            end 
            default: next_state = IDLE; 
        endcase 
    end 
     
    always @(*) begin 
        S_ARREADY = 1'b0; 
        S_RDATA = {DATA_WIDTH{1'b0}}; 
        S_RRESP = 2'b00; 
        S_RVALID = 1'b0; 
        S_AWREADY = 1'b0; 
        S_WREADY = 1'b0; 
        S_BRESP = 2'b00; 
        S_BVALID = 1'b0; 
         
        case (state) 
            WRITE_ADDR: begin 
                S_AWREADY = 1'b1; 
                S_WREADY = 1'b1; 
            end 
            WRITE_DATA: begin 
                S_WREADY = 1'b1; 
                S_BVALID = 1'b1; 
                S_BRESP = 2'b00; 
            end 
            WRITE_RESP: begin 
                S_BVALID = 1'b1; 
                S_BRESP = 2'b00; 
            end 
            READ_ADDR: begin 
                S_ARREADY = 1'b1; 
                S_RVALID = 1'b1; 
                S_RDATA = registers[addr_reg]; 
                S_RRESP = 2'b00; 
            end 
            READ_DATA: begin 
                S_RVALID = 1'b1; 
                S_RDATA = registers[addr_reg]; 
                S_RRESP = 2'b00; 
            end 
            default: begin 
            end 
        endcase 
    end 
 
endmodule