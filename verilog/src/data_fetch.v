`timescale 1ns / 1ps

`define NUM_ADDRS 115200

module data_fetch(

    // Clock and Async Reset
    input           clk,
    input           rst_,
    input           en,
    
    // Input Interface
    input   [31:0]  in_data,
    input           in_rts,
    output          in_rtr,
    output reg [16:0] mem_ptr,
    
    // Output Interface
    output  [31:0]  out_data,
    output          r_rts,
    input           r_rtr, 
    
    output          g_rts,
    input           g_rtr,
    
    output          b_rts,
    input           b_rtr
    
    // DEBUG CODE
//    output [31:0] q0, q1,
//    output [1:0] rd_addr, wr_addr,
//    output reg [2:0] state 
);
    
    // Buffer Components
    reg  [1:0] rd_addr;
    reg  [1:0] wr_addr;    
    reg [31:0] queue [0:1];
    
    // State to Write Color
    reg [2:0] state;
    
    // Transfer Complete Signals
    wire in_xfc;
    wire r_xfc;
    wire g_xfc;
    wire b_xfc;
    
    assign in_xfc = in_rts & in_rtr;
    assign r_xfc  = r_rts  & r_rtr;
    assign g_xfc  = g_rts  & g_rtr;
    assign b_xfc  = b_rts  & b_rtr;
    
    // Full and Empty Signals
    wire full, empty;
    
    // Empty when Read and Write Address are the same
    assign empty = (rd_addr == wr_addr);
    
    // Full when Read and Write Pointer Overlap
    assign full  = (rd_addr[0] == wr_addr[0]) & (rd_addr != wr_addr);
    
    // Ready to Receive Input when Not Full
    assign in_rtr  = ~full;
    
    // Ready to Send Output when Not Empty  
    assign r_rts = ~empty & state[0];
    assign g_rts = ~empty & state[1];
    assign b_rts = ~empty & state[2];
    
    // Output Data
    assign out_data = queue[rd_addr[0]];
    
    // DEBUG CODE
//    assign q0 = queue[0];
//    assign q1 = queue[1];
    
    always@(posedge clk or negedge rst_ or posedge en)
    begin
    
        if (!rst_ || en)
        begin
            rd_addr <= 0;
            wr_addr <= 0;
            mem_ptr <= 0;
            state   <= 3'b001;
        end
        
        else 
        begin               
        
            if (in_xfc)
            begin
                queue[wr_addr[0]]   <= in_data;
                wr_addr             <= wr_addr + 1;                
                mem_ptr             <= (mem_ptr == `NUM_ADDRS-1) ? (0) : (mem_ptr + 1); 
            end
                
            if (r_xfc)
            begin
                rd_addr             <= rd_addr + 1;
                state               <= 3'b010; 
            end
            
            if (g_xfc)
            begin
                rd_addr             <= rd_addr + 1;
                state               <= 3'b100; 
            end
            
            if (b_xfc)
            begin
                rd_addr             <= rd_addr + 1;
                state               <= 3'b001; 
            end
                
                
        end
        
    end
    
endmodule
