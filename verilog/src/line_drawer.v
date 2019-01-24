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
    
    input in_rts,
    output in_rtr 
);

    // get ops from fifo    
    reg current_op;
    always @ (posedge clk or negedge rst_)
    begin
        if (!rst_)
            current_op <= 0;
        else
        begin
            if (in_rts & in_rtr)
                current_op <= 1;    // read next op here...
        end
    end

    // change in x and y (determines driving axis)
    wire [9:0] dx, dy;    
    assign dx = (x2_in >= x1_in) ? (x2_in - x1_in) : (x1_in - x2_in);
    assign dy = (y2_in >= y1_in) ? (y2_in - y1_in) : (y1_in - y2_in); 
    
    // order points properly
    wire [9:0] x1, x2, y1, y2;
    assign x1 = (x1_in <= x2_in) ? (x1_in) : (x2_in);
    assign x2 = (x1_in >  x2_in) ? (x1_in) : (x2_in);
    assign y1 = (y1_in <= y2_in) ? (y1_in) : (y2_in);
    assign y2 = (y1_in >  y2_in) ? (y1_in) : (y2_in);
    
    // line drawing state machine
    reg [1:0] state;
    reg [9:0] draw_x, draw_y; 
    reg signed [9:0] error; 
    
    assign in_rtr = (state == 2'b00 || state == 2'b11) ? (1) : (0);
    
    always @ (posedge clk or negedge rst_)
    begin
        if (!rst_)
            state <= 2'b00;
        
        else
        begin        
            // start state
            if (state == 2'b00)
                state <= (dx >= dy) ? (2'b01) : (2'b10); 
            
            // draw state 1 (x is driving axis)
            else if (state == 2'b01)
                state <= (draw_x < x2) ? (2'b01) : (2'b11); 
                
            // draw state 2 (y is driving axis)
            else if (state == 2'b10)
                state <= (draw_y < y2) ? (2'b10) : (2'b11);
                
            // end state
            else if (state == 2'b11)
                state <= 2'b11;             
         end
    end
    
    // line drawer
    always @ (posedge clk or negedge rst_)
    begin
        if (state == 2'b00)
        begin
            draw_y <= y1;
            draw_x <= x1;
            error  <= (dx >= dy) ? (dy - dx) : (dx - dy); 
        end 
        
        else if (state == 2'b01)
        begin
            // write pixel data
            $display("!WRITE PX (%d,%d) --> %d", draw_x, draw_y, $signed(error));
            
            if (error >= 0)    
                draw_y <= draw_y + 1; 
                
            error  <= (error >= 0) ? (error - dx + dy) : (error + dy);
            draw_x <= draw_x + 1;
        end
        
        else if (state == 2'b10)
        begin
            // write pixel data
            $display("WRITE PX (%d,%d) --> %d", draw_x, draw_y, $signed(error));
            
            if (error >= 0) 
                draw_x <= draw_x + 1;
                
            error  <= (error >= 0) ? (error - dy + dx) : (error + dx) ;
            draw_y <= draw_y + 1;
        end
    end
    
endmodule