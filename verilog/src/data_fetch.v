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
    input           b_rtr,
    
    input           bcast_xfc
    
    // DEBUG CODE
//    output [31:0] q0, q1,
//    output [1:0] rd_addr, wr_addr,
//    output reg [2:0] state 
);
    
    // Buffer Components
    reg  [2:0] rd_addr;
    reg  [2:0] wr_addr;   

    reg [31:0] queue [0:7];
    wire [2:0] next_wr_addr_1;//, next_wr_addr_2;
    
    
    // State to Write Color
    reg [2:0] state;
    
    reg [2:0] request_count; 
    
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
    // assign empty = (rd_addr == wr_addr);
    
    // Full when Read and Write Pointer Overlap
    // assign full  = (rd_addr[0] == wr_addr[0]) & (rd_addr != wr_addr);
    
    // Ready to Receive Input when Not Full
    // assign in_rtr  = ~full;
    assign in_rtr       = (next_wr_addr_1 != rd_addr) & (request_count+2 < 7); //|| (next_wr_addr_2 != rd_addr);
    
    // Ready to Send Output when Not Empty  
    assign r_rts = (rd_addr != wr_addr) & state[0];
    assign g_rts = (rd_addr != wr_addr) & state[1];
    assign b_rts = (rd_addr != wr_addr) & state[2];
    
    // Output Data
    // assign out_data = queue[rd_addr[0]];
    assign out_data = queue[rd_addr]; 
    assign next_wr_addr_1 = wr_addr + 2; 
    // assign next_wr_addr_1 = (request_count+2 < 7);
    //assign next_wr_addr_2 = wr_addr + 2;
    
    
    
    
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
            request_count <= 0;
            state   <= 3'b001;
        end
        
        else 
        begin               
            
            if (in_xfc)
            begin
                              
                mem_ptr             <= (mem_ptr == `NUM_ADDRS-1) ? (0) : (mem_ptr + 1); 
//                request_count       <= request_count + 1;
               // queue[wr_addr[0]]   <= in_data;  
                //wr_addr             <= wr_addr + 1; 
                
            end
          
            if (bcast_xfc)
            begin
                //mem_ptr             <= (mem_ptr == `NUM_ADDRS-1) ? (0) : (mem_ptr + 1); 
                // queue[wr_addr[0]]   <= in_data;  
                queue[wr_addr] <= in_data;
                wr_addr             <= wr_addr + 1;  
            end
                
            if (r_xfc)
            begin
                rd_addr             <= rd_addr + 1;
                state               <= 3'b010; 
//                request_count       <= request_count - 1;
            end
            
            if (g_xfc)
            begin
                rd_addr             <= rd_addr + 1;
                state               <= 3'b100; 
//                request_count       <= request_count - 1;
            end
            
            if (b_xfc)
            begin
                rd_addr             <= rd_addr + 1;
                state               <= 3'b001; 
//                request_count       <= request_count - 1;
            end
                
               
            if (in_xfc == 1 && (r_xfc == 1 || g_xfc == 1 || b_xfc == 1)) 
            begin
                // $display("both\t%d", request_count);
                request_count <= request_count;
            end
            
            else if (in_xfc == 1)
            begin
                // $display("only in_xfc\t%d", request_count);
                request_count <= request_count + 1;
            end
            
            else if (r_xfc == 1 || g_xfc == 1 || b_xfc == 1) 
            begin
                // $display("only out_xfc\t%d", request_count);
                request_count <= request_count - 1; 
            end
                
                
        end
        
    end
    
endmodule
