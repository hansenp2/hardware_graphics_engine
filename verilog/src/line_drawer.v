`timescale 1ns / 1ps

`define L_START_STATE       0
`define L_INIT_STATE        1
`define L_GET_ERROR_STATE   2
`define L_DRAW_STATE_1      3
`define L_DRAW_STATE_2      4
`define L_END_STATE         5

module line_drawer (

    // Clock and Sync Reset
    input clk,
    input rst_,

    // Point 1
    input [9:0] x1_in, y1_in,

    // Point 2
    input [9:0] x2_in, y2_in,

    input [11:0] color,

    // input interface
    input  in_rts,
    output in_rtr,

    // output interface
    output  out_rts,
    input   out_rtr,

    output reg [9:0] draw_x, draw_y,
    output reg [11:0] color_hold
);

    // Hold coordinates for duration of operation
    reg [9:0] x1_hold, y1_hold, x2_hold, y2_hold;

    // Determines driving axis of line
    wire [9:0] dx, dy;
    assign dx = (x2_hold >= x1_hold) ? (x2_hold - x1_hold) : (x1_hold - x2_hold);
    assign dy = (y2_hold >= y1_hold) ? (y2_hold - y1_hold) : (y1_hold - y2_hold);

    // Order points properly
    wire [9:0] x1, x2, y1, y2;

    assign x1 = (dx >= dy) ?
        ((x1_hold <= x2_hold)  ? (x1_hold) : (x2_hold)) :
        ((y1_hold <= y2_hold)  ? (x1_hold) : (x2_hold)) ;

    assign y1 = (dx >= dy) ?
        ((x1_hold <= x2_hold)  ? (y1_hold) : (y2_hold)) :
        ((y1_hold <= y2_hold)  ? (y1_hold) : (y2_hold)) ;

    assign x2 = (dx >= dy) ?
        ((x1_hold <= x2_hold)  ? (x2_hold) : (x1_hold)) :
        ((y1_hold <= y2_hold)  ? (x2_hold) : (x1_hold)) ;

    assign y2 = (dx >= dy) ?
        ((x1_hold <= x2_hold)  ? (y2_hold) : (y1_hold)) :
        ((y1_hold <= y2_hold)  ? (y2_hold) : (y1_hold)) ;

    // Line drawing state machine
    reg [2:0] state;
    reg signed [9:0] error;

    // Transfer complete signals
    wire in_xfc, out_xfc;
    assign in_xfc  = in_rts  & in_rtr;
    assign out_xfc = out_rts & out_rtr;

    // Ready to recieve when in start state
    assign in_rtr  = (state == `L_START_STATE) ? 1 : 0;

    // Ready to send when in either draw state
    assign out_rts = (state == `L_DRAW_STATE_1 || state == `L_DRAW_STATE_2) ? 1 : 0;

    always @ (posedge clk or negedge rst_)
    begin
        if (!rst_)
            state <= `L_START_STATE;

        else
        begin
            case (state)
                `L_START_STATE:
                begin
                    if (in_xfc)
                        state <= `L_INIT_STATE;
                end

                `L_INIT_STATE:
                    state <= `L_GET_ERROR_STATE;

                `L_GET_ERROR_STATE:
                    state <= (dx >= dy) ? `L_DRAW_STATE_1 : `L_DRAW_STATE_2;

                // Draw state 1 (x is driving axis)
                `L_DRAW_STATE_1:
                begin
                    if (out_xfc)
                        state <= (draw_x < x2) ? `L_DRAW_STATE_1 : `L_END_STATE;
                end

                // Draw state 2 (y is driving axis)
                `L_DRAW_STATE_2:
                begin
                    if (out_xfc)
                        state <= (draw_y < y2) ? `L_DRAW_STATE_2 : `L_END_STATE;
                end

                `L_END_STATE:
                    state <= `L_START_STATE;

                default:
                    state <= 0;
            endcase
         end
    end

    // Line drawer
    always @ (posedge clk or negedge rst_)
    begin
        if (!rst_)
        begin
            x1_hold <= 0;
            y1_hold <= 0;
            x2_hold <= 0;
            y2_hold <= 0;
            color_hold <= 0;
            draw_x <= 0;
            draw_y <= 0;
            error <= 0;
        end

        else
        begin
            case (state)
                `L_START_STATE:
                begin
                    if (in_xfc)
                    begin
                        x1_hold <= x1_in;
                        y1_hold <= y1_in;
                        x2_hold <= x2_in;
                        y2_hold <= y2_in;
                        color_hold <= color;
                        draw_x <= 0;
                        draw_y <= 0;
                    end
                end

                `L_INIT_STATE:
                begin
                    draw_y <= y1;
                    draw_x <= x1;
                end

                `L_GET_ERROR_STATE:
                    error <= (dx >= dy) ? (dy - dx) : (dx - dy);

                `L_DRAW_STATE_1:
                begin
                    if (out_xfc)
                    begin
                        // $display("!WRITE PX (%d,%d) --> %d", draw_x, draw_y, $signed(error));
                        if (error >= 0)
                            draw_y = (y1 >= y2) ? (draw_y - 1) : (draw_y + 1);

                        error  <= (error >= 0) ? (error - dx + dy) : (error + dy);
                        draw_x <= draw_x + 1;
                    end
                end

                `L_DRAW_STATE_2:
                begin
                    if (out_xfc)
                    begin
                        // $display("WRITE PX (%d,%d) --> %d", draw_x, draw_y, $signed(error));
                        if (error >= 0)
                            draw_x = (x1 >= x2) ? (draw_x - 1) : (draw_x + 1);

                        error  <= (error >= 0) ? (error - dy + dx) : (error + dx);
                        draw_y <= draw_y + 1;
                    end
                end

                default:
                begin
                    x1_hold <= 0;
                    y1_hold <= 0;
                    x2_hold <= 0;
                    y2_hold <= 0;
                    color_hold <= 0;
                    draw_x <= 0;
                    draw_y <= 0;
                    error <= 0;
                end
            endcase
        end

    end

endmodule
