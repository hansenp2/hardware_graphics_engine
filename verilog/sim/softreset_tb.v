`timescale 1ns / 1ps

module softreset_tb();

    reg clk;
    reg rst_;
    wire sftrst_;
    
    reg cmd_rts_in;
    wire cmd_rtr_out;
    
    wire [16:0] arb_addr;
    wire [31:0] arb_wr_data;
    wire arb_rts_out;
    reg arb_rtr_in;
    wire [3:0] arb_op;
    
    softreset uut (
    .clk(clk),
    .rst_(rst_), //not sure if needed
    .sftrst_(sftrst_),
    
    .cmd_rts_in(cmd_rts_in),
    .cmd_rtr_out(cmd_rtr_out),
    
    .arb_addr(arb_addr),
    .arb_wr_data(arb_wr_data),
    .arb_rts_out(arb_rts_out),
    .arb_rtr_in(arb_rtr_in),
    .arb_op(arb_op)
    );
    
    initial begin
        clk = 0;
            forever begin
                #5;
                clk = ~clk;
            end
    end
    
    initial begin
        rst_ = 0;
        cmd_rts_in = 0;
        arb_rtr_in = 1;
        
        #12;
        rst_ = 1;
        
        #38;
        cmd_rts_in = 1;
        
        #20;
        cmd_rts_in = 0;
    end

endmodule
