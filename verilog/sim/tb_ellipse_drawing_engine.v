`timescale 1ns / 1ps

module tb_ellipse_drawing_engine;

    // Clock and Sync Reset
    reg clk;
    reg rst_;

    reg [51:0] in_op;
    reg in_rts;
    wire in_rtr;

    wire out_rts;
    reg out_rtr;

    // Unit Under Test
    ellipse_drawing_engine uut(
        .clk(clk),
        .rst_(rst_),
        .in_op(in_op),
        .in_rts(in_rts),
        .in_rtr(in_rtr),
        .out_rts(out_rts),
        .out_rtr(out_rtr)
    );

    initial
    begin

        clk     = 1'b0;
        rst_    = 1'b1;

        out_rtr = 1;
        in_rts = 1;

        #10;

        #5 rst_ = ~rst_; clk = ~clk;
        #5 rst_ = ~rst_; clk = ~clk;

        // load first op
        #5;
            clk = ~clk;
            in_rts = 1;
            in_op = 52'b0000000010_0000000010_0000000010_0000000010_111111111111;
        #5;
            clk = ~clk;

        /* // load second op
        #5;
            clk = ~clk;
            in_rts = 1;
            in_op = 42'b0001100100_0001100100_0000001010_101010111100;
        #5;
            clk = ~clk;

        // load third op
        #5;
            clk = ~clk;
            in_rts = 1;
            in_op = 42'b0000000000000000000000000010100000000000101010111100;
        #5;
            clk = ~clk; */

        #5;
            clk = ~clk;
            in_rts = 0;
        #5;
            clk = ~clk;

        repeat(200)
        begin
            #5 clk = ~clk;
        end

    end

endmodule
