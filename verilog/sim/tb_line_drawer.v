`timescale 1ns / 1ps

module tb_line_drawer;

    // Clock and Sync Reset
    reg clk;
    reg rst_;
    
    // Point 1
    reg [9:0] x1_in, y1_in;
    
    // Point 2
    reg [9:0] x2_in, y2_in;
    
    reg [11:0] color;
    
    reg in_rts;
    wire in_rtr; 
    wire out_rts;                    
    reg out_rtr; 
    
    // Unit Under Test
    line_drawer uut(
        .clk(clk),
        .rst_(rst_),  
        .x1_in(x1_in), 
        .y1_in(y1_in),
        .x2_in(x2_in), 
        .y2_in(y2_in),        
        .color(color),
        .in_rts(in_rts),
        .in_rtr(in_rtr),
        .out_rts(out_rts),
        .out_rtr(out_rtr)
    );
    
    initial 
    begin
    
        clk     = 1'b0;
        rst_    = 1'b1;
        
        x1_in   = 4;
        y1_in   = 0;
        
        x2_in   = 0;
        y2_in   = 10;
        
        color   = 0;
        
        out_rtr = 1;
        
        #10;
        
        #5 rst_ = ~rst_; clk = ~clk;
        #5 rst_ = ~rst_; clk = ~clk;
        
        #5; 
            in_rts  = 1;
            clk = ~clk;
        #5; 
            in_rts  = 0;
            clk = ~clk;
        
        repeat(200)
        begin
            #5 clk = ~clk;
        end
    
    end

endmodule
