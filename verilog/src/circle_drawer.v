`timescale 1ns / 1ps

`define START_STATE         0
`define INIT_STATE          1
`define PRE_DRAW_STATE      2
`define DRAW_STATE          3
`define DRAW_SETUP_STATE    4
`define END_STATE           5

module circle_drawer(

    // clock and sync reset
    input clk,
    input rst_,

    // circle values
    input [9:0] x0_in,
    input [9:0] y0_in,
    input [9:0] r_in,
    input [11:0] color,

    // input interface
    input  in_rts,
    output in_rtr,

    // output interface
    output  out_rts,
    input   out_rtr,

    output reg [9:0] draw_x_0, draw_x_1, draw_x_2, draw_x_3,
    output reg [9:0] draw_x_4, draw_x_5, draw_x_6, draw_x_7,

    output reg [9:0] draw_y_0, draw_y_1, draw_y_2, draw_y_3,
    output reg [9:0] draw_y_4, draw_y_5, draw_y_6, draw_y_7
);

    // Circle Drawing Variables
    reg [9:0] x, y;

    // Circle Drawing Components
    reg [2:0] state;
    reg signed [9:0] dx, dy;
    reg signed [9:0] error;

    // Transfer completes
    wire in_xfc, out_xfc;
    assign in_xfc  = in_rts  & in_rtr;
    assign out_xfc = out_rts & out_rtr;

    // Ready to recieve when in state 00
    assign in_rtr  = (state == `START_STATE) ? (1) : (0);

    // Ready to send when in state 01 or 10
    assign out_rts = (state == `DRAW_STATE) ? (1) : (0);

    // State machine
    always @ (posedge clk or negedge rst_)
    begin
        if (!rst_)
            state <= `START_STATE;

        else
        begin

            // Start state
            if (state == `START_STATE && in_xfc == 1)
                state <= `INIT_STATE;

            // Init state
            if (state == `INIT_STATE)
                state <= `PRE_DRAW_STATE;

            if (state == `PRE_DRAW_STATE)
                state <= (x >= y) ? (`DRAW_STATE) : (`END_STATE);

            if (state == `DRAW_STATE && out_xfc == 1)
                state <= `DRAW_SETUP_STATE;

            if (state == `DRAW_SETUP_STATE)
                state <= `PRE_DRAW_STATE;

            // End state
            else if (state == `END_STATE)
                state <= `START_STATE;
        end
    end

    // Drawing Engine
    always @ (posedge clk or negedge rst_)
    begin

        if (!rst_)
        begin
            x <= 0;
            y <= 0;
            dx <= 0;
            dy <= 0;
            error <= 0;
        end

        else
        begin
            if (state == `INIT_STATE)
            begin
                x  <= r_in;
                y  <= 0;
                dx <= 1 - (r_in << 1);
                dy <= 1;
                error <= 0;
                $display("*******************");
            end

            //else if (state == `DRAW_STATE)
            else if (state == `PRE_DRAW_STATE)
            begin
                draw_x_0 <= x0_in + x; draw_y_0 <= y0_in + y;
                draw_x_1 <= x0_in + y; draw_y_1 <= y0_in + x;
                draw_x_2 <= x0_in - y; draw_y_2 <= y0_in + x;
                draw_x_3 <= x0_in - x; draw_y_3 <= y0_in + y;
                draw_x_4 <= x0_in - x; draw_y_4 <= y0_in - y;
                draw_x_5 <= x0_in - y; draw_y_5 <= y0_in - x;
                draw_x_6 <= x0_in + y; draw_y_6 <= y0_in - x;
                draw_x_7 <= x0_in + x; draw_y_7 <= y0_in - y;
            end

            else if (state == `DRAW_SETUP_STATE)
            begin
                // Write pixel data
                // $display("*%d\t%d\t%d\t%d\t%d", x, y, $signed(dx), $signed(dy), $signed(error));

                if ( (((error + dy) << 1) + dx) > 0 )
                begin
                    x <= x - 1;
                    error <= error + dx;
                    dx <= dx + 2;
                end

                else
                begin
                    y <= y + 1;
                    error <= error + dy;
                    dy <= dy + 2;
                end
            end

            else if (state == `DRAW_STATE && out_xfc == 1)
                $display("(%d,%d), (%d,%d), (%d,%d), (%d,%d), (%d,%d), (%d,%d), (%d,%d), (%d,%d)",
                    x0_in + x, y0_in + y,
                    x0_in + y, y0_in + x,
                    x0_in - y, y0_in + x,
                    x0_in - x, y0_in + y,
                    x0_in - x, y0_in - y,
                    x0_in - y, y0_in - x,
                    x0_in + y, y0_in - x,
                    x0_in + x, y0_in - y);

        end
    end

endmodule
