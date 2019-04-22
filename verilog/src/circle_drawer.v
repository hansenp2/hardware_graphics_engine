`timescale 1ns / 1ps

`define C_START_STATE         0
`define C_INIT_STATE          1
`define C_PRE_DRAW_STATE      2
`define C_DRAW_STATE          3
`define C_DRAW_SETUP_STATE    4
`define C_END_STATE           5

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
    output reg [9:0] draw_y_4, draw_y_5, draw_y_6, draw_y_7,
    output reg [11:0] color_hold
);

    reg [9:0] x0_hold;
    reg [9:0] y0_hold;
    reg [9:0] r_hold;

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

    // Ready to recieve when in start state
    assign in_rtr  = (state == `C_START_STATE) ? (1) : (0);

    // Ready to send when in draw state
    assign out_rts = (state == `C_DRAW_STATE) ? (1) : (0);

    // State machine
    always @ (posedge clk or negedge rst_)
    begin
        if (!rst_)
            state <= `C_START_STATE;

        else
        begin

            case (state)
                `C_START_STATE:
                begin
                    if (in_xfc)
                        state <= `C_INIT_STATE;
                end

                `C_INIT_STATE:
                    state <= `C_PRE_DRAW_STATE;

                `C_PRE_DRAW_STATE:
                    state <= (x >= y) ? `C_DRAW_STATE : `C_END_STATE;

                `C_DRAW_STATE:
                begin
                    if (out_xfc)
                        state <= `C_DRAW_SETUP_STATE;
                end

                `C_DRAW_SETUP_STATE:
                    state <= `C_PRE_DRAW_STATE;

                `C_END_STATE:
                    state <= `C_START_STATE;
            endcase

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
            x0_hold <= 0;
            y0_hold <= 0;
            r_hold <= 0;
            color_hold <= 0;
        end

        else
        begin
            case (state)
                `C_START_STATE:
                begin
                    x0_hold <= x0_in;
                    y0_hold <= y0_in;
                    r_hold <= r_in;
                    color_hold <= color;
                end

                `C_INIT_STATE:
                begin
                    x  <= r_hold;
                    y  <= 0;
                    dx <= 1 - (r_hold << 1);
                    dy <= 1;
                    error <= 0;
                end

                `C_PRE_DRAW_STATE:
                begin
                    draw_x_0 <= x0_hold + x; draw_y_0 <= y0_hold + y;
                    draw_x_1 <= x0_hold + y; draw_y_1 <= y0_hold + x;
                    draw_x_2 <= x0_hold - y; draw_y_2 <= y0_hold + x;
                    draw_x_3 <= x0_hold - x; draw_y_3 <= y0_hold + y;
                    draw_x_4 <= x0_hold - x; draw_y_4 <= y0_hold - y;
                    draw_x_5 <= x0_hold - y; draw_y_5 <= y0_hold - x;
                    draw_x_6 <= x0_hold + y; draw_y_6 <= y0_hold - x;
                    draw_x_7 <= x0_hold + x; draw_y_7 <= y0_hold - y;
                end

                `C_DRAW_SETUP_STATE:
                begin
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
            endcase

        end
    end

endmodule
