`timescale 1ns / 1ps

module fill_rect_engine(
    input clk,
    input rst_,
    // Command Processor Interface
    input   [7:0]   cmd_in_data,
    input           cmd_in_rts,
    input           cmd_out_rtr,
    // Arbiter Interface
    output  [31:0]  arb_out_data,
    output  [15:0]  arb_out_addr,
    output  [3:0]   arb_out_wben,
    input           arb_in_rtr,
    output          arb_out_rts,
    output          arb_out_op,
    input   [31:0]  arb_in_data,
    input           arb_in_xfc
    );
    
    wire            cmd_fifo_rtr;
    wire            cmd_fifo_rts;
    wire    [7:0]   cmd_fifo_data;
    
    fifo #(.DATA_WIDTH(8),
            .DEPTH(32),
            .LOG2DEPTH(5)) 
    cmd_data_fifo_(
            .clk(clk),
            .rst_(rst_),
            // Input Interface
            .in_data(cmd_in_data),
            .in_rtr(cmd_out_rtr),
            .in_rts(cmd_in_rts),
            // Output Interface
            .out_rtr(cmd_fifo_rtr),
            .out_rts(cmd_fifo_rts),
            .out_data(cmd_fifo_data)
            );
    /*        
    rect_generator generator_ut(
            .clk(clk),
            .rst_(rst_),
            // Command Processor FIFO Interface
            .cmd_fifo_data(cmd_fifo_data),
            .cmd_fifo_rtr(cmd_fifo_rtr),
            .cmd_fifo_rts(cmd_fifo_rts),
            // Arbiter FIFO Interface
            .arb_data(arb_out_data),
            .arb_addr(arb_out_addr),
            .arb_wben(arb_out_wben),
            .arb_rts(arb_out_rts),
            .arb_rtr(arb_in_rtr)
            );
    */    
     
   // Command Data Fields       
   //   (values will not get over written until a command has been completed)
   //   (can later be replaced with fifos)
    reg     [15:0]  cmd_data_origx;
    reg     [15:0]  cmd_data_origy;
    reg     [15:0]  cmd_data_wid;
    reg     [15:0]  cmd_data_hgt;
    reg     [3:0]   cmd_data_rval;
    reg     [3:0]   cmd_data_gval;
    reg     [3:0]   cmd_data_bval;
    
    wire    [3:0]   fill_rect_gen_eng_state;
    wire    [3:0]   addr_eng_state;
    wire    [3:0]   fill_rect_decode_eng_state;
        
    fill_rect_decode_engine dec_eng(
        .clk(clk),
        .rst_(rst_),
        // Command Fifo Interface
        .cmd_fifo_rtr(cmd_fifo_rtr),
        .cmd_fifo_rts(cmd_fifo_rts),
        .cmd_fifo_data(cmd_fifo_data),
        // Fill Rect Data Gen Engine INterface
        .fill_rect_gen_eng_state(fill_rect_gen_eng_state),
        // Command Data Field Outputs 
        .cmd_data_origx(cmd_data_origx),
        .cmd_data_origy(cmd_data_origy),
        .cmd_data_wid(cmd_data_wid),
        .cmd_data_hgt(cmd_data_hgt),
        .cmd_data_rval(cmd_data_rval),
        .cmd_data_gval(cmd_data_gval),
        .cmd_data_bval(cmd_data_bval),
        // Addressing Engine Interface
        .fill_rect_decode_eng_state(fill_rect_decode_eng_state)
        );
        
        
    wire    [15:0]  init_addr;
    
    addr_engine addr_eng(
        .clk(clk),
        .rst_(rst_),
        // Command Data Field Engine Interface
        .cmd_data_origx(cmd_data_origx),
        .cmd_data_origy(cmd_data_origy),
        // Fill Rect Decode Engine Interface
        .fill_rect_decode_eng_state(fill_rect_decode_eng_state),
        // Generation Engine Interface
        .addr_eng_state(addr_eng_state),
        .addr(init_addr)
        );
    
    fill_rect_data_gen_engine data_gen_eng(
        .clk(clk),
        .rst_(rst_),
        // Addressing Engine Interface
        .addr_eng_state(addr_eng_state),
        .init_addr(init_addr),
        // Fill Rect Data Field Interface
        .cmd_data_wid(cmd_data_wid),
        .cmd_data_hgt(cmd_data_hgt),
        .cmd_data_rval(cmd_data_rval),
        .cmd_data_gval(cmd_data_gval),
        .cmd_data_bval(cmd_data_bval),
        // Fill Rect Decode Engine Interface
        .fill_rect_gen_eng_state(fill_rect_gen_eng_state),
        // Arbiter Interface
        .arb_out_wben(arb_out_wben),
        .arb_out_addr(arb_out_addr),
        .arb_out_data(arb_out_data),
        .arb_out_op(arb_out_op),
        .arb_in_data(arb_in_data),
        .arb_in_xfc(arb_in_xfc)
        );
endmodule
