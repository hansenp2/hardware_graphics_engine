`timescale 1ns / 1ps

module arbiter_integration(
    input               clk,
    input               rst_,
    input               enable, 
    
    input               test_mode,
    input               cmd_in_rts,
    //output              cmd_out_rtr,
     
    output              vga_h_sync,
    output              vga_v_sync,     
    output  [3:0]       vga_red, 
    output  [3:0]       vga_green, 
    output  [3:0]       vga_blue,
    
    
    // FOR DEBUGGING
    //output [9:0] h_counter, v_counter,
    input [7:0] cmd_proc_data,
    input cmd_proc_rts     
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
    refresh_engine_2 rf(
        .clk(clk25),
        .rst_(rst_),
        //.enable(enable),
        .test_mode(test_mode),
        .current_pixel(current_pixel),
        .vga_h_sync(vga_h_sync), 
        .vga_v_sync(vga_v_sync), 
        .active_video(active_video),
        .vga_red(vga_red),
        .vga_green(vga_green),
        .vga_blue(vga_blue),
        .en_fetching(en_fetching),
        .h_counter(h_counter),
        .v_counter(v_counter)
    );  
         
    // Interface Needed without Arbiter
    wire df_rtr_mem, df_rts_mem, df_rts_rf;
    wire [31:0] data_from_mem;
    wire [16:0] df_mem_ptr;
    wire arb_rts_df;
    wire [31:0] arb_bcast_data;
    wire [2:0] bcast_xfc;
    
    // Data Fetching Engine
    data_fetching_engine df(
        .clk(clk25),
        .rst_(rst_),
        .en_fetching(en_fetching),        
        .in_addr(df_mem_ptr),
        .in_data(arb_bcast_data),
        .in_rtr(df_rtr_mem),
        .in_rts(arb_rts_df),                  
        .out_data(current_pixel),
        .out_rtr(active_video),
        .out_rts(df_rts_rf),
        .bcast_xfc(bcast_xfc[0])
    );
    
    wire [31:0] mem_data_out;
    wire [16:0] arb_mem_addr;
    wire [2:0] sel;
    wire [3:0] wben;
    wire rectanglepix_rtr_out, fetch_xfc, rectanglefill_xfc, rectanglepix_xfc;
    
    wire fill_rect_in_rtr, fill_rect_out_rts, fill_rect_out_op;
    wire cmdproc_in_rts, cmdproc_out_rtr;
    wire [16:0] fill_rect_out_addr;
    wire [11:0] fill_rect_out_data;
    wire [3:0] fill_rect_out_wben;
    arbitor arb(
        .clk(clk25),
        .rst_(rst_),
        
        .fetch_addr(df_mem_ptr),
        .fetch_wrdata(0),
        .fetch_rts_in(df_rtr_mem),
        .fetch_rtr_out(arb_rts_df),
        .fetch_op(0),
        
        .rectanglefill_addr(fill_rect_out_addr),
        .rectanglefill_wrdata(fill_rect_out_data),
        .rectanglefill_rts_in(fill_rect_out_rts),
        .rectanglefill_rtr_out(fill_rect_in_rtr),
        .rectanglefill_op(fill_rect_out_wben),
        
        .rectanglepix_addr(0),
        .rectanglepix_wrdata(0),
        .rectanglepix_rts_in(0),
        .rectanglepix_rtr_out(rectanglepix_rtr_out),
        .rectanglepix_op(0),
        
        /*
        //for debugging
        .sel(sel),
        .fetch_xfc(fetch_xfc),
        .rectanglefill_xfc(rectanglefill_xfc),
        .rectanglepix_xfc(rectanglepix_xfc),
        */
        
        .mem_data_in(data_from_mem),
        .wben(wben),
        .mem_addr(arb_mem_addr),
        .mem_data_out(mem_data_out),
        
        .bcast_data(arb_bcast_data),
        .bcast_xfc_out(bcast_xfc),
        .en_fetching(en_fetching)
    );
    
    fill_rect_engine fre(
        .clk(clk25),
        .rst_(rst_),
        .cmd_in_data(cmd_proc_data),
        .cmd_in_rts(cmd_proc_rts),
        .cmd_out_rtr(cmdproc_out_rtr),
        .arb_out_data(fill_rect_out_data),
        .arb_out_addr(fill_rect_out_addr),
        .arb_out_wben(fill_rect_out_wben),
        .arb_in_rtr(fill_rect_in_rtr),
        .arb_out_rts(fill_rect_out_rts),
        .arb_out_op(fill_rect_out_op),
        .arb_bcast_in_data(arb_bcast_data),
        .arb_bcast_in_xfc(bcast_xfc)
    );
        
        wire            cmd_fifo_rtr;
        wire            cmd_fifo_rts;
        wire    [7:0]   cmd_fifo_data;
    // Block RAM Module
    GRAM_wrapper gw(
        .BRAM_PORTA_0_addr(arb_mem_addr),
        .BRAM_PORTA_0_clk(clk25),
        .BRAM_PORTA_0_din(0),
        .BRAM_PORTA_0_dout(data_from_mem),
        .BRAM_PORTA_0_we(0)
    );


//     INFERRED BRAM USED FOR SIMULATION ONLY
//    mem_for_testing mt(
//        .clk(clk25),
//        .in_addr(arb_mem_addr),
//        .out_data(data_from_mem)
//    ); 
    
endmodule
