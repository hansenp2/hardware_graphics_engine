`timescale 1ns / 1ps

module circle_drawer(
    input clk,
    input rst_,
    
    input [9:0] x0_in,
    input [9:0] y0_in,
    input [9:0] r_in
);

    // Circle Drawing Variables
    wire [9:0] draw_x [0:7];
    wire [9:0] draw_y [0:7]; 
    reg [9:0] x, y; 
    
    // Circle Drawing Components 
    reg [1:0] state;
    reg signed [9:0] dx, dy;
    reg signed [9:0] error; 
    
    // State Machine
    always @ (posedge clk or negedge rst_)
    begin
        if (!rst_)
        begin
            state <= 2'b00;
            x     <= 0;
            y     <= 0;
            dx    <= 0;
            dy    <= 0;
            error <= 0;
        end
            
        else
        begin
        
            // start state
            if (state == 2'b00)
                state <= 2'b01;
                
            // draw state
            else if (state == 2'b01)
                state <= (x >= y) ? (2'b01) : (2'b11); 
               
            // end state
            else if (state == 2'b11)
                state <= 2'b11;
        end
    end
    
    // Drawing Engine
    always @ (posedge clk or negedge rst_)
    begin
        
        if (state == 2'b00)
        begin
            x     <= r_in;
            y     <= 0;
            dx    <= 1 - (r_in << 1);
            dy    <= 1;
            error <= 0;
        end
        
        else if (state == 2'b01)
        begin
            // write pixel data
            $display("*%d\t%d\t%d\t%d\t%d", x, y, $signed(dx), $signed(dy), $signed(error));
        
            if ( (((error + dy) << 1) + dx) > 0 )
            begin
                x     <= x - 1;
                error <= error + dx;
                dx    <= dx + 2;
            end
            
            else
            begin
                y     <= y + 1;
                error <= error + dy;
                dy    <= dy + 2;
            end
        end
        
    end
    
    assign draw_x[0] = x0_in + x; assign draw_y[0] = y0_in + y;
    assign draw_x[1] = x0_in + y; assign draw_y[1] = y0_in + x;    
    assign draw_x[2] = x0_in - y; assign draw_y[2] = y0_in + x;    
    assign draw_x[3] = x0_in - x; assign draw_y[3] = y0_in + y;    
    assign draw_x[4] = x0_in - x; assign draw_y[4] = y0_in - y;    
    assign draw_x[5] = x0_in - y; assign draw_y[5] = y0_in - x;    
    assign draw_x[6] = x0_in + y; assign draw_y[6] = y0_in - x;    
    assign draw_x[7] = x0_in + x; assign draw_y[7] = y0_in - y;
        
endmodule