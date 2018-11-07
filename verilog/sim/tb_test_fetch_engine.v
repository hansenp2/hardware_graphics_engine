`timescale 1ns / 1ps

module tb_test_fetch_engine;

    reg clk;
    reg rst_;
    reg enable;
    reg test_mode;
    
    // Memory Interface
    reg [31:0] mem_in_data;
    reg mem_rts_df;
    wire [16:0] df_mem_ptr;
    
    wire              vga_h_sync;
    wire              vga_v_sync;   
    wire  [3:0]       vga_red; 
    wire  [3:0]       vga_green; 
    wire  [3:0]       vga_blue;
    
    wire active_video; 
    wire [11:0] current_pixel;
//    wire [31:0] mem_out_data; 
//    wire [11:0] d0, d1, d2, d3, d4, d5, d6, d7;
//    wire [9:0] v_counter, h_counter;
//    wire rb_rts_pb, gb_rts_pb, bb_rts_pb, pb_rtr_cb; 
    
    test_fetch_engine uut(
        .clk(clk),
        .rst_(rst_),
        .enable(enable),
        .test_mode(test_mode),
        .mem_in_data(mem_in_data),
        .mem_rts_df(mem_rts_df),
        .df_mem_ptr(df_mem_ptr),
        .vga_h_sync(vga_h_sync),
        .vga_v_sync(vga_v_sync),
        .vga_red(vga_red),
        .vga_green(vga_green),
        .vga_blue(vga_blue),
        .active_video(active_video), 
        .current_pixel(current_pixel) 
    );
    
    // Memory Contents for Testing
    reg [31:0] memory [0:115119]; 
    initial 
        //$readmemh("C:/Users/Patrick/Documents/TCNJ/senior_project_prep/mem_for_integration.txt", memory);
        $readmemh("C:/Users/Patrick/Documents/TCNJ/senior_project_prep/py_create_mem_inits/other_mem.txt", memory);
        
    
    integer i, count;
        
    initial begin
    
        // Iniatilze Inputs
        clk     = 1'b0;
        rst_    = 1'b1;
        enable  = 1'b0;
        test_mode = 0;
        mem_rts_df  = 1;
        
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
                    if (active_video && count < 48)
                    begin
                        $display("pixel[%06d] --> 0x%h", count, current_pixel); 
                        count = count + 1;
                    end
                end
                
                else 
                begin
                    #1 clk = ~clk;
                    mem_in_data = memory[df_mem_ptr];                     
                end 
                
            end
        end
    
    end

endmodule
