`timescale 1ns / 1ps

// INPUT FIFO PARAMETERS
`define IN_FIFO_DATA_WIDTH  52
`define IN_FIFO_DEPTH        4
`define IN_FIFO_LOG2DEPTH    2

// OUTPUT FIFO PARAMETERS
`define OUT_FIFO_DATA_WIDTH 10
`define OUT_FIFO_DEPTH      32
`define OUT_FIFO_LOG2DEPTH   5

module line_drawing_engine(

    // clock and sync reset
    input clk,
    input rst_, 
    
    // input interface
    input [51:0] in_op,
    input  in_rts,
    output in_rtr,
    
    // output interface
    output out_rts,
    input  out_rtr
);

    // input fifo for ops
    wire [51:0] current_op;
    wire fi_rts_ld, ld_rtr_fi;
    fifo #(`IN_FIFO_DATA_WIDTH, `IN_FIFO_DEPTH, `IN_FIFO_LOG2DEPTH) fi (
        .clk(clk),
        .rst_(rst_), 
        
        .in_data(in_op),
        .in_rts(in_rts),
        .in_rtr(in_rtr),
        
        .out_data(current_op),
        .out_rts(fi_rts_ld),
        .out_rtr(ld_rtr_fi) 
    );     

    // TEMPORARY VALUES FOR TESTING
    wire [ 9:0] x_out, y_out, f_out;
    reg [ 9:0] x1, y1, x2, y2;
    reg [11:0] color;
    
    /* assign x1 = 0; assign y1 = 0;
    assign x2 = 5; assign y2 = 10;
    assign color = 12'habc; 
    
    assign x1       = current_op[51:42];
    assign y1       = current_op[41:32];
    assign x2       = current_op[31:22];
    assign y2       = current_op[21:12];
    assign color    = current_op[ 11:0];*/
    
    always @ (*)
    begin
        if (fi_rts_ld && ld_rtr_fi)
        begin
            x1       = current_op[51:42];
            y1       = current_op[41:32];
            x2       = current_op[31:22];
            y2       = current_op[21:12];
            color    = current_op[ 11:0]; 
        end 
    end

    // line drawing algorithm module
    wire ld_rts_fx, rx_rtr_ld;
    line_drawer ld ( 
        .clk(clk),
        .rst_(rst_), 
        .x1_in(x1), 
        .y1_in(y1), 
        .x2_in(x2), 
        .y2_in(y2), 
        .color(color), 
        
        .in_rts(fi_rts_ld),
        .in_rtr(ld_rtr_fi),
        
        .out_rts(ld_rts_fx),
        .out_rtr(rx_rtr_ld),
        
        .draw_x(x_out),
        .draw_y(y_out) 
    );
    
    
    // output fifos
    fifo #(`OUT_FIFO_DATA_WIDTH, `OUT_FIFO_DEPTH, `OUT_FIFO_LOG2DEPTH) fx (
        .clk(clk),
        .rst_(rst_), 
        
        .in_data(x_out),
        .in_rts(ld_rts_fx),
        .in_rtr(rx_rtr_ld),
        
        .out_data(f_out),
        .out_rts(),
        .out_rtr(1'b0) 
    );
    
endmodule
