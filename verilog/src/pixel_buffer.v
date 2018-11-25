`timescale 1ns / 1ps

module pixel_buffer(
    
    // Clock and Async Reset
    input clk,
    input rst_, 
    input en,
    
    // Input Interface
    input [31:0] r_data,
    input [31:0] g_data,
    input [31:0] b_data,
    input r_rts,
    input g_rts,
    input b_rts,
    output in_rtr,
    
    // Output Interface
    output [11:0] current_pixel,
    output out_rts,
    input  out_rtr                   // active video 
    
//    // FOR DEBUGGING 
//    output [11:0] d0, d1, d2, d3, d4, d5, d6, d7    
//    output [11:0] d8, d9, d10, d11, d12, d13, d14, d15
);

    //Set for expected word-length being saved and queue depth
    parameter DATA_WIDTH    = 12;
    parameter DEPTH         = 64;
    parameter LOG2DEPTH     = 6;

    // Buffer Components
    reg  [LOG2DEPTH-1:0] rd_addr;    
    reg  [LOG2DEPTH-1:0] wr_addr;
    wire [LOG2DEPTH-1:0] next_wr_addr_8, next_wr_addr_7, next_wr_addr_6, next_wr_addr_5, next_wr_addr_4, next_wr_addr_3, next_wr_addr_2, next_wr_addr_1;
 
    reg [DATA_WIDTH-1:0] queue [(DEPTH-1):0];
    
    // Transfer Complete Signals
    wire in_xfc;
    wire out_xfc;
    
    assign in_xfc  = in_rtr;
    assign out_xfc = out_rts & out_rtr;
    
    assign current_pixel = queue[rd_addr];  
        
    assign next_wr_addr_8 = wr_addr + 8;      
    assign next_wr_addr_7 = wr_addr + 7;      
    assign next_wr_addr_6 = wr_addr + 6;      
    assign next_wr_addr_5 = wr_addr + 5;      
    assign next_wr_addr_4 = wr_addr + 4;      
    assign next_wr_addr_3 = wr_addr + 3;      
    assign next_wr_addr_2 = wr_addr + 2;      
    assign next_wr_addr_1 = wr_addr + 1;
        
    assign in_rtr       = (r_rts & g_rts & b_rts) & ( (next_wr_addr_8 != rd_addr) &    
                                                      (next_wr_addr_7 != rd_addr) &
                                                      (next_wr_addr_6 != rd_addr) &
                                                      (next_wr_addr_5 != rd_addr) &
                                                      (next_wr_addr_4 != rd_addr) &
                                                      (next_wr_addr_3 != rd_addr) &
                                                      (next_wr_addr_2 != rd_addr) &
                                                      (next_wr_addr_1 != rd_addr));
                                                      
    assign out_rts      = 1; //(rd_addr != wr_addr);
    
    // Output Data
    assign current_pixel = queue[rd_addr];
    
    // Parsing Input Pixel Data
    wire [11:0] p0, p1, p2, p3, p4, p5, p6, p7;
    
    assign p0[11:8] = r_data[3:0];
    assign p0[7:4]  = g_data[3:0];
    assign p0[3:0]  = b_data[3:0];
    
    assign p1[11:8] = r_data[7:4];
    assign p1[7:4]  = g_data[7:4];
    assign p1[3:0]  = b_data[7:4];
    
    assign p2[11:8] = r_data[11:8];
    assign p2[7:4]  = g_data[11:8];
    assign p2[3:0]  = b_data[11:8];
    
    assign p3[11:8] = r_data[15:12];
    assign p3[7:4]  = g_data[15:12];
    assign p3[3:0]  = b_data[15:12];
    
    assign p4[11:8] = r_data[19:16];
    assign p4[7:4]  = g_data[19:16];
    assign p4[3:0]  = b_data[19:16];
    
    assign p5[11:8] = r_data[23:20];
    assign p5[7:4]  = g_data[23:20];
    assign p5[3:0]  = b_data[23:20];
    
    assign p6[11:8] = r_data[27:24];
    assign p6[7:4]  = g_data[27:24];
    assign p6[3:0]  = b_data[27:24];
    
    assign p7[11:8] = r_data[31:28];
    assign p7[7:4]  = g_data[31:28];
    assign p7[3:0]  = b_data[31:28];
    
    
    // FOR DEBUG
//    assign d0 = queue[0];
//    assign d1 = queue[1];
//    assign d2 = queue[2];
//    assign d3 = queue[3];
//    assign d4 = queue[4];
//    assign d5 = queue[5];
//    assign d6 = queue[6];
//    assign d7 = queue[7];
    
//    assign d8 = queue[8];
//    assign d9 = queue[9];
//    assign d10 = queue[10];
//    assign d11 = queue[11];
//    assign d12 = queue[12];
//    assign d13 = queue[13];
//    assign d14 = queue[14];
//    assign d15 = queue[15];
    
    always@(posedge clk or negedge rst_ or posedge en)
    begin
        
        if (!rst_ || en)
        begin
            rd_addr <= 0;
            wr_addr <= 0; 
        end
        
        else
        begin 
            
            if (in_xfc) 
            begin 
            
                queue[wr_addr+0] <= p0;
                queue[wr_addr+1] <= p1;
                queue[wr_addr+2] <= p2;
                queue[wr_addr+3] <= p3;
                queue[wr_addr+4] <= p4;
                queue[wr_addr+5] <= p5;
                queue[wr_addr+6] <= p6;
                queue[wr_addr+7] <= p7;
            
                wr_addr <= next_wr_addr_8;
                
             end
            
            if (out_xfc)
                rd_addr <= rd_addr + 1;
            
        end
        
    end

endmodule