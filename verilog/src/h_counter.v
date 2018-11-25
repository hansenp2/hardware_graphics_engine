`timescale 1ns / 1ps

// HORIZONTAL MACROS  
`define H_FRONT_PORCH   16
`define H_SYNC          96
`define H_BACK_PORCH    48
`define H_ACTIVE        640

/* h_counter
    produces horizontal sync signal
    
    Inputs:
        clk         : pixel clock at 25 MHz
        rst_        : asynchronous reset (active low)
        enable      : display driver enable (active high)
    
    Outputs:
        h_sync      : h sync signal (pulsed low)
        h_active    : indicates active period of horizontal signal
        end_line    : indicates end of line
        h_counter   : counting pixels 0 to 799 (10-bits)
*/
module h_counter(
    input               clk,
    input               rst_,
    input               enable,
    
    output reg          h_sync,
    output reg          h_active,
    output reg          end_line,
    output reg  [9:0]   h_counter
    );
    
    always@(posedge clk or negedge rst_)
    begin
    
        if (rst_ == 1'b0)
        begin
            h_counter   <= 0;
            h_sync      <= 1;
            h_active    <= 0;
            end_line    <= 0;
        end
    
        else if (rst_ == 1'b1 && enable == 1'b1)
        begin
                        
            // Front Porch (0 <= C < 16)
            if (h_counter >= 0 && h_counter < (`H_FRONT_PORCH))
            begin
                h_sync      <= 1'b1;    
                h_active    <= 1'b0;  
                end_line    <= 1'b0;  
                h_counter   <= h_counter + 1;
            end
            
            // Sync (16 <= C < 112)
            else if (h_counter >= (`H_FRONT_PORCH)  && h_counter < (`H_FRONT_PORCH + `H_SYNC))   
            begin
                h_sync      <= 1'b0;
                h_active    <= 1'b0;  
                end_line    <= 1'b0;                
                h_counter   <= h_counter + 1;
            end
            
            // Back Porch (112 <= C < 160)
            else if (h_counter >= (`H_FRONT_PORCH + `H_SYNC) && h_counter < (`H_FRONT_PORCH + `H_SYNC + `H_BACK_PORCH))
            begin
                h_sync      <= 1'b1;
                h_active    <= 1'b0;  
                end_line    <= 1'b0;                
                h_counter   <= h_counter + 1;
            end
            
            // Active Video (168 <= C < 799)
            else if (h_counter >= (`H_FRONT_PORCH + `H_SYNC + `H_BACK_PORCH) && h_counter < (`H_FRONT_PORCH + `H_SYNC + `H_BACK_PORCH + `H_ACTIVE - 1))
            begin
                h_sync      <= 1'b1;
                h_active    <= 1'b1;  
                end_line    <= 1'b0;                
                h_counter   <= h_counter + 1;
            end
            
            // End of Line (C == 799)
            else if (h_counter == (`H_FRONT_PORCH + `H_SYNC + `H_BACK_PORCH + `H_ACTIVE - 1))
            begin
                h_sync      <= 1'b1;
                h_active    <= 1'b1;  
                end_line    <= 1'b1;
                h_counter   <= 0; 
            end 
            
        end
         
    end
    
endmodule
