`timescale 1ns / 1ps

module writer_integration(
    input               clk,
    input               rst_,
    input               enable,

    input               test_mode,

    output              vga_h_sync,
    output              vga_v_sync,
    output  [3:0]       vga_red,
    output  [3:0]       vga_green,
    output  [3:0]       vga_blue

    // FOR DEBUGGING
    // output [9:0] h_counter, v_counter
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
        .en_fetching(en_fetching)
        // .h_counter(h_counter),
        // .v_counter(v_counter)
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
    wire rectanglefill_rtr_out, rectanglepix_rtr_out, fetch_xfc, rectanglefill_xfc, rectanglepix_xfc;

    // line drawing engine stuff here
    wire [16:0] lindrawer_arb_addr;
    wire [31:0] linedrawer_wr_data;
    wire linedrawer_rtr_out, linedrawer_rts_arb, linedrawer_xfc;
    wire [3:0] linedrawer_wr_op;

    // circle drawing engine stuff here
    wire [16:0] circledrawer_arb_addr;
    wire [31:0] circledrawer_wr_data;
    wire circledrawer_rtr_out, circledrawer_rts_arb, circledrawer_xfc;
    wire [3:0] circledrawer_wr_op;

    arbitor_v2 arb(
        .clk(clk25),
        .rst_(rst_),

        .fetch_addr(df_mem_ptr),
        .fetch_wrdata(32'b0),
        .fetch_rts_in(df_rtr_mem),
        .fetch_rtr_out(arb_rts_df),
        .fetch_op(4'b0),

        .linedrawer_addr(lindrawer_arb_addr),
        .linedrawer_wrdata(linedrawer_wr_data),
        .linedrawer_rts_in(linedrawer_rts_arb),
        .linedrawer_rtr_out(linedrawer_rtr_out),
        .linedrawer_op(linedrawer_wr_op),

        .circledrawer_addr(circledrawer_arb_addr),
        .circledrawer_wrdata(circledrawer_wr_data),
        .circledrawer_rts_in(circledrawer_rts_arb),
        .circledrawer_rtr_out(circledrawer_rtr_out),
        .circledrawer_op(circledrawer_wr_op),

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
        .bcast_xfc_out(bcast_xfc)
        // .en_fetching(en_fetching)
    );

    // Block RAM Module
    gram_wrapper gw(
        .BRAM_PORTA_0_addr(arb_mem_addr),
        .BRAM_PORTA_0_clk(clk25),
        .BRAM_PORTA_0_din(mem_data_out),
        .BRAM_PORTA_0_dout(data_from_mem),
        .BRAM_PORTA_0_we(wben)
    );


    // temp for drawing static line
    wire [51:0] test_line;
    // assign test_line = 52'b0000000000_0000000000_0000000001_0000000001_111111111111;
    assign test_line = 52'b0000000000_0000000000_1001111111_0111011111_111111111111;
    // assign test_line = 52'b0000000000_0000000000_0111011111_0111011111_111111111111;
    line_drawing_engine lde(
        .clk(clk25),
        .rst_(rst_),
        .in_op(test_line),
        .in_rts(1'b1),
        .in_rtr(),
        .out_rts(linedrawer_rts_arb),
        .out_rtr(linedrawer_rtr_out),
        .bcast_xfc(bcast_xfc[1]),
        .arb_data_in(arb_bcast_data),
        .arb_data_out(linedrawer_wr_data),
        .arb_addr_out(lindrawer_arb_addr),
        .wr_op(linedrawer_wr_op)
    );


    // Circle Drawing Engine
    wire [41:0] test_circle;
    // assign test_circle = 42'b0000000010_0000000010_0000000010_111111111111;
    assign test_circle = 42'b0100111111_0011011101_0010000000_111100000000;
    // assign test_circle = 42'b0010000000_0010000000_0001000001_111111111111;
    circle_drawing_engine cde(
        .clk(clk25),
        .rst_(rst_),
        .in_op(test_circle),
        .in_rts(1'b1),
        .in_rtr(),
        .out_rts(circledrawer_rts_arb),
        .out_rtr(circledrawer_rtr_out),
        .bcast_xfc(bcast_xfc[2]),
        .arb_data_in(arb_bcast_data),
        .arb_data_out(circledrawer_wr_data),
        .arb_addr_out(circledrawer_arb_addr),
        .wr_op(circledrawer_wr_op)
    );

endmodule
