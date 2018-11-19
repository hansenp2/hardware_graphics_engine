`timescale 1ns / 1ps
`define CLK 20
`define I2C_DELAY 400

module command_processor_tb(

    );
    reg     [7:0]   i2c_in_data;
    wire    [7:0]   bcast_out_data;
    reg     [7:0]   cmd;
    reg     [4:0]   engine_rtr;
    wire    [4:0]   engine_rts;
    reg             i2c_rts;
    
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
        .bcast_out_data(bcast_out_data),
        .i2c_rts(i2c_rts)
    );
    
    initial begin
        #101;
        engine_rtr = 5'b00010;          // Fill Rect Engine is ready to send
        #`I2C_DELAY;
        i2c_rts = 1'b1;
        // Command 1:  Fill Rect Engine X,Y => (0,0) WID = 64, HGT = 64, R = 15, G = 0, B = 0
        cmd         = 8'h1;
        i2c_in_data = 8'h0;             // X[15:8]
        i2c_rts = 1'b1;
        #`CLK;
        i2c_rts = 1'b0;
        #`I2C_DELAY;
        cmd         = 8'h1;
        i2c_in_data = 8'h0;             // X[7:0]
        i2c_rts = 1'b1;
        #`CLK;
        i2c_rts = 1'b0;
        #`I2C_DELAY;
        cmd         = 8'h1;
        i2c_rts = 1'b1;
        #`CLK;
        i2c_rts = 1'b0;
        #`I2C_DELAY;
        cmd         = 8'h1;
        i2c_in_data = 8'h0;             // Y[7:0]
        i2c_rts = 1'b1;
        #`CLK;
        i2c_rts = 1'b0;
        #`I2C_DELAY;
        cmd         = 8'h1;
        i2c_in_data = 8'h1;             // WID[15:8]
        i2c_rts = 1'b1;
        #`CLK;
        i2c_rts = 1'b0;        
        #`I2C_DELAY;
        cmd         = 8'h1;
        i2c_in_data = 8'h0;             // WID[7:0]
        i2c_rts = 1'b1;
        #`CLK;
        i2c_rts = 1'b0;        
        #`I2C_DELAY;    
         cmd         = 8'h1;
        i2c_in_data = 8'h1;             // HGT[15:8]
        i2c_rts = 1'b1;
        #`CLK;
        i2c_rts = 1'b0;        
        #`I2C_DELAY;
        cmd         = 8'h1;
        i2c_in_data = 8'h0;             // HGT[7:0]
        i2c_rts = 1'b1;
        #`CLK;
        i2c_rts = 1'b0;
        #`I2C_DELAY;
        cmd         = 8'h1;
        i2c_in_data = 8'hf;             // R[7:0] = 8'bZZZ1111
        i2c_rts = 1'b1;
        #`CLK;
        i2c_rts = 1'b0; 
        #`I2C_DELAY;    
        cmd         = 8'h1;
        i2c_in_data = 8'h0;             // G[7:0] = 8'bZZZ0000
        i2c_rts = 1'b1;
        #`CLK;
        i2c_rts = 1'b0; 
        #`I2C_DELAY;    
        cmd         = 8'h1;
        i2c_in_data = 8'h0;             // B[7:0] = 8'bZZZ0000 
        i2c_rts = 1'b1;
        #`CLK;
        i2c_rts = 1'b0;  
    end
endmodule
