`timescale 1ns / 1ps

`define ADDR_STATE_IDLE         0
`define ADDR_STATE_ROW_IDX      1
`define ADDR_STATE_START_ADDR   2

module addressing_engine(
    input           clk,
    input           rst_,
    // Decode Engine Interface
    input   [3:0]   decode_eng_state,
    input   [15:0]  cmd_data_origx,
    input   [15:0]  cmd_data_origy,
    // Generation Engine Interface
    output reg[3:0] addr_eng_state,
    output reg[15:0]init_addr
    );

    always @(posedge clk or negedge rst_)
    begin
        if (!rst_)
        begin
            addr_eng_state <= `ADDR_STATE_IDLE;
            init_addr <= 16'h00;
        end
        else
        begin
            // ------------------ Calc State Machine
            case (addr_eng_state)
                `ADDR_STATE_IDLE:
                begin
                    // State Machine defaults to idle
                end
                `ADDR_STATE_ROW_IDX:
                begin
                    // Calculate the starting row index address in mem
                    init_addr <= cmd_data_origx * 640;
                    addr_eng_state <= `ADDR_STATE_START_ADDR;
                end
                `ADDR_STATE_START_ADDR:
                begin
                    // Calculate the beinging starting address using the begining y offset
                    init_addr <= ((init_addr + cmd_data_origy) >> 3) * 3;
                    addr_eng_state <= `ADDR_STATE_IDLE;
                end
            endcase
        end
    end
    
endmodule
