`timescale 1ns / 1ps


module pwm_tb();
    integer k;
    reg clk=0;
    wire pwm;
    wire IN3;
    wire IN4;
    reg [1:0]temp_variable;





motor_driver CUT(
    .clk(clk),
    .temp_variable(temp_variable),
    .IN3(IN3),
    .IN4(IN4),
    .pwm(pwm)
);

    always #5 clk =~clk;
    
    initial begin    
    
    for(k=0;k<3;k=k+1)begin
        temp_variable = k;
        #10000;
    end
    $finish;
    
    
    end

endmodule