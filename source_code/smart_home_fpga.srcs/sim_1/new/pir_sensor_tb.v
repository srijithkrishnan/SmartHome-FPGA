`timescale 1ns / 1ps


module pir_sensor_tb();
    reg clk=0;
    reg S0;
    reg S1;
    reg S2;
    wire led;
    wire [2:0] sensor;
    wire [3:0] state_active;

pir_sensor CUT(
    .clk(clk),
    .S0(S0),
    .S1(S1),
    .S2(S2),
    .led(led),
    .sensor(sensor),
    .state_active(state_active) 
);

    always #5 clk =~clk;
    
    initial begin
    

    
    
    assign S0 =0;
    assign S1 =0;
    assign S2 =0;
    #20
  
    //each sensor stays in logic 1 for 3 seconds
    assign S0=1;
    #2000000000
    #1000000000
    assign S0=0;
    #5
    assign S1=1;
    #2000000000
    #1000000000
    assign S1=0;
    #5
    assign S2=1;
    #2000000000
    #1000000000
    assign S2=0;   
    #20
    assign S2=1;
    #2000000000
    #1000000000
    assign S2=0; 
    #5
    assign S1=1;
    #2000000000
    #1000000000
    assign S1=0;
    #5
    assign S0=1;
    #2000000000
    #1000000000
    assign S0=0;

    $finish;
    
    end

endmodule