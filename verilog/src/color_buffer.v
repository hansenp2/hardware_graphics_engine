`timescale 1ns / 1ps

module color_buffer(
clk,
rst_,
en, 
in_data,
in_rts,
in_rtr,
out_data,
out_rts,
out_rtr
//For debug purposes
//start_addr, 
//end_addr
);

    //Set for expected word-length being saved and queue depth
    parameter DATA_WIDTH    = 32;
    parameter DEPTH         = 8;
    parameter LOG2DEPTH     = 3;
  
    input   clk;
    input   rst_;                       // active low reset
    input   en;

   

    // FIFO input interface
    input   [DATA_WIDTH-1:0] in_data;
    input   in_rts;                        // FIFO writer is ready to send
    output  in_rtr;                        // FIFO is ready to receive input data 

    // FIFO output interface
    output  [DATA_WIDTH-1:0] out_data;
    output  out_rts;                       // FIFO is ready to send output data
    input   out_rtr;                       // FIFO reader is ready to receive
 
    reg  [LOG2DEPTH-1:0] rd_addr;
    reg  [LOG2DEPTH-1:0] wr_addr;
    wire [LOG2DEPTH-1:0] next_wr_addr;   

    reg [DATA_WIDTH-1:0] queue [(DEPTH-1):0];    

    // Transfer Complete signals
    wire in_xfc;
    wire out_xfc;
 
    //For debug purposes...
//    output reg [LOG2DEPTH-1:0] start_addr, end_addr;  
 

    // xfc = Transfer Complete
    assign in_xfc   = in_rts  & in_rtr;
    assign out_xfc  = out_rts & out_rtr;   

    assign out_data = queue[rd_addr];  
    assign next_wr_addr = wr_addr + 1;
 

    // we'll say that the FIFO is full
    // when the next write address would match
    // the read address (this wastes one element)
    assign in_rtr       = (next_wr_addr != rd_addr); 

    // the FIFO is empty when the write address is
    // equal to the read address, i.e. the current
    // location being read (currently output)
    // has not yet been written
    assign out_rts      = (rd_addr != wr_addr);

   

    always @ (posedge clk or negedge rst_ or posedge en)
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
                queue[wr_addr] <= in_data;
                wr_addr <= next_wr_addr;         
            end

            if (out_xfc)
                rd_addr <= rd_addr + 1;       

        end
        
    end       

endmodule