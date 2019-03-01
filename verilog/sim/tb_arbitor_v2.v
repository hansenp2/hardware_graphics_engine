`timescale 1ns / 1ps

module tb_arbitor_v2;

    // Clock and Sync Reset
    reg clk;
    reg rst_; 
    
    wire [31:0] bcast_data;
    wire [`NUM_ENGINES:0] bcast_xfc_out;
    reg en_fetching;
    
    // RAM connections
    wire [3:0] wben;
    wire [16:0] mem_addr;
    reg [31:0] mem_data_in;
    wire [31:0] mem_data_out;
    
    // data fetcher connections
    reg [16:0] fetch_addr;
    reg [31:0] fetch_wrdata;
    reg fetch_rts_in;
    wire fetch_rtr_out;
    reg [3:0] fetch_op;
    
    // line drawer conncetions
    reg [16:0] linedrawer_addr;
    reg [31:0] linedrawer_wrdata;
    reg linedrawer_rts_in;
    wire linedrawer_rtr_out;
    reg [3:0] linedrawer_op;
    
    // circle drawer connections
    reg [16:0] circledrawer_addr;
    reg [31:0] circledrawer_wrdata;
    reg circledrawer_rts_in;
    wire circledrawer_rtr_out;
    reg [3:0] circledrawer_op;
    
    // Unit Under Test
    arbitor_v2 uut(
        .clk(clk),
        .rst_(rst_),
        .en_fetching(en_fetching),
        .fetch_rts_in(fetch_rts_in),
        .fetch_rtr_out(fetch_rtr_out),
        .linedrawer_rts_in(linedrawer_rts_in),
        .linedrawer_rtr_out(linedrawer_rtr_out),
        .fetch_op(fetch_op),
        .fetch_addr(fetch_addr),
        .fetch_wrdata(fetch_wrdata),
        .linedrawer_op(linedrawer_op),
        .linedrawer_addr(linedrawer_addr),
        .linedrawer_wrdata(linedrawer_wrdata),
        .circledrawer_addr(circledrawer_addr),
        .circledrawer_wrdata(circledrawer_wrdata),
        .circledrawer_rts_in(circledrawer_rts_in),
        .circledrawer_rtr_out(circledrawer_rtr_out),
        .circledrawer_op(circledrawer_op),
        
        .wben(wben),
        .mem_addr(mem_addr),
        .mem_data_in(mem_data_in),
        .mem_data_out(mem_data_out),
        .bcast_xfc_out(bcast_xfc_out)
    );
    
    initial 
    begin
    
        clk     = 1'b0;
        rst_    = 1'b1; 
        en_fetching = 1'b1;
        
        fetch_rts_in = 1'b1;
        linedrawer_rts_in = 1'b1;
        circledrawer_rts_in = 1'b0;
        
        fetch_op = 0;
        fetch_addr = 17'h0;
        fetch_wrdata = 32'h1111_1111;
        
        // linedrawer_op = 4'b1111;
        linedrawer_op = 0;
        linedrawer_addr = 17'h2;
        linedrawer_wrdata = 32'h2222_2222;
        
        circledrawer_op = 4'b0000;
        circledrawer_addr = 17'h1;
        circledrawer_wrdata = 32'hffff_ffff;
        
        #10;
        
        #5 rst_ = ~rst_; clk = ~clk;
        #5 rst_ = ~rst_; clk = ~clk; 
        
        repeat(200)
        begin
            #5 clk = ~clk;
        end
    
    end

endmodule
