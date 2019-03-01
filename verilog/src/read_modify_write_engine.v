`timescale 1ns / 1ps

`define START_STATE  0
`define INIT_STATE   1
`define RD_ADDR_0    2
`define WAIT_RD_0    3
`define RD_ADDR_1    4
`define WAIT_RD_1    5
`define RD_ADDR_2    6
`define WAIT_RD_2    7
`define WR_ADDR_0    8
`define WAIT_WR_0    9
`define WR_ADDR_1   10
`define WAIT_WR_1   11
`define WR_ADDR_2   12
`define WAIT_WR_2   13
`define END_STATE   14

module read_modify_write_engine(
    input clk,
    input rst_,
    
    // address engine interface
    input [16:0] addr_base,
    input [ 2:0] addr_offset,
    input [11:0] color,
    input  addr_rts,
    output addr_rtr, 
    
    // arbitor interface
    input [31:0] in_data,
    output reg [31:0] out_data,
    output reg [16:0] out_addr,
    output arb_rts,
    input  arb_rtr,
    input  bcast_xfc,
    output [3:0] wr_op   
);

    // State Machine Registers
    reg [ 3:0] state;
    reg [31:0] data_0, data_1, data_2;

    // Transfer Complete with Addressing Engine
    wire addr_xfc;
    assign addr_xfc = addr_rts & addr_rtr;
    assign addr_rtr = (state == `START_STATE);
    
    // Input Interface with Arbiter
    wire arb_xfc;
    assign arb_xfc = arb_rtr & arb_rts;
    assign arb_rts = (state == `RD_ADDR_0) || (state == `RD_ADDR_1) || (state == `RD_ADDR_2)
                  || (state == `WR_ADDR_0) || (state == `WR_ADDR_1) || (state == `WR_ADDR_2);
    
    assign wr_op = (state == `WR_ADDR_0 || state == `WR_ADDR_1 || state == `WR_ADDR_2) ? (4'b1111) : (4'b0000);
    
    reg [16:0] hold_addr_base;
    reg [ 2:0] hold_addr_offset;
    reg [11:0] hold_color;
    always @ (posedge clk or negedge rst_)
    begin
        if (!rst_)
        begin
            hold_addr_base <= 0;
            hold_addr_offset <= 0;
            hold_color <= 0;
        end
        
        else
        begin
            if (addr_xfc)
            begin
                hold_addr_base <= addr_base;
                hold_addr_offset <= addr_offset;
                hold_color <= color;
            end 
        end
    end

    // state machine
    always @ (posedge clk or negedge rst_)
    begin
    
        if (!rst_)
        begin
            state    <= `START_STATE;
            data_0   <= 0;
            data_1   <= 0;
            data_2   <= 0;
        end
        
        else
        begin
            case (state)
            
                `START_STATE: 
                begin
                    if (addr_xfc)
                        state <= `INIT_STATE;
                end
                
                `INIT_STATE:
                begin
                    state <= `RD_ADDR_0;
                end
                
                `RD_ADDR_0: 
                begin
                    if (arb_xfc) 
                        state <= `WAIT_RD_0;   
                end
                
                `WAIT_RD_0: 
                begin
                    if (bcast_xfc)
                    begin
                        state <= `RD_ADDR_1;
                        data_0 <= in_data;    
                    end
                end 
                
                `RD_ADDR_1: 
                begin
                    if (arb_xfc) 
                        state <= `WAIT_RD_1;   
                end
                
                `WAIT_RD_1: 
                begin
                    if (bcast_xfc)
                    begin
                        state <= `RD_ADDR_2;
                        data_1 <= in_data;    
                    end
                end
                
                `RD_ADDR_2: 
                begin
                    if (arb_xfc) 
                        state <= `WAIT_RD_2;   
                end
                
                `WAIT_RD_2: 
                begin
                    if (bcast_xfc)
                    begin
                        state <= `WAIT_WR_0;
                        data_2 <= in_data;    
                    end
                end
                
                `WAIT_WR_0: 
                    state <= `WR_ADDR_0; 
                
                `WR_ADDR_0: 
                begin
                    if (arb_xfc)
                        state <= `WAIT_WR_1;
                end
                
                `WAIT_WR_1: 
                    state <= `WR_ADDR_1; 
                    
                `WR_ADDR_1: 
                begin   
                    if (arb_xfc)
                        state <= `WAIT_WR_2;  
                end
                
                `WAIT_WR_2: 
                    state <= `WR_ADDR_2;
                              
                `WR_ADDR_2: 
                begin
                    if (arb_xfc)
                        state <= `END_STATE;
                end
                
                `END_STATE: 
                    state <= `START_STATE;
            
            endcase
        end
        
    end
    
    
    // behavior of state machine
    always @ (posedge clk or negedge rst_)
    begin
        
        if (!rst_)
        begin            
            out_data <= 0;
            out_addr <= 0;
        end
        
        else
        begin
            case (state) 
            
                `START_STATE: 
                    out_addr <= hold_addr_base + 0;
                            
                `INIT_STATE:
                    out_addr <= hold_addr_base + 0;

                `WAIT_RD_0:
                begin
                    if (bcast_xfc)
                        out_addr <= hold_addr_base + 1;
                end
                
                `RD_ADDR_1:
                    out_data <= 0;
                
                `WAIT_RD_1:
                begin
                    if (bcast_xfc)
                        out_addr <= hold_addr_base + 2;
                end
                
                `RD_ADDR_2:
                    out_data <= 0;
                
                `WAIT_WR_0:
                begin
                    out_addr <= hold_addr_base + 0;
                    case (hold_addr_offset)
                        0: out_data <= (data_0 & 32'hffff_fff0) | {28'b0,hold_color[11:8]};                     
                        1: out_data <= (data_0 & 32'hffff_ff0f) | {24'b0,hold_color[11:8],4'b0};
                        2: out_data <= (data_0 & 32'hffff_f0ff) | {20'b0,hold_color[11:8],8'b0};
                        3: out_data <= (data_0 & 32'hffff_0fff) | {16'b0,hold_color[11:8],12'b0};
                        4: out_data <= (data_0 & 32'hfff0_ffff) | {12'b0,hold_color[11:8],16'b0};
                        5: out_data <= (data_0 & 32'hff0f_ffff) | {8'b0,hold_color[11:8],20'b0};
                        6: out_data <= (data_0 & 32'hf0ff_ffff) | {4'b0,hold_color[11:8],24'b0};
                        7: out_data <= (data_0 & 32'h0fff_ffff) | {hold_color[11:8],28'b0};
                    endcase
                end
                
                `WAIT_WR_1:
                begin
                    out_addr <= hold_addr_base + 1;
                    case (hold_addr_offset)
                        0: out_data <= (data_1 & 32'hffff_fff0) | {28'b0,hold_color[7:4]};  
                        1: out_data <= (data_1 & 32'hffff_ff0f) | {24'b0,hold_color[7:4],4'b0};
                        2: out_data <= (data_1 & 32'hffff_f0ff) | {20'b0,hold_color[7:4],8'b0};
                        3: out_data <= (data_1 & 32'hffff_0fff) | {16'b0,hold_color[7:4],12'b0};
                        4: out_data <= (data_1 & 32'hfff0_ffff) | {12'b0,hold_color[7:4],16'b0};
                        5: out_data <= (data_1 & 32'hff0f_ffff) | {8'b0,hold_color[7:4],20'b0};
                        6: out_data <= (data_1 & 32'hf0ff_ffff) | {4'b0,hold_color[7:4],24'b0};
                        7: out_data <= (data_1 & 32'h0fff_ffff) | {hold_color[7:4],28'b0};
                    endcase
                end
                           
                `WAIT_WR_2:
                begin
                    out_addr <= hold_addr_base + 2;
                    case (hold_addr_offset)
                        0: out_data <= (data_2 & 32'hffff_fff0) | {28'b0,hold_color[3:0]};  
                        1: out_data <= (data_2 & 32'hffff_ff0f) | {24'b0,hold_color[3:0],4'b0};
                        2: out_data <= (data_2 & 32'hffff_f0ff) | {20'b0,hold_color[3:0],8'b0};
                        3: out_data <= (data_2 & 32'hffff_0fff) | {16'b0,hold_color[3:0],12'b0};
                        4: out_data <= (data_2 & 32'hfff0_ffff) | {12'b0,hold_color[3:0],16'b0};
                        5: out_data <= (data_2 & 32'hff0f_ffff) | {8'b0,hold_color[3:0],20'b0};
                        6: out_data <= (data_2 & 32'hf0ff_ffff) | {4'b0,hold_color[3:0],24'b0};
                        7: out_data <= (data_2 & 32'h0fff_ffff) | {hold_color[3:0],28'b0};
                    endcase
                end
                
            endcase
        end
        
    end

endmodule
