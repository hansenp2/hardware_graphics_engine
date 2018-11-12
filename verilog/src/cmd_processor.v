`timescale 1ns / 1ps

// TODO: Stall when engine !rtr
// TODO: Turn Off rts when we arent getting valid data (how do we know when this will be?)
module cmd_processor(
    input           clk,
    input           rst_,
    input   [7:0]   cmd,
    input   [15:0]  i2c_in_data,
    output reg [4:0]engine_out_rts,
    input   [4:0]   engine_in_rtr,
    output reg[15:0]bcast_out_data
    );

    wire    [4:0]   xfc;
    reg             test_pat_op;

    
    // Set RTR and RTS so that the 2d engines knows when
    // to sample the engine_data_out bus 
    always @(cmd)
    begin
        engine_out_rts = 5'b00000;
        case (cmd)
            8'h0:
                // Test Pat Op
                engine_out_rts[0] <= 1'b1;
            8'h1:
                engine_out_rts[1] <= 1'b1;
            8'h2:
                engine_out_rts[2] <= 1'b1;
            8'h3:
                engine_out_rts[3] <= 1'b1;
            8'h4:
                engine_out_rts[4] <= 1'b1;
        endcase
        
    end
    
    always @(posedge clk)
    begin
        if (!rst_)
        begin
            engine_out_rts <= 5'b00000;
        end
        
        bcast_out_data <= i2c_in_data;
    end
    
endmodule

