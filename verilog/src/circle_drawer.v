`timescale 1ns / 1ps

`define INIT_STATE  0
`define START_STATE 1
`define DRAW_STATE  2
`define END_STATE   3

module circle_drawer(

    // Clock and sync reset
    input clk,
    input rst_,

    // Circle values
    input [9:0] x0_in,
    input [9:0] y0_in,
    input [9:0] r_in,
    input [11:0] color,

    // Input interface
    input  in_rts,
    output in_rtr,

    // Output interface
    output  out_rts,
    input   out_rtr,

    output [9:0] draw_x_0, draw_x_1, draw_x_2, draw_x_3,
    output [9:0] draw_x_4, draw_x_5, draw_x_6, draw_x_7,

    output [9:0] draw_y_0, draw_y_1, draw_y_2, draw_y_3,
    output [9:0] draw_y_4, draw_y_5, draw_y_6, draw_y_7
);

    // Circle drawing variables
    reg [9:0] x, y;

    // Circle drawing components
    reg [1:0] state;
    reg signed [9:0] dx, dy;
    reg signed [9:0] error;

    // Transfer completes
    wire in_xfc, out_xfc;
    assign in_xfc  = in_rts  & in_rtr;
    assign out_xfc = out_rts & out_rtr;

    // Ready to recieve when in state START STATE
    assign in_rtr  = (state == `START_STATE) ? (1) : (0);

    // Ready to send when in state DRAW STATE
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
                state <= `DRAW_STATE;

            // Draw state
            else if (state == `DRAW_STATE && out_xfc == 1)
                state <= (x >= y) ? (`DRAW_STATE) : (`END_STATE);

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
            if (state == `START_STATE && in_xfc == 1)
            begin
                x  <= r_in;
                y  <= 0;
                dx <= 1 - (r_in << 1);
                dy <= 1;
                error <= 0;
            end

            else if (state == `DRAW_STATE && out_xfc == 1)
            begin
                // Write pixel data
                $display("*%d\t%d\t%d\t%d\t%d", x, y, $signed(dx), $signed(dy), $signed(error));

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
        end
    end

    assign draw_x_0 = x0_in + x; assign draw_y_0 = y0_in + y;
    assign draw_x_1 = x0_in + y; assign draw_y_1 = y0_in + x;
    assign draw_x_2 = x0_in - y; assign draw_y_2 = y0_in + x;
    assign draw_x_3 = x0_in - x; assign draw_y_3 = y0_in + y;
    assign draw_x_4 = x0_in - x; assign draw_y_4 = y0_in - y;
    assign draw_x_5 = x0_in - y; assign draw_y_5 = y0_in - x;
    assign draw_x_6 = x0_in + y; assign draw_y_6 = y0_in - x;
    assign draw_x_7 = x0_in + x; assign draw_y_7 = y0_in - y;

endmodule
