`timescale 1ns / 1ps

`define NUM_PACKETS_SOFT_RST        1
`define NUM_PACKETS_LINE_DRAW       11
`define NUM_PACKETS_RECT_FILL       11

// TODO: Stall when engine !rtr
// TODO: Turn Off rts when we arent getting valid data (how do we know when this will be?)
module cmd_processor(
    input               clk,
    input               rst_,
    input       [7:0]   cmd,
    input               i2c_rts,
    output              i2c_rtr,
    input       [7:0]   i2c_in_data,
    output  reg [4:0]   engine_out_rts,
    input       [4:0]   engine_in_rtr,
    output    [127:0]   bcast_out_data,
    output  reg         test_pat_state,
    output  reg         line_demo_state
    );

    wire    [4:0]   xfc;
    reg     [3:0]   packet_cnt;
    wire    [7:0]   packet_shift;
    reg     [127:0] cmd_out;
    wire    [31:0]   i2c_in_tmp;
    wire            packet_xfc;
    wire    [3:0]   num_packets_in_cmd;
    
    always @(posedge clk or negedge rst_)
    begin
        if (!rst_)
        begin
            //cmd <= 0;
            cmd_out <= 0;
            packet_cnt <= 0;
        end 
        else
        begin
            if (packet_xfc)
            begin
                cmd_out <= cmd_out | (i2c_in_tmp << (packet_shift));
                packet_cnt <= packet_cnt + 1; 
            end
            else
            begin
                if (packet_cnt == (num_packets_in_cmd))
                begin
                    packet_cnt <= 0;
                    engine_out_rts[cmd] <= 1'b1;
                end
                else
                begin
                    engine_out_rts <= 0;
                end
            end 
                
        end
    end
    
    always @(posedge clk or negedge rst_) 
    begin
        if (!rst_) 
        begin
            test_pat_state <= 1'b0;
        end
        else
        begin
            if (cmd == 8'b0)
            begin
                if (i2c_in_data)
                    test_pat_state <= 1'b1;
                else
                    test_pat_state <= 1'b0;     
            end
        end
    end
    
    always @(posedge clk or negedge rst_) 
    begin
        if (!rst_) 
        begin
            line_demo_state <= 1'b0;
        end
        else
        begin
            if (cmd == 8'b1)
            begin
                if (i2c_in_data)
                    line_demo_state <= 1'b1;
                else
                    line_demo_state <= 1'b0;     
            end
        end
    end
    
    
    assign packet_xfc = i2c_rts;
    assign i2c_in_tmp = i2c_in_data;
    assign packet_shift = (packet_cnt << 3);
    assign num_packets_in_cmd = (cmd==8'h4) ? `NUM_PACKETS_LINE_DRAW : 
                                (cmd==8'h0) ? `NUM_PACKETS_SOFT_RST : 
                                (cmd==8'h3) ? `NUM_PACKETS_RECT_FILL : 0;
    assign bcast_out_data = cmd_out;//(i2c_in_tmp << packet_shift);
    assign i2c_rtr = (engine_in_rtr) ? 1'b1 : 1'b0;
    assign xfc = engine_in_rtr & engine_out_rts;
endmodule

