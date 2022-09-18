//top module
module smart_wrapper(
    input clk, rst,
    input S0, S1, S2,
    inout one_wire,
    input [15:0] bcd,
    output reg [3:0]D0_AN,
    output reg [0:7]D0_SEG,
    output reg pwm,
    output reg RGB,
    output [2:0] sensor,
    output IN3, IN4,
    output logic [3:0] state_active
);


//Motion sensor direction detection and light control
pir_sensor pir_sensor(
    .clk(clk),
    .S0(S0),
    .S1(S1),
    .S2(S2),
    .sensor(sensor),
    .led(RGB),
    .state_active(state_active)
);

//DS18B20 temperature sensor configuration and digital temperature display
ds18b20 ds18b20(
    .clk(clk),
    .rst(rst),
    .D0_AN(D0_AN),
    .bcd(bcd),
    .one_wire(one_wire),
    .D0_SEG(D0_SEG)
);
//wire [15:0]bcd;
reg [1:0] temp_driver = 2'b00; // temperature value to decide motor driver speed

always @(posedge clk) begin
    if((RGB == 1'b1))begin
        if((bcd[3:0] > 4'd6) && (bcd[7:4] > 2'd1)) temp_driver <= 2'b10;
        else if(((bcd[3:0] > 4'd3)|| (bcd[3:0] < 4'd6)) && (bcd[7:4] > 2'd1)) temp_driver <= 2'b01;
        else temp_driver <= 2'b00;
    end
    else temp_driver <= 2'b00;
    
end

//generate pwm signal to control the speed of a DC motor
motor_driver motor_driver(
 .clk(clk),      
 .temp_variable(temp_driver), 
 .IN4(IN4),
 .IN3(IN3),
 .pwm(pwm)
);

endmodule