module seq1101 (
    input clk,
    input rst,
    input x,
    output reg y
);

parameter S0 = 3'd0,
          S1 = 3'd1,
          S2 = 3'd2,
          S3 = 3'd3,
          S4 = 3'd4;

reg [2:0] state, next_state;

// State Register
always @(posedge clk or posedge rst)
begin
    if (rst)
        state <= S0;
    else
        state <= next_state;
end

// Next State Logic
always @(*)
begin
    case(state)
        S0: next_state = (x) ? S1 : S0;
        S1: next_state = (x) ? S2 : S0;
        S2: next_state = (x) ? S2 : S3;
        S3: next_state = (x) ? S4 : S0;
        S4: next_state = (x) ? S2 : S0;
        default: next_state = S0;
    endcase
end

// Output Logic (Moore)
always @(*)
begin
    case(state)
        S4: y = 1'b1;
        default: y = 1'b0;
    endcase
end

endmodule


