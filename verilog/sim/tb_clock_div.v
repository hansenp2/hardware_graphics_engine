`timescale 1ns / 1ps

module tb_clock_div;

    reg clk_i;
    reg reset;
    
    wire clk_o;
    wire counter;
    
    clock_div uut (
        .clk_i(clk_i),
        .reset(reset),
        .clk_o(clk_o),
        .counter(counter)
    );
    
    initial begin
    
        clk_i = 0;
        reset = 1;
        
        #10 reset = ~reset;
        #10 reset = ~reset;
        
        begin
            repeat(64)
            begin
                #5 clk_i = ~clk_i;
            end
        end
    
    end

endmodule
