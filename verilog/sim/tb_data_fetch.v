`timescale 1ns / 1ps

module tb_data_fetch;

    // Clock and Async Reset
    reg           clk;
    reg           rst_;
    reg           en;
    
    // Input Interface
    reg   [31:0]  in_data;
    reg           in_rts;
    wire          in_rtr;
    wire  [16:0]  mem_ptr;
    
    // Output Interface
    wire  [31:0]  out_data;
    wire          r_rts;
    reg           r_rtr;     
    wire          g_rts;
    reg           g_rtr;    
    wire          b_rts;
    reg           b_rtr;
    
//    wire [31:0] q0, q1;
//    wire [1:0] rd_addr, wr_addr;
//    wire [2:0] state;
//    wire r_xfc;
    
    // Unit Under Test
    data_fetch uut(
        .clk(clk),
        .rst_(rst_),
        .en(en),
        .in_data(in_data),
        .in_rts(in_rts),
        .in_rtr(in_rtr),
        .mem_ptr(mem_ptr),
        .out_data(out_data),        
        .r_rts(r_rts),
        .r_rtr(r_rtr),        
        .g_rts(g_rts),
        .g_rtr(g_rtr),        
        .b_rts(b_rts),
        .b_rtr(b_rtr)                     
//        .q0(q0),
//        .q1(q1),
//        .rd_addr(rd_addr),
//        .wr_addr(wr_addr),
//        .state(state) 
    );
    
    // Memory Contents for Testing
    reg [31:0] memory [0:15]; 
    initial 
        $readmemh("C:/Users/Patrick/Documents/TCNJ/senior_project_prep/test_mem.txt", memory);
    
    integer i, clock_cycle;
    initial begin
    
        clk     = 0;
        rst_    = 1;      
        en      = 0;  
        in_data = 0;
        in_rts  = 0; 
        r_rtr   = 1;
        g_rtr   = 1;
        b_rtr   = 1;
        
        #10 rst_ = ~rst_;
        #10 rst_ = ~rst_; en = 0;
        
        begin            
            clock_cycle = 0; 
            for (i = -1; i < 256; i = i + 1)
            begin
            
                if (clk == 1)
                begin
                    #10 clk = ~clk;                     
                end
                
                else 
                begin
                    #10 clk = ~clk;
                    in_data = memory[mem_ptr];
                    in_rts  = 1; 
                end 
                
                if (i == 10)
                    en = 1;
                else
                    en = 0;
                     
            
//                if (i >= 0 && (i%2 == 0))
//                    clock_cycle = clock_cycle + 1;
                    
//                #10 clk = ~clk;
                
//                // Write
//                if (i >= 5 && i < 7)
//                begin
//                    in_data = memory[mem_ptr];
//                    in_rts  = 1;                    
//                end
                
//                // Write
//                else if (i >= 5 && i < 7)
//                begin
//                    in_data = memory[mem_ptr];
//                    in_rts  = 1; 
//                end
                
//                // Write
//                else if (i >= 7 && i < 9)
//                begin                    
//                    in_data = memory[mem_ptr];
//                    in_rts  = 1;
//                end
                
//                // Write
//                else if (i >= 9 && i < 11)
//                begin
//                    in_data = memory[mem_ptr];
//                    in_rts  = 1;
//                end
                
//                // Write
//                else if (i >= 11 && i < 13)
//                begin
//                    in_data = memory[mem_ptr];
//                    in_rts  = 1;
//                end
                
//                // Reset
//                else if (i >= 13 && i < 15)
//                begin
//                    en = 1;
//                end
                
//                // Write
//                else if (i >= 15 && i < 17)
//                begin
//                    en = 0;
//                    in_data = memory[mem_ptr];
//                    in_rts  = 1;
//                end
                
//                // Write
//                else if (i >= 17 && i < 19)
//                begin
//                    in_data = memory[mem_ptr];
//                    in_rts  = 1;
//                end
                
//                else 
//                begin
//                    in_rts = 0;
//                    r_rtr  = 1;
//                    g_rtr  = 1;
//                    b_rtr  = 1;
//                    en     = 0;
//                end
                
                if ((i % 2 == 1) && (r_rts & r_rtr))
                    $display("out_data (r) --> %08h", out_data);
                if ((i % 2 == 1) && (g_rts & g_rtr))
                    $display("out_data (g) --> %08h", out_data);
                if ((i % 2 == 1) && (b_rts & b_rtr))
                    $display("out_data (b) --> %08h", out_data);
                
            end
        end
    
    end

endmodule
