`timescale 1ns / 1ps

module circle_drawer(

    // clock and sync reset
    input clk,
    input rst_,
    
    // circle values
    input [9:0] x0_in,
    input [9:0] y0_in,
    input [9:0] r_in,
    input [11:0] color,
    
    // input interface
    input  in_rts,
    output in_rtr, 
    
    // output interface
    output  out_rts,                       
    input   out_rtr,
    
    output [9:0] draw_x_0, draw_x_1, draw_x_2, draw_x_3,
    output [9:0] draw_x_4, draw_x_5, draw_x_6, draw_x_7,
    
    output [9:0] draw_y_0, draw_y_1, draw_y_2, draw_y_3,
    output [9:0] draw_y_4, draw_y_5, draw_y_6, draw_y_7
);

    // Circle Drawing Variables
    // wire [9:0] draw_x [0:7];
    // wire [9:0] draw_y [0:7]; 
    reg [9:0] x, y; 
    
    // Circle Drawing Components 
    reg [1:0] state;
    reg signed [9:0] dx, dy;
    reg signed [9:0] error; 
    
    // transfer completes
    wire in_xfc, out_xfc;
    assign in_xfc  = in_rts  & in_rtr;
    assign out_xfc = out_rts & out_rtr;
    
    // ready to recieve when in state 00
    assign in_rtr  = (state == 2'b00) ? (1) : (0);
    
    // ready to send when in state 01 or 10
    assign out_rts = (state == 2'b01) ? (1) : (0);
    
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
            if (state == 2'b00 && in_xfc == 1)
                state <= 2'b01;
                
            // draw state
            else if (state == 2'b01 && out_xfc == 1)
                state <= (x >= y) ? (2'b01) : (2'b11); 
               
            // end state
            else if (state == 2'b11)
                state <= 2'b00;
        end
    end
    
    // Drawing Engine
    always @ (posedge clk or negedge rst_)
    begin
        
        if (state == 2'b00 && in_xfc == 1)
        begin
            x     <= r_in;
            y     <= 0;
            dx    <= 1 - (r_in << 1);
            dy    <= 1;
            error <= 0;
        end
        
        else if (state == 2'b01 && out_xfc == 1)
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
    
    /* assign draw_x[0] = x0_in + x; assign draw_y[0] = y0_in + y;
    assign draw_x[1] = x0_in + y; assign draw_y[1] = y0_in + x;    
    assign draw_x[2] = x0_in - y; assign draw_y[2] = y0_in + x;    
    assign draw_x[3] = x0_in - x; assign draw_y[3] = y0_in + y;    
    assign draw_x[4] = x0_in - x; assign draw_y[4] = y0_in - y;    
    assign draw_x[5] = x0_in - y; assign draw_y[5] = y0_in - x;    
    assign draw_x[6] = x0_in + y; assign draw_y[6] = y0_in - x;    
    assign draw_x[7] = x0_in + x; assign draw_y[7] = y0_in - y; */
    
    assign draw_x_0 = x0_in + x; assign draw_y_0 = y0_in + y;
    assign draw_x_1 = x0_in + y; assign draw_y_1 = y0_in + x;    
    assign draw_x_2 = x0_in - y; assign draw_y_2 = y0_in + x;    
    assign draw_x_3 = x0_in - x; assign draw_y_3 = y0_in + y;    
    assign draw_x_4 = x0_in - x; assign draw_y_4 = y0_in - y;    
    assign draw_x_5 = x0_in - y; assign draw_y_5 = y0_in - x;    
    assign draw_x_6 = x0_in + y; assign draw_y_6 = y0_in - x;    
    assign draw_x_7 = x0_in + x; assign draw_y_7 = y0_in - y;
        

endmodule
