`timescale 1ns / 1ps

module data_fetching_engine(

    input           clk,
    input           rst_,
    input           en_fetching,
    
    output  [16:0]  in_addr,
    input   [31:0]  in_data,
    output          in_rtr,
    input           in_rts,
    
    output  [11:0]  out_data,
    input           out_rtr,
    output          out_rts 
    );
    
//    wire df_rtr_mem; 
    wire [31:0] mem_out_data;
    wire r_rts_rb, g_rts_gb, b_rts_bb;
    wire rb_rtr_r, gb_rtr_g, bb_rtr_b;
    
    data_fetch df(
        .clk(clk), 
        .rst_(rst_), 
        .en(en_fetching),        
        .in_data(in_data), 
        .in_rts(in_rts), 
        .in_rtr(in_rtr), 
        .mem_ptr(in_addr),         
        .out_data(mem_out_data),
        .r_rts(r_rts_rb),
        .r_rtr(rb_rtr_r),
        .g_rts(g_rts_gb),
        .g_rtr(gb_rtr_g), 
        .b_rts(b_rts_bb),
        .b_rtr(bb_rtr_b)
    );
    
    wire [31:0] r_data, g_data, b_data; 
    wire rb_rts_pb, gb_rts_pb, bb_rts_pb, pb_rtr_cb;
    color_buffer rb(
        .clk(clk),
        .rst_(rst_),
        .en(en_fetching),
        .in_data(mem_out_data),
        .in_rts(r_rts_rb),
        .in_rtr(rb_rtr_r),
        .out_data(r_data),
        .out_rts(rb_rts_pb),
        .out_rtr(pb_rtr_cb)        
    );
    
    color_buffer gb(
        .clk(clk),
        .rst_(rst_),
        .en(en_fetching),
        .in_data(mem_out_data),
        .in_rts(g_rts_gb),
        .in_rtr(gb_rtr_g),
        .out_data(g_data),
        .out_rts(gb_rts_pb),
        .out_rtr(pb_rtr_cb)        
    );
    
    color_buffer bb(
        .clk(clk),
        .rst_(rst_),
        .en(en_fetching),
        .in_data(mem_out_data),
        .in_rts(b_rts_bb),
        .in_rtr(bb_rtr_b),
        .out_data(b_data),
        .out_rts(bb_rts_pb),
        .out_rtr(pb_rtr_cb)        
    );
    
    wire pb_rts_disp;         
    pixel_buffer pb(
        .clk(clk),
        .rst_(rst_),
        .en(en_fetching),
        .r_data(r_data),
        .g_data(g_data),
        .b_data(b_data),
        .r_rts(rb_rts_pb),
        .g_rts(gb_rts_pb),
        .b_rts(bb_rts_pb),
        .in_rtr(pb_rtr_cb),
        .current_pixel(out_data),
        .out_rts(out_rts),
        .out_rtr(out_rtr)              // active video
    );
    
endmodule
