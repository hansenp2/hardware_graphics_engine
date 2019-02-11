`timescale 1ns / 1ps

// TODO: Stall when engine !rtr
// TODO: Turn Off rts when we arent getting valid data (how do we know when this will be?)
module cmd_processor(
    input           clk,
    input           rst_,
    input   [7:0]   cmd,
    input           i2c_rts,
    output          i2c_rtr,
    input   [7:0]   i2c_in_data,
    output  reg[4:0]engine_out_rts,
    input   [4:0]   engine_in_rtr,
    output  [7:0]   bcast_out_data
    );

    wire    [4:0]   xfc;
    reg             test_pat_op;

    
    // Set RTR and RTS so that the 2d engines knows when
    // to sample the engine_data_out bus 
    always @(*)
    begin
        engine_out_rts <= 5'b00000;
        if (i2c_rts && engine_in_rtr)
        begin
            case (cmd)
                8'h0:
                    // Test Pat Op
                    engine_out_rts[0] <= i2c_in_data[0];
                8'h1:
                    // Fill Rect Engine
                    engine_out_rts[1] <= 1'b1;
                8'h2:
                    engine_out_rts[2] <= 1'b1;
                8'h3:
                    engine_out_rts[3] <= 1'b1;
                8'h4:
                    engine_out_rts[4] <= 1'b1;
            endcase
        end
        else
        begin
            engine_out_rts <= 5'b00000;
        end
    end
    assign bcast_out_data = i2c_in_data;
    assign i2c_rtr = (engine_in_rtr) ? 1'b1 : 1'b0;
    assign xfc = engine_in_rtr & engine_out_rts;
endmodule

