`timescale 1ns / 1ps
`define CLK 20

module fill_rect_engine_tb(
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
    
    //  Command Processor <-> Fill Rect Engine Interface
    reg     [7:0]   cmd_proc_fil_rect_data;
    reg             cmd_proc_fill_rect_rts;
    wire            cmd_proc_fill_rect_rtr;
    //  Fill Rect Engine <-> Arbiter Interface
    wire    [31:0]  fill_rect_arb_data;
    wire    [15:0]  fill_rect_arb_addr;
    wire    [3:0]   fill_rect_arb_wben;
    wire            fill_rect_arb_rts;
    reg             fill_rect_arb_rtr;
    wire            fill_rect_arb_op;
    
    fill_rect_engine uut1(
        .clk(CLOCK),
        .rst_(RESET),
        // Command Processor Interface
        .cmd_in_data(cmd_proc_fil_rect_data),
        .cmd_in_rts(cmd_proc_fill_rect_rts),
        .cmd_out_rtr(cmd_proc_fill_rect_rtr),
        // Arbiter Interface
        .arb_out_data(fill_rect_arb_data),
        .arb_out_addr(fill_rect_arb_addr),
        .arb_out_wben(fill_rect_arb_wben),
        .arb_in_rtr(fill_rect_arb_rtr),
        .arb_out_rts(fill_rect_arb_rts),
        .arb_out_op(fill_rect_arb_op)
        );
        
    initial
        begin
            cmd_proc_fill_rect_rts = 1'b0;
            #101;
            // --------- Command #1
            cmd_proc_fill_rect_rts = 1'b1;
            fill_rect_arb_rtr = 1'b1;
            cmd_proc_fil_rect_data = 8'h00;
            #`CLK;
            cmd_proc_fil_rect_data = 8'h20;
            #`CLK;
            cmd_proc_fil_rect_data = 8'h00;
            #`CLK;
            cmd_proc_fil_rect_data = 8'h20;
            #`CLK;
            cmd_proc_fil_rect_data = 8'h00;
            #`CLK;
            cmd_proc_fil_rect_data = 8'h04;
            #`CLK;
            cmd_proc_fil_rect_data = 8'h00;
            #`CLK;
            cmd_proc_fil_rect_data = 8'h01;
            #`CLK;
            cmd_proc_fil_rect_data = 8'h01;
            #`CLK;
            cmd_proc_fil_rect_data = 8'h02;  
            #`CLK;
            cmd_proc_fil_rect_data = 8'h03;  
            #`CLK;
            cmd_proc_fill_rect_rts = 1'b0;
            #100;
            // --------- Command #2
            
            fill_rect_arb_rtr = 1'b1;
            cmd_proc_fil_rect_data = 8'h00;
            #`CLK;
            cmd_proc_fil_rect_data = 8'h00;
            #`CLK;
            cmd_proc_fil_rect_data = 8'h00;
            #`CLK;
            cmd_proc_fil_rect_data = 8'h00;
            #`CLK;
            cmd_proc_fil_rect_data = 8'h00;
            #`CLK;
            cmd_proc_fil_rect_data = 8'h01;
            #`CLK;
            cmd_proc_fil_rect_data = 8'h00;
            #`CLK;
            cmd_proc_fil_rect_data = 8'h04;
            #`CLK;
            cmd_proc_fil_rect_data = 8'h07;
            #`CLK;         
            cmd_proc_fil_rect_data = 8'h08;  
            #`CLK;
            cmd_proc_fil_rect_data = 16'h09;  
            #`CLK;
            cmd_proc_fill_rect_rts = 1'b0;
            
        end
endmodule
