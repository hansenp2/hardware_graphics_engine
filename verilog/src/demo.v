`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2019 03:55:09 PM
// Design Name: 
// Module Name: demo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module demo(
    input clk,
    input rst_,
    input mode,
    output reg [51:0] command
    );
    
    reg temp;
    
    always @ (posedge clk or negedge rst_) 
    begin
        if(!rst_)
        begin
            command <= 1;
            temp <= 0;
        end
        else
        begin
            if (mode)
            begin
                /*LFSR Logic*/
                temp <= command[51] ~^ command[48];
                command <= { command[50:0],temp};
            end
        end
    
    end
    
    
endmodule
