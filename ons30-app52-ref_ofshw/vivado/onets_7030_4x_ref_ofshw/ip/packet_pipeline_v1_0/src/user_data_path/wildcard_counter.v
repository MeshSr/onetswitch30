`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/03/31 15:48:05
// Design Name: 
// Module Name: wildcard_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module wildcard_counter
#(parameter ADDR_WIDTH=4,
  parameter PKT_WIDTH=12,
  parameter LUT_DEPTH=16,
  parameter DEPTH_BITS=4
  )
(
   input clk,
   input reset,
   output fifo_rd_en,
   input [PKT_WIDTH-1:0]dout_pkt_size,
   input wildcard_data_vld,
   input wildcard_hit,
   input [DEPTH_BITS-1:0]wildcard_address,
   
   input [DEPTH_BITS-1:0] counter_addr_in,
   input counter_addr_rd,
   output reg [31:0]pkt_counter_out,
   output reg [31:0]byte_counter_out
   
    );

`ifdef ONETS45
begin   
    reg [31:0]byte_count[LUT_DEPTH-1:0];
    reg [31:0]pkt_count [LUT_DEPTH-1:0];
    reg [DEPTH_BITS-1:0]wildcard_address_d;
    
    assign fifo_rd_en=wildcard_data_vld;
    reg wildcard_hit_d;
    always@(posedge clk)
      wildcard_hit_d<=wildcard_hit;
    
    localparam CLEAR=0,
               IDLE=1;
    reg [DEPTH_BITS-1:0]clear_count;
    reg [2:0]cur_st,nxt_st;
    always@(posedge clk)
      if(reset) wildcard_address_d<=0;
      else wildcard_address_d<=wildcard_address;
    
    always@(posedge clk)
      if(reset) cur_st<=0;
      else cur_st<=nxt_st;
      
    always@(*)
    begin  
      nxt_st=cur_st;
      case(cur_st)
         CLEAR:if(clear_count==LUT_DEPTH-1) nxt_st=IDLE;
         IDLE:nxt_st=IDLE;
         default:nxt_st=IDLE;
      endcase
    end         
       
    always@(posedge clk)
    if(reset)
      clear_count<=0;
    else if(cur_st==CLEAR) clear_count<=clear_count+1;
    
    always@(posedge clk)
    if(cur_st==CLEAR)
    begin
        byte_count[clear_count]<=0;
        pkt_count[clear_count]<=0;
    end
    else if(cur_st==IDLE && wildcard_hit_d)
    begin
      byte_count[wildcard_address_d]<=byte_count[wildcard_address_d]+dout_pkt_size+4;
      pkt_count[wildcard_address_d]<=pkt_count[wildcard_address_d]+1;
    end
    
    always@(posedge clk)
    if(reset)
      pkt_counter_out<=0;
    else if(counter_addr_rd) 
      pkt_counter_out<=pkt_count[counter_addr_in];
      
      always@(posedge clk)
      if(reset)
        byte_counter_out<=0;
      else if(counter_addr_rd) 
        byte_counter_out<=byte_count[counter_addr_in];
end

`elsif ONETS30
begin   
    reg [31:0]byte_count[LUT_DEPTH-1:0];
    reg [31:0]pkt_count [LUT_DEPTH-1:0];
    reg [DEPTH_BITS-1:0]wildcard_address_d;
    
    assign fifo_rd_en=wildcard_data_vld;
    reg wildcard_hit_d;
    always@(posedge clk)
      wildcard_hit_d<=wildcard_hit;
    
    localparam CLEAR=0,
               IDLE=1;
    reg [DEPTH_BITS-1:0]clear_count;
    reg [2:0]cur_st,nxt_st;
    always@(posedge clk)
      if(reset) wildcard_address_d<=0;
      else wildcard_address_d<=wildcard_address;
    
    always@(posedge clk)
      if(reset) cur_st<=0;
      else cur_st<=nxt_st;
      
    always@(*)
    begin  
      nxt_st=cur_st;
      case(cur_st)
         CLEAR:if(clear_count==LUT_DEPTH-1) nxt_st=IDLE;
         IDLE:nxt_st=IDLE;
         default:nxt_st=IDLE;
      endcase
    end         
       
    always@(posedge clk)
    if(reset)
      clear_count<=0;
    else if(cur_st==CLEAR) clear_count<=clear_count+1;
    
    always@(posedge clk)
    if(cur_st==CLEAR)
    begin
        byte_count[clear_count]<=0;
        pkt_count[clear_count]<=0;
    end
    else if(cur_st==IDLE && wildcard_hit_d)
    begin
      byte_count[wildcard_address_d]<=byte_count[wildcard_address_d]+dout_pkt_size+4;
      pkt_count[wildcard_address_d]<=pkt_count[wildcard_address_d]+1;
    end
    
    always@(posedge clk)
    if(reset)
      pkt_counter_out<=0;
    else if(counter_addr_rd) 
      pkt_counter_out<=pkt_count[counter_addr_in];
      
      always@(posedge clk)
      if(reset)
        byte_counter_out<=0;
      else if(counter_addr_rd) 
        byte_counter_out<=byte_count[counter_addr_in];
end
`elsif ONETS20
always@(*)
begin
    pkt_counter_out=0;
    byte_counter_out=0;
end 
`endif
    
endmodule
