`timescale 1ns / 1ps

`define ADDR_STATE_IDLE         0
`define ADDR_STATE_ROW_IDX      1
`define ADDR_STATE_START_ADDR   2

module addressing_engine(
    input               clk,
    input               rst_,
    // Decode Engine Interface
    input               addr_start_strobe,
    input       [15:0]  cmd_data_origx,
    input       [15:0]  cmd_data_origy,
    // Generation Engine Interface
    output  reg [15:0]  init_addr,
    output  reg         gen_start_strobe 
    );


    reg    [3:0]   addr_eng_state;
    
    wire            addr_sm_start_cond;
    always @(posedge clk or negedge rst_)
    begin
        if (!rst_)
        begin
            addr_eng_state <= `ADDR_STATE_IDLE;
            init_addr <= 16'h00;
            
            gen_start_strobe <= 1'b0;
        end
        else
        begin
            // ------------------ Calc State Machine
            case (addr_eng_state)
                `ADDR_STATE_IDLE:
                begin
                    // State Machine defaults to idle
                    if (addr_sm_start_cond)
                    begin
                        addr_eng_state <= `ADDR_STATE_ROW_IDX;
                    end
                end
                `ADDR_STATE_ROW_IDX:
                begin
                    // Calculate the starting row index address in mem
                    init_addr <= cmd_data_origy * 640;
                    addr_eng_state <= `ADDR_STATE_START_ADDR;
                    gen_start_strobe <= 1'b1;
                end
                `ADDR_STATE_START_ADDR:
                begin
                    // Calculate the beinging starting address using the begining y offset
                    if (!gen_start_strobe)
                    begin
                        init_addr <= ((init_addr + cmd_data_origx) >> 3) * 3;
                        gen_start_strobe <= 1'b1;
                    end
                    else
                    begin
                        gen_start_strobe <= 1'b0;
                        addr_eng_state <= `ADDR_STATE_IDLE;
                    end
                    
                end
            endcase
        end
    end
    reg temp;
    always @(posedge clk or negedge rst_)
    begin
        if (!rst_)
        begin
            temp <= 1'b0;
        end
        else
        begin
            if (addr_start_strobe & !temp)
            begin
                temp <= 1'b1;
            end
            else
            begin
                temp <= 1'b0;
            end
        end
    end
    
    assign addr_sm_start_cond = addr_start_strobe & (addr_eng_state == `ADDR_STATE_IDLE) & !temp;
    
endmodule
