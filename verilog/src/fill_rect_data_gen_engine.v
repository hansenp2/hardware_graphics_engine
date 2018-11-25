`timescale 1ns / 1ps

`define GEN_STATE_IDLE         0
`define GEN_STATE_ROW_IDX      1
`define GEN_STATE_START_ADDR   2

`define DECODE_STATE_B          10

module fill_rect_data_gen_engine(
    input               clk,
    input               rst_,
    // Addressing Engine Interface
    input       [4:0]   addr_eng_state,
    input       [15:0]  init_addr,
    // Command Field Data Interface
    input       [15:0]  cmd_data_hgt,
    input       [15:0]  cmd_data_wid,
    input       [3:0]   cmd_data_rval,
    input       [3:0]   cmd_data_bval,
    input       [3:0]   cmd_data_gval,
    // Fill Rect Decode Engine Interface
    output  reg [4:0]   fill_rect_data_gen_eng_state,
    // Arbiter Output Interface
    output  reg         arb_out_rts,
    input               arb_in_rtr,
    output  reg [3:0]   arb_out_wben,
    output  reg [15:0]  arb_out_addr,
    output  reg [31:0]  arb_out_data,
    output  reg         arb_out_op,
    input       [31:0]  arb_in_data,
    input               arb_in_xfc
    );

    reg     [3:0]   rgb_idx;
    reg     [15:0]  col_cnt;
    reg     [15:0]  row_cnt;

    wire            internal_xfc;
    reg     [15:0]  hgt;
    reg     [15:0]  wid;

    always @(posedge clk or negedge rst_)
    begin
        if (!rst_)
        begin
            arb_out_wben <= 4'h0;
            arb_out_addr <= 16'h00;
            arb_out_data <= 32'h0000;
            arb_out_op <= 1'b0;

            fill_rect_data_gen_eng_state <= `GEN_STATE_IDLE;
        end
        // Begin data generation when arb is rtr and this module is rts
        else if (internal_xfc)
        begin
            // ------------------ Generation State Machine
            case (fill_rect_data_gen_eng_state)
                `GEN_STATE_IDLE:
                begin
                    // Default idle state
                    if (addr_eng_state == `DECODE_STATE_B)
                    begin
                        arb_out_rts <= 1'b1;
                        hgt <= cmd_data_hgt;
                        wid <= cmd_data_wid;

                        fill_rect_data_gen_eng_state <= `GEN_STATE_DRIVE;
                    end
                end
                `GEN_STATE_DRIVE:
                begin
                    // State to drive the increment the addresses and counters
                    // that are used to determin wben bits and rgb mem indexing
                    if ((col_cnt == (wid - 1'b1)) && (row_cnt == (hgt - 1'b1)) && (rgb_idx == 2'b10))
                    begin
                        //cmd_fifo_rtr <= 1'b1;
                        col_cnt <= 1'b0;
                        row_cnt <= 1'b0;
                        rgb_idx <= 1'b0;

                        arb_out_addr <= 16'h0000;
                        arb_out_rts <= 1'b0;
                        fill_rect_data_gen_eng_state <= `GEN_STATE_IDLE;
                    end
                    else
                    begin
                        if (rgb_idx == 2'b10)
                        begin
                            if (col_cnt == (wid - 1'b1)) // If we are on the final column we want reset some counters and
                            begin // increment the addr to the next row
                                col_cnt <= 1'b0;
                                arb_out_addr <= arb_out_addr + 240 - 2'b10;
                                row_cnt <= row_cnt + 1'b1;
                            end
                            else
                            begin
                                arb_out_addr <= arb_out_addr - 2'b10;
                                col_cnt <= col_cnt + 1'b1;
                            end
                            rgb_idx <= 2'b00;
                        end
                        else
                        begin
                            rgb_idx <= rgb_idx + 1'b1;
                            arb_out_addr <= arb_out_addr + 1'b1;
                        end
                    end
                end
            endcase
        end
    end


    assign internal_xfc = arb_in_rtr & arb_out_rts;
endmodule
