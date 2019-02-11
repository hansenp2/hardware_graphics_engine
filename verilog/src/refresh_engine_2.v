`timescale 1ns / 1ps

module refresh_engine_2(
    input clk,
    input rst_,
    input test_mode,
    
    input [11:0] current_pixel,
    
    output vga_h_sync, 
    output vga_v_sync,
    output reg [3:0]       vga_red, 
    output reg [3:0]       vga_green, 
    output reg [3:0]       vga_blue,
    output active_video, en_fetching
    
    // FOR DEBUGGING
    // output reg [9:0] h_counter, v_counter    
);

    // horizontal counter
    reg [9:0] h_counter;
    always @ (posedge clk or negedge rst_)
    begin
        if (!rst_)
            h_counter <= 0;            
        else
            h_counter <= (h_counter == 799) ? (0) : (h_counter + 1);
    end
    
    // vertical counter
    reg [9:0] v_counter;
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
    
    always @ (*)
    begin
        if (!rst_)
        begin
            vga_red     <= 0;
            vga_green   <= 0;
            vga_blue    <= 0;  
        end
        
        else 
        begin
            if (!active_video)
            begin
                vga_red     <= 0;
                vga_green   <= 0;
                vga_blue    <= 0; 
            end
            
            else
            begin
                if (!test_mode)
                begin
                    vga_red     <= current_pixel[11:8];    
                    vga_green   <= current_pixel[7:4];     
                    vga_blue    <= current_pixel[3:0];     
                end
                
                else 
                begin
                    if      (h_counter >= 160 && h_counter <= 239) begin vga_red <= 4'b0000; vga_green <= 4'b0000; vga_blue <= 4'b0000; end                    
                    else if (h_counter >= 240 && h_counter <= 319) begin vga_red <= 4'b1111; vga_green <= 4'b1111; vga_blue <= 4'b1111; end                    
                    else if (h_counter >= 320 && h_counter <= 399) begin vga_red <= 4'b1111; vga_green <= 4'b0000; vga_blue <= 4'b0000; end                    
                    else if (h_counter >= 400 && h_counter <= 479) begin vga_red <= 4'b1111; vga_green <= 4'b1111; vga_blue <= 4'b0000; end                    
                    else if (h_counter >= 480 && h_counter <= 559) begin vga_red <= 4'b0000; vga_green <= 4'b1111; vga_blue <= 4'b0000; end                    
                    else if (h_counter >= 560 && h_counter <= 639) begin vga_red <= 4'b0000; vga_green <= 4'b1111; vga_blue <= 4'b1111; end                    
                    else if (h_counter >= 640 && h_counter <= 719) begin vga_red <= 4'b0000; vga_green <= 4'b0000; vga_blue <= 4'b1111; end                    
                    else                                           begin vga_red <= 4'b1111; vga_green <= 4'b0000; vga_blue <= 4'b1111; end
                end
            end
        end
        
    end

endmodule
