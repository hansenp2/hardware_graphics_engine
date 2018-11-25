`timescale 1ns / 1ps

// VERTICAL MACROS 
`define V_FRONT_PORCH   10
`define V_SYNC          2
`define V_BACK_PORCH    33
`define V_ACTIVE        480

/* v_counter
    produces vertical sync signal
    
    Inputs:
        clk         : pixel clock at 25 MHz
        rst_        : asynchronous reset (active low)
        enable      : enabled at end of line (active high)
    
    Outputs:
        v_sync      : v sync signal (pulsed low)
        v_active    : indicates active period of vertical signal
        end_frame   : indicates end of frame
        v_counter   : counting pixels 0 to 524 (10-bits)
*/
module v_counter(
    input               clk,
    input               rst_,
    input               enable,
    
    output reg          v_sync,
    output reg          v_active, 
    output reg          end_frame,
    output reg          en_fetching,
    output reg  [9:0]   v_counter
    );
    
        // 10-bit Counter (Counting from 0 to 524)
//        reg [9:0] v_counter;
//        reg end_frame;
        
        always@(posedge clk or negedge rst_)
        begin
        
            if (rst_ == 1'b0)
            begin
                v_counter   <= 0;
                v_sync      <= 1;
                v_active    <= 0;
                en_fetching <= 0;
                end_frame   <= 0;
            end
        
            else if (rst_ == 1'b1 && enable == 1'b1)
            begin
                
                // Start/Reset Fetcher at Start of Vertical Blanking
                en_fetching <= (v_counter == 0) ? (1) : (0);
                                
                // Front Porch (0 <= C < 10)
                if (v_counter >= 0 && v_counter < (`V_FRONT_PORCH))
                begin
                    v_sync      <= 1'b1;   
                    v_active    <= 1'b0;   
                    end_frame   <= 1'b0;
                    v_counter   <= v_counter + 1;
                end
                
                // Sync (10 <= C < 12)
                else if (v_counter >= (`V_FRONT_PORCH) && v_counter < (`V_FRONT_PORCH + `V_SYNC))   
                begin
                    v_sync      <= 1'b0;
                    v_active    <= 1'b0; 
                    end_frame   <= 1'b0;
                    v_counter   <= v_counter + 1;
                end
                
                // Back Porch (12 <= C < 45)
                else if (v_counter >= (`V_FRONT_PORCH + `V_SYNC) && v_counter < (`V_FRONT_PORCH + `V_SYNC + `V_BACK_PORCH))
                begin
                    v_sync      <= 1'b1;
                    v_active    <= 1'b0; 
                    end_frame   <= 1'b0;
                    v_counter   <= v_counter + 1;
                end
                
                // Active Video (45 <= C < 524)
                else if (v_counter >= (`V_FRONT_PORCH + `V_SYNC + `V_BACK_PORCH) && v_counter < (`V_FRONT_PORCH + `V_SYNC + `V_BACK_PORCH + `V_ACTIVE - 1))
                begin
                    v_sync      <= 1'b1;
                    v_active    <= 1'b1; 
                    end_frame   <= 1'b0;                    
                    v_counter   <= v_counter + 1;
                end
                
                // End of Frame (C == 524)
                else if (v_counter == (`V_FRONT_PORCH + `V_SYNC + `V_BACK_PORCH + `V_ACTIVE - 1))
                begin
                    v_sync      <= 1'b1;
                    v_active    <= 1'b1; 
                    end_frame   <= 1'b1;
                    v_counter   <= 0;
                end
                
            end
             
        end
    
endmodule
