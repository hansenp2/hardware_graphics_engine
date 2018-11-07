`timescale 1 ns / 1 ps

module tb_bram;
    
    reg   [16:0]  BRAM_PORTA_0_addr;
    reg           BRAM_PORTA_0_clk;
    reg   [31:0]  BRAM_PORTA_0_din;
    wire  [31:0]  BRAM_PORTA_0_dout; 
    reg   [3:0]   BRAM_PORTA_0_we; 

    bram_wrapper uut (
        .BRAM_PORTA_0_addr(BRAM_PORTA_0_addr),
        .BRAM_PORTA_0_clk(BRAM_PORTA_0_clk),
        .BRAM_PORTA_0_din(BRAM_PORTA_0_din),
        .BRAM_PORTA_0_dout(BRAM_PORTA_0_dout), 
        .BRAM_PORTA_0_we(BRAM_PORTA_0_we)
    );
    
    integer i, clock_cycle;
    initial 
    begin
        BRAM_PORTA_0_addr   = 17'b00000000000000000;
        BRAM_PORTA_0_clk    = 0;
        BRAM_PORTA_0_din    = 32'h00000000;  
        BRAM_PORTA_0_we     = 4'b0000;  
        
        #10 
        
        begin
            clock_cycle = 0;
            for (i = -1; i < 256; i = i + 1)
            begin
            
                if (i >= 0 && (i%2 == 0))
                    clock_cycle = clock_cycle + 1;
            
                #10 BRAM_PORTA_0_clk = ~BRAM_PORTA_0_clk;
                
                if (i >= 3 && i < 11)
                begin 
                    BRAM_PORTA_0_addr = 17'b00000000000000001;
                    BRAM_PORTA_0_din  = 32'hffffffff;                 
                    BRAM_PORTA_0_we   = 4'b1000;
                end
                
                else if (i >= 15 && i < 19)
                begin
                    BRAM_PORTA_0_addr = 10'b0000000001;
                end
                
                else
                begin
                    BRAM_PORTA_0_addr = 10'b0000000000;
                    BRAM_PORTA_0_we   = 2'b00;  
                end
                
//                else if (i >= 11 && i <= 15)
//                begin 
//                    BRAM_PORTA_0_addr = 10'b0000000001;
//                    BRAM_PORTA_0_we   = 2'b00;
//                end 
                
//                else 
//                begin
//                    BRAM_PORTA_0_addr = 10'b0000000000;
//                    BRAM_PORTA_0_din  = 16'h0000; 
//                    BRAM_PORTA_0_en   = 1'b1;
//                    BRAM_PORTA_0_we   = 2'b00;
//                end
                
            end
        end
             
    end 
    
endmodule
