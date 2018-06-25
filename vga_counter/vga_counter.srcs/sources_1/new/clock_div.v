`timescale 1ns / 1ps

`define DIV_CONST 4

module clock_div(
    input clk_i,
    input reset,
    output reg clk_o
    );
    
    reg counter;
    
    always@(posedge clk_i, negedge reset)
    begin
        if (reset == 1'b0)
        begin
            clk_o <= 0;
            counter <= 2'b1;
        end
        
        else 
        begin
            if (counter == ((`DIV_CONST/2)-1))
            begin
                clk_o <= ~clk_o;
                counter <= 0;
            end
            
            else
            begin
                counter <= counter + 1;
            end
        end
        
    end
    
endmodule