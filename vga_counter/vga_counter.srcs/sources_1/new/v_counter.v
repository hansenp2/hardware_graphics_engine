`timescale 1ns / 1ps

// VERTICAL MACROS
`define V_FRONT_PORCH   10
`define V_SYNC          2
`define V_BACK_PORCH    33
`define V_ACTIVE        480

module v_counter(
    input       clock,
    input       reset,
    input       enable,
    
    output reg  v_sync
    // output reg  end_frame
    // output reg [9:0] v_counter
    );
    
        // 10-bit Counter (Counting from 0 to 524)
        reg [9:0] v_counter;
        reg end_frame;
        
        always@(posedge clock, negedge reset)
        begin
        
            if (reset == 1'b0)
            begin
                v_counter   <= 0; //10'b1111111111;
                v_sync      <= 1;
                end_frame   <= 0;
            end
        
            else if (reset == 1'b1 && enable == 1'b1)
            begin
            
                v_counter <= v_counter + 1;
                
                // 0 <= C <= 32
                if (v_counter >= 0 && v_counter < (`V_FRONT_PORCH - 1))
                begin
                    v_sync      <= 1'b1;      
                    end_frame   <= 1'b0;
                end
                
                // 33 <= C <= 34
                else if (v_counter >= (`V_FRONT_PORCH - 1) && v_counter < (`V_FRONT_PORCH + `V_SYNC - 1))   
                begin
                    v_sync      <= 1'b0;
                    end_frame   <= 1'b0;
                end
                
                // 35 <= C <= 44
                else if (v_counter >= (`V_FRONT_PORCH + `V_SYNC - 1) && v_counter < (`V_FRONT_PORCH + `V_SYNC + `V_FRONT_PORCH - 1))
                begin
                    v_sync      <= 1'b1;
                    end_frame   <= 1'b0;
                end
                
                // 45 <= C < 524
                else if (v_counter >= (`V_FRONT_PORCH + `V_SYNC + `V_FRONT_PORCH - 1) && v_counter < (`V_FRONT_PORCH + `V_SYNC + `V_FRONT_PORCH + `V_ACTIVE - 1))
                begin
                    v_sync      <= 1'b1;
                    end_frame   <= 1'b0;
                end
                
                // C == 524
                else if (v_counter == `V_FRONT_PORCH + `V_SYNC + `V_BACK_PORCH + `V_ACTIVE - 1)
                begin
                    v_sync      <= 1'b1;
                    end_frame   <= 1'b1;
                    v_counter   <= 0;
                end
                
            end
             
        end
    
endmodule
