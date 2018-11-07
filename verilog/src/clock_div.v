`timescale 1ns / 1ps

`define DIV_CONST 4

/* clock_div
    divide clock by factor of 2
    
    Inputs:
        clk_i       : input clock signal
        rst_        : asynchronous reset (active low)
    
    Outputs:
        clk_o       : output clock signal
*/
module clock_div(
    input               clk_i,
    input               rst_,
    output reg          clk_o
    );
    
    // To Count Clock Periods
    reg counter;
    
    always@(posedge clk_i or negedge rst_)
    begin
        if (rst_ == 1'b0)
        begin
            clk_o   <= 0;
            counter <= 2'b1;
        end
        
        else 
        begin
            if (counter == ((`DIV_CONST / 2) - 1))
            begin
                clk_o   <= ~clk_o;
                counter <= 0;
            end
            
            else
            begin
                counter <= counter + 1;
            end
        end
        
    end
    
endmodule