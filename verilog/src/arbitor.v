`timescale 1ns / 1ps

// in denotes that the signal is coming into the arbiter from another module, out denotes that the signal is leaving the arbiter and being sent to another module

module arbitor(
clk,
rst_,
/*
softrst_addr,
softrst_wrdata,
softrst_rts_in,
softrst_rtr_out,
softrst_op,
*/
//inputs
fetch_addr,
fetch_wrdata, //not used
fetch_rts_in,
fetch_rtr_out,
fetch_op,

rectanglefill_addr,
rectanglefill_wrdata,
rectanglefill_rts_in,
rectanglefill_rtr_out,
rectanglefill_op,

rectanglepix_addr,
rectanglepix_wrdata,
rectanglepix_rts_in,
rectanglepix_rtr_out,
rectanglepix_op,

//Interface with BRAM
wben,
mem_addr,
mem_data_in,
mem_data_out,
/*
//for debugging
sel,
//softrst_xfc,
fetch_xfc,
rectanglefill_xfc,
rectanglepix_xfc,
priority_check,
priority_x,
round_robin,
next_round_robin,
counter,
*/
//read-back outputs
bcast_data,
bcast_xfc
    );
    
    parameter NUM_ENGINES = 3;
    
    
    input clk;
    input rst_;
    
    
    //for data being read from a client
    output wire [31:0] bcast_data;
    output reg [NUM_ENGINES-1:0] bcast_xfc;
    
    
    //for deciding whose turn it is to communicate
    reg [NUM_ENGINES-1:0] round_robin;
    reg [NUM_ENGINES-1:0] next_round_robin; 
    reg [NUM_ENGINES-1:0] sel; //output for debugging
    reg [3:0] counter;
    
    //wrap round_robin around when shifted to the last possible bit, update when round robin is changed
    //assign next_round_robin = (round_robin < (1 << (NUM_ENGINES-1))) ? (round_robin << 1):3'b001;
    
/*
    //connections to soft rest
    input [16:0] softrst_addr;
    input [31:0] softrst_wrdata; //not used 
    input softrst_rts_in;
    output softrst_rtr_out; 
    input [3:0] softrst_op; 
    output wire softrst_xfc; //output for debugging
    
    assign softrst_rtr_out = 1;
    
    assign softrst_xfc = softrst_rtr_out & softrst_rts_in;
*/
    //connections to fetcher
    input [16:0] fetch_addr;
    input [31:0] fetch_wrdata; //not used 
    input fetch_rts_in;
    output fetch_rtr_out; 
    input [3:0] fetch_op; 
    wire fetch_xfc; //output for debugging
    
    //ready to recieve when it's their turn
    assign fetch_rtr_out = sel[0];
    //xfc when it's their turn and they have a request 
    assign fetch_xfc = fetch_rtr_out & fetch_rts_in;
    
    
    //connections to engines, same format as fetcher
    input [16:0] rectanglefill_addr;
    input [31:0] rectanglefill_wrdata;
    input rectanglefill_rts_in;
    output rectanglefill_rtr_out;  
    input [3:0] rectanglefill_op; 
    wire rectanglefill_xfc; //output for debugging
    
    assign rectanglefill_rtr_out = sel[1];
    assign rectanglefill_xfc = rectanglefill_rtr_out & rectanglefill_rts_in;
    
    
    //connections to engines, same format as fetcher
    input [16:0] rectanglepix_addr;
    input [31:0] rectanglepix_wrdata;
    input rectanglepix_rts_in;
    output rectanglepix_rtr_out;  
    input [3:0] rectanglepix_op; 
    wire rectanglepix_xfc; //output for debugging
        
    assign rectanglepix_rtr_out = sel[2];
    assign rectanglepix_xfc = rectanglepix_rtr_out & rectanglepix_rts_in;
    
    
    //connections to BRAM
    output reg [3:0] wben;
    output reg [16:0] mem_addr;
    input [31:0] mem_data_in;
    output reg [31:0] mem_data_out;
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //PRIORITY LOGIC
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    wire priority_check;
    //output reg priority_check;
    wire [NUM_ENGINES-1:0] priority_x;
    reg [NUM_ENGINES-1:0] priority;
    
    
    //only true if the module being talked to is not trying to send or recieve data
    //next robin is now 0 and priority check is always on
    assign priority_check = !((fetch_rts_in && next_round_robin[0]) || ( rectanglefill_rts_in && next_round_robin[1]) || ( rectanglepix_rts_in && next_round_robin[2]));
    
    //concatenate bits in order of priority, least siginficant bit is has highest priority
    //has don't cares, only care about most insignificant bit
    assign priority_x = {rectanglepix_rts_in, rectanglefill_rts_in, fetch_rts_in};
    
    //priority encoder to filter out lesser priority requests, put into form sel can use
    always @ */*(priority_x)*/ begin
        casez (priority_x)
            3'b??1   : begin
                        priority = 3'b001;
                      end
            
            3'b?10   : begin
                        priority = 3'b010;
                      end
                      
            3'b100   : begin
                        priority = 3'b100;
                      end
                      
            default : begin
                        priority = 3'b000;
                      end
        
        endcase
    end
    
   //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //SELECTOR AND ROUND ROBIN LOGIC
   //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
   reg [NUM_ENGINES-1:0] delay_bcast_xfc;
   reg [NUM_ENGINES-1:0] delay2_bcast_xfc;
   assign bcast_data = mem_data_in;
   
   //assume if op is 0, it's reading.
   //Sent data back to whoever's turn it is as long as op is 0.

   

    //updating selector (whose turn it is to communicate)
    always @ (posedge clk or negedge rst_) begin
        
        
        
        if(!rst_) begin
           wben = 4'b0000;
           mem_addr = 17'b00000000000000000;
           mem_data_out = 0;
           
           round_robin = 3'b001;
           next_round_robin = 3'b010;
           counter = 0;
           sel = 3'b000;
           
           delay_bcast_xfc = 0;
           delay2_bcast_xfc = 0;
           bcast_xfc = 0;
           
           priority = 0;
        end
/*
        //softreset doesn't wait for it's turn, highest priority
        else if(softrst_xfc) begin
            wben <= softrst_op;
            mem_addr <= softrst_addr;
            mem_data_out <= softrst_wrdata;
            delay_bcast_xfc <= 0;
        end
*/
        else begin
        //if counter <15 counter = counter + 1
            counter <= counter + 1;
//clock rst into 3 stages
            
            //fetcher should be allowed to pull data at least once every other cycle to make sure it does not run out of data, skip if fetcher doesnt need anything
            if((counter < 1) || !fetch_rts_in) begin
            
                //If the round robin's turn does not have request, move to priority 
                if(priority_check) begin
                    sel <= round_robin;
                    round_robin <= priority;
                    next_round_robin <= (next_round_robin < (1 << (NUM_ENGINES-1))) ? (next_round_robin << 1):3'b001;
                end        
                
                else begin
                    //talk to round robin and update for next cycle
                    sel <= round_robin;
                    round_robin <= next_round_robin;
                    next_round_robin <= (next_round_robin < (1 << (NUM_ENGINES-1))) ? (next_round_robin << 1):3'b001;
                end
            end
            
            //give fetcher it's turn if it's been too long to prevent underflow, reset counter for underflow check
            else begin
                sel <= 3'b001;
                counter <= 0;
            end
            
       
        
     
        case (sel)
               3'b001   : begin //fetcher
                               
                              if(fetch_xfc) begin
                                   wben <= fetch_op;
                                   mem_addr <= fetch_addr;
                                   mem_data_out <= fetch_wrdata;
                                   delay_bcast_xfc <= (fetch_op) ? 3'b000:sel;
                              end

                         end
                         
               3'b010   : begin //rectanglefill 
                               
                               if(rectanglefill_xfc) begin
                                   wben <= rectanglefill_op;
                                   mem_addr <= rectanglefill_addr;
                                   mem_data_out <= rectanglefill_wrdata;
                                   delay_bcast_xfc <= (rectanglefill_op) ? 3'b000:sel;
                               end

                         end
                         
                 3'b100   : begin //rectanglepix 
                         
                         if(rectanglepix_xfc) begin
                             wben <= rectanglepix_op;
                             mem_addr <= rectanglepix_addr;
                             mem_data_out <= rectanglepix_wrdata;
                             delay_bcast_xfc <= (rectanglepix_op) ? 3'b000:sel;
                         end
   
                   end
                         
               default : begin //No one is trying to communicate
                                   wben <= 0;
                                   delay_bcast_xfc <= 0;
                         end
          endcase
          delay2_bcast_xfc <= delay_bcast_xfc;
          bcast_xfc <= delay2_bcast_xfc;
          end
    end
    
endmodule
