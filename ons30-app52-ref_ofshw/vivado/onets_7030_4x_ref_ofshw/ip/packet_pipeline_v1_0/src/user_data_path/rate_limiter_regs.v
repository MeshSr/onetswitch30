///////////////////////////////////////////////////////////////////////////////
// vim:set shiftwidth=3 softtabstop=3 expandtab:
// $Id: rate_limiter_regs.v 5803 2009-08-04 21:23:10Z g9coving $
//
// Module: rate_limiter_regs.v
// Project: rate limiter
// Description: Demultiplexes, stores and serves register requests
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module rate_limiter_regs
  #(
      parameter NUM_QUEUES=0
   )
   (
      
      input   [31:0] data_meter_i,
      input   [31:0] addr_meter_i,
      input          req_meter_i,
      input          rw_meter_i,
      output  reg       ack_meter_o,
      output  reg [31:0] data_meter_o,

      output reg[19:0]                          token_interval,
      output reg[7:0]                           token_increment,
      output reg[NUM_QUEUES-1:0]                token_interval_vld,
      output reg[NUM_QUEUES-1:0]                token_increment_vld,     

      input                                  clk,
      input                                  reset,
      
      input [31:0]                      pass_pkt_counter_0,
      input [31:0]                      pass_pkt_counter_1,
      input [31:0]                      pass_pkt_counter_2,
      input [31:0]                      pass_pkt_counter_3,
      input [31:0]                      pass_pkt_counter_4,
  
      input [31:0]                      pass_byte_counter_0,
      input [31:0]                      pass_byte_counter_1,
      input [31:0]                      pass_byte_counter_2,
      input [31:0]                      pass_byte_counter_3,
      input [31:0]                      pass_byte_counter_4,
 
      input [31:0]                      drop_pkt_counter_0,
      input [31:0]                      drop_pkt_counter_1,
      input [31:0]                      drop_pkt_counter_2,
      input [31:0]                      drop_pkt_counter_3,
      input [31:0]                      drop_pkt_counter_4,

      input [31:0]                      drop_byte_counter_0,
      input [31:0]                      drop_byte_counter_1,
      input [31:0]                      drop_byte_counter_2,
      input [31:0]                      drop_byte_counter_3,
      input [31:0]                      drop_byte_counter_4
   );

   function integer log2;
      input integer number;
      begin
         log2=0;
         while(2**log2<number) begin
            log2=log2+1;
         end
      end
   endfunction // log2
   
   localparam NUM_QUEUES_BITS=log2(NUM_QUEUES);
   // ------------- Wires/reg -----------------

   reg [NUM_QUEUES_BITS-1:0]            reg_addr;
   // -------------- Logic -------------------
   
   reg [19:0]token_interval_reg[3:0];
   reg [7:0]token_increment_reg[3:0];
   

   always@(posedge clk)
   if(reset)
      token_interval<=0;
   else if(req_meter_i && addr_meter_i[7:0]==`RATE_LIMIT_TOKEN_INTERVAL && rw_meter_i==0)
      token_interval<=data_meter_i;
      
   always@(posedge clk)
   if(reset)
      token_increment<=0;
   else if(req_meter_i && addr_meter_i[7:0]==`RATE_LIMIT_TOKEN_INC && rw_meter_i==0)
      token_increment<=data_meter_i;      
 
   always@(posedge clk)
   if(reset)
   begin
      token_interval_reg[0]<=0;
      token_interval_reg[1]<=0;
      token_interval_reg[2]<=0;
      token_interval_reg[3]<=0;
   end
   else if(req_meter_i && addr_meter_i[7:0]==`RATE_LIMIT_TOKEN_INTERVAL && rw_meter_i==0)
         case(addr_meter_i[15:8])
         0:token_interval_reg[0]<=data_meter_i;
         1:token_interval_reg[1]<=data_meter_i;
         2:token_interval_reg[2]<=data_meter_i;
         3:token_interval_reg[3]<=data_meter_i;
       endcase

 
    always@(posedge clk)
    if(reset)
    begin
       token_increment_reg[0]<=0;
       token_increment_reg[1]<=0;
       token_increment_reg[2]<=0;
       token_increment_reg[3]<=0;
    end
    else if(req_meter_i && addr_meter_i[7:0]==`RATE_LIMIT_TOKEN_INC && rw_meter_i==0)
          case(addr_meter_i[15:8])
          0:token_increment_reg[0]<=data_meter_i;
          1:token_increment_reg[1]<=data_meter_i;
          2:token_increment_reg[2]<=data_meter_i;
          3:token_increment_reg[3]<=data_meter_i;
        endcase  
           
           
    always@(posedge clk )
    if(reset)
      token_interval_vld<=0;
    else if(req_meter_i && rw_meter_i==0 && addr_meter_i[7:0]==`RATE_LIMIT_TOKEN_INTERVAL)
    case(addr_meter_i[15:8])
      0:token_interval_vld[0]<=1;
      1:token_interval_vld[1]<=1;
      2:token_interval_vld[2]<=1;
      3:token_interval_vld[3]<=1;
    endcase
    else begin
      token_interval_vld[0]<=0;
      token_interval_vld[1]<=0;
      token_interval_vld[2]<=0;
      token_interval_vld[3]<=0;
    end
   
    always@(posedge clk )
    if(reset)
      token_increment_vld<=0;
    else if(req_meter_i && rw_meter_i==0 && addr_meter_i[7:0]==`RATE_LIMIT_TOKEN_INC)
    case(addr_meter_i[15:8])
      0:token_increment_vld[0]<=1;
      1:token_increment_vld[1]<=1;
      2:token_increment_vld[2]<=1;
      3:token_increment_vld[3]<=1;
    endcase
    else begin
      token_increment_vld[0]<=0;
      token_increment_vld[1]<=0;
      token_increment_vld[2]<=0;
      token_increment_vld[3]<=0;
    end
   
