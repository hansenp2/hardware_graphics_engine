`timescale 1ns / 1ps

// INPUT FIFO PARAMETERS
`define IN_FIFO_DATA_WIDTH  128
`define IN_FIFO_DEPTH        4
`define IN_FIFO_LOG2DEPTH    2

// OUTPUT FIFO PARAMETERS
`define OUT_FIFO_DATA_WIDTH 32
`define OUT_FIFO_DEPTH      32
`define OUT_FIFO_LOG2DEPTH   5

module line_drawing_engine(

    // clock and sync reset
    input clk,
    input rst_,

    // input interface
    input [127:0] in_op,
    input  in_rts,
    output in_rtr,

    // output interface
    output out_rts,
    input  out_rtr,

    // arbiter interface
    input bcast_xfc,
    input [31:0] arb_data_in,
    output [31:0] arb_data_out,
    output [16:0] arb_addr_out,
    output [3:0] wr_op
);

    // input fifo for ops
    wire [127:0] current_op;
    wire fi_rts_ld, ld_rtr_fi;
    fifo #(`IN_FIFO_DATA_WIDTH, `IN_FIFO_DEPTH, `IN_FIFO_LOG2DEPTH) fi (
        .clk(clk),
        .rst_(rst_),

        .in_data(in_op),
        .in_rts(in_rts),
        .in_rtr(in_rtr),

        .out_data(current_op),
        .out_rts(fi_rts_ld),
        .out_rtr(ld_rtr_fi)
    );

    // TEMPORARY VALUES FOR TESTING
    wire [ 9:0] x_out, y_out;
    wire [31:0] f_out;
    reg [ 9:0] x1, y1, x2, y2;
    wire [11:0] color_out;

    // line drawing algorithm module
    wire ld_rts_fx, rx_rtr_ld;
    line_drawer ld (
        .clk(clk),
        .rst_(rst_),
        .x1_in({current_op[7:0], current_op[15:8]}),
        .y1_in({current_op[23:16], current_op[31:24]}),
        .x2_in({current_op[39:32], current_op[47:40]}),
        .y2_in({current_op[55:48], current_op[63:56]}),
        .color({current_op[77:64], current_op[75:72], current_op[83:80]}),

        .in_rts(fi_rts_ld),
        .in_rtr(ld_rtr_fi),

        .out_rts(ld_rts_fx),
        .out_rtr(rx_rtr_ld),

        .draw_x(x_out),
        .draw_y(y_out),
        .color_hold(color_out)
    );


    // output fifo
    wire fo_rts_ae, ae_rtr_fo;
    fifo #(32, `OUT_FIFO_DEPTH, `OUT_FIFO_LOG2DEPTH) fo (
        .clk(clk),
        .rst_(rst_),

        .in_data({x_out, y_out, color_out}),
        .in_rts(ld_rts_fx),
        .in_rtr(rx_rtr_ld),

        .out_data(f_out),
        .out_rts(fo_rts_ae),
        .out_rtr(ae_rtr_fo)
    );


    // addressing engine
    wire [16:0] addr_base;
    wire [ 2:0] addr_offset;
    wire [11:0] color_rmw;
    wire ae_rts_rmw, rmw_rtr_ae;

    addressing_engine ae (
        .clk(clk),
        .rst_(rst_),
        .cmd_data_origx(f_out[31:22]),
        .cmd_data_origy(f_out[21:12]),
        .in_color(f_out[11:0]),
        .init_addr(addr_base),
        .addr_offset(addr_offset),
        .out_color(color_rmw),
        .in_rts(fo_rts_ae),
        .in_rtr(ae_rtr_fo),
        .out_rts(ae_rts_rmw),
        .out_rtr(rmw_rtr_ae)
    );


    // read-modify-write engine
    read_modify_write_engine rmw (
        .clk(clk),
        .rst_(rst_),
        .addr_base(addr_base),
        .addr_offset(addr_offset),
        .color(color_rmw),

        .addr_rts(ae_rts_rmw),
        .addr_rtr(rmw_rtr_ae),

        .in_data(arb_data_in),
        .out_data(arb_data_out),
        .out_addr(arb_addr_out),
        .arb_rts(out_rts),
        .arb_rtr(out_rtr),
        .bcast_xfc(bcast_xfc),
        .wr_op(wr_op)
    );

endmodule
