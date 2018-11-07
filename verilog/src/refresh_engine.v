`timescale 1ns / 1ps

module refresh_engine(

    // Input Interface
    input               clk,
    input               rst_,
    input               enable, 
    input               test_mode,
    input   [11:0]      current_pixel, 
    
    // Output Interface
    output              vga_h_sync,
//    output              vga_h_active,
    output              vga_v_sync,
//    output              vga_v_active,     
    output              active_video,
    output  [3:0]       vga_red, 
    output  [3:0]       vga_green, 
    output  [3:0]       vga_blue,    
    output              en_fetching
    
    );
     
    wire [9:0] v_counter, h_counter; 
    wire end_line, end_frame;
    
    wire vga_h_active, vga_v_active;
    assign active_video = vga_h_active & vga_v_active;
    
    h_counter hc(
        .clk(clk), 
        .rst_(rst_), 
        .enable(enable), 
        .h_sync(vga_h_sync), 
        .h_active(vga_h_active), 
        .end_line(end_line), 
        .h_counter(h_counter)
    );
    
    v_counter vc(
        .clk(clk), 
        .rst_(rst_), 
        .enable(end_line), 
        .v_sync(vga_v_sync), 
        .v_active(vga_v_active), 
        .end_frame(end_frame), 
        .en_fetching(en_fetching), 
        .v_counter(v_counter)
    ); 
    
    colors cl(
        .clk(clk),
        .rst_(rst_), 
        .test_mode(test_mode), 
        .next_test(0), 
        .h_active(vga_h_active), 
        .v_active(vga_v_active), 
        .h_counter(h_counter), 
        .v_counter(v_counter), 
        .current_pixel(current_pixel), 
        .red(vga_red), 
        .green(vga_green), 
        .blue(vga_blue)
    ); 
         
    
endmodule
