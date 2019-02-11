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
        
        // FOR DEBUGGING
        wire  [9:0] h_counter;
        wire  [9:0] v_counter; 
        
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
            .vga_blue(vga_blue),
            .h_counter(h_counter),
            .v_counter(v_counter)  
        ); 
        
        integer i, count;
        
        integer pixel_count, clk_counter; 
        reg [3:0] R_DATA [0:307199];
        reg [3:0] G_DATA [0:307199];
        reg [3:0] B_DATA [0:307199];
        integer NUM_PASS, NUM_FAIL;
            
        initial begin
        
            $readmemh("C:/Users/Patrick/Documents/TCNJ/senior_project_prep/py_create_mem_inits/tb_cmp/R_DATA.txt", R_DATA);
            $readmemh("C:/Users/Patrick/Documents/TCNJ/senior_project_prep/py_create_mem_inits/tb_cmp/G_DATA.txt", G_DATA);
            $readmemh("C:/Users/Patrick/Documents/TCNJ/senior_project_prep/py_create_mem_inits/tb_cmp/B_DATA.txt", B_DATA);
        
            // Iniatilze Inputs
            clk     = 1'b0;
            rst_    = 1'b1;
            enable  = 1'b0;
            test_mode = 0; 
            
            #5;
            
            // Pulse Active Low Reset
            #5 clk = ~clk; rst_ = ~rst_;
            #5 clk = ~clk; rst_ = ~rst_; enable = 1'b1;
            
            begin
                count = 0;
                pixel_count = 0;
                clk_counter = 0;
                NUM_PASS = 0; NUM_FAIL = 0;
                $display("*** PIXEL DATA STARTS HERE ***");
                for (i = 0; i < 25200000; i = i + 1)
                begin
                    
                    if (clk == 1)
                    begin
                        #1 clk = ~clk;  
                        
                        if (pixel_count >= 0 && pixel_count < 1280 && clk_counter == 0)
                        begin
                            if ( (h_counter >= 160) && (h_counter <= 799) && (v_counter >= 45) && (v_counter <= 524) )
                            begin
                                
                                if (vga_red == R_DATA[pixel_count] && vga_green == G_DATA[pixel_count] && vga_blue == B_DATA[pixel_count])
                                begin
                                    $display("%06d\t%h\t%h\t%h\t|\t%h\t%h\t%h\t|\tPASS", pixel_count, vga_red, vga_green, vga_blue, R_DATA[pixel_count],  G_DATA[pixel_count],  B_DATA[pixel_count]);
                                    NUM_PASS = NUM_PASS + 1;
                                end
                                
                                else
                                begin
                                    $display("%06d\t%h\t%h\t%h\t|\t%h\t%h\t%h\t|\tFAIL", pixel_count, vga_red, vga_green, vga_blue, R_DATA[pixel_count],  G_DATA[pixel_count],  B_DATA[pixel_count]);
                                    NUM_FAIL = NUM_FAIL + 1;
                                end
                                
                                pixel_count = pixel_count + 1;
                            end 
                        end                      
                        clk_counter = (clk_counter == 3) ? (0) : (clk_counter + 1);                   
                    end
                    
                    else 
                    begin
                        #1 clk = ~clk;                   
                    end 
                    
                end
            end
        
        end
    
    endmodule
