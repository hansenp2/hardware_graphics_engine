`timescale 1ns / 1ps

// INPUT FIFO PARAMETERS
`define E_IN_FIFO_DATA_WIDTH  88
`define E_IN_FIFO_DEPTH        4
`define E_IN_FIFO_LOG2DEPTH    2

// OUTPUT FIFO PARAMETERS
`define E_OUT_FIFO_DATA_WIDTH  10
`define E_OUT_FIFO_DEPTH      128
`define E_OUT_FIFO_LOG2DEPTH    7

module ellipse_drawing_engine(

    // clock and sync reset
    input clk,
    input rst_,

    // input interface
    input [87:0] in_op,
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

    // Input fifo for ops
    wire [87:0] current_op;
    wire fi_rts_ed, ed_rtr_fi;
    fifo #(`E_IN_FIFO_DATA_WIDTH, `E_IN_FIFO_DEPTH, `E_IN_FIFO_LOG2DEPTH) fi (
        .clk(clk),
        .rst_(rst_),

        .in_data(in_op),
        .in_rts(in_rts),
        .in_rtr(in_rtr),

        .out_data(current_op),
        .out_rts(fi_rts_ed),
        .out_rtr(ed_rtr_fi)
    );


    // Line drawing algorithm module
    wire ed_rts_fx, rx_rtr_ed;
    wire [9:0] draw_x [0:3];
    wire [9:0] draw_y [0:3];
    wire [11:0] color_out;
    ellipse_drawer ed(
        .clk(clk),
        .rst_(rst_),
        .x0_in({current_op[7:0], current_op[15:8]}),
        .y0_in({current_op[23:16], current_op[31:24]}),
        .a_in({current_op[39:32], current_op[47:40]}),
        .b_in({current_op[55:48], current_op[63:56]}),
        .color({current_op[77:64], current_op[75:72], current_op[83:80]}),

        .in_rts(fi_rts_ed),
        .in_rtr(ed_rtr_fi),

        .out_rts(ed_rts_fx),
        .out_rtr(rx_rtr_ed),

        .draw_x_0(draw_x[0]),
        .draw_x_1(draw_x[1]),
        .draw_x_2(draw_x[2]),
        .draw_x_3(draw_x[3]),

        .draw_y_0(draw_y[0]),
        .draw_y_1(draw_y[1]),
        .draw_y_2(draw_y[2]),
        .draw_y_3(draw_y[3]),
        .color_hold(color_out)
    );

    // Output fifos
    wire [31:0] f_out;
    wire fo_rts_ae, ae_rtr_fo;
    ellipse_buffer_out #(32, `E_OUT_FIFO_DEPTH, `E_OUT_FIFO_LOG2DEPTH) fo (
        .clk(clk),
        .rst_(rst_),

        .in_px_0({ draw_x[0], draw_y[0], color_out}),
        .in_px_1({ draw_x[1], draw_y[1], color_out}),
        .in_px_2({ draw_x[2], draw_y[2], color_out}),
        .in_px_3({ draw_x[3], draw_y[3], color_out}),

        .in_rts(ed_rts_fx),
        .in_rtr(rx_rtr_ed),

        .out_data(f_out),
        .out_rts(fo_rts_ae),
        .out_rtr(ae_rtr_fo)
    );

    // Addressing engine
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


    // Read-Modify-Write engine
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
