`timescale 1ns / 1ps

module circle_buffer_out(

    // clock and sync reset
    input clk,
    input rst_,

    // Input Interface
    input [31:0] in_px_0,
    input [31:0] in_px_1,
    input [31:0] in_px_2,
    input [31:0] in_px_3,
    input [31:0] in_px_4,
    input [31:0] in_px_5,
    input [31:0] in_px_6,
    input [31:0] in_px_7,
    input in_rts,
    output in_rtr,

    // Output Interface
    output [31:0] out_data,
    output out_rts,
    input  out_rtr
);

    // set for expected word-length being saved and queue depth
    parameter DATA_WIDTH    = 12;
    parameter DEPTH         = 64;
    parameter LOG2DEPTH     = 6;

    // buffer components
    reg  [LOG2DEPTH-1:0] rd_addr;
    reg  [LOG2DEPTH-1:0] wr_addr;
    wire [LOG2DEPTH-1:0] next_wr_addr_8, next_wr_addr_7, next_wr_addr_6, next_wr_addr_5;
    wire [LOG2DEPTH-1:0] next_wr_addr_4, next_wr_addr_3, next_wr_addr_2, next_wr_addr_1;

    reg [DATA_WIDTH-1:0] queue [0:(DEPTH-1)];

    // transfer complete signals
    wire in_xfc;
    wire out_xfc;

    assign in_xfc   = in_rtr & in_rts;
    assign out_xfc  = out_rts & out_rtr;

    assign next_wr_addr_8 = wr_addr + 8;
    assign next_wr_addr_7 = wr_addr + 7;
    assign next_wr_addr_6 = wr_addr + 6;
    assign next_wr_addr_5 = wr_addr + 5;
    assign next_wr_addr_4 = wr_addr + 4;
    assign next_wr_addr_3 = wr_addr + 3;
    assign next_wr_addr_2 = wr_addr + 2;
    assign next_wr_addr_1 = wr_addr + 1;

    assign in_rtr       = (in_rts) & ((next_wr_addr_8 != rd_addr) &
                                      (next_wr_addr_7 != rd_addr) &
                                      (next_wr_addr_6 != rd_addr) &
                                      (next_wr_addr_5 != rd_addr) &
                                      (next_wr_addr_4 != rd_addr) &
                                      (next_wr_addr_3 != rd_addr) &
                                      (next_wr_addr_2 != rd_addr) &
                                      (next_wr_addr_1 != rd_addr));

    assign out_rts      = (rd_addr != wr_addr);

    // output data
    assign out_data = queue[rd_addr];

    always@(posedge clk or negedge rst_)
    begin

        if (!rst_)
        begin
            rd_addr <= 0;
            wr_addr <= 0;
        end

        else
        begin

            if (in_xfc)
            begin
                queue[wr_addr+0] <= in_px_0;
                queue[wr_addr+1] <= in_px_1;
                queue[wr_addr+2] <= in_px_2;
                queue[wr_addr+3] <= in_px_3;
                queue[wr_addr+4] <= in_px_4;
                queue[wr_addr+5] <= in_px_5;
                queue[wr_addr+6] <= in_px_6;
                queue[wr_addr+7] <= in_px_7;

                wr_addr <= next_wr_addr_8;
             end

            if (out_xfc)
                rd_addr <= rd_addr + 1;

        end

    end

endmodule
