module ps2_receiver(
    input ps2_clk,
    input rst,
    input ps2_data,

    output reg [7:0] scan_code,
    output reg data_valid,
    output reg parity_error,
    output reg frame_error
);

reg [3:0] bit_count;
reg [7:0] data_reg;
reg parity;

reg [1:0] state;

localparam IDLE   = 2'd0;
localparam DATA   = 2'd1;
localparam PARITY = 2'd2;
localparam STOP   = 2'd3;

always @(negedge ps2_clk or posedge rst)
begin
    if(rst)
    begin
        state <= IDLE;
        bit_count <= 0;
        data_reg <= 0;
        scan_code <= 0;
        data_valid <= 0;
        parity_error <= 0;
        frame_error <= 0;
    end
    else
    begin
        data_valid <= 0;

        case(state)

        //---------------------------------
        // Wait for Start Bit
        //---------------------------------
        IDLE:
        begin
            if(ps2_data == 0)
            begin
                bit_count <= 0;
                parity_error <= 0;
                frame_error <= 0;
                state <= DATA;
            end
        end

        //---------------------------------
        // Receive 8 Data Bits (LSB First)
        //---------------------------------
        DATA:
        begin
            data_reg[bit_count] <= ps2_data;

            if(bit_count == 7)
                state <= PARITY;
            else
                bit_count <= bit_count + 1;
        end

        //---------------------------------
        // Receive Parity Bit
        //---------------------------------
        PARITY:
        begin
            parity <= ps2_data;

            if((^data_reg) == ps2_data)
                parity_error <= 1;

            state <= STOP;
        end

        //---------------------------------
        // Receive Stop Bit
        //---------------------------------
        STOP:
        begin
            if(ps2_data != 1'b1)
                frame_error <= 1;

            scan_code <= data_reg;
            data_valid <= 1;
            state <= IDLE;
        end

        endcase
    end
end
endmodule



