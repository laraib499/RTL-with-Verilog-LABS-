module sync_fifo (

    input clk,

    input rst,

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


    reg [4:0] cnt;


    always @(posedge clk) begin

        if (rst) begin

            wr_ptr   <= 0;
            rd_ptr   <= 0;

            cnt      <= 0;

            data_out <= 0;

            full     <= 0;
            empty    <= 1;

        end


        else begin

            // WRITE
            if (wr && !full) begin

                mem[wr_ptr] <= data_in;

                wr_ptr <= wr_ptr + 1;

            end


            // READ
            if (rd && !empty) begin

                data_out <= mem[rd_ptr];

                rd_ptr <= rd_ptr + 1;

            end


            // COUNT
            case ({wr && !full, rd && !empty})

                2'b10: cnt <= cnt + 1;

                2'b01: cnt <= cnt - 1;

                default: cnt <= cnt;

            endcase


            // FULL
            if (cnt == 15)
                full <= 1;

            else
                full <= 0;


            // EMPTY
            if (cnt == 0)
                empty <= 1;

            else
                empty <= 0;

        end

    end



