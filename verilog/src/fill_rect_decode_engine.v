`timescale 1ns / 1ps

`define DECODE_STATE_ORIGX_B1   0
`define DECODE_STATE_ORIGX_B2   1
`define DECODE_STATE_ORIGY_B1   2
`define DECODE_STATE_ORIGY_B2   3
`define DECODE_STATE_WID_B1     4
`define DECODE_STATE_WID_B2     5
`define DECODE_STATE_HGT_B1     6
`define DECODE_STATE_HGT_B2     7
`define DECODE_STATE_R          8
`define DECODE_STATE_G          9
`define DECODE_STATE_B          10

module fill_rect_decode_engine(
    input               clk,
    input               rst_,
    // Command Fifo Interface
    input               cmd_fifo_rtr,
    input               cmd_fifo_rts,
    input   [7:0]       cmd_fifo_data,
    // Fill Rect Generation Engine Interface
    input               fill_rect_gen_eng_state,
    output  reg [15:0]  cmd_data_origx,
    output  reg [15:0]  cmd_data_origy,
    output  reg [15:0]  cmd_data_wid,
    output  reg [15:0]  cmd_data_hgt,
    output  reg [3:0]   cmd_data_rval,
    output  reg [3:0]   cmd_data_gval,
    output  reg [3:0]   cmd_data_bval,
    // Addressing Engine Interface
    output  reg [3:0]   fill_rect_decode_eng_state
    );


    always @(posedge clk or negedge rst_)
    begin
        if (!rst_)
        begin
            // reset logic
            cmd_fifo_rtr <= 1'b1;
            rgb_idx <= 2'b00;

            dec_state <= `DECODE_STATE_ORIGX_B1;
        end
        else
        begin

        // For the generator to begin outputting addresses and data the arbiter must
        // be ready to recieve and the fifo must be ready to send
        if (cmd_fifo_xfc)//arb_rtr && stall_on_decode_await)// && cmd_fifo_rts)
        begin
            // ----------------- Decode Instruction State Machine
            case (dec_state)
              `DECODE_STATE_ORIGX_B1:
              begin
                  if (cmd_fifo_xfc)
                  begin
                  // Store X origin data
                   origx[15:8] <= cmd_fifo_data;

                  // Initiate Calculation State machine to begin calculating
                  // row index addresses from the X origin data
                  dec_state <= `DECODE_STATE_ORIGX_B2;
                  end
              end
              `DECODE_STATE_ORIGX_B2:
              begin
                  origx[7:0] <= cmd_fifo_data;
                  dec_state <= `DECODE_STATE_ORIGY_B1;
              end
              `DECODE_STATE_ORIGY_B1:
              begin
                  // Store y origin data
                      origy[15:8] <= cmd_fifo_data;
                      dec_state <= `DECODE_STATE_ORIGY_B2;
              end
             `DECODE_STATE_ORIGY_B2:
              begin
                  origy[7:0] <= cmd_fifo_data;
                  dec_state <= `DECODE_STATE_WID_B1;
              end
              `DECODE_STATE_WID_B1:
              begin
                  // Store width of box
                  wid[15:8] <= cmd_fifo_data;
                  dec_state <= `DECODE_STATE_WID_B2;
              end
              `DECODE_STATE_WID_B2:
              begin
                  wid[7:0] <= cmd_fifo_data;
                  dec_state <= `DECODE_STATE_HGT_B1;
              end
              `DECODE_STATE_HGT_B1:
              begin
                  // Store hight of box
                  hgt[15:8] <= cmd_fifo_data;
                  dec_state <= `DECODE_STATE_HGT_B2;

                  // Start up calc state machine so multiplication is ready when we want to output
                  calc_state <= `CALC_STATE_ROW_IDX;
              end
              `DECODE_STATE_HGT_B2:
              begin
                  hgt[7:0] <= cmd_fifo_data;
                  dec_state <= `DECODE_STATE_R;
              end
              `DECODE_STATE_R:
              begin
                  // Store R pixel data
                  r_val <=  cmd_fifo_data;
                  dec_state <= `DECODE_STATE_G;
              end
              `DECODE_STATE_G:
                  begin
                  // Store G pixel value
                  g_val <= cmd_fifo_data;
                  dec_state <= `DECODE_STATE_B;
              end
              `DECODE_STATE_B:
              begin
                  // Store B pixel value
                  b_val <= cmd_fifo_data;

                  // Done decoding a command
                  cmd_fifo_rtr <= 1'b0;
                  dec_state <= `DECODE_STATE_ORIGX_B1;
              end
            endcase
        end
    end


endmodule
