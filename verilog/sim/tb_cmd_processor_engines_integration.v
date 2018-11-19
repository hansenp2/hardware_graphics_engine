`timescale 1ns / 1ps
`define CLK 20
module tb_cmd_processor_engines_integration(
    );
    
    reg CLOCK = 0;
    reg RESET = 0;
        
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
        RESET = 1;
        #`CLK;
        #`CLK;
        #`CLK;
        // Active Low
        RESET = 0;
        #1;
        #`CLK;
        #`CLK;
        #`CLK;
        RESET = 1;
    end   
    
    cmd_processor_engines_integration uut(
        .clk(CLOCK),
        .rst_(RESET)
        );
        
    initial
    begin
        #101;
        
    end
    
endmodule
