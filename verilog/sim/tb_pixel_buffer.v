`timescale 1ns / 1ps

module tb_pixel_buffer;

    // Clock and Async Reset
    reg clk;
    reg rst_;
    
    // Input Interface
    reg [31:0] r_data;
    reg [31:0] g_data;
    reg [31:0] b_data;
    reg r_rts;
    reg g_rts;
    reg b_rts;
    wire in_rtr;
    
    // Output Interface
    wire [11:0] current_pixel;
    wire out_rts;
    reg  out_rtr;
    
    // DEBUG
    wire [5:0] wr_addr;
    wire [5:0] rd_addr;
    wire [11:0] d0, d1, d2, d3, d4, d5, d6, d7;
    wire [11:0] d8, d9, d10, d11, d12, d13, d14, d15;
    
    pixel_buffer uut(
        .clk(clk),
        .rst_(rst_),
        .r_data(r_data),
        .g_data(g_data),
        .b_data(b_data),
        .r_rts(r_rts),
        .g_rts(g_rts),
        .b_rts(b_rts),
        .in_rtr(in_rtr),
        .current_pixel(current_pixel),
        .out_rts(out_rts),
        .out_rtr(out_rtr),
        .wr_addr(wr_addr),
        .rd_addr(rd_addr),
        
        .d0(d0),
        .d1(d1),
        .d2(d2),
        .d3(d3),
        .d4(d4),
        .d5(d5),
        .d6(d6),
        .d7(d7),
        .d8(d8),
        .d9(d9),
        .d10(d10),
        .d11(d11),
        .d12(d12),
        .d13(d13),
        .d14(d14),
        .d15(d15)
    );

    integer i;
    initial begin
    
        clk     = 0;
        rst_    = 1;
        r_data  = 0;
        g_data  = 0;
        b_data  = 0;
        r_rts   = 0;
        g_rts   = 0;
        b_rts   = 0;
        out_rtr = 1;
        
        #10 rst_ = ~rst_;
        #10 rst_ = ~rst_;
        
        begin
            for (i = 0; i < 256; i = i + 1)
            begin
            
                #10 clk = ~clk;
                
                if (i >= 3 && i < 5)
                begin
                    r_data = 32'h76543210;
                    g_data = 32'h76543210;
                    b_data = 32'h76543210;
                    r_rts = 1;
                    g_rts = 1;
                    b_rts = 1;                   
                end
                
                else if (i >= 5 && i < 7)
                begin
                    r_data = 32'hfedcba98;
                    g_data = 32'hfedcba98;
                    b_data = 32'hfedcba98;
                    r_rts = 1;
                    g_rts = 1;
                    b_rts = 1;                   
                end 
                
                else if (i >= 7 && i < 9)
                begin
                    r_data = 32'h76543210;
                    g_data = 32'h76543210;
                    b_data = 32'h76543210;
                    r_rts = 1;
                    g_rts = 1;
                    b_rts = 1;                   
                end
                
                else
                begin
                    r_rts = 0;
                    g_rts = 0;
                    b_rts = 0;                   
                end
                
            end
        end
    
    end

endmodule
