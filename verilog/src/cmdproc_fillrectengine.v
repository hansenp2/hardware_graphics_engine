`timescale 1ns / 1ps

module cmd_processor_engines_integration(
    input           clk,
    input           rst_
    );
    
    wire    [7:0]   cmd_proc_bcast_data;
    wire    [4:0]   cmd_proc_out_rts;
    wire    [4:0]   cmd_proc_in_rtr;
    
    
    wire    [31:0]  arb_fill_rect_data;
    wire    [15:0]  arb_fill_rect_addr;
    wire    [3:0]   arb_fill_rect_wben;
    wire            arb_fill_rect_rtr;
    wire            arb_fill_rect_rts;
    wire            arb_fill_rect_op;
    wire    [31:0]  arb_out_bcast_data;
    wire            arb_out_xfc;
    
    // Psuedo I2C Engine
    always @(posedge clk or negedge rst_)
    begin
        
    end
    
    cmd_processor cmd_processor(
        .clk(clk),
        .rst_(rst_),
        .i2c_in_data(),
        .engine_out_rts(cmd_proc_out_rts),
        .engine_in_rtr(cmd_proc_in_rtr),
        .bcast_out_data(cmd_proc_bcast_data)
        );
        
    fill_rect_engine rect_fill_engine(
        .clk(clk),
        .rst_(rst_),
        .cmd_in_data(cmd_proc_bcast_data),
        .cmd_out_rtr(cmd_proc_in_rtr[1]),
        .cmd_in_rts(cmd_proc_out_rts[1]),
        .arb_out_data(arb_fill_rect_data),
        .arb_out_addr(arb_fill_rect_addr),
        .arb_out_wben(arb_fill_rect_wben),
        .arb_in_rtr(arb_fill_rect_rtr),
        .arb_out_rts(arb_fill_rect_rts),
        .arb_out_op(arb_fill_rect_op),
        .arb_bcast_in_data(arb_out_bcast_data),
        .arb_bcast_in_xfc(arb_out_xfc)
        );
endmodule
