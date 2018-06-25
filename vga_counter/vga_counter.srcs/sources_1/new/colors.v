`timescale 1ns / 1ps

module colors(
    input clock, reset,
    output reg [3:0] red,
    output reg [3:0] green,
    output reg [3:0] blue
    );
    
    
    // VGA Color Analog Signals
    // 4-bit Color, 0 - 15 Digital
    // 4-bit Color, 0 - 0.7V Analog
    
    always@(posedge clock, negedge reset)
    begin
        if (reset == 1'b0)
        begin
            red <= 0;
            green <= 0;
            blue <= 0;
        end
        
        else
        begin
            red <= 4'b0000;
            green <= 4'b0000;
            blue <= 4'b1000;
        end
    end
    
endmodule