`ifdef ONETS 20   
begin
   always@(posedge clk)
   if(reset)
      data_meter_o<=32'hdeadbeef;
   else if(req_meter_i && addr_meter_i[7:0]==`RATE_LIMIT_TOKEN_INTERVAL && rw_meter_i==1)
   case(addr_meter_i[15:8])
      0:data_meter_o<=token_interval_reg[0];
      1:data_meter_o<=token_interval_reg[1];
      2:data_meter_o<=token_interval_reg[2];
      3:data_meter_o<=token_interval_reg[3];
      default:data_meter_o<=32'hdeadbeef;
   endcase
   else if(req_meter_i && addr_meter_i[7:0]==`RATE_LIMIT_TOKEN_INC && rw_meter_i==1)
   case(addr_meter_i[15:8])
      0:data_meter_o<=token_increment_reg[0];
      1:data_meter_o<=token_increment_reg[1];
      2:data_meter_o<=token_increment_reg[2];
      3:data_meter_o<=token_increment_reg[3];
      default:data_meter_o<=32'hdeadbeef;
   endcase   
   else if(req_meter_i && rw_meter_i==1)
      data_meter_o<=32'hdeadbeef;
end
`else 
begin
   always@(posedge clk)
   if(reset)
      data_meter_o<=32'hdeadbeef;
   else if(req_meter_i && addr_meter_i[7:0]==`RATE_LIMIT_TOKEN_INTERVAL && rw_meter_i==1)
   case(addr_meter_i[15:8])
      0:data_meter_o<=token_interval_reg[0];
      1:data_meter_o<=token_interval_reg[1];
      2:data_meter_o<=token_interval_reg[2];
      3:data_meter_o<=token_interval_reg[3];
      default:data_meter_o<=32'hdeadbeef;
   endcase
   else if(req_meter_i && addr_meter_i[7:0]==`RATE_LIMIT_TOKEN_INC && rw_meter_i==1)
   case(addr_meter_i[15:8])
      0:data_meter_o<=token_increment_reg[0];
      1:data_meter_o<=token_increment_reg[1];
      2:data_meter_o<=token_increment_reg[2];
      3:data_meter_o<=token_increment_reg[3];
      default:data_meter_o<=32'hdeadbeef;
   endcase   
   else if(req_meter_i && addr_meter_i[7:0]==`METER_PASS_PKT_COUNTER && rw_meter_i==1)
   case(addr_meter_i[15:8])
      0:data_meter_o<=pass_pkt_counter_0;
      1:data_meter_o<=pass_pkt_counter_1;
      2:data_meter_o<=pass_pkt_counter_2;
      3:data_meter_o<=pass_pkt_counter_3;
      4:data_meter_o<=pass_pkt_counter_4;
      default:   data_meter_o<=32'hdeadbeef;
   endcase
   else if(req_meter_i && addr_meter_i[7:0]==`METER_PASS_BYTE_COUNTER && rw_meter_i==1)
   case(addr_meter_i[15:8])
      0:data_meter_o<=pass_byte_counter_0;
      1:data_meter_o<=pass_byte_counter_1;
      2:data_meter_o<=pass_byte_counter_2;
      3:data_meter_o<=pass_byte_counter_3;
      4:data_meter_o<=pass_byte_counter_4;
      default:   data_meter_o<=32'hdeadbeef;
   endcase
   else if(req_meter_i && addr_meter_i[7:0]==`METER_DROP_PKT_COUNTER && rw_meter_i==1)
   case(addr_meter_i[11:8])
      0:data_meter_o<=drop_pkt_counter_0;
      1:data_meter_o<=drop_pkt_counter_1;
      2:data_meter_o<=drop_pkt_counter_2;
      3:data_meter_o<=drop_pkt_counter_3;
      4:data_meter_o<=drop_pkt_counter_4;
      default:   data_meter_o<=32'hdeadbeef;
   endcase
   else if(req_meter_i && addr_meter_i[7:0]==`METER_DROP_BYTE_COUNTER && rw_meter_i==1)
   case(addr_meter_i[11:8])
      0:data_meter_o<=drop_byte_counter_0;
      1:data_meter_o<=drop_byte_counter_1;
      2:data_meter_o<=drop_byte_counter_2;
      3:data_meter_o<=drop_byte_counter_3;
      4:data_meter_o<=drop_byte_counter_4;
      default:   data_meter_o<=32'hdeadbeef;
   endcase
   else if(req_meter_i && rw_meter_i==1)
      data_meter_o<=32'hdeadbeef;
end
`endif

    always@(posedge clk)
        if(reset)
            ack_meter_o<=0;            
        else if(req_meter_i)
            ack_meter_o<=1;
        else ack_meter_o<=0;



endmodule // rate_lim_regs


