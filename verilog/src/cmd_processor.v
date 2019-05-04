`timescale 1ns / 1ps

`define NUM_PACKETS_TEST_PAT        2
`define NUM_PACKETS_LINE_DRAW       12
`define NUM_PACKETS_RECT_FILL       12
`define NUM_PACKETS_ELLIPSE         12
`define NUM_PACKETS_CIRCLE          10
`define NUM_PACKETS_SOFT_RESET      2


`define CIRCLE_CMD_ID               1    // BCAST ENGINE RTS -> 3
`define ELLIPSE_CMD_ID              2    // BCAST ENGINE RTS -> 4
`define LINE_DRAW_CMD_ID            4    // BCAST ENGINE RTS -> 0
`define TEST_PAT_CMD_ID             8    // BCAST ENGINE RTS -> 1
`define SOFT_RESET_CMD_ID           16   // BCAST ENGINE RTS -> 5

module cmd_processor(
    input               clk,
    input               rst_,
    input       [7:0]   cmd,
    input               i2c_rts,
    output              i2c_rtr,
    input       [7:0]   i2c_in_data,
    output  reg [5:0]   engine_out_rts,
    input       [5:0]   engine_in_rtr,
    output    [127:0]   bcast_out_data,
    output  reg         test_pat_state,
    output  reg         soft_reset_state
    //output              packet_xfc
    );

    wire    [4:0]   xfc;
    reg     [3:0]   packet_cnt;
    wire    [7:0]   packet_shift;
    reg     [127:0] cmd_out;
    wire    [31:0]  i2c_in_tmp;
    wire            packet_xfc;
    wire    [3:0]   num_packets_in_cmd;
    reg     [3:0]   engine_id;
    wire    [3:0]   engine_rts_idx;
    
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
                if (packet_cnt == 0)
                begin
                    //engine_id <= i2c_in_data;
                    cmd_out <= 0;
                end
                else
                begin
                    cmd_out <= cmd_out | (i2c_in_data << (packet_shift)); 
                end
                packet_cnt <= packet_cnt + 1;
            end
            else
            begin
                if (packet_cnt == (num_packets_in_cmd))
                begin
                    packet_cnt <= 0;
                    engine_out_rts[engine_rts_idx] <= 1'b1;
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
            if (cmd == 8'h`TEST_PAT_CMD_ID)
            begin
                if ((packet_cnt == (num_packets_in_cmd)))
                    test_pat_state <= i2c_in_data;
                else
                    if (test_pat_state)
                        test_pat_state <= 1'b1;    
                    else
                        test_pat_state <= 1'b0;
            end
            else
                test_pat_state <= (test_pat_state) ? 1'b1 : 1'b0;
        end
    end
    
    always @(posedge clk or negedge rst_) 
    begin
        if (!rst_) 
        begin
            soft_reset_state <= 1'b0;
        end
        else
        begin
        if (cmd == 8'h`SOFT_RESET_CMD_ID)
        begin
            if ((packet_cnt == (num_packets_in_cmd)))
                soft_reset_state <= i2c_in_data;
            else
                if (soft_reset_state)
                    soft_reset_state <= 1'b1;    
                else
                    soft_reset_state <= 1'b0;
        end
        else
            soft_reset_state <= (soft_reset_state) ? 1'b1 : 1'b0;
        end
    end
    
    
    assign packet_xfc = i2c_rts;
    assign i2c_in_tmp = i2c_in_data;
    assign packet_shift = ((packet_cnt - 1) << 3);
    assign num_packets_in_cmd = (cmd==8'd`LINE_DRAW_CMD_ID) ? `NUM_PACKETS_LINE_DRAW : 
                                (cmd==8'd`TEST_PAT_CMD_ID) ? `NUM_PACKETS_TEST_PAT : 
                                (cmd==8'd4) ? `NUM_PACKETS_RECT_FILL : 
                                (cmd==8'd`CIRCLE_CMD_ID) ? `NUM_PACKETS_CIRCLE:
                                (cmd==8'd`ELLIPSE_CMD_ID) ? `NUM_PACKETS_ELLIPSE: 
                                (cmd==8'd`SOFT_RESET_CMD_ID) ? `NUM_PACKETS_SOFT_RESET : 8'hX;
                                
    assign engine_rts_idx = (cmd==8'd`LINE_DRAW_CMD_ID)     ? 0 : 
                            (cmd==8'd`TEST_PAT_CMD_ID)      ? 1 : 
                            (cmd==8'd4)                     ? 2 : 
                            (cmd==8'd`CIRCLE_CMD_ID)        ? 3 :
                            (cmd==8'd`ELLIPSE_CMD_ID)       ? 4 :
                            (cmd==8'd`SOFT_RESET_CMD_ID)    ? 5 :8'hX;
                            
    assign bcast_out_data = cmd_out;//(i2c_in_tmp << packet_shift);
    assign i2c_rtr = (engine_in_rtr) ? 1'b1 : 1'b0;
    assign xfc = engine_in_rtr & engine_out_rts;
endmodule

