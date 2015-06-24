`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/05/06 14:34:16
// Design Name: 
// Module Name: configuration
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


module configuration(
   input [31:0]   data_config_i,
   input [31:0]   addr_config_i,
   input req_config_i,
   input rw_config_i,
   output reg ack_config_o,
   output reg [31:0]data_config_o,
   
   input clk,
   input reset,
   
   output reg config_sw_ok
   
    );
    
    reg [2:0]cur_st,nxt_st;
    localparam IDLE=0,
               ACK=1;
    
    
       always@(posedge clk)
          if(reset)
            cur_st<=0;
          else cur_st<=nxt_st;
       
       always@(*)
       begin
         nxt_st=cur_st;
         case(cur_st)
            IDLE:if(req_config_i) nxt_st=ACK;
            ACK:nxt_st=IDLE;
            default:nxt_st=IDLE;
         endcase
       end
       
       always@(*)
          if(reset)
            ack_config_o=0;
          else if(cur_st==ACK)
            ack_config_o=1;
          else ack_config_o=0;
       
       always@(posedge clk)
          if(reset)
            config_sw_ok<=0;
          else if(cur_st==ACK && addr_config_i[23:0]=={16'h0,`CONFIG_SW_STARTED} && rw_config_i==0)
            config_sw_ok<=data_config_i[0]; 
         
   `ifdef ONETS20
    begin
       always@(*)
          if(reset)
            data_config_o=0;
          else if(cur_st==ACK && addr_config_i[23:0]=={16'h0,`CONFIG_SW_STARTED} && rw_config_i)
            data_config_o=config_sw_ok;
          else if(cur_st==ACK && addr_config_i[23:0]=={16'h0,`CONFIG_CARD} && rw_config_i)
            data_config_o=20;
          else if(cur_st==ACK && addr_config_i[23:0]=={16'h0,`CONFIG_VERSION} && rw_config_i)
            data_config_o=`VERSION;
          else if(cur_st==ACK && addr_config_i[23:0]=={16'h0,`CONFIG_TABLE_NUM} && rw_config_i)
            data_config_o=`TABLE_NUM;
          else if(cur_st==ACK && addr_config_i[23:0]=={16'h0,`CONFIG_DEPTH} && rw_config_i)
            data_config_o=`T0_OPENFLOW_WILDCARD_TABLE_SIZE;
          else data_config_o=32'hdeadbeef;
    end
    `elsif ONETS30
    begin
       always@(*)
          if(reset)
            data_config_o=0;
          else if(cur_st==ACK && addr_config_i[23:0]=={16'h0,`CONFIG_SW_STARTED} && rw_config_i)
            data_config_o=config_sw_ok;
          else if(cur_st==ACK && addr_config_i[23:0]=={16'h0,`CONFIG_CARD} && rw_config_i)
            data_config_o=30;
          else if(cur_st==ACK && addr_config_i[23:0]=={16'h0,`CONFIG_VERSION} && rw_config_i)
            data_config_o=`VERSION;
          else if(cur_st==ACK && addr_config_i[23:0]=={16'h0,`CONFIG_TABLE_NUM} && rw_config_i)
            data_config_o=`TABLE_NUM;
          else if(cur_st==ACK && addr_config_i[23:0]=={16'h0,`CONFIG_DEPTH} && rw_config_i)
            data_config_o=`T0_OPENFLOW_WILDCARD_TABLE_SIZE;
          else data_config_o=32'hdeadbeef;
    end     
    `elsif ONETS45
    begin
       always@(*)
          if(reset)
            data_config_o=0;
          else if(cur_st==ACK && addr_config_i[23:0]=={16'h0,`CONFIG_SW_STARTED} && rw_config_i)
            data_config_o=config_sw_ok;
          else if(cur_st==ACK && addr_config_i[23:0]=={16'h0,`CONFIG_CARD} && rw_config_i)
            data_config_o=45;
          else if(cur_st==ACK && addr_config_i[23:0]=={16'h0,`CONFIG_VERSION} && rw_config_i)
            data_config_o=`VERSION;
          else if(cur_st==ACK && addr_config_i[23:0]=={16'h0,`CONFIG_TABLE_NUM} && rw_config_i)
            data_config_o=`TABLE_NUM;
          else if(cur_st==ACK && addr_config_i[23:0]=={16'h0,`CONFIG_DEPTH} && rw_config_i)
            data_config_o=`T0_OPENFLOW_WILDCARD_TABLE_SIZE;
          else data_config_o=32'hdeadbeef;
    end     
    `endif
    
    
endmodule
