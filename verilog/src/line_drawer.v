`timescale 1ns / 1ps

module line_drawer (

    // Clock and Sync Reset
    input clk,
    input rst_,
    
    // Point 1
    input [9:0] x1_in, y1_in,
    
    // Point 2
    input [9:0] x2_in, y2_in,
    
    input [11:0] color,
    
    // input interface
    input  in_rts,
    output in_rtr, 
    
    // output interface
    output  out_rts,                       
    input   out_rtr, 
    
    output reg [9:0] draw_x, draw_y 
);

    
    // change in x and y (determines driving axis)
    wire [9:0] dx, dy;    
    assign dx = (x2_in >= x1_in) ? (x2_in - x1_in) : (x1_in - x2_in);
    assign dy = (y2_in >= y1_in) ? (y2_in - y1_in) : (y1_in - y2_in); 
    
    // order points properly
    wire [9:0] x1, x2, y1, y2; 

    assign x1 = (dx >= dy) ? 
        ((x1_in <= x2_in)  ? (x1_in) : (x2_in)) : 
        ((y1_in <= y2_in)  ? (x1_in) : (x2_in)) ;
        
    assign y1 = (dx >= dy) ? 
        ((x1_in <= x2_in)  ? (y1_in) : (y2_in)) : 
        ((y1_in <= y2_in)  ? (y1_in) : (y2_in)) ;
        
    assign x2 = (dx >= dy) ? 
        ((x1_in <= x2_in)  ? (x2_in) : (x1_in)) : 
        ((y1_in <= y2_in)  ? (x2_in) : (x1_in)) ;
        
    assign y2 = (dx >= dy) ? 
        ((x1_in <= x2_in)  ? (y2_in) : (y1_in)) : 
        ((y1_in <= y2_in)  ? (y2_in) : (y1_in)) ;
    
    // line drawing state machine
    reg [1:0] state;
    // reg [9:0] draw_x, draw_y; 
    reg signed [9:0] error; 
    
    // transfer completes
    wire in_xfc, out_xfc;
    assign in_xfc  = in_rts  & in_rtr;
    assign out_xfc = out_rts & out_rtr;
    
    // ready to recieve when in state 00
    assign in_rtr  = (state == 2'b00) ? (1) : (0);
    
    // ready to send when in state 01 or 10
    assign out_rts = (state == 2'b01 || state == 2'b10) ? (1) : (0);
    
    always @ (posedge clk or negedge rst_)
    begin
        if (!rst_)
            state <= 2'b00;
        
        else
        begin        
            // start state
            if (state == 2'b00 && in_xfc == 1)
                state <= (dx >= dy) ? (2'b01) : (2'b10); 
            
            // draw state 1 (x is driving axis)
            else if (state == 2'b01 && out_xfc == 1)
                state <= (draw_x < x2) ? (2'b01) : (2'b11); 
                
            // draw state 2 (y is driving axis)
            else if (state == 2'b10 && out_xfc == 1)
                state <= (draw_y < y2) ? (2'b10) : (2'b11);
                
            // end state
            else if (state == 2'b11)
                state <= 2'b00;             
         end
    end
    
    // line drawer
    always @ (posedge clk or negedge rst_)
    begin
        if (state == 2'b00 && in_xfc == 1)
        begin
            draw_y <= y1;
            draw_x <= x1;
            error  <= (dx >= dy) ? (dy - dx) : (dx - dy); 
        end 
        
        else if (state == 2'b01 && out_xfc == 1)
        begin
            // write pixel data
            $display("!WRITE PX (%d,%d) --> %d", draw_x, draw_y, $signed(error));
            
            if (error >= 0)   
                draw_y = (y1 >= y2) ? (draw_y - 1) : (draw_y + 1);  
                
            error  <= (error >= 0) ? (error - dx + dy) : (error + dy);
            draw_x <= draw_x + 1;
        end
        
        else if (state == 2'b10 && out_xfc == 1)
        begin
            // write pixel data
            $display("WRITE PX (%d,%d) --> %d", draw_x, draw_y, $signed(error));
            
            if (error >= 0) 
                draw_x = (x1 >= x2) ? (draw_x - 1) : (draw_x + 1); 
                
            error  <= (error >= 0) ? (error - dy + dx) : (error + dx) ;
            draw_y <= draw_y + 1;
        end
    end
    
endmodule
