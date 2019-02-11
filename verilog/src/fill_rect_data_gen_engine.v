`timescale 1ns / 1ps

`define GEN_STATE_IDLE         0
`define GEN_STATE_DRIVE        1

module fill_rect_data_gen_engine(
    input               clk,
    input               rst_,
    // Pipeline Stall Interface
    input               dec_eng_has_data,//dead
    output              data_gen_is_idle,
    // Addressing Engine Interface
    input               gen_start_strobe,
    input       [15:0]  init_addr,
    // Command Field Data Interface
    input       [15:0]  cmd_data_hgt,
    input       [15:0]  cmd_data_wid,
    input       [3:0]   cmd_data_rval,
    input       [3:0]   cmd_data_bval,
    input       [3:0]   cmd_data_gval,
    // Arbiter Output Interface
    output  reg         arb_out_rts,
    input               arb_in_rtr,
    output      [3:0]   arb_out_wben ,
    output  reg [15:0]  arb_out_addr,
    output      [31:0]  arb_out_data,
    output  reg         arb_out_op,
    input       [31:0]  arb_bcast_in_data,
    input               arb_bcast_in_xfc
    );

    reg     [3:0]   rgb_idx;
    reg     [15:0]  col_cnt;
    reg     [15:0]  row_cnt;

    wire            internal_xfc;
    reg     [15:0]  hgt;
    reg     [15:0]  wid;

    wire    [15:0]  color_data;
    wire    [7:0]   rgb_shift;
    wire    [3:0]   rval;
    wire    [3:0]   gval;
    wire    [3:0]   bval; 

    reg     [3:0]   fill_rect_data_gen_eng_state;
    
    wire            data_gen_sm_start_cond;
    
    always @(posedge clk or negedge rst_)
    begin
        if (!rst_)
        begin
            arb_out_op <= 1'b0;
            fill_rect_data_gen_eng_state <= `GEN_STATE_IDLE;
            rgb_idx <= 4'h0;
            col_cnt <= 16'h00;
            row_cnt <= 16'h00;
            hgt <= 16'h00;
            wid <= 16'h00;
            arb_out_rts <= 1'b0;
            arb_out_addr <= 16'h00;
            arb_out_op <= 1'b0;
        end
        // Begin data generation when arb is rtr and this module is rts
        else if (arb_in_rtr)
        begin
            // ------------------ Generation State Machine
            case (fill_rect_data_gen_eng_state)
                `GEN_STATE_IDLE:
                begin
                    
                    // Default idle state
                    if (data_gen_sm_start_cond)
                    begin
                        arb_out_rts <= 1'b1;
                        hgt <= cmd_data_hgt;
                        wid <= cmd_data_wid;
                        arb_out_addr <= init_addr;

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

    // RGB Index the output data
    assign rval = cmd_data_rval;
    assign gval = cmd_data_gval;
    assign bval = cmd_data_bval;
    
    assign v  = 4'h1 << ((col_cnt % 8) >> 1);
    assign color_data = (rgb_idx==1'b0) ? rval: (rgb_idx==1'b1) ? gval : bval;
    assign rgb_shift = (arb_out_wben==8) ? 24: (arb_out_wben==4) ? 16: (arb_out_wben==2) ? 8: 0;
    assign arb_out_data = (color_data << rgb_shift) << ((col_cnt % 2) << 2);
    
    
    assign internal_xfc = arb_in_rtr & arb_out_rts;
    
    assign data_gen_is_idle = (fill_rect_data_gen_eng_state == `GEN_STATE_IDLE);
    assign data_gen_sm_start_cond = gen_start_strobe;
endmodule
