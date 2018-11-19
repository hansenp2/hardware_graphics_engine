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
            .LOG2DEPTH(5)) fifo_ut(
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
        
endmodule
