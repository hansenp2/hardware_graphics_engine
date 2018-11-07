`timescale 1ns / 1ps

/* colors
    produces color component signal
    
    VGA Color Analog Signals (4-bit Color) 
    0 - 15 Digital
    0 - 0.7V Analog
    
    Inputs: 
        rst_        : asynchronous reset (active low) 
        test_mode   : active test mode for display controller
        h_active    : active period for horizontal
        v_active    : active period for vertical
        h_counter   : counting number of pixels per line (10-bits)
        v_counter   : counting number of lines (10-bits)
    
    Outputs:
        red         : red color component (4-bits)
        green       : green color component (4-bits)
        blue        : blue color component (4-bits)
*/
module colors( 
    input               clk, rst_,
    input               test_mode, 
    input               next_test,
    input               h_active, 
    input               v_active, 
    input       [9:0]   h_counter,
    input       [9:0]   v_counter,
    
    input       [11:0]  current_pixel,      // this line is only change to this file
    output reg  [3:0]   red,
    output reg  [3:0]   green,
    output reg  [3:0]   blue
    );   
    
    reg test_num;
    
//    always@(h_active, v_active, h_counter, v_counter, test_mode, next_test, rst_)
    always@(posedge clk or negedge rst_)
    begin
        if (rst_ == 1'b0)
        begin
            red         <= 0;
            green       <= 0;
            blue        <= 0; 
            test_num    <= 0;
        end
        
        else
        begin
            if (h_active == 1'b1 && v_active == 1'b1)
            begin
                if (test_mode == 1'b0)
                begin
                    red     <= current_pixel[11:8];    // 4'b1111;
                    green   <= current_pixel[7:4];     // 4'b0111;
                    blue    <= current_pixel[3:0];     // 4'b0000;
                end
                
                // Test Patterns
                else 
                begin
                    if (test_num == 1'b0)
                    begin
                        if (next_test) test_num <= 1'b1;
                
//                        if      (h_counter >=   0 && h_counter <=  79) begin red <= 4'b0000; green <= 4'b0000; blue <= 4'b0000; end                    
//                        else if (h_counter >=  80 && h_counter <= 159) begin red <= 4'b1111; green <= 4'b1111; blue <= 4'b1111; end                    
//                        else if (h_counter >= 160 && h_counter <= 239) begin red <= 4'b1111; green <= 4'b0000; blue <= 4'b0000; end                    
//                        else if (h_counter >= 240 && h_counter <= 319) begin red <= 4'b1111; green <= 4'b1111; blue <= 4'b0000; end                    
//                        else if (h_counter >= 320 && h_counter <= 399) begin red <= 4'b0000; green <= 4'b1111; blue <= 4'b0000; end                    
//                        else if (h_counter >= 400 && h_counter <= 479) begin red <= 4'b0000; green <= 4'b1111; blue <= 4'b1111; end                    
//                        else if (h_counter >= 480 && h_counter <= 559) begin red <= 4'b0000; green <= 4'b0000; blue <= 4'b1111; end                    
//                        else if (h_counter >= 560 && h_counter <= 639) begin red <= 4'b1111; green <= 4'b0000; blue <= 4'b1111; end
                        
                        if      (h_counter >= 160 && h_counter <= 239) begin red <= 4'b0000; green <= 4'b0000; blue <= 4'b0000; end                    
                        else if (h_counter >= 240 && h_counter <= 319) begin red <= 4'b1111; green <= 4'b1111; blue <= 4'b1111; end                    
                        else if (h_counter >= 320 && h_counter <= 399) begin red <= 4'b1111; green <= 4'b0000; blue <= 4'b0000; end                    
                        else if (h_counter >= 400 && h_counter <= 479) begin red <= 4'b1111; green <= 4'b1111; blue <= 4'b0000; end                    
                        else if (h_counter >= 480 && h_counter <= 559) begin red <= 4'b0000; green <= 4'b1111; blue <= 4'b0000; end                    
                        else if (h_counter >= 560 && h_counter <= 639) begin red <= 4'b0000; green <= 4'b1111; blue <= 4'b1111; end                    
                        else if (h_counter >= 640 && h_counter <= 719) begin red <= 4'b0000; green <= 4'b0000; blue <= 4'b1111; end                    
                        else                                           begin red <= 4'b1111; green <= 4'b0000; blue <= 4'b1111; end 
                        
                    end
                    
                    else if (test_num == 1'b1)
                    begin
                        if (next_test) test_num <= 1'b0;
                        
                        red <= 4'b0000; green <= 4'b1111; blue <= 4'b0111;
                    end
                    
                end
                
            end
            
            else 
            begin
                red     <= 4'b0000;
                green   <= 4'b0000;
                blue    <= 4'b0000;
            end
        end
    end
    
endmodule
