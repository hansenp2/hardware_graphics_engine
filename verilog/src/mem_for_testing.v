`timescale 1ns / 1ps

module mem_for_testing(
    input clk, 
    
    input   [16:0] in_addr,  
    output reg [31:0] out_data 
    );
    
    // 32-bit Memory with 115200 Addresses
    reg [31:0] test_mem [0:131071];
    
    integer i;
    initial 
    begin
        $readmemh("C:/Users/Patrick/Documents/TCNJ/senior_project_prep/py_create_mem_inits/other_mem.txt", test_mem);
        // $readmemh("C:/Users/Patrick/Documents/TCNJ/senior_project_prep/mem_for_integration.txt", test_mem);
        for (i = 0; i < 32; i = i + 1)
        begin
            $display("MEM[%06d] --> %h", i, test_mem[i]);
        end     
    end
        
    
    // Async Read
     // assign out_data = test_mem[in_addr];
    
    // Async Read
    always@(posedge clk)
    begin
        
        out_data <= test_mem[in_addr];
        $display("READ %h from ADDR %d", out_data, in_addr);
        
    end  
    
endmodule
