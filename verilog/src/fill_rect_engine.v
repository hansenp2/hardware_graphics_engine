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
    input   [31:0]  arb_bcast_in_data,
    input           arb_bcast_in_xfc
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
     
   // Command Data Fields       
   //   (values will not get over written until a command has been completed)
   //   (can later be replaced with fifos)
    wire    [15:0]  cmd_data_origx;
    wire    [15:0]  cmd_data_origy;
    wire    [15:0]  cmd_data_wid;
    wire    [15:0]  cmd_data_hgt;
    wire    [3:0]   cmd_data_rval;
    wire    [3:0]   cmd_data_gval;
    wire    [3:0]   cmd_data_bval;
        
    wire            dec_eng_has_data;
    wire            data_gen_is_idle;
    
    wire            addr_start_strobe;
    wire            gen_start_strobe;
    fill_rect_decode_engine dec_eng(
        .clk(clk),
        .rst_(rst_),
        // Pipeline Stall Interface
        .dec_eng_has_data(dec_eng_has_data),
        .data_gen_is_idle(data_gen_is_idle),
        // Command Fifo Interface
        .cmd_fifo_rtr(cmd_fifo_rtr),
        .cmd_fifo_rts(cmd_fifo_rts),
        .cmd_fifo_data(cmd_fifo_data),
        // Command Data Field Outputs 
        .cmd_data_origx(cmd_data_origx),
        .cmd_data_origy(cmd_data_origy),
        .cmd_data_wid(cmd_data_wid),
        .cmd_data_hgt(cmd_data_hgt),
        .cmd_data_rval(cmd_data_rval),
        .cmd_data_gval(cmd_data_gval),
        .cmd_data_bval(cmd_data_bval),
        .addr_start_strobe(addr_start_strobe)
        );
        
        
    wire    [15:0]  init_addr;
    
    addressing_engine addr_eng(
        .clk(clk),
        .rst_(rst_),
        // Command Data Field Engine Interface
        .cmd_data_origx(cmd_data_origx),
        .cmd_data_origy(cmd_data_origy),
        // Fill Rect Decode Engine Interface
        .addr_start_strobe(addr_start_strobe),
        // Generation Engine Interface
        .init_addr(init_addr),
        .gen_start_strobe(gen_start_strobe)
        );
    
    fill_rect_data_gen_engine data_gen_eng(
        .clk(clk),
        .rst_(rst_),
        // Pipeline Stall Interface
        .dec_eng_has_data(dec_eng_has_data),
        .data_gen_is_idle(data_gen_is_idle),
        // Addressing Engine Interface
        .init_addr(init_addr),
        .gen_start_strobe(gen_start_strobe),
        // Fill Rect Data Field Interface
        .cmd_data_wid(cmd_data_wid),
        .cmd_data_hgt(cmd_data_hgt),
        .cmd_data_rval(cmd_data_rval),
        .cmd_data_gval(cmd_data_gval),
        .cmd_data_bval(cmd_data_bval),
        // Arbiter Interface
        .arb_out_rts(arb_out_rts),
        .arb_in_rtr(arb_in_rtr),
        .arb_out_wben(arb_out_wben),
        .arb_out_addr(arb_out_addr),
        .arb_out_data(arb_out_data),
        .arb_out_op(arb_out_op),
        .arb_bcast_in_data(arb_bcast_in_data),
        .arb_bcast_in_xfc(arb_bcast_in_xfc)
        );
endmodule
