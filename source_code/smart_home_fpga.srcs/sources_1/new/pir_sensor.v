
module pir_sensor 
#(clk_div_width=28, // For creating a slow clock from 100 MHz
  STATE_COUNT=4     //total states
  )  
(
input clk, S0, S1, S2,
output [2:0] sensor,
output reg led,
output logic [STATE_COUNT-1:0] state_active
);
 
// State machine
enum {FIRST, SECOND, THIRD, FOURTH} state, next_state;

//sensor values displayed
assign sensor[0] = S0;
assign sensor[1] = S1;
assign sensor[2] = S2;

// Clock divider
logic clk_slow;
logic [clk_div_width-1:0] clk_div;

always @(posedge clk)
    if(clk_div < 210000000) clk_div = clk_div + 1;   // 2 seconds clock cycle
	else clk_div = 0;

assign clk_slow = clk_div[clk_div_width-1];

//FSM
always @(posedge clk_slow)
	state <= next_state;   //change state in every 2 seconds

always_comb begin
	next_state = state;
	unique case (state)
		FIRST: begin
			state_active = 1<<0;
			if (S0) begin        //sensor 1 detected
				next_state = SECOND;
		    end
		end
		SECOND: begin
			state_active = 1<<1;

			if (S1) begin    //sensor 2 detected
				next_state = THIRD;
			end
			else if(S0) begin    //sensor 1 detected
			     next_state = FIRST;
			     led <= 1'b0;    //LED switched OFF
			end
		end
		THIRD: begin
			state_active = 1<<2;
			if (S2) begin    //sensor 3 detected
			     next_state = FOURTH;
			end
			else if(S1) begin    //sensor 2 detected
			     next_state = SECOND;
			end
		end
		FOURTH: begin
		    led <= 1'b1;      //LED illuminated
			state_active = 1<<3;
			if(S2) begin     //sensor 3 detected
			     next_state = THIRD;
			end
		end
	endcase
end


endmodule