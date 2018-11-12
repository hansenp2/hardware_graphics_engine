`timescale 1ns / 1ps
`define CLK 20

module command_processor_tb(

    );
    reg [15:0]  i2c_in_data
    ;
    wire [15:0]  bcast_out_data;
    reg [7:0]   cmd;
    wire [4:0]  engine_rtr;
    wire [4:0]  engine_rts;
    
    reg CLOCK = 0;
    reg RESET = 0;
    //assign rst_n = !RESET;
    
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
        RESET = 0;
        #1;
        #`CLK;
        #`CLK;
        #`CLK;
        RESET = 1;
    end
    
    cmd_processor uut (
        .clk(CLOCK),
        .rst_(RESET),
        .cmd(cmd),
        .i2c_in_data(i2c_in_data),
        .engine_in_rtr(engine_rtr),
        .engine_out_rts(engine_rts),
        .bcast_out_data(bcast_out_data)
    );
    initial begin
        #100;
        #`CLK;
        cmd = 8'h0;
        i2c_in_data = 8'h0;
        #`CLK;
        cmd = 8'h1;
        i2c_in_data = 8'h5;
        #`CLK;
        cmd = 8'h2;
        i2c_in_data = 8'hc;
        #`CLK;
        i2c_in_data = 8'hd;
        #`CLK;
        i2c_in_data = 8'he;
        #`CLK;
        i2c_in_data = 8'hf;
        #`CLK;
    end
endmodule
