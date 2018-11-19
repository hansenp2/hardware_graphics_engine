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

`define CALC_STATE_IDLE         0
`define CALC_STATE_ROW_IDX      1
`define CALC_STATE_START_ADDR   2

`define GEN_STATE_IDLE          0
`define GEN_STATE_DRIVE         1

module rect_generator(
    input           clk,
    input           rst_,
    // Command Processor FIFO Interface
    input   [7:0]   cmd_fifo_data,
    output reg      cmd_fifo_rtr,
    input           cmd_fifo_rts,
    // Arbiter FIFO Interface
    output [31:0]   arb_data,
    output [15:0]   arb_addr,
    output reg      arb_rts,
    input           arb_rtr,
    output [3:0]    arb_wben
    );
    wire    [15:0]  color_data;
    wire            cmd_fifo_xfc;
    wire            arb_xfc;
    wire    [7:0]   rgb_shift;
    reg     [1:0]   rgb_idx;

    reg     [3:0]   calc_state;
    reg     [3:0]   gen_state;
    reg     [3:0]   dec_state;
    reg     [15:0]  origx;
    reg     [15:0]  origy;
    reg     [15:0]  wid;
    reg     [15:0]  hgt;
    reg     [3:0]   r_val;
    reg     [3:0]   g_val;
    reg     [3:0]   b_val;
    reg     [16:0]  cur_addr;
    reg     [15:0]  col_cnt;
    reg     [15:0]  row_cnt;

    reg             stall_on_decode_await;
    always @(posedge clk or negedge rst_)
    begin
        if (!rst_)
        begin
            // reset logic
            cmd_fifo_rtr <= 1'b1;
            arb_rts <= 1'b0;
            col_cnt <= 16'h0000;
            row_cnt <= 16'h0000;
            cur_addr <= 17'h0000;
            rgb_idx <= 2'b00;

            dec_state <= `DECODE_STATE_ORIGX_B1;
            gen_state <= `GEN_STATE_IDLE;
            calc_state <= `CALC_STATE_IDLE;
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
                            gen_state <= `GEN_STATE_DRIVE;
                            // Assert that the generator will be able
                            // to send data on the next cycle because thats when we will
                            // have the R value to be sent
                            arb_rts <= 1'b1;
                        end
                    endcase

                    // ------------------ Calc State Machine
                    case (calc_state)
                        `CALC_STATE_IDLE:
                        begin
                            // State Machine defaults to idle
                        end
                        `CALC_STATE_ROW_IDX:
                        begin
                            // Calculate the starting row index address in mem
                            cur_addr <= origx * 640;
                            calc_state <= `CALC_STATE_START_ADDR;
                        end
                        `CALC_STATE_START_ADDR:
                        begin
                            // Calculate the beinging starting address using the begining y offset
                            cur_addr <= ((cur_addr + origy) >> 3) * 3;
                            calc_state <= `CALC_STATE_IDLE;
                        end
                    endcase     
            end
        end
    end

    always @(posedge clk or negedge rst_)
    begin
        if (!rst_)
        begin
            gen_state <= `GEN_STATE_IDLE;
        end
        else if (gen_state)
        begin
            // ------------------ Generation State Machine
            case (gen_state)
                `GEN_STATE_IDLE:
                begin
                // Default idle state
                end
                `GEN_STATE_DRIVE:
                begin
                    // State to drive the increment the addresses and counters
                    // that are used to determin wben bits and rgb mem indexing
                    if ((col_cnt == (wid - 1'b1)) && (row_cnt == (hgt - 1'b1)) && (rgb_idx == 2'b10))
                    begin
                        gen_state <= `GEN_STATE_IDLE;
                        cmd_fifo_rtr <= 1'b1;
                        arb_rts <= 1'b0;
                        col_cnt <= 1'b0;
                        row_cnt <= 1'b0;
                        rgb_idx <= 1'b0;
                        cur_addr <= 17'h0000;
                    end
                    else
                    begin
                        if (rgb_idx == 2'b10)
                        begin
                            if (col_cnt == (wid - 1'b1)) // If we are on the final column we want reset some counters and
                            begin // increment the addr to the next row
                                col_cnt <= 1'b0;
                                cur_addr <= cur_addr + 240 - 2'b10;
                                row_cnt <= row_cnt + 1'b1;
                            end
                            else
                            begin
                                cur_addr <= cur_addr - 2'b10;
                                col_cnt <= col_cnt + 1'b1;
                            end
                            rgb_idx <= 2'b00;
                        end
                        else
                        begin
                            rgb_idx <= rgb_idx + 1'b1;
                            cur_addr <= cur_addr + 1'b1;
                        end
                    end
                end
            endcase       
        end
    end


    // Decode Await Stalling Logic
    //  Stalls state machines until all data is available
    reg     [4:0]   field_cnt;
    always @(posedge clk or negedge rst_)
    begin
        if (!rst_)
        begin
            field_cnt <= 3'b000;
            stall_on_decode_await <= 1'b1;
        end
        else
        begin
            if (gen_state)
            begin
                if (field_cnt == 4'd11)
                begin
                    stall_on_decode_await <= 1'b0;
                end
                else
                begin
                    field_cnt <= field_cnt + 1'b1;
                end
            end
        end
    end

    // Attempt at rgb indexing the data
    assign color_data = (rgb_idx==1'b0) ? {r_val, r_val}: (rgb_idx==1'b1) ? {g_val, g_val} : {b_val, b_val};
    assign rgb_shift = (arb_wben==8) ? 24: (arb_wben==4) ? 16: (arb_wben==2) ? 8: 0;
    assign arb_data = color_data << rgb_shift;

    // WBEN logic
    assign arb_wben = 4'h1 << (col_cnt >> 1);
    assign arb_addr = cur_addr;

    // XFC logic
    assign cmd_fifo_xfc = cmd_fifo_rtr & cmd_fifo_rts;
    assign arb_xfc = arb_rtr & arb_rts;
endmodule
