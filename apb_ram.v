module apb_ram (
    input  presetn,
    input  pclk,
    input  psel,
    input  penable,
    input  pwrite,
    input  [31:0] paddr,
    input  [31:0] pwdata,
    output reg [31:0] prdata,
    output reg pready,
    output reg pslverr
);

reg [31:0] mem [32];

    // Based on Image 4
    typedef enum {idle = 0, setup = 1, access = 2, transfer = 3} state_type;
    state_type state = idle;

    always @(posedge pclk or negedge presetn) begin
        // Reset logic (implied by presetn input, added to complete the code)
        if (!presetn) begin
            state    <= idle;
            pready   <= 1'b0;
            pslverr  <= 1'b0;
            prdata   <= 32'h00000000;
        end
        else begin
            case (state)
                // From Image 3
                idle: begin
                    prdata   <= 32'h00000000;
                    pready   <= 1'b0;
                    pslverr  <= 1'b0;
                    state    <= setup;
                end

                // From Image 3 and Image 2
                setup: begin // ///start of transaction
                    // Added psel to the condition to make standard APB logic
                    if (psel && penable) begin
                        if (pwrite) begin
                            mem[paddr] <= pwdata;
                            state      <= transfer;
                            pslverr    <= 1'b0;
                            pready     <= 1'b1;
                        end
                        else if (!pwrite) begin
                            if (paddr < 32) begin
                                prdata     <= mem[paddr];
                                state      <= transfer;
                                pready     <= 1'b1;
                                pslverr    <= 1'b0;
                            end
                            else begin
                                // Out of bounds read (Implied by the if(paddr < 32), completed here)
                                prdata     <= 32'h00000000;
                                state      <= transfer;
                                pready     <= 1'b1;
                                pslverr    <= 1'b1;
                            end
                        end
                        else begin
                            // Wait state if psel/penable not active
                            state <= setup;
                        end
                    end
                end

                // From Image 1
                access: begin
                    state    <= setup;
                    pready   <= 1'b0;
                    pslverr  <= 1'b0;
                end

                // transfer state logic (Needs to be defined to complete the FSM)
                transfer: begin
                    state    <= idle;
                    pready   <= 1'b0;
                    pslverr  <= 1'b0;
                end

                // From Image 1
                default: begin
                    state <= idle;
                end
            endcase
        end
    end

endmodule

