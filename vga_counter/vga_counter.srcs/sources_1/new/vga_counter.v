`timescale 1ns / 1ps

module vga_counter(
    input clock,
    input reset,
    input enable,
    
    output vga_h_sync,
    output vga_v_sync,    
    
    // output end_line, end_frame,
    
    // output [9:0] v_counter,
    // output [9:0] h_counter,
    
    output [3:0] vga_red, vga_green, vga_blue
    );
    
    // Clock Divider (100 MHz -> 25 MHz)
    wire clk25;        
    clock_div cd(clock, reset, clk25);
        
    // VGA Hardware 
    wire end_line;
    h_counter hc(clk25, reset, enable, vga_h_sync, end_line);
    v_counter vc(clk25, reset, end_line, vga_v_sync);
    colors    cl(clk25, reset, vga_red, vga_green, vga_blue);
    
endmodule
