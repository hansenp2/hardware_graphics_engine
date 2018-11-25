`timescale 1ns / 1ps

module cmd_proc_fifo_integration(
    input               clk,
    input               rst_,
    input   [7:0]       i2c_in_data,
    input   [7:0]       cmd,
    input               i2c_rts
    );
    
    wire                i2c_rtr;
    
    wire    [7:0]       cmd_proc_bcast_data;
    wire    [4:0]       cmd_proc_rtr;
    wire    [4:0]       cmd_proc_rts;
    
    wire    [7:0]       generator_data;
    wire                generator_rtr;
    wire                generator_rts;
    
    cmd_processor cmd_proc(
        .clk(clk),
        .rst_(rst_),
        // I2C Interface
        .cmd(cmd),
        .i2c_in_data(i2c_in_data),
        .i2c_rts(i2c_rts),
        .i2c_rtr(i2c_rtr),
        // Engine Interface
        .engine_out_rts(cmd_proc_rts),
        .engine_in_rtr(cmd_proc_rtr),
        .bcast_out_data(cmd_proc_bcast_data)
        );
        
    wire fifo_rtr;  
    wire fifo_rts;
    
    fifo #(.DATA_WIDTH(8),
           .DEPTH(16),
           .LOG2DEPTH(4)) fifo(
        .clk(clk),
        .rst_(rst_),
        // Cmd Proc Interface
        .in_data(cmd_proc_bcast_data),
        .in_rtr(fifo_rtr),
        .in_rts(fifo_rts),
        // Generator Interface
        .out_data(generator_data),
        .out_rtr(generator_rtr),
        .out_rts(generator_rts)
        );
          
    assign cmd_proc_rtr = {1'b0, 1'b0, 1'b0, fifo_rtr, 1'b0};
    assign fifo_rts = cmd_proc_rts[1];   
endmodule
