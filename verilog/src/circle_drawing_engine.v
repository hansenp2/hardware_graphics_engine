`timescale 1ns / 1ps

// INPUT FIFO PARAMETERS
`define C_IN_FIFO_DATA_WIDTH  128
`define C_IN_FIFO_DEPTH        4
`define C_IN_FIFO_LOG2DEPTH    2

// OUTPUT FIFO PARAMETERS
`define C_OUT_FIFO_DATA_WIDTH  10
`define C_OUT_FIFO_DEPTH      128
`define C_OUT_FIFO_LOG2DEPTH    7

module circle_drawing_engine(

    // clock and sync reset
    input clk,
    input rst_,

    // input interface
    input [`C_IN_FIFO_DATA_WIDTH-1:0] in_op,
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
    wire [`C_IN_FIFO_DATA_WIDTH-1:0] current_op;
    wire fi_rts_cd, cd_rtr_fi;
    fifo #(`C_IN_FIFO_DATA_WIDTH, `C_IN_FIFO_DEPTH, `C_IN_FIFO_LOG2DEPTH) fi (
        .clk(clk),
        .rst_(rst_),

        .in_data(in_op),
        .in_rts(in_rts),
        .in_rtr(in_rtr),

        .out_data(current_op),
        .out_rts(fi_rts_cd),
        .out_rtr(cd_rtr_fi)
    );


    // TEMPORARY VALUES FOR TESTING
    reg [ 9:0] x0, y0, r;
    reg [11:0] color;

    always @ (posedge clk or negedge rst_)
    begin
        if (!rst_)
        begin
            x0 <= 0;
            y0 <= 0;
            r <= 0;
            color <= 0;
        end

        else
        begin
            if (fi_rts_cd && cd_rtr_fi)
            begin
                x0 <= {current_op[7:0], current_op[15:8]};
                y0 <= {current_op[23:16], current_op[31:24]};
                r <= {current_op[39:32], current_op[47:40]};
                color <= {current_op[67:64], current_op[59:56], current_op[51:48]};
            end
        end
    end


    // line drawing algorithm module
    wire cd_rts_fx, rx_rtr_cd;
    wire [9:0] draw_x [0:7];
    wire [9:0] draw_y [0:7];
    circle_drawer cd (
        .clk(clk),
        .rst_(rst_),
        .x0_in(x0),
        .y0_in(y0),
        .r_in(r),
        .color(color),

        .in_rts(fi_rts_cd),
        .in_rtr(cd_rtr_fi),

        .out_rts(cd_rts_fx),
        .out_rtr(rx_rtr_cd),

        .draw_x_0(draw_x[0]),
        .draw_x_1(draw_x[1]),
        .draw_x_2(draw_x[2]),
        .draw_x_3(draw_x[3]),
        .draw_x_4(draw_x[4]),
        .draw_x_5(draw_x[5]),
        .draw_x_6(draw_x[6]),
        .draw_x_7(draw_x[7]),

        .draw_y_0(draw_y[0]),
        .draw_y_1(draw_y[1]),
        .draw_y_2(draw_y[2]),
        .draw_y_3(draw_y[3]),
        .draw_y_4(draw_y[4]),
        .draw_y_5(draw_y[5]),
        .draw_y_6(draw_y[6]),
        .draw_y_7(draw_y[7])
    );


    // output fifos (WILL NEED TO MAKE THIS CUSTOM - ACCEPT 8 WRITES AT ONCE)
    wire [31:0] f_out;
    wire fo_rts_ae, ae_rtr_fo;
    circle_buffer_out #(32, `C_OUT_FIFO_DEPTH, `C_OUT_FIFO_LOG2DEPTH) fo (
        .clk(clk),
        .rst_(rst_),

        .in_px_0({ draw_x[0], draw_y[0], color}),
        .in_px_1({ draw_x[1], draw_y[1], color}),
        .in_px_2({ draw_x[2], draw_y[2], color}),
        .in_px_3({ draw_x[3], draw_y[3], color}),
        .in_px_4({ draw_x[4], draw_y[4], color}),
        .in_px_5({ draw_x[5], draw_y[5], color}),
        .in_px_6({ draw_x[6], draw_y[6], color}),
        .in_px_7({ draw_x[7], draw_y[7], color}),

        .in_rts(cd_rts_fx),
        .in_rtr(rx_rtr_cd),

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
