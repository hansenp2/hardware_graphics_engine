`timescale 1ns / 1ps

module tb_vga_counter;

    // Inputs 
    reg clock;
    reg reset;
    reg enable;
    
    // Outputs
    wire vga_v_sync;
    wire vga_h_sync;   
    wire end_line;
    wire end_frame;
//    wire [9:0] v_counter;
//    wire [9:0] h_counter;
    wire [3:0] vga_red;
    wire [3:0] vga_green;
    wire [3:0] vga_blue;
//    wire clk25;
    
    // Unit Under Test (UUT)
    vga_counter uut (
        .clock(clock),
        .reset(reset),
        .enable(enable),
        .vga_v_sync(vga_v_sync),
        .vga_h_sync(vga_h_sync),
        .end_line(end_line),
        .end_frame(end_frame),
//        .v_counter(v_counter),
//        .h_counter(h_counter),
        .vga_red(vga_red),
        .vga_green(vga_green),
        .vga_blue(vga_blue)
//        .clk25(clk25)
    );
    
    integer i;
    
    initial begin
    
        // Iniatilze Inputs
        clock   = 1'b0;
        reset   = 1'b1;
        enable  = 1'b0;
        
        #5;
        
        // Pulse Active Low Reset
        #5 reset = ~reset;
        #5 reset = ~reset;
        #5 enable = 1'b1;
        
        begin
            for (i = 0; i < 25200000; i = i + 1)
            begin
                #1 clock = ~clock;
            end
        end
    
    end

endmodule
