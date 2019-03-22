`timescale 1ns / 1ps

`define E_START_STATE           0
`define E_INIT_STATE            1
`define E_PRE_DRAW_STATE_1      2
`define E_PRE_DRAW_STATE_2      3
`define E_DRAW_STATE            4
`define E_POST_DRAW_STATE       5
`define E_DRAW_SETUP_STATE_1    6
`define E_DRAW_SETUP_STATE_2    7
`define E_END_STATE             8

module ellipse_drawer(
    input clk,
    input rst_,

    input [9:0] x0_in, y0_in,
    input [9:0] a_in, b_in,
    input [11:0] color,

    // input interface
    input  in_rts,
    output in_rtr,

    // output interface
    output  out_rts,
    input   out_rtr,

    output reg [9:0] draw_x_0, draw_x_1, draw_x_2, draw_x_3,
    output reg [9:0] draw_y_0, draw_y_1, draw_y_2, draw_y_3,
    output reg [11:0] color_hold
);

    reg [9:0] x0_hold, y0_hold;
    reg [9:0] a_hold, b_hold;

    // Ellipse variables
    reg [9:0] x, y;
    reg signed [31:0] d1, d2;

    // Temporary variables
    wire signed [31:0] t1, t2, t3;
    wire signed [31:0] t4, t5, t6, t7;
    reg  signed [31:0] t8, t9;
    reg [2:0] state;

    // Transfer completes
    wire in_xfc, out_xfc;
    assign in_xfc  = in_rts  & in_rtr;
    assign out_xfc = out_rts & out_rtr;

    // Ready to recieve when in start state
    assign in_rtr  = (state == `E_START_STATE) ? 1 : 0;

    // Ready to send when in draw state
    assign out_rts = (state == `E_DRAW_STATE) ? 1 : 0;

    // State machine
    always @ (posedge clk or negedge rst_)
    begin
        if (!rst_)
            state <= `E_START_STATE;

        else
        begin
            case (state)
                `E_START_STATE:
                begin
                    if (in_xfc)
                        state <= `E_INIT_STATE;
                end

                `E_INIT_STATE:
                    state <= `E_PRE_DRAW_STATE_1;

                `E_PRE_DRAW_STATE_1:
                    state <= `E_DRAW_STATE;

                `E_PRE_DRAW_STATE_2:
                begin
                    if (x != ((2 << 9) - 1))
                        state <= `E_DRAW_STATE;
                    else
                        state <= `E_END_STATE;
                end

                `E_DRAW_STATE:
                begin
                    if (out_xfc)
                        state <= `E_POST_DRAW_STATE;
                end

                `E_POST_DRAW_STATE:
                begin
                    if (d2 < 0)
                        state <= `E_DRAW_SETUP_STATE_1;
                    else
                        state <= `E_DRAW_SETUP_STATE_2;
                end

                `E_DRAW_SETUP_STATE_1:
                    state <= `E_PRE_DRAW_STATE_1;

                `E_DRAW_SETUP_STATE_2:
                    state <= `E_PRE_DRAW_STATE_2;

                `E_END_STATE:
                    state <= `E_START_STATE;

                default:
                    state <= 0;
            endcase
        end
    end

    // Drawing engine
    assign t1 = a_hold ** 2;
    assign t2 = t1 << 1;
    assign t3 = t2 << 1;
    assign t4 = b_hold ** 2;
    assign t5 = t4 << 1;
    assign t6 = t5 << 1;
    assign t7 = a_hold * t5;

    always @ (posedge clk or negedge rst_)
    begin

        if (!rst_)
        begin
            x <= 0;
            y <= 0;
            d1 <= 0;
            d2 <= 0;
            t8 <= 0;
            t9 <= 0;
            x0_hold <= 0;
            y0_hold <= 0;
            a_hold <= 0;
            b_hold <= 0;
            color_hold <= 0;
        end

        else
        begin
            case (state)
                `E_START_STATE:
                begin
                    if (in_xfc)
                    begin
                        x0_hold <= x0_in;
                        y0_hold <= y0_in;
                        a_hold <= a_in;
                        b_hold <= b_in;
                        color_hold <= color;
                        x <= 0;
                        y <= 0;
                    end
                end

                `E_INIT_STATE:
                begin
                    x <= a_hold;
                    y <= 0;
                    t8 <= t7 << 1;
                    t9 <= 0;
                    d1 <= (t2 - t7 + t4) >>> 1;
                    d2 <= (t1 >>> 1) - (t7 << 1) + t5;
                end

                `E_PRE_DRAW_STATE_1:
                begin
                    draw_x_0 <= x0_hold + x; draw_y_0 <= y0_hold + y;
                    draw_x_1 <= x0_hold + x; draw_y_1 <= y0_hold - y;
                    draw_x_2 <= x0_hold - x; draw_y_2 <= y0_hold + y;
                    draw_x_3 <= x0_hold - x; draw_y_3 <= y0_hold - y;
                end

                `E_PRE_DRAW_STATE_2:
                begin
                    draw_x_0 <= x0_hold + x; draw_y_0 <= y0_hold + y;
                    draw_x_1 <= x0_hold + x; draw_y_1 <= y0_hold - y;
                    draw_x_2 <= x0_hold - x; draw_y_2 <= y0_hold + y;
                    draw_x_3 <= x0_hold - x; draw_y_3 <= y0_hold - y;
                end

                `E_DRAW_SETUP_STATE_1:
                begin
                    if (d2 < 0)
                    begin
                        y <= y + 1;
                        t9 <= t9 + t3;

                        if (d1 < 0)
                        begin
                            d1 <= d1 + (t9 + t3) + t2;
                            d2 <= d2 + (t9 + t3);
                        end

                        else
                        begin
                            x <= x - 1;
                            t8 <= t8 - t6;
                            d1 <= d1 - (t8 - t6) + (t9 + t3) + t2;
                            d2 <= d2 - (t8 - t6) + t5 + (t9 + t3);
                        end
                    end
                end

                `E_DRAW_SETUP_STATE_2:
                begin
                    x  <= x - 1;
                    t8 <= t8 - t6;

                    if (d2 < 0)
                    begin
                        y  <= y + 1;
                        t9 <= t9 + t3;
                        d2 <= d2 - (t8 - t6) + t5 + (t9 + t3);
                    end

                    else
                        d2 <= d2 - (t8 - t6) + t5;
                end
            endcase
        end

    end

endmodule
