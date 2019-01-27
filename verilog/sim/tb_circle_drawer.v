`timescale 1ns / 1ps

module tb_circle_drawer;

    // Clock and Sync Reset
    reg clk;
    reg rst_;
    
    // Circle Defintion
    reg [9:0] x0_in;
    reg [9:0] y0_in;
    reg [9:0] r_in;
    reg [11:0] color;
    
    // input interface
    reg  in_rts;
    wire in_rtr;
    
    // output interface
    wire  out_rts;                       
    reg   out_rtr;
    
    // Unit Under Test
    circle_drawer uut(
        .clk(clk),
        .rst_(rst_),  
        .x0_in(x0_in), 
        .y0_in(y0_in),
        .r_in(r_in),        
        .color(color),
        .in_rts(in_rts),
        .in_rtr(in_rtr),
        .out_rts(out_rts),
        .out_rtr(out_rtr) 
    );
    
    initial 
    begin
    
        $display("*x\ty\tdx\tdy\te");
    
        clk     = 1'b0;
        rst_    = 1'b1; 
        
        x0_in = 100;
        y0_in = 100;
        r_in  = 10;
        color = 12'habc;
        
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
