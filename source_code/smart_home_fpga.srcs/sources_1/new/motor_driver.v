
module motor_driver(
    input clk, 
    input  [1:0]temp_variable,  //temperature variable passed from wrapper module
    output IN4, IN3,
    output reg pwm
    );
    
//counter to reduce the clock cycle
reg [15:0] counter;


always@(posedge clk) begin
    if(counter < 5000) counter <= counter + 1;   //clock signal reduced to 20KHz from 100Mhz
    else counter <= 0;
end

// deciding the motor rotation clockwise
assign IN3 = 1'b1;
assign IN4 = 1'b0;

always @(*) begin
    if(temp_variable == 2'b10)   pwm = (counter<5000) ? 1 : 0; //maximum duty cycle
    else if(temp_variable == 2'b01)   pwm = (counter<4000) ? 1 : 0; //reduced duty cycle
    else if(temp_variable == 2'b00)  pwm = 0;
end

endmodule
