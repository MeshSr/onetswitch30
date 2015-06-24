///////////////////////////////////////////////////////////////////////////////
// vim:set shiftwidth=3 softtabstop=3 expandtab:
// $Id: udp_reg_master.v 1965 2007-07-18 01:24:21Z grg $
//
// Module: udp_reg_master.v
// Project: NetFPGA
// Description: User data path register master
//
// Note: Set TIMEOUT_RESULT to specify the return value on timeout.
// This can be used to identify broken rings.
//
// Result: ack_in -> data_in
//         timeout -> TIMEOUT_RESULT
//         loop complete && !ack_in -> deadbeef
//
///////////////////////////////////////////////////////////////////////////////

module udp_reg_master
   #(
      parameter TABLE_NUM = 1
   )
   (
      input                              reg_req_in                  ,
      input                              reg_rd_wr_L_in              ,
      input [31:0]                       reg_addr_in                 ,
      input [31:0]                       reg_data_in                 ,
      output reg [31:0]                 reg_rd_data                 ,
      output reg                         reg_ack                     ,

      input                              clk                         ,
      input                              reset                       ,
      
      output   [31:0]                    data_output_port_lookup_o ,
      /*output   [31:0]                    data_output_port_lookup_1_o ,
      output   [31:0]                    data_output_port_lookup_2_o ,*/
      output   [31:0]                    data_meter_o                ,
      output   [31:0]                    data_output_queues_o        ,
      output   [31:0]                    data_config_o               ,
      
      output   [31:0]                    addr_output_port_lookup_o ,
      /*output   [31:0]                    addr_output_port_lookup_1_o ,
      output   [31:0]                    addr_output_port_lookup_2_o ,*/
      output   [31:0]                    addr_meter_o                ,
      output   [31:0]                    addr_output_queues_o        ,
      output   [31:0]                    addr_config_o               ,
      
      output                             req_output_port_lookup_o ,
      /*output                             req_output_port_lookup_1_o ,
      output                             req_output_port_lookup_2_o ,*/
      output                             req_meter_o                 ,
      output                             req_output_queues_o         ,
      output                             req_config_o                ,
      
      output                             rw_output_port_lookup_o ,
      /*output                             rw_output_port_lookup_1_o ,
      output                             rw_output_port_lookup_2_o ,*/
      output                             rw_meter_o                  ,
      output                             rw_output_queues_o          ,
      output                             rw_config_o                 ,
            
      input                              ack_output_port_lookup_i  ,
      /*input                              ack_output_port_lookup_1_i  ,
      input                              ack_output_port_lookup_2_i  ,*/
      input                              ack_meter_i                 ,
      input                              ack_output_queues_i         ,     
      input                              ack_config_i                ,  
      
      input   [31:0]                     data_output_port_lookup_i ,
      /*input   [31:0]                     data_output_port_lookup_1_i ,
      input   [31:0]                     data_output_port_lookup_2_i ,*/
      input   [31:0]                     data_meter_i                ,
      input   [31:0]                     data_output_queues_i        ,
      input   [31:0]                     data_config_i
        
      

   );
   assign data_output_port_lookup_o  =  reg_data_in ;
   /*assign data_output_port_lookup_1_o  =  reg_data_in ;
   assign data_output_port_lookup_2_o  =  reg_data_in ;*/
   assign data_meter_o                 =  reg_data_in ;
   assign data_output_queues_o         =  reg_data_in ;
   assign data_config_o                =  reg_data_in ;
   
   assign addr_output_port_lookup_o  =  reg_addr_in ;
   /*assign addr_output_port_lookup_1_o  =  reg_addr_in ;
   assign addr_output_port_lookup_2_o  =  reg_addr_in ;*/
   assign addr_meter_o                 =  reg_addr_in;
   assign addr_output_queues_o         =  reg_addr_in;
   assign addr_config_o                =  reg_addr_in ;
   
   assign req_output_port_lookup_o      =  (reg_addr_in[`MODULE_ID_POS+`MODULE_ID_WIDTH-1:`MODULE_ID_POS]==`OUTPUT_PORT_LOOKUP_TAG && reg_addr_in[`TABLE_ID_POS+`TABLE_ID_WIDTH-1:`TABLE_ID_POS]<=TABLE_NUM) ? reg_req_in : 0;
   /*assign req_output_port_lookup_1_o      =  (reg_addr_in[`MODULE_ID_POS+`MODULE_ID_WIDTH-1:`MODULE_ID_POS]==`OUTPUT_PORT_LOOKUP_TAG && reg_addr_in[`TABLE_ID_POS+`TABLE_ID_WIDTH-1:`TABLE_ID_POS]==1) ? reg_req_in : 0;
   assign req_output_port_lookup_2_o      =  (reg_addr_in[`MODULE_ID_POS+`MODULE_ID_WIDTH-1:`MODULE_ID_POS]==`OUTPUT_PORT_LOOKUP_TAG && reg_addr_in[`TABLE_ID_POS+`TABLE_ID_WIDTH-1:`TABLE_ID_POS]==2) ? reg_req_in : 0;  */    
   assign req_meter_o                     =  (reg_addr_in[`MODULE_ID_POS+`MODULE_ID_WIDTH-1:`MODULE_ID_POS]==`METER_TAG)              ? reg_req_in : 0;
   assign req_output_queues_o             =  (reg_addr_in[`MODULE_ID_POS+`MODULE_ID_WIDTH-1:`MODULE_ID_POS]==`QOS_TAG)                ? reg_req_in : 0;
   assign req_config_o                    =  (reg_addr_in[`MODULE_ID_POS+`MODULE_ID_WIDTH-1:`MODULE_ID_POS]==`CONFIG)                 ? reg_req_in : 0;
   
   assign rw_output_port_lookup_o       =  reg_rd_wr_L_in;
   /*assign rw_output_port_lookup_1_o       =  reg_rd_wr_L_in;
   assign rw_output_port_lookup_2_o       =  reg_rd_wr_L_in;   */   
   assign rw_meter_o                      =  reg_rd_wr_L_in;
   assign rw_output_queues_o              =  reg_rd_wr_L_in;
   assign rw_config_o                     =  reg_rd_wr_L_in;
   
   
   reg [2:0]ack_state;
   always@(posedge clk)
   if(reset)
      ack_state<=0;
   else case(ack_state)
      0:if(req_output_port_lookup_o  | req_meter_o | req_output_queues_o | req_config_o) ack_state<=1;//| req_output_port_lookup_1_o | req_output_port_lookup_2_o
        else if(reg_req_in) ack_state<=3;
      1:if(ack_output_port_lookup_i | ack_meter_i | ack_output_queues_i | ack_config_i) ack_state<=2;
      2:ack_state<=0;
      3:ack_state<=0;
      default:ack_state<=0;
      endcase
  
   always@(posedge clk)
   if(reset)
      reg_ack <= 0;
   else if(ack_state==2 | ack_state==3)
      reg_ack<=1;
   else reg_ack<=0;
   
   always@(posedge clk)
   if(reset)
      reg_rd_data<=0;
   else if(ack_state==1)
   begin
      if(ack_output_port_lookup_i)      reg_rd_data <= data_output_port_lookup_i;
      /*else if(ack_output_port_lookup_1_i) reg_rd_data <= data_output_port_lookup_1_i;
      else if(ack_output_port_lookup_2_i) reg_rd_data <= data_output_port_lookup_2_i;*/
      else if(ack_meter_i)                reg_rd_data <= data_meter_i;
      else if(ack_output_queues_i)        reg_rd_data <= data_output_queues_i;
      else if(ack_config_i)               reg_rd_data <= data_config_i;
   end
   else if(ack_state==3) reg_rd_data<=32'hdeadbeef;

   
        
            
            
endmodule // unused_reg