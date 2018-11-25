`timescale 1ns / 1ps

module test_fetch_engine_hw(
    input               clk,
    input               rst_,
    input               enable, 
    
    input               test_mode,
     
    output              vga_h_sync,
    output              vga_v_sync,     
    output  [3:0]       vga_red, 
    output  [3:0]       vga_green, 
    output  [3:0]       vga_blue        
    );
    
    // Clock Divider
    wire clk25;        
    clock_div cd(
        .clk_i(clk), 
        .rst_(rst_), 
        .clk_o(clk25)
    );
         
    // Refresh Engine
    wire active_video, en_fetching;
    wire [11:0] current_pixel;
    refresh_engine rf(
        .clk(clk25),
        .rst_(rst_),
        .enable(enable),
        .test_mode(test_mode),
        .current_pixel(current_pixel),
        .vga_h_sync(vga_h_sync), 
        .vga_v_sync(vga_v_sync), 
        .active_video(active_video),
        .vga_red(vga_red),
        .vga_green(vga_green),
        .vga_blue(vga_blue),
        .en_fetching(en_fetching)
    );  
         
    // Interface Needed without Arbiter
    wire df_rtr_mem, df_rts_mem, df_rts_rf;
    wire [31:0] data_from_mem;
    wire [16:0] df_mem_ptr;
    
    reg [1:0] wait_two_cycles;
    reg test_signal;
    always@(posedge clk25 or negedge rst_)
    begin
        if (!rst_) 
        begin
            wait_two_cycles <= 2'b00;
            test_signal <= 0;    
        end
            
        else 
        begin
        
            if (wait_two_cycles == 2'b10)
                test_signal <= 1;
            else
                test_signal <= 0;
        
            wait_two_cycles <= (wait_two_cycles == 2'b10) ? (2'b00) : (wait_two_cycles + 2'b01);
        end
    end
    
    // Data Fetching Engine
    data_fetching_engine df(
        .clk(clk25),
        .rst_(rst_),
        .en_fetching(en_fetching),        
        .in_addr(df_mem_ptr),
        .in_data(data_from_mem),
        .in_rtr(df_rtr_mem),
        .in_rts(test_signal),                  
        .out_data(current_pixel),
        .out_rtr(active_video),
        .out_rts(df_rts_rf)
    );
    
    // Block RAM Module
    bram_wrapper bw(
        .BRAM_PORTA_0_addr(df_mem_ptr),
        .BRAM_PORTA_0_clk(clk25),
        .BRAM_PORTA_0_din(0),
        .BRAM_PORTA_0_dout(data_from_mem),
        .BRAM_PORTA_0_we(0)
    );


    // INFERRED BRAM USED FOR SIMULATION ONLY
    // mem_for_testing mt(
    //     .clk(clk25),
    //     .in_addr(df_mem_ptr),
    //     .out_data(data_from_mem)
    // ); 
    
endmodule
