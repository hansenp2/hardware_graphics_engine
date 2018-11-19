`timescale 1ns / 1ps
`define CLK 20
`define I2C_DELAY 200
`define I2C_DELAY 200
module tb_cmd_proc_fifo_integration(

    );
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
    
    reg     [7:0]   cmd;
    reg     [7:0]   i2c_in_data;
    reg             i2c_rts;
        
    cmd_proc_fifo_integration uut(
        .clk(CLOCK),
        .rst_(RESET),
        .cmd(cmd),
        .i2c_in_data(i2c_in_data),
        .i2c_rts(i2c_rts)
        );
       
    initial begin
            #101;
            #`I2C_DELAY;
            i2c_rts     = 1'b1;
            // Command 1:  Fill Rect Engine X,Y => (0,0) WID = 64, HGT = 64, R = 15, G = 0, B = 0
            cmd         = 8'h1;
            i2c_in_data = 8'h0;             // X[15:8]
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0;
            #`I2C_DELAY;
            cmd         = 8'h1;
            i2c_in_data = 8'h0;             // X[7:0]
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0;
            #`I2C_DELAY;
            cmd         = 8'h1;
            i2c_in_data = 8'h0;             // Y[15:8]
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0;
            #`I2C_DELAY;
            cmd         = 8'h1;
            i2c_in_data = 8'h0;             // Y[7:0]
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0;
            #`I2C_DELAY;
            cmd         = 8'h1;
            i2c_in_data = 8'h2;             // WID[15:8]
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0;        
            #`I2C_DELAY;
            cmd         = 8'h1;
            i2c_in_data = 8'h0;             // WID[7:0]
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0;        
            #`I2C_DELAY;    
            cmd         = 8'h1;
            i2c_in_data = 8'h2;             // HGT[15:8]
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0;        
            #`I2C_DELAY;
            cmd         = 8'h1;
            i2c_in_data = 8'h0;             // HGT[7:0]
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0;
            #`I2C_DELAY;
            cmd         = 8'h1;
            i2c_in_data = 8'hf;             // R[7:0] = 8'bZZZ1111
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0; 
            #`I2C_DELAY;    
            cmd         = 8'h1;
            i2c_in_data = 8'h0;             // G[7:0] = 8'bZZZ0000
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0; 
            #`I2C_DELAY;    
            cmd         = 8'h1;
            i2c_in_data = 8'h0;             // B[7:0] = 8'bZZZ0000 
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0;
            #`CLK;
            // Command 2: Fill Rect Engine X,Y => (32,32) WID = 128, HGT = 128, R = 0, G = 15, B = 0
            cmd         = 8'h1;
            i2c_in_data = 8'h1;             // X[15:8]
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0;
            #`I2C_DELAY;
            cmd         = 8'h1;
            i2c_in_data = 8'h0;             // X[7:0]
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0;
            #`I2C_DELAY;
            cmd         = 8'h1;
            i2c_in_data = 8'h1;             // Y[15:8]
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0;
            #`I2C_DELAY;
            cmd         = 8'h1;
            i2c_in_data = 8'h0;             // Y[7:0]
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0;
            #`I2C_DELAY;
            cmd         = 8'h1;
            i2c_in_data = 8'h4;             // WID[15:8]
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0;        
            #`I2C_DELAY;
            cmd         = 8'h1;
            i2c_in_data = 8'h0;             // WID[7:0]
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0;        
            #`I2C_DELAY;    
            cmd         = 8'h1;
            i2c_in_data = 8'h4;             // HGT[15:8]
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0;        
            #`I2C_DELAY;
            cmd         = 8'h1;
            i2c_in_data = 8'h0;             // HGT[7:0]
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0;
            #`I2C_DELAY;
            cmd         = 8'h1;
            i2c_in_data = 8'h0;             // R[7:0] = 8'bZZZ0000
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts = 1'b0; 
            #`I2C_DELAY;    
            cmd         = 8'h1;
            i2c_in_data = 8'hf;             // G[7:0] = 8'bZZZ1111
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0; 
            #`I2C_DELAY;    
            cmd         = 8'h1;
            i2c_in_data = 8'h0;             // B[7:0] = 8'bZZZ0000 
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0;   
            #`CLK;
            // Command 3: Fill Rect Engine X,Y => (32,32) WID = 256, HGT = 256, R = 0, G = 0, B = 15
            cmd         = 8'h1;
            i2c_in_data = 8'h1;             // X[15:8]
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0;
            #`I2C_DELAY;
            cmd         = 8'h1;
            i2c_in_data = 8'h0;             // X[7:0]
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0;
            #`I2C_DELAY;
            cmd         = 8'h1;
            i2c_in_data = 8'h1;             // Y[15:8]
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0;
            #`I2C_DELAY;
            cmd         = 8'h1;
            i2c_in_data = 8'h0;             // Y[7:0]
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0;
            #`I2C_DELAY;
            cmd         = 8'h1;
            i2c_in_data = 8'h8;             // WID[15:8]
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0;        
            #`I2C_DELAY;
            cmd         = 8'h1;
            i2c_in_data = 8'h0;             // WID[7:0]
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0;        
            #`I2C_DELAY;    
            cmd         = 8'h1;
            i2c_in_data = 8'h8;             // HGT[15:8]
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0;        
            #`I2C_DELAY;
            cmd         = 8'h1;
            i2c_in_data = 8'h0;             // HGT[7:0]
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0;
            #`I2C_DELAY;
            cmd         = 8'h1;
            i2c_in_data = 8'h0;             // R[7:0] = 8'bZZZ0000
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts = 1'b0; 
            #`I2C_DELAY;    
            cmd         = 8'h1;
            i2c_in_data = 8'h0;             // G[7:0] = 8'bZZZ0000
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0; 
            #`I2C_DELAY;    
            cmd         = 8'h1;
            i2c_in_data = 8'hf;             // B[7:0] = 8'bZZZ1111 
            i2c_rts     = 1'b1;
            #`CLK;
            i2c_rts     = 1'b0;          
        end  
endmodule
