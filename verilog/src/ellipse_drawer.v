`timescale 1ns / 1ps

module ellipse_drawer(
    input clk,
    input rst_,
    
    input [9:0] x0_in, y0_in,
    input [9:0] a_in, b_in
);

    // Ellipse Variables
    reg [9:0] x, y;
    reg signed [15:0] d1, d2;
    
    // Temporary Variables
    wire signed [15:0] t1, t2, t3;
    wire signed [15:0] t4, t5, t6, t7;
    reg  signed [15:0] t8, t9;
    reg [1:0] state;
    
    // State Machine
    always @ (posedge clk or negedge rst_)
    begin
        if (!rst_)
        begin
            state <= 2'b00;
            x     <= 0;
            y     <= 0;
            d1    <= 0;
            d2    <= 0;
            t8    <= 0;
            t9    <= 0;
        end
            
        else
        begin
            // start state
            if (state == 2'b00)
                state <= 2'b01;
                
            // draw state
            else if (state == 2'b01)
                state <= (d2 < 0) ? (2'b01) : (2'b10); 
                
            // draw state
            else if (state == 2'b10)
                state <= (x != 0) ? (2'b10) : (2'b11); 

            // end state
            else if (state == 2'b11)
                state <= 2'b11;
        end 
    end
    
    // Drawing Engine  
    assign t1 = a_in ** 2;
    assign t2 = t1 << 1;
    assign t3 = t2 << 1;
    assign t4 = b_in ** 2;
    assign t5 = t4 << 1;
    assign t6 = t5 << 1;
    assign t7 = a_in * t5;    
    
    always @ (posedge clk or negedge rst_)
    begin
        
        if (state == 2'b00)
        begin
            x  <= a_in;
            y  <= 0;
            
            t8 <= t7 << 1; 
            t9 <= 0;
            
            d1 <= (t2 - t7 + t4) >>> 1;
            d2 <= (t1 >> 1) - (t7 << 1) + t5;
        end
        
        else if (state == 2'b01 && d2 < 0)
        begin
            // draw pixels here
            $display("*%d\t%d\t%d\t%d\t%d\t%d", x, y, $signed(d1), $signed(d2), $signed(t8), $signed(t9));
            
            y  <= y + 1;                       
            t9 <= t9 + t3; 
            
            if (d1 < 0)  
            begin                    
                d1 <= d1 + (t9 + t3) + t2;
                d2 <= d2 + (t9 + t3);
            end 
            
            else
            begin                           
                x  <= x - 1;
                t8 <= t8 - t6; 
                d1 <= d1 - (t8 - t6) + (t9 + t3) + t2; 
                d2 <= d2 - (t8 - t6) + t5 + (t9 + t3);
            end
            
        end 
        
        else if (state == 2'b10)
        begin
            //draw pixels here
            $display("**%d\t%d\t%d\t%d\t%d\t%d", x, y, $signed(d1), $signed(d2), $signed(t8), $signed(t9));
            
            x  <= x - 1;                       
            t8 <= t8 - t6; 
            
            if (d2 < 0)
            begin       
                y  <= y + 1;
                t9 <= t9 + t3; 
                d2 <= d2 - (t8 - t6) + t5 + (t9 + t3); 
            end
            
            else                         
                d2 <= d2 - (t8 - t6) + t5; 
        
        end 
        
    end
    
endmodule