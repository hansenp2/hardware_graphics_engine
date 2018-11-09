`timescale 1ns / 1ps

module fifo_tb();

    parameter DATA_WIDTH = 12;
    parameter DEPTH = 5;

    reg clk;
    reg rst;
    reg [DATA_WIDTH-1:0] data_in;
    reg read_request;
    reg write_request;
    
    wire [DATA_WIDTH-1:0] data_out;
    wire rtr, rts;
    wire [2:0] start_addr, end_addr;  
    wire in_xfc;
    wire out_xfc;
    
    reg [DATA_WIDTH-1:0] data [((1 << DEPTH) -1):0];
 
    fifo uut(
    .clk(clk),
    .rst_(rst),
    .in_data(data_in),
    .in_rtr(rtr),
    .out_data(data_out),
    .out_rtr(read_request),
    .out_rts(rts),
    .in_rts(write_request),
    .in_xfc(in_xfc),
    .out_xfc(out_xfc),
    .rd_addr(start_addr),
    .wr_addr(end_addr)
    );

    initial begin
        clk = 0;
            forever begin
                #5;
                clk <= ~clk;
            end
    end
    
    initial begin
        $readmemh("fifo.mem", data);
    end
    
    initial begin
        rst = 0;
        write_request = 1;
        read_request = 1;
        
        #5;
        rst = 1;
    end
        
    reg [5:0] counter =0;
    always @ (posedge clk) begin
    
        if (rtr) begin
        data_in <= data[counter];
        counter <= counter + 1;
        end
        
      
/*        else begin
            write_request = ~write_request;
            read_request = ~read_request;
        end
        */
   end 
    
endmodule
