
module vending_machine(
    input clk,
    input rst,
    input coin5,
    input coin10,
    output reg dispense
);


// State declaration
parameter IDLE     = 2'd0,
          FIVE     = 2'd1,
          DISPENSE = 2'd2;


reg [1:0] state, next_state;


//==============================
// 1. State Register
//==============================

always @(posedge clk or posedge rst)
begin
    if(rst)
        state <= IDLE;
    else
        state <= next_state;
end



//==============================
// 2. Next State Logic
//==============================

always @(*)
begin

    case(state)

        IDLE:
        begin
            if(coin10)
                next_state = DISPENSE;

            else if(coin5)
                next_state = FIVE;

            else
                next_state = IDLE;
        end


        FIVE:
        begin
            if(coin5)
                next_state = DISPENSE;

            else
                next_state = FIVE;
        end


        DISPENSE:
        begin
            next_state = IDLE;
        end


        default:
            next_state = IDLE;

    endcase

end



//==============================
// 3. Output Logic
//==============================

always @(*)
begin

    case(state)

        DISPENSE:
            dispense = 1'b1;

        default:
            dispense = 1'b0;

    endcase

end


endmodule