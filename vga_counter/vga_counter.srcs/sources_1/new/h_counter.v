`timescale 1ns / 1ps

// HORIZONTAL MACROS
`define H_FRONT_PORCH   16
`define H_SYNC          96
`define H_BACK_PORCH    48
`define H_ACTIVE        640

module h_counter(
    input       clock,
    input       reset,
    input       enable,
    
    output reg  h_sync,
    output reg  end_line
    // output reg [9:0] h_counter
    );
    
    // 10-bit Counter (Counting from 0 to 799)
     reg [9:0] h_counter;
    
    always@(posedge clock, negedge reset)
    begin
    
        if (reset == 1'b0)
        begin
            h_counter   <= 10'b1111111111;
            h_sync      <= 1;
            end_line    <= 0;
        end
    
        else if (reset == 1'b1 && enable == 1'b1)
        begin
            h_counter <= h_counter + 1;
            
            // 0 <= C <= 47
            if (h_counter >= 0 && h_counter < (`H_FRONT_PORCH - 1))
            begin
                h_sync      <= 1'b1;      
                end_line    <= 1'b0;  
            end
            
            // 48 <= C <= 143
            else if (h_counter >= (`H_FRONT_PORCH - 1) && h_counter < (`H_FRONT_PORCH + `H_SYNC - 1))   
            begin
                h_sync      <= 1'b0;
                end_line    <= 1'b0;
            end
            
            // 144 <= C <= 159
            else if (h_counter >= (`H_FRONT_PORCH + `H_SYNC - 1) && h_counter < (`H_FRONT_PORCH + `H_SYNC + `H_FRONT_PORCH - 1))
            begin
                h_sync      <= 1'b1;
                end_line    <= 1'b0;
            end
            
            // 160 <= C < 799
            else if (h_counter >= (`H_FRONT_PORCH + `H_SYNC + `H_FRONT_PORCH - 1) && h_counter < (`H_FRONT_PORCH + `H_SYNC + `H_FRONT_PORCH + `H_ACTIVE - 1))
            begin
                h_sync      <= 1'b1;
                end_line    <= 1'b0;
            end
            
            // C == 799
            else if (h_counter == `H_FRONT_PORCH + `H_SYNC + `H_BACK_PORCH + `H_ACTIVE - 1)
            begin
                h_sync      <= 1'b1;
                end_line    <= 1'b1;
                h_counter   <= 0; 
            end
            
        end
         
    end
    
endmodule
