module traffic_light (
    input clk,
    input rst,
    output reg [2:0] light
);

parameter RED    = 2'd0,
          GREEN  = 2'd1,
          YELLOW = 2'd2;

reg [1:0] state, next_state;

// State Register
always @(posedge clk or posedge rst)
begin
    if (rst)
        state <= RED;
    else
        state <= next_state;
end

// Next State Logic
always @(*)
begin
    case(state)
        RED:    next_state = GREEN;
        GREEN:  next_state = YELLOW;
        YELLOW: next_state = RED;
        default: next_state = RED;
    endcase
end

// Output Logic
always @(*)
begin
    case(state)
        RED:    light = 3'b100;   // Red ON
        GREEN:  light = 3'b001;   // Green ON
        YELLOW: light = 3'b010;   // Yellow ON
        default: light = 3'b100;
    endcase
end

endmodule


