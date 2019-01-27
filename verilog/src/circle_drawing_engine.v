`timescale 1ns / 1ps

// INPUT FIFO PARAMETERS
`define C_IN_FIFO_DATA_WIDTH  42
`define C_IN_FIFO_DEPTH        4
`define C_IN_FIFO_LOG2DEPTH    2

// OUTPUT FIFO PARAMETERS
`define C_OUT_FIFO_DATA_WIDTH  10
`define C_OUT_FIFO_DEPTH      128
`define C_OUT_FIFO_LOG2DEPTH    7 

module circle_drawing_engine(

    // clock and sync reset
    input clk,
    input rst_,
    
    // input interface
    input [41:0] in_op,
    input  in_rts,
    output in_rtr,
    
    // output interface
    output out_rts,
    input  out_rtr
);

    // input fifo for ops
    wire [41:0] current_op;
    wire fi_rts_cd, cd_rtr_fi;
    fifo #(`C_IN_FIFO_DATA_WIDTH, `C_IN_FIFO_DEPTH, `C_IN_FIFO_LOG2DEPTH) fi (
        .clk(clk),
        .rst_(rst_), 
        
        .in_data(in_op),
        .in_rts(in_rts),
        .in_rtr(in_rtr),
        
        .out_data(current_op),
        .out_rts(fi_rts_cd),
        .out_rtr(cd_rtr_fi) 
    );
    
    
    // TEMPORARY VALUES FOR TESTING 
    reg [ 9:0] x0, y0, r;
    reg [11:0] color;
    
    always @ (*)
    begin
        if (fi_rts_cd && cd_rtr_fi)
        begin 
            x0       = current_op[41:32];
            y0       = current_op[31:22];
            r        = current_op[21:12];
            color    = current_op[ 11:0]; 
        end 
    end
    
    
    // line drawing algorithm module
    wire cd_rts_fx, rx_rtr_cd;
    wire [9:0] draw_x [0:7];
    circle_drawer cd ( 
        .clk(clk),
        .rst_(rst_), 
        .x0_in(x0), 
        .y0_in(y0), 
        .r_in(r), 
        .color(color),
        
        .in_rts(fi_rts_cd),
        .in_rtr(cd_rtr_fi),
        
        .out_rts(cd_rts_fx),
        .out_rtr(rx_rtr_cd),
        
        .draw_x_0(draw_x[0]),
        .draw_x_1(draw_x[1]),
        .draw_x_2(draw_x[2]),
        .draw_x_3(draw_x[3]),
        .draw_x_4(draw_x[4]),
        .draw_x_5(draw_x[5]),
        .draw_x_6(draw_x[6]),
        .draw_x_7(draw_x[7])
    );
    
    
    // output fifos (WILL NEED TO MAKE THIS CUSTOM - ACCEPT 8 WRITES AT ONCE)
    circle_buffer_out #(`C_OUT_FIFO_DATA_WIDTH, `C_OUT_FIFO_DEPTH, `C_OUT_FIFO_LOG2DEPTH) fx (
        .clk(clk),
        .rst_(rst_), 
        
        .in_px_0(draw_x[0]),
        .in_px_1(draw_x[1]),
        .in_px_2(draw_x[2]),
        .in_px_3(draw_x[3]),
        .in_px_4(draw_x[4]),
        .in_px_5(draw_x[5]),
        .in_px_6(draw_x[6]),
        .in_px_7(draw_x[7]),
        
        .in_rts(cd_rts_fx),
        .in_rtr(rx_rtr_cd),
        
        .out_data(),
        .out_rts(),
        .out_rtr(out_rtr) 
    );

endmodule
