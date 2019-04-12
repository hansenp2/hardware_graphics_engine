
`timescale 1ns / 1ps

`define NUM_ENGINES 3
`define DF_CYCLES   2

module arbitor_v2(

    // clock and async reset
    input clk,
    input rst_,
    
    output [31:0] bcast_data,
    output reg [`NUM_ENGINES:0] bcast_xfc_out,
    input en_fetching,
    
    // RAM connections
    output reg [3:0] wben,
    output reg [16:0] mem_addr,
    input [31:0] mem_data_in,
    output reg [31:0] mem_data_out,
    
    // data fetcher connections
    input [16:0] fetch_addr,
    input [31:0] fetch_wrdata,
    input fetch_rts_in,
    output fetch_rtr_out,
    input [3:0] fetch_op,
    
    // line drawer conncetions
    input [16:0] linedrawer_addr,
    input [31:0] linedrawer_wrdata,
    input linedrawer_rts_in,
    output linedrawer_rtr_out, 
    input [3:0] linedrawer_op,
    
    // circle drawer conncetions
    input [16:0] circledrawer_addr,
    input [31:0] circledrawer_wrdata,
    input circledrawer_rts_in,
    output circledrawer_rtr_out, 
    input [3:0] circledrawer_op,
    
    // line drawer conncetions
    input [16:0] fillrect_addr,
    input [31:0] fillrect_wrdata,
    input fillrect_rts_in,
    output fillrect_rtr_out, 
    input [3:0] fillrect_op
);
    
    // transer complete signals
    reg [`NUM_ENGINES:0] select;
    
    wire fetch_xfc; 
    assign fetch_rtr_out = select[0];
    assign fetch_xfc = fetch_rts_in & fetch_rtr_out; 
       
    wire linedrawer_xfc;
    assign linedrawer_rtr_out = select[1];
    assign linedrawer_xfc = linedrawer_rts_in & linedrawer_rtr_out;
    
    wire fillrect_xfc;
    assign fillrect_rtr_out = select[3];
    assign fillrect_xfc = fillrect_rts_in & fillrect_rtr_out;
    
    wire circledrawer_xfc;
    assign circledrawer_rtr_out = select[2];
    assign circledrawer_xfc = circledrawer_rts_in & circledrawer_rtr_out;
    
    // arbitor functionality
    reg [1:0] df_priority;
    reg [`NUM_ENGINES-1:0] round_robin;
    
    assign bcast_data = mem_data_in;    
    
    always @ (posedge clk or negedge rst_)
    begin
        if (!rst_)
        begin
            // wben <= 0;
            // mem_addr <= 0;
            // mem_data_out <= 0; 
            df_priority <= 0;
            round_robin <= 1;
            // select <= 0;
            // bcast_xfc_out <= 0;
        end
        
        else
        begin
            if (df_priority != 0 || fetch_rts_in != 1) 
                round_robin <= (round_robin[`NUM_ENGINES-1] == 1) ? (1) : (round_robin << 1);
            df_priority <= (df_priority + 1) % `DF_CYCLES;
        end
    end
        
    always @ (posedge clk or negedge rst_)
    begin      
    
        if (!rst_)
        begin
           select <= 0;
        end
        
        else
        begin
            // service data fetcher's request
            if (df_priority == 0 && fetch_rts_in == 1)
            begin
                select <= 4'b001;
            end
            
            // other client requests
            else
            begin
                case (round_robin)
                    `NUM_ENGINES'b001:
                    begin
                        select <= 4'b0010; 
                        // $display("client 1");
                    end
                    
                    `NUM_ENGINES'b010:
                    begin
                        select <= 4'b0100; 
                        // $display("client 2");
                    end
                    
                    `NUM_ENGINES'b100:
                    begin
                        select <= 4'b1000; 
                        // $display("client 2");
                    end
                    
                    default:
                    begin
                        select <= 4'b0000; 
                    end
                endcase 
            end 
        end                         
    end
    
    reg [`NUM_ENGINES:0] bcast_delay_1, bcast_delay_2;
    always @ (posedge clk or negedge rst_)
    begin
        if (!rst_)
        begin
            // bcast_delay_1 <= 0;
            bcast_delay_2 <= 0;
            bcast_xfc_out <= 0;
        end
        else
        begin
            bcast_delay_2 <= bcast_delay_1;
            bcast_xfc_out <= bcast_delay_2;
        end
    end
    
    /* always @ (*)
    begin
        
        if (fetch_xfc)
        begin
            wben <= fetch_op;
            mem_addr <= fetch_addr;
            mem_data_out <= fetch_wrdata;
            bcast_delay_1 <= 3'b001;
        end
        
        else if (linedrawer_xfc)
        begin
            wben <= linedrawer_op;
            mem_addr <= linedrawer_addr;
            mem_data_out <= linedrawer_wrdata;
            bcast_delay_1 <= (linedrawer_op == 4'b1111) ? 0 : 3'b010; 
        end
        
        else if (circledrawer_xfc)
        begin
            wben <= circledrawer_op;
            mem_addr <= circledrawer_addr;
            mem_data_out <= circledrawer_wrdata;
            bcast_delay_1 <= (circledrawer_op == 4'b1111) ? 0 : 3'b100;
        end
        
         else
         begin
            wben <= wben;
            mem_addr <= mem_addr;
            mem_data_out <= mem_data_out;
            bcast_delay_1 <= 3'b000;    
        end
        
    end */
    
    always @ (posedge clk or negedge rst_)
        begin
            
            if (!rst_)
            begin
                wben <= 0;
                mem_addr <= 0;
                mem_data_out <= 0;
                bcast_delay_1 <= 0;
            end
            
            else
            begin
                if (fetch_xfc)
                begin
                    wben <= fetch_op;
                    mem_addr <= fetch_addr;
                    mem_data_out <= fetch_wrdata;
                    bcast_delay_1 <= 4'b0001;
                end
                
                else if (linedrawer_xfc)
                begin
                    wben <= linedrawer_op;
                    mem_addr <= linedrawer_addr;
                    mem_data_out <= linedrawer_wrdata;
                    bcast_delay_1 <= (linedrawer_op == 4'b1111) ? 0 : 4'b0010; 
                end
                
                else if (fillrect_xfc)
                begin
                    wben <= fillrect_op;
                    mem_addr <= fillrect_addr;
                    mem_data_out <= fillrect_wrdata;
                    bcast_delay_1 <= (fillrect_op == 4'b1111) ? 0 : 4'b1000; 
                end
                
                else if (circledrawer_xfc)
                begin
                    wben <= circledrawer_op;
                    mem_addr <= circledrawer_addr;
                    mem_data_out <= circledrawer_wrdata;
                    bcast_delay_1 <= (circledrawer_op == 4'b1111) ? 0 : 4'b0100;
                end
                
                else
                begin
                    wben <= 0;
                    mem_addr <= 0;
                    mem_data_out <= 0;
                    bcast_delay_1 <= 4'b0000;    
                end
            end
            
        end

endmodule

