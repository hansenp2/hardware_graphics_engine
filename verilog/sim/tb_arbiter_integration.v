`timescale 1ns / 1ps

module tb_arbiter_integration;

    reg clk;
    reg rst_;
    reg enable;
    reg test_mode; 
    
    wire              vga_h_sync;
    wire              vga_v_sync;   
    wire  [3:0]       vga_red; 
    wire  [3:0]       vga_green; 
    wire  [3:0]       vga_blue;  
    
//    wire [31:0] mem_out_data; 
//    wire [11:0] d0, d1, d2, d3, d4, d5, d6, d7;
//    wire [9:0] v_counter, h_counter;
//    wire rb_rts_pb, gb_rts_pb, bb_rts_pb, pb_rtr_cb; 
    
    arbiter_integration uut(
        .clk(clk),
        .rst_(rst_),
        .enable(enable),
        .test_mode(test_mode), 
        .vga_h_sync(vga_h_sync),
        .vga_v_sync(vga_v_sync),
        .vga_red(vga_red),
        .vga_green(vga_green),
        .vga_blue(vga_blue) 
    ); 
    
    integer i, count;
        
    initial begin
    
        // Iniatilze Inputs
        clk     = 1'b0;
        rst_    = 1'b1;
        enable  = 1'b0;
        test_mode = 0; 
        
        #5;
        
        // Pulse Active Low Reset
        #5 rst_ = ~rst_;
        #5 rst_ = ~rst_;
        #5 enable = 1'b1;
        
        begin
            count = 0;
            for (i = 0; i < 25200000; i = i + 1)
            begin
                
                if (clk == 1)
                begin
                    #1 clk = ~clk;  
                end
                
                else 
                begin
                    #1 clk = ~clk;                   
                end 
                
            end
        end
    
    end

endmodule
