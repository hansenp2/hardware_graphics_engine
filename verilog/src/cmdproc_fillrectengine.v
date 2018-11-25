`timescale 1ns / 1ps

module cmd_processor_engines_integration(
    input           clk,
    input           rst_,
    // I2C Interface
    input   [7:0]   i2c_cmd,
    input   [7:0]   i2c_data,
    input           i2c_rtr,
    input           i2c_rts,
    // Arbiter Interface
    output  [31:0]  arb_fill_rect_data,
    output  [15:0]  arb_fill_rect_addr,
    output  [3:0]   arb_fill_rect_wben,
    output          arb_fill_rect_op,
    output          arb_fill_rect_rts,
    input           arb_fill_rect_rtr,
    input   [31:0]  arb_out_bcast_data,
    input           arb_out_xfc
    );
    
    wire    [7:0]   cmd_proc_bcast_data;
    wire    [4:0]   cmd_proc_engines_rts;
    wire    [4:0]   cmd_proc_engines_rtr;
    wire            fill_rect_engine_rtr;
    wire            fill_rect_engine_rts;
    
    cmd_processor cmd_processor(
        .clk(clk),
        .rst_(rst_),
        // I2C Interface
        .cmd(i2c_cmd),
        .i2c_in_data(i2c_data),
        .i2c_rtr(i2c_rtr),
        .i2c_rts(i2c_rts),
        // Engine Output Interface
        .engine_out_rts(cmd_proc_engines_rts),
        .engine_in_rtr(cmd_proc_engines_rtr),
        .bcast_out_data(cmd_proc_bcast_data)
        );
        
    fill_rect_engine fill_rect_eng(
        .clk(clk),
        .rst_(rst_),
        // Command Processor Interface
        .cmd_in_data(cmd_proc_bcast_data),
        .cmd_out_rtr(fill_rect_engine_rtr),
        .cmd_in_rts(fill_rect_engine_rts),
        // Arbiter Interface
        .arb_out_data(arb_fill_rect_data),
        .arb_out_addr(arb_fill_rect_addr),
        .arb_out_wben(arb_fill_rect_wben),
        .arb_in_rtr(arb_fill_rect_rtr),
        .arb_out_rts(arb_fill_rect_rts),
        .arb_out_op(arb_fill_rect_op),
        .arb_bcast_in_data(arb_out_bcast_data),
        .arb_bcast_in_xfc(arb_out_xfc)
        );
        
    assign cmd_proc_engines_rtr = {1'b0, 1'b0, 1'b0, fill_rect_engine_rtr, 1'b0};
    assign fill_rect_engine_rts =  cmd_proc_engines_rts[1];
     
        
endmodule
