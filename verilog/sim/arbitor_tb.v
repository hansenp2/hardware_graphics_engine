`timescale 1ns / 1ps


module arbitor_tb();

    parameter NUM_ENGINES = 3;
    
    reg clk, rst_;

    //fetcher
    reg [16:0] fetch_addr;
    reg [31:0] fetch_wrdata; //not used
    reg fetch_rts_in;
    wire fetch_rtr_out; 
    reg [3:0] fetch_op; 

    //connections to engines
    reg [16:0] rectanglefill_addr;
    reg [31:0] rectanglefill_wrdata;
    reg rectanglefill_rts_in;
    wire rectanglefill_rtr_out;  
    reg [3:0] rectanglefill_op; 
    
    reg [16:0] rectanglepix_addr;
    reg [31:0] rectanglepix_wrdata;
    reg rectanglepix_rts_in;
    wire rectanglepix_rtr_out;  
    reg [3:0] rectanglepix_op; 

    //connections to BRAM
    wire [31:0] mem_data_in;
    wire [3:0] wben;
    wire [16:0] mem_addr;
    wire [31:0] mem_data_out;
    
    wire [31:0] bcast_data;
    wire [NUM_ENGINES-1:0] bcast_xfc;
    
    wire [NUM_ENGINES-1:0] sel;
    wire fetch_xfc, rectanglefill_xfc, rectanglepix_xfc;

    arbitor uut(
        .clk(clk),
        .rst_(rst_),
        
        .fetch_addr(fetch_addr),
        .fetch_wrdata(fetch_wrdata),
        .fetch_rts_in(fetch_rts_in),
        .fetch_rtr_out(fetch_rtr_out),
        .fetch_op(fetch_op),
        
        .rectanglefill_addr(rectanglefill_addr),
        .rectanglefill_wrdata(rectanglefill_wrdata),
        .rectanglefill_rts_in(rectanglefill_rts_in),
        .rectanglefill_rtr_out(rectanglefill_rtr_out),
        .rectanglefill_op(rectanglefill_op),
        
        .rectanglepix_addr(rectanglepix_addr),
        .rectanglepix_wrdata(rectanglepix_wrdata),
        .rectanglepix_rts_in(rectanglepix_rts_in),
        .rectanglepix_rtr_out(rectanglepix_rtr_out),
        .rectanglepix_op(rectanglepix_op),

        //for debugging
        .sel(sel),
        .fetch_xfc(fetch_xfc),
        .rectanglefill_xfc(rectanglefill_xfc),
        .rectanglepix_xfc(rectanglepix_xfc),
        
        
        .mem_data_in(mem_data_in),
        .wben(wben),
        .mem_addr(mem_addr),
        .mem_data_out(mem_data_out),
        
        .bcast_data(bcast_data),
        .bcast_xfc(bcast_xfc)
    );
    
    bram_wrapper bram(
        .BRAM_PORTA_0_addr(mem_addr),
        .BRAM_PORTA_0_clk(clk),
        .BRAM_PORTA_0_din(mem_data_out), //switched these
        .BRAM_PORTA_0_dout(mem_data_in),
        .BRAM_PORTA_0_we(wben)
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
        
        fetch_addr = 17'b00000000000000001;
        fetch_wrdata = 32'h00000000;
        fetch_rts_in = 1;
        fetch_op = 4'b0000;
        
        rectanglefill_addr = 17'b00000000000000000;
        rectanglefill_wrdata =32'hAAAABBBB;
        rectanglefill_rts_in = 1;
        rectanglefill_op =4'b1010;
        
        rectanglepix_addr = 17'b00000000000000001;
        rectanglepix_wrdata =32'h12345678;
        rectanglepix_rts_in = 1;
        rectanglepix_op =4'b1101;
        
        #12;
        rst_ = 1;

    end

endmodule
