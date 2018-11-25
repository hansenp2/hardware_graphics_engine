`timescale 1ns / 1ps

module arbiter_integration(
    input               clk,
    input               rst_,
    input               enable, 
    
    input               test_mode,
     
    output              vga_h_sync,
    output              vga_v_sync,     
    output  [3:0]       vga_red, 
    output  [3:0]       vga_green, 
    output  [3:0]       vga_blue     
    );
    
    // Clock Divider
    wire clk25;        
    clock_div cd(
        .clk_i(clk), 
        .rst_(rst_), 
        .clk_o(clk25)
    ); 
         
    // Refresh Engine
    wire active_video, en_fetching;
    wire [11:0] current_pixel;
    refresh_engine rf(
        .clk(clk25),
        .rst_(rst_),
        .enable(enable),
        .test_mode(test_mode),
        .current_pixel(current_pixel),
        .vga_h_sync(vga_h_sync), 
        .vga_v_sync(vga_v_sync), 
        .active_video(active_video),
        .vga_red(vga_red),
        .vga_green(vga_green),
        .vga_blue(vga_blue),
        .en_fetching(en_fetching)
    );  
         
    // Interface Needed without Arbiter
    wire df_rtr_mem, df_rts_mem, df_rts_rf;
    wire [31:0] data_from_mem;
    wire [16:0] df_mem_ptr;
    wire arb_rts_df;
    wire [31:0] arb_bcast_data;
    wire bcast_xfc;
    
    // Data Fetching Engine
    data_fetching_engine df(
        .clk(clk25),
        .rst_(rst_),
        .en_fetching(en_fetching),        
        .in_addr(df_mem_ptr),
        .in_data(arb_bcast_data),
        .in_rtr(df_rtr_mem),
        .in_rts(bcast_xfc),                  
        .out_data(current_pixel),
        .out_rtr(active_video),
        .out_rts(df_rts_rf)
    );
    
    wire [31:0] mem_data_out;
    wire [16:0] arb_mem_addr;
    wire [2:0] sel;
    wire [3:0] wben;
    wire rectanglefill_rtr_out, rectanglepix_rtr_out, fetch_xfc, rectanglefill_xfc, rectanglepix_xfc;
    arbitor arb(
        .clk(clk25),
        .rst_(rst_),
        
        .fetch_addr(df_mem_ptr),
        .fetch_wrdata(0),
        .fetch_rts_in(df_rtr_mem),
        .fetch_rtr_out(arb_rts_df),
        .fetch_op(0),
        
        .rectanglefill_addr(0),
        .rectanglefill_wrdata(0),
        .rectanglefill_rts_in(0),
        .rectanglefill_rtr_out(rectanglefill_rtr_out),
        .rectanglefill_op(0),
        
        .rectanglepix_addr(0),
        .rectanglepix_wrdata(0),
        .rectanglepix_rts_in(0),
        .rectanglepix_rtr_out(rectanglepix_rtr_out),
        .rectanglepix_op(0),

        //for debugging
        .sel(sel),
        .fetch_xfc(fetch_xfc),
        .rectanglefill_xfc(rectanglefill_xfc),
        .rectanglepix_xfc(rectanglepix_xfc),
        
        
        .mem_data_in(data_from_mem),
        .wben(wben),
        .mem_addr(arb_mem_addr),
        .mem_data_out(mem_data_out),
        
        .bcast_data(arb_bcast_data),
        .bcast_xfc(bcast_xfc)
    );
    
    // Block RAM Module
//    bram_wrapper bw(
//        .BRAM_PORTA_0_addr(arb_mem_addr),
//        .BRAM_PORTA_0_clk(clk25),
//        .BRAM_PORTA_0_din(0),
//        .BRAM_PORTA_0_dout(data_from_mem),
//        .BRAM_PORTA_0_we(0)
//    );


    // INFERRED BRAM USED FOR SIMULATION ONLY
    mem_for_testing mt(
        .clk(clk25),
        .in_addr(arb_mem_addr),
        .out_data(data_from_mem)
    ); 
    
endmodule
