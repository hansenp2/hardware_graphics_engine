`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Author: Jeffrey Sabo
//Advisor: Dr. Larry Pearlstein
//Subject: Senior Project
//Date: 9/25/2018
//
//Module name: fifo
//
//Purpose: To serve as an abstract reusable First-In-First-Out buffer. It allows for data to be written to it and read from it on any clock cycle. 
//
//Inputs:
//  -clk:   1 Bit,  Clock signal 
//  -rst:   1 Bit, Asynchronous Reset signal 
//  -data_in:  DATA_WIDTH Bits, incoming data that will be written to the buffer
//  -out_rtr:  1 Bit, Signal from external device or module informing the buffer that the oldest element is to be read
//  -in_rst:  1 Bit, Signal from external device or module informing the buffer that a new element is to be written 
//
//Outputs:
//  -data_out: DATA_WIDTH Bits, outgoing data read from the buffer as a result of a read request
//  -in_rtr:  1 Bit, Signal informing any external device or module that the buffer has room and is ready to receive new data
//  -out_rts:  1 Bit, Signal informing any external device or module that the buffer has data in it and is ready to be read from
//
//Usage: Set the paramter values DATA_WIDTH, DEPTH, LOG2DEPTH to the word-size that will be stored, the address size, and the number of bits required for the address size respectively
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module fifo(
clk,
rst_,
in_data,
in_rts,
in_rtr,
out_data,
out_rts,
out_rtr,
//For debug purposes
in_xfc,
out_xfc,
rd_addr, 
wr_addr
);

    //Set for expected word-length being saved and queue depth

    parameter DATA_WIDTH    = 12;

    parameter DEPTH         = 8;

    parameter LOG2DEPTH     = 3;

   

    input   clk;

    input   rst_;                       // active low reset

   

    // FIFO input interface

    input   [DATA_WIDTH-1:0] in_data;

    input   in_rts;                        // FIFO writer is ready to send

    output  in_rtr;                        // FIFO is ready to receive input data

 

    // FIFO output interface

    output  [DATA_WIDTH-1:0] out_data;

    output  out_rts;                       // FIFO is ready to send output data

    input   out_rtr;                       // FIFO reader is ready to receive

 

    //reg  [LOG2DEPTH-1:0] rd_addr;

    //reg  [LOG2DEPTH-1:0] wr_addr;

    wire [LOG2DEPTH-1:0] next_wr_addr;

   

    reg [DATA_WIDTH-1:0] queue [(DEPTH-1):0];

    

    // Transfer Complete signals

    output wire in_xfc;

    output wire out_xfc;

 

    //For debug purposes...

    output reg [LOG2DEPTH-1:0] rd_addr, wr_addr;  
 

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

   

    always @ (posedge clk or negedge rst_)

    begin

   

        if (!rst_)

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

