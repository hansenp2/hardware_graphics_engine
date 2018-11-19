`timescale 1ns / 1ps
`define CLK 20
`define I2C_DELAY 200
module tb_cmd_processor_engines_integration(
    );
    
    reg CLOCK = 0;
    reg RESET = 0;
        
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
        // Active Low
        RESET = 0;
        #1;
        #`CLK;
        #`CLK;
        #`CLK;
        RESET = 1;
    end   
    
    // I2C Interaface
    reg     [7:0]   cmd;
    reg     [7:0]   i2c_in_data;
    wire            i2c_rtr;
    reg             i2c_rts;
    
    // Arbiter Interface
    wire    [31:0]  arb_fill_rect_data;
    wire    [15:0]  arb_fill_rect_addr;
    wire    [3:0]   arb_fill_rect_wben;
    wire            arb_fill_rect_op;
    wire            arb_fill_rect_rts;
    reg             arb_fill_rect_rtr;
    
    reg     [31:0]  arb_out_bcast_data;
    reg             arb_out_xfc;
    
    cmd_processor_engines_integration uut(
        .clk(CLOCK),
        .rst_(RESET),
        // I2C Interface
        .i2c_cmd(cmd),
        .i2c_data(i2c_in_data),
        .i2c_rtr(i2c_rtr),
        .i2c_rts(i2c_rts),
        // Arbiter Interface
        .arb_fill_rect_data(arb_fill_rect_data),
        .arb_fill_rect_addr(arb_fill_rect_addr),
        .arb_fill_rect_wben(arb_fill_rect_wben),
        .arb_fill_rect_op(arb_fill_rect_op),
        .arb_fill_rect_rts(arb_fill_rect_rts),
        .arb_fill_rect_rtr(arb_fill_rect_rtr),
        .arb_out_bcast_data(arb_out_bcast_data),
        .arb_out_xfc(arb_out_xfc)
        );
        
    initial begin
                #101;
                #`I2C_DELAY;
                arb_fill_rect_rtr = 1'b1;
                i2c_rts     = 1'b1;
                // Command 1:  Fill Rect Engine X,Y => (0,0) WID = 4, HGT = 4, R = 15, G = 0, B = 0
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
                i2c_in_data = 8'h0;             // WID[15:8]
                i2c_rts     = 1'b1;
                #`CLK;
                i2c_rts     = 1'b0;        
                #`I2C_DELAY;
                cmd         = 8'h1;
                i2c_in_data = 8'h4;             // WID[7:0]
                i2c_rts     = 1'b1;
                #`CLK;
                i2c_rts     = 1'b0;        
                #`I2C_DELAY;    
                cmd         = 8'h1;
                i2c_in_data = 8'h0;             // HGT[15:8]
                i2c_rts     = 1'b1;
                #`CLK;
                i2c_rts     = 1'b0;        
                #`I2C_DELAY;
                cmd         = 8'h1;
                i2c_in_data = 8'h4;             // HGT[7:0]
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
                #`I2C_DELAY;
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
                #`I2C_DELAY;
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
