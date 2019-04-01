`timescale 1ns / 1ps
`define DECODE_STATE_IDLE       0
`define DECODE_STATE_ORIGX_B1   1
`define DECODE_STATE_ORIGX_B2   2
`define DECODE_STATE_ORIGY_B1   3
`define DECODE_STATE_ORIGY_B2   4
`define DECODE_STATE_WID_B1     5
`define DECODE_STATE_WID_B2     6
`define DECODE_STATE_HGT_B1     7
`define DECODE_STATE_HGT_B2     8
`define DECODE_STATE_R          9
`define DECODE_STATE_G          10
`define DECODE_STATE_B          11

module fill_rect_decode_engine(
    input               clk,
    input               rst_,
    // Pipeline Stall Interface
    input               data_gen_is_idle,
    output              dec_eng_has_data,
    // Command Fifo Interface
    output              cmd_fifo_rtr,
    input               cmd_fifo_rts,
    input       [7:0]   cmd_fifo_data,
    // Command Field Data Interface
    output  reg [15:0]  cmd_data_origx,
    output  reg [15:0]  cmd_data_origy,
    output  reg [15:0]  cmd_data_wid,
    output  reg [15:0]  cmd_data_hgt,
    output  reg [3:0]   cmd_data_rval,
    output  reg [3:0]   cmd_data_gval,
    output  reg [3:0]   cmd_data_bval,
    output              addr_start_strobe
    );

    reg     [1:0]   rgb_idx;
    reg     [3:0]   dec_state;
    wire            cmd_fifo_xfc;
    wire            decode_sm_start_cond;
   
    always @(posedge clk or negedge rst_)
    begin
        if (!rst_)
        begin
            // reset logic
            rgb_idx <= 2'b00;
            cmd_data_origx <= 16'h00;
            cmd_data_origy <= 16'h00;
            cmd_data_wid <=  16'h00;
            cmd_data_hgt <= 16'h00;
            cmd_data_rval <= 4'h0;
            cmd_data_bval <= 4'h0;
            cmd_data_gval <= 4'h0;
            //cmd_fifo_rtr <= 1'b0;
            //addr_start_strobe <= 1'b0;
            
            dec_state <= `DECODE_STATE_IDLE;
        end
        else
        begin

            // For the generator to begin outputting addresses and data the arbiter must
            // be ready to recieve and the fifo must be ready to send
            if (cmd_fifo_rts)//arb_rtr && stall_on_decode_await)// && cmd_fifo_rts)
            begin
                // ----------------- Decode Instruction State Machine
                case (dec_state)
                    `DECODE_STATE_IDLE:
                    begin
                        //addr_start_strobe <= 1'b0;
                        if (decode_sm_start_cond)
                        begin
                            dec_state <= `DECODE_STATE_ORIGX_B1;
                            
                        end
                    end
                    `DECODE_STATE_ORIGX_B1:
                    begin
                        // Store X origin data
                        cmd_data_origx[15:8] <= 8'd0;//cmd_fifo_data;

                        // Initiate Calculation State machine to begin calculating
                        // row index addresses from the X origin data
                        dec_state <= `DECODE_STATE_ORIGX_B2;
                    end
                    `DECODE_STATE_ORIGX_B2:
                    begin
                        cmd_data_origx[7:0] <= 8'd0;//cmd_fifo_data;
                        dec_state <= `DECODE_STATE_ORIGY_B1;
                    end
                    `DECODE_STATE_ORIGY_B1:
                    begin
                        // Store y origin data
                        cmd_data_origy[15:8] <= 8'd0;//cmd_fifo_data;
                        dec_state <= `DECODE_STATE_ORIGY_B2;
                    end
                    `DECODE_STATE_ORIGY_B2:
                    begin
                        cmd_data_origy[7:0] <= 8'd0;//cmd_fifo_data;
                        dec_state <= `DECODE_STATE_WID_B1;
                    end
                    `DECODE_STATE_WID_B1:
                    begin
                        // Store width of box
                        cmd_data_wid[15:8] <= 8'd0;//cmd_fifo_data;
                        dec_state <= `DECODE_STATE_WID_B2;
                    end
                    `DECODE_STATE_WID_B2:
                    begin
                        cmd_data_wid[7:0] <= 8'd4;//cmd_fifo_data;
                        dec_state <= `DECODE_STATE_HGT_B1;
                    end
                    `DECODE_STATE_HGT_B1:
                    begin
                        // Store hight of box
                        cmd_data_hgt[15:8] <= 8'd0;//cmd_fifo_data;
                        dec_state <= `DECODE_STATE_HGT_B2;
                    end
                    `DECODE_STATE_HGT_B2:
                    begin
                        cmd_data_hgt[7:0] <= 8'd4;//cmd_fifo_data;
                        dec_state <= `DECODE_STATE_R;
                    end
                    `DECODE_STATE_R:
                    begin
                        // Store R pixel data
                        cmd_data_rval <=  4'hF;//cmd_fifo_data;
                        dec_state <= `DECODE_STATE_G;
                    end
                    `DECODE_STATE_G:
                    begin
                        // Store G pixel value
                        cmd_data_gval <= 4'hF;//cmd_fifo_data;
                        dec_state <= `DECODE_STATE_B;
                    end
                    `DECODE_STATE_B:
                    begin
                        //if (!addr_start_strobe)
                        //begin
                        //addr_start_strobe <= 1'b1;
                            // Store B pixel value
                        cmd_data_bval <= 4'hF;//cmd_fifo_data;                       
                        //end
                        //else
                        //begin
                        //addr_start_strobe <= 1'b0;
                        // Done parsing a command
                        dec_state <= `DECODE_STATE_IDLE;
                        //end
                    end
                endcase
            end
        end
    end
    
    reg [3:0]   fifo_counter;
    always @(posedge clk or negedge rst_)
    begin
        if (!rst_)
        begin
            fifo_counter <= 4'h0;
        end
        else
        begin
            if (cmd_fifo_xfc)
            begin
                fifo_counter <= fifo_counter + 1'b1;
            end
        end
    end
    
    
    //assign addr_start_strobe = (dec_state == `DECODE_STATE_B);

    assign cmd_fifo_xfc = cmd_fifo_rtr;
    
    assign dec_eng_has_data = (dec_state >= `DECODE_STATE_G); 
    assign decode_sm_start_cond = data_gen_is_idle & cmd_fifo_rts;
    
    assign cmd_fifo_rtr = (dec_state > `DECODE_STATE_IDLE);
    
    assign addr_start_strobe = (dec_state == `DECODE_STATE_B) & (cmd_fifo_rts);
endmodule
