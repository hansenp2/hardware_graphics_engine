`timescale 1ns / 1ps
`define CLK 20
module rect_generator_tb(
    );
    reg CLOCK;
    reg RESET;
           
    initial
    begin
        CLOCK = 1;
            
        while (1)
        begin
            #(`CLK/2);
            CLOCK = ~ CLOCK;
        end
    end
    
    initial
    begin
        RESET = 0;
        #1;
        #`CLK;
        #`CLK;
        #`CLK;
        RESET = 1;
    end
    
    wire     [15:0] cmd_fifo_out_data;
    wire            cmd_fifo_rts;
    wire            cmd_proc_rtr;
    
    wire    [31:0]  arb_out_data;
    wire    [16:0]  arb_out_addr;
    wire    [3:0]   arb_out_wben;
    reg             arb_rtr;
    wire            arb_rts;
    
    wire           cmd_fifo_rtr;
    reg            cmd_proc_rts;
    reg    [15:0]  cmd_proc_in_data;
    
    fifo #(.DATA_WIDTH(16),
           .DEPTH(16),
           .LOG2DEPTH(8)) 
        fifo_ut(
        .clk(CLOCK),
        .rst_(RESET),
        // Input Interface
        .in_data(cmd_proc_in_data),
        .in_rtr(cmd_proc_rtr),
        .in_rts(cmd_proc_rts),
        // Output Interface
        .out_rtr(cmd_fifo_rtr),
        .out_rts(cmd_fifo_rts),
        .out_data(cmd_fifo_out_data)
        );
        
    rect_generator generator_ut(
        .clk(CLOCK),
        .rst_(RESET),
        // Command Processor FIFO Interface
        .cmd_fifo_data(cmd_fifo_out_data),
        .cmd_fifo_rtr(cmd_fifo_rtr),
        .cmd_fifo_rts(cmd_fifo_rts),
        // Arbiter FIFO Interface
        .arb_data(arb_out_data),
        .arb_addr(arb_out_addr),
        .arb_wben(arb_out_wben),
        .arb_rts(arb_rts),
        .arb_rtr(arb_rtr)
        );
           
    initial
    begin
        cmd_proc_rts = 1'b0;
        #101;
        // --------- Command #1
        cmd_proc_rts = 1'b1;
        arb_rtr = 1'b1;
        cmd_proc_in_data = 16'h20;
        #`CLK;
        cmd_proc_in_data = 16'h20;
        #`CLK;
        cmd_proc_in_data = 16'h4;
        #`CLK;
        cmd_proc_in_data = 16'h1;
        #`CLK;
        cmd_proc_in_data = 16'h1;
        #`CLK;
        cmd_proc_in_data = 16'h2;  
        #`CLK;
        cmd_proc_in_data = 16'h3;  
        #`CLK;
        
        // --------- Command #2
        cmd_proc_rts = 1'b1;
        arb_rtr = 1'b1;
        cmd_proc_in_data = 16'h00;
        #`CLK;
        cmd_proc_in_data = 16'h00;
        #`CLK;
        cmd_proc_in_data = 16'h1;
        #`CLK;
        cmd_proc_in_data = 16'h4;
        #`CLK;
        cmd_proc_in_data = 16'h4;
        #`CLK;
        cmd_proc_in_data = 16'h5;  
        #`CLK;
        cmd_proc_in_data = 16'h6;  
        #`CLK;
        cmd_proc_rts = 1'b0;
    end
endmodule