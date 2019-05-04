`timescale 1ns / 1ps

module refresh_engine_2(
    input clk,
    input rst_,
    input test_mode,
    
    input [11:0] current_pixel,
    
    output vga_h_sync, 
    output vga_v_sync,
    output [3:0]       vga_red, 
    output [3:0]       vga_green, 
    output [3:0]       vga_blue,
    output active_video, en_fetching,
    
    // FOR DEBUGGING
    output reg [9:0] h_counter, v_counter    
);

    // horizontal counter
    // reg [9:0] h_counter;
    always @ (posedge clk or negedge rst_)
    begin
        if (!rst_)
            h_counter <= 0;            
        else
            h_counter <= (h_counter == 799) ? (0) : (h_counter + 1);
    end
    
    // vertical counter
    // reg [9:0] v_counter;
    always @ (posedge clk or negedge rst_)
    begin
        if (!rst_)
            v_counter <= 0;            
        else if (h_counter == 799)
            v_counter <= (v_counter == 524) ? (0) : (v_counter + 1);
    end
    
    // VGA Outputs
    assign vga_h_sync   = !(h_counter >= 16) || !(h_counter <= 111);
    assign vga_v_sync   = !(v_counter >= 10) || !(v_counter <=  11);
    assign active_video = (h_counter >= 160) && (h_counter <= 799) && (v_counter >= 45) && (v_counter <= 524);
    
//    assign en_fetching  = (h_counter == 0) && (v_counter == 1);
    assign en_fetching = (v_counter != 0);    
    
    // VGA Color Output 
    
    wire out_color;
    assign out_color = (h_counter >= 159) && (h_counter < 799) && (v_counter >= 45) && (v_counter <= 524);
    
    reg test_state;
    always @ (posedge clk or negedge rst_)
    begin
        if (!rst_)
            test_state = 0;
        else
        begin
            case (test_state)
                0:
                begin
                    if (test_mode) test_state <= 1;
                end
                
                1:
                begin
                    if (!test_mode) test_state <= 0;
                end
            endcase
        end
    end
    
    wire tp1, tp2, tp3, tp4, tp5, tp6, tp7, tp8;
    assign tp1 = (h_counter >= 160 && h_counter <= 239);
    assign tp2 = (h_counter >= 240 && h_counter <= 319);
    assign tp3 = (h_counter >= 320 && h_counter <= 399);
    assign tp4 = (h_counter >= 400 && h_counter <= 479);
    assign tp5 = (h_counter >= 480 && h_counter <= 559);
    assign tp6 = (h_counter >= 560 && h_counter <= 639);
    assign tp7 = (h_counter >= 640 && h_counter <= 719);
    assign tp8 = (h_counter >= 720 && h_counter <= 799);
    
    wire [3:0] test_red, test_green, test_blue;
    assign test_red =   (tp1) ? 4'b0000 : 
                        (tp2) ? 4'b1111 :
                        (tp3) ? 4'b1111 :
                        (tp4) ? 4'b1111 :
                        (tp5) ? 4'b0000 :
                        (tp6) ? 4'b0000 :
                        (tp7) ? 4'b0000 : 4'b1111;  
                                               
    assign test_green = (tp1) ? 4'b0000 : 
                        (tp2) ? 4'b1111 :
                        (tp3) ? 4'b0000 :
                        (tp4) ? 4'b1111 :
                        (tp5) ? 4'b1111 :
                        (tp6) ? 4'b1111 :
                        (tp7) ? 4'b0000 : 4'b0000;
                        
    assign test_blue =  (tp1) ? 4'b0000 : 
                        (tp2) ? 4'b1111 :
                        (tp3) ? 4'b0000 :
                        (tp4) ? 4'b0000 :
                        (tp5) ? 4'b0000 :
                        (tp6) ? 4'b1111 :
                        (tp7) ? 4'b1111 : 4'b1111;
    
    assign vga_red = (active_video) ? 
        ( (test_state) ? test_red : current_pixel[11:8] )
        :  0;
        
    assign vga_green = (active_video) ? 
        ( (test_state) ? test_green : current_pixel[7:4] )
        : 0;
        
    assign vga_blue = (active_video) ? 
        ( (test_state) ? test_blue : current_pixel[3:0] )
        : 0;


endmodule

