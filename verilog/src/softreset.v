`timescale 1ns / 1ps

module softreset(
clk,
rst_, //not sure if needed
sftrst_,

cmd_rts_in,
cmd_rtr_out,

arb_addr,
arb_wr_data,
arb_rts_out,
arb_rtr_in,
arb_op
    );
    
    input clk;
    input rst_;     //not sure what this would be
    output reg sftrst_;
    
    reg [16:0] addr;
    
    input cmd_rts_in;
    output reg cmd_rtr_out;
    
    output wire [16:0] arb_addr;
    output wire [31:0] arb_wr_data;
    output reg arb_rts_out;
    input arb_rtr_in;
    output reg [3:0] arb_op;
    
    assign arb_wr_data = 32'h00000000;
    assign arb_addr = addr;
    
    wire cmd_xfc;
    assign cmd_xfc = cmd_rts_in && cmd_rtr_out;
    
    wire arb_xfc;
    assign arb_xfc = arb_rts_out && arb_rtr_in;
    
    reg [1:0] state;

    parameter idle = 2'b00;
    parameter reset = 2'b01;
    parameter done = 2'b10;
    
    always @ (state) begin
    
        case (state)
        
            idle : begin
                        sftrst_ = 1;
                        cmd_rtr_out = 1;
                        arb_rts_out = 0;
                        arb_op = 4'b0000;
                    end
            
            reset : begin
                        sftrst_ = 1;
                        cmd_rtr_out = 0;
                        arb_rts_out = 1;
                        arb_op = 4'b1111;
                    end
                    
            done : begin
                        sftrst_ = 0;                     
                        cmd_rtr_out = 0;                 
                        arb_rts_out = 0;                 
                        arb_op = 4'b0000;                
                    end
                    
            default : begin
                        sftrst_ = 1;                     
                        cmd_rtr_out = 0;                 
                        arb_rts_out = 0;                 
                        arb_op = 4'b0000;    
                      end
                      
        endcase
        
    end
    
    
    
    always @ (posedge clk) begin
        
        if(!rst_) begin
            state <= idle;
            addr <= 17'b00000000000000000;
        end
        
        else begin
            
            if(cmd_xfc) begin
                state <= reset;
            end
            
            else if(state == reset && arb_xfc) begin
                addr <= addr + 1;
                
                if(addr == 17'h1FFFF)
                    state <= done;
            end
            
            //might have no purpose
            else if(state == done) begin
                state <= idle;
            end
        end
        
    end
    
endmodule
