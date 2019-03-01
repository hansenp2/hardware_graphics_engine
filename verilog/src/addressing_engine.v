`timescale 1ns / 1ps

`define ADDR_STATE_IDLE         0
`define ADDR_STATE_ROW_IDX      1
`define ADDR_STATE_START_ADDR   2
`define ADDR_STATE_WRITE        3

// `define DECODE_STATE_ORIGY_B2   3

module addressing_engine(
    input           clk,
    input           rst_,
    
    // Decode Engine Interface
    // input          addr_start_strobe,
    input   [9:0]  cmd_data_origx,
    input   [9:0]  cmd_data_origy,
    input   [11:0] in_color, 
    
    // Generation Engine Interface
    output reg [16:0] init_addr,
    output reg [ 2:0] addr_offset, 
    output reg [11:0] out_color,
    
    // input interface
    input  in_rts,
    output in_rtr, 
    
    // output interface
    output  out_rts,                       
    input   out_rtr 
    
);

    // transfer completes
    wire in_xfc, out_xfc;
    assign in_xfc  = in_rts  & in_rtr;
    assign out_xfc = out_rts & out_rtr;
    
    reg    [ 3:0]   addr_eng_state;
    reg    [31:0]   temp_addr; 
    
    // ready to recieve when in state 00
    assign in_rtr  = (addr_eng_state == `ADDR_STATE_IDLE) ? (1) : (0);
    
    // ready to send when in state 01 or 10
    assign out_rts = (addr_eng_state == `ADDR_STATE_WRITE) ? (1) : (0);

    reg [15:0] in_x, in_y;
    reg [11:0] in_c;
    
    always @(posedge clk or negedge rst_)
    begin
        if (!rst_)
        begin
            addr_eng_state <= `ADDR_STATE_IDLE;
            init_addr <= 16'h00;
            temp_addr <= 0;
            addr_offset <= 0;
            out_color <= 0;
            in_x <= 0;
            in_y <= 0;
            in_c <= 0;
        end
        else
        begin
            // ------------------ Calc State Machine
            case (addr_eng_state)
                `ADDR_STATE_IDLE:
                begin
                    // State Machine defaults to idle
                    if (in_xfc)
                    begin
                        addr_eng_state <= `ADDR_STATE_ROW_IDX;
                        in_x <= cmd_data_origx;
                        in_y <= cmd_data_origy;
                        in_c <= in_color;
                    end
                end
                
                `ADDR_STATE_ROW_IDX:
                begin
                    // Calculate the starting row index address in mem
                    temp_addr <= in_y * 640;
                    addr_eng_state <= `ADDR_STATE_START_ADDR;
                end
                
                `ADDR_STATE_START_ADDR:
                begin
                    // Calculate the beinging starting address using the begining y offset
                    init_addr <= ((temp_addr + in_x) >> 3) * 3;
                    addr_offset <= (temp_addr + in_x) % 8;
                    out_color <= in_c;
                    addr_eng_state <= `ADDR_STATE_WRITE; 
                end
                
                `ADDR_STATE_WRITE:
                begin
                    if (out_xfc) 
                        addr_eng_state <= `ADDR_STATE_IDLE;
                end
                
            endcase
        end
    end
    
endmodule
