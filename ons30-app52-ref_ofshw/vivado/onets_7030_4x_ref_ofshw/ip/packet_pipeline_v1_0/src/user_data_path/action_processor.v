`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/27/2015 02:16:18 PM
// Design Name: 
// Module Name: action_processer
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


module action_processor
#(parameter NUM_OUTPUT_QUEUES = 8,
  parameter DATA_WIDTH = 64,
  parameter CTRL_WIDTH = DATA_WIDTH/8,
  parameter CURRENT_TABLE_ID = 0,
  parameter TABLE_NUM=2
)
(// --- interface to results fifo
   input                                   actions_en,
   input                                   actions_hit,
   input      [`OPENFLOW_ACTION_WIDTH-1:0]          actions,
   input  [3:0]                           src_port,

   // --- interface to input fifo
   input [CTRL_WIDTH-1:0]                  in_ctrl,
   input [DATA_WIDTH-1:0]                  in_data,
   output reg                              in_rdy,
   input                                   in_wr,

   // --- interface to output
   output reg [DATA_WIDTH-1:0]             out_data,
   output reg [CTRL_WIDTH-1:0]             out_ctrl,
   output reg                              out_wr,
   input                                   out_rdy,

   // --- interface to registers

   // --- Misc
   input                                   clk,
   input                                   reset
   
   );
   
    //wire [3:0]                                  src_port;
    wire [`OPENFLOW_NF2_ACTION_FLAG_WIDTH-1:0]  nf2_action_flag;
    wire [`OPENFLOW_FORWARD_BITMASK_WIDTH-1:0]  forward_bitmask;
    wire [`OPENFLOW_SET_VLAN_VID_WIDTH-1:0]     set_vlan_vid;
    wire [`OPENFLOW_SET_VLAN_PCP_WIDTH-1:0]     set_vlan_pcp;
    wire [`OPENFLOW_SET_DL_SRC_WIDTH-1:0]       set_dl_src;
    wire [`OPENFLOW_SET_DL_DST_WIDTH-1:0]       set_dl_dst;
    wire [`OPENFLOW_SET_NW_SRC_WIDTH-1:0]       set_nw_src;
    wire [`OPENFLOW_SET_NW_DST_WIDTH-1:0]       set_nw_dst;
    wire [`OPENFLOW_SET_NW_TOS_WIDTH-1:0]       set_nw_tos;
    wire [`OPENFLOW_SET_TP_SRC_WIDTH-1:0]       set_tp_src;
    wire [`OPENFLOW_SET_TP_DST_WIDTH-1:0]       set_tp_dst;
    wire [`OPENFLOW_METER_ID_WIDTH-1:0]         meter_id_undecoded;
    wire [`OPENFLOW_NEXT_TABLE_ID_WIDTH-1:0]    next_table_id;
    reg [`OPENFLOW_NEXT_TABLE_ID_WIDTH-1:0]     pkt_dst_table_id;
    wire [`OPENFLOW_SET_QUEUE_WIDTH-1:0]        set_queue;
    wire [`SET_METADATA_WIDTH-1:0]              set_metadata;
    reg [`OPENFLOW_METER_ID_WIDTH-1:0]          meter_id;
    wire [`OPENFLOW_ADD_VLAN_VID_WIDTH-1:0]      add_vlan_id;
    wire [`OPENFLOW_ADD_VLAN_PCP_WIDTH-1:0]      add_vlan_pcp;
      
    assign forward_bitmask      = (actions[`OPENFLOW_FORWARD_BITMASK_POS +: `OPENFLOW_FORWARD_BITMASK_WIDTH]);
    assign nf2_action_flag      = (actions[`OPENFLOW_NF2_ACTION_FLAG_POS +: `OPENFLOW_NF2_ACTION_FLAG_WIDTH]);
    assign set_vlan_vid         = (actions[`OPENFLOW_SET_VLAN_VID_POS +: `OPENFLOW_SET_VLAN_VID_WIDTH]);
    assign set_vlan_pcp         = (actions[`OPENFLOW_SET_VLAN_PCP_POS +: `OPENFLOW_SET_VLAN_PCP_WIDTH]);
    assign set_dl_src           = (actions[`OPENFLOW_SET_DL_SRC_POS +: `OPENFLOW_SET_DL_SRC_WIDTH]);
    assign set_dl_dst           = (actions[`OPENFLOW_SET_DL_DST_POS +: `OPENFLOW_SET_DL_DST_WIDTH]);
    assign set_nw_src           = (actions[`OPENFLOW_SET_NW_SRC_POS +: `OPENFLOW_SET_NW_SRC_WIDTH]);
    assign set_nw_dst           = (actions[`OPENFLOW_SET_NW_DST_POS +: `OPENFLOW_SET_NW_DST_WIDTH]);
    assign set_nw_tos           = (actions[`OPENFLOW_SET_NW_TOS_POS +: `OPENFLOW_SET_NW_TOS_WIDTH]);
    assign set_tp_src           = (actions[`OPENFLOW_SET_TP_SRC_POS +: `OPENFLOW_SET_TP_SRC_WIDTH]);
    assign set_tp_dst           = (actions[`OPENFLOW_SET_TP_DST_POS +: `OPENFLOW_SET_TP_DST_WIDTH]);
    assign meter_id_undecoded   = (actions[`OPENFLOW_METER_ID_POS +: `OPENFLOW_METER_ID_WIDTH]);
    assign next_table_id        = (actions[`OPENFLOW_NEXT_TABLE_ID_POS +: `OPENFLOW_NEXT_TABLE_ID_WIDTH]); 
    assign set_queue            = (actions[`OPENFLOW_SET_QUEUE_POS +: `OPENFLOW_SET_QUEUE_WIDTH]);
    assign set_metadata         = (actions[`SET_METADATA_POS +: `SET_METADATA_WIDTH]);
    assign add_vlan_id          = (actions[`OPENFLOW_ADD_VLAN_VID_POS +: `OPENFLOW_ADD_VLAN_VID_WIDTH]);
    assign add_vlan_pcp         = (actions[`OPENFLOW_ADD_VLAN_PCP_POS +: `OPENFLOW_ADD_VLAN_PCP_WIDTH]);
   
    always @(*) begin
       meter_id = 0;
       meter_id[meter_id_undecoded] = 1'b1;
    end
     
    always@(*)
        if(reset)
            in_rdy<=0;
        else in_rdy<=out_rdy;  
      
    reg [63:0]  in_fifo_data_d1_nxt;
    reg [7:0]   in_fifo_ctrl_d1_nxt;
    reg         in_fifo_wr_d1_nxt;
    reg [63:0]  in_fifo_data_d1;
    reg [7:0]   in_fifo_ctrl_d1;
    reg in_wr_d1;
    
    always@(posedge clk)
    if(reset)
      in_fifo_data_d1<=0;
    else in_fifo_data_d1<=in_data;
    
    always@(posedge clk)
    if(reset)
      in_fifo_ctrl_d1<=0;
    else in_fifo_ctrl_d1<=in_ctrl;
    
    always@(posedge clk)
    if(reset)
      in_wr_d1<=0;
    else in_wr_d1<=in_wr;
    
    always@(posedge clk)
        if(reset)
            out_data<=0;
        else
            out_data<=in_fifo_data_d1_nxt;
    
    always@(posedge clk)
        if(reset)
            out_ctrl<=0;
        else 
            out_ctrl<=in_fifo_ctrl_d1_nxt;
            
    always@(posedge clk)
        if(reset)
            out_wr<=0;
        else
            out_wr<=in_fifo_wr_d1_nxt;  
      
    reg [15:0]cur_st,nxt_st;
    localparam IDLE=0,
               WAIT=1,
               PKT_HEAD=2,
               PKT_METADATA=3,
               PKT_DATA_0=4,
               PKT_DATA_1=5,
               PKT_DATA_2=6,
               PKT_DATA_3=7,
               PKT_DATA_4=8,
               WAIT_EOP=9,
               PKT_HEAD_D=10,
               PKT_METADATA_D=11,
               PKT_DATA_0_D=12,
               PKT_DATA_1_D=13,
               PKT_DATA_2_D=14,
               PKT_DATA_3_D=15,
               PKT_DATA_4_D=16,
               WAIT_EOP_D=17;
               
    
    
    always@(posedge clk)
        if(reset)   cur_st<=0;
        else        cur_st<=nxt_st;
    
    always@(*)
        begin
            nxt_st=cur_st; 
            case(cur_st)
                IDLE:nxt_st=WAIT;
                WAIT:
                    if(in_wr && in_ctrl==`VLAN_CTRL_WORD) nxt_st=PKT_HEAD;
                    else if(in_wr && in_ctrl==`IO_QUEUE_STAGE_NUM && ((nf2_action_flag & `ADD_VLAN_VID) | (nf2_action_flag & `ADD_VLAN_PCP))) nxt_st=PKT_HEAD_D;
                    else if(in_wr && in_ctrl==`IO_QUEUE_STAGE_NUM) nxt_st=PKT_METADATA;
                PKT_HEAD: if(in_wr && in_ctrl==`IO_QUEUE_STAGE_NUM) nxt_st=PKT_METADATA;
                PKT_METADATA:
                    if(in_wr && in_ctrl==`METEDATA_NUM) nxt_st=PKT_DATA_0;
                PKT_DATA_0:if(in_wr) nxt_st=PKT_DATA_1;
                PKT_DATA_1:if(in_wr) nxt_st=PKT_DATA_2;
                PKT_DATA_2:if(in_wr) nxt_st=PKT_DATA_3;
                PKT_DATA_3:if(in_wr) nxt_st=PKT_DATA_4;
                PKT_DATA_4:if(in_wr) nxt_st=WAIT_EOP;
                WAIT_EOP:if(in_wr && in_ctrl!=0) nxt_st=IDLE;
                PKT_HEAD_D:if(in_wr_d1 && in_fifo_ctrl_d1==`IO_QUEUE_STAGE_NUM) nxt_st=PKT_METADATA_D;
                PKT_METADATA_D:
                    if(in_wr_d1 && in_fifo_ctrl_d1==`METEDATA_NUM) nxt_st=PKT_DATA_0_D;
                PKT_DATA_0_D:if(in_wr_d1) nxt_st=PKT_DATA_1_D;
                PKT_DATA_1_D:if(in_wr_d1) nxt_st=PKT_DATA_2_D;
                PKT_DATA_2_D:if(in_wr_d1) nxt_st=PKT_DATA_3_D;
                PKT_DATA_3_D:if(in_wr_d1) nxt_st=PKT_DATA_4_D;
                PKT_DATA_4_D:if(in_wr_d1) nxt_st=WAIT_EOP_D;
                WAIT_EOP_D:if(in_wr_d1 && in_fifo_ctrl_d1!=0) nxt_st=IDLE;
                default:nxt_st=IDLE;
            endcase
        end
             
                
    always@(*)
        begin 
           in_fifo_data_d1_nxt=in_data;
           in_fifo_ctrl_d1_nxt=in_ctrl;
           in_fifo_wr_d1_nxt=in_wr;
           if(actions_en)
           begin
              if(cur_st==WAIT)  
              begin  
                  if(in_ctrl==`VLAN_CTRL_WORD)
                  begin
                     if(nf2_action_flag & `NF2_OFPAT_SET_VLAN_VID)
                        in_fifo_data_d1_nxt[11:0]   =  set_vlan_vid;  
                     if(nf2_action_flag & `NF2_OFPAT_SET_VLAN_PCP)
                        in_fifo_data_d1_nxt[15:12]   =  set_vlan_vid;  
                     if(nf2_action_flag & `NF2_OFPAT_STRIP_VLAN)
                        in_fifo_data_d1_nxt[31] = 1;
                  end
                  else if(in_ctrl==`IO_QUEUE_STAGE_NUM && ((nf2_action_flag & `ADD_VLAN_VID) | (nf2_action_flag & `ADD_VLAN_PCP)))
                     begin
                          in_fifo_data_d1_nxt=0;
                          if(nf2_action_flag & `ADD_VLAN_VID)
                        begin
                           in_fifo_data_d1_nxt[11:0]   =  add_vlan_id;  
                           in_fifo_ctrl_d1_nxt =  `VLAN_CTRL_WORD;
                        end
                        if(nf2_action_flag & `ADD_VLAN_PCP)
                        begin
                           in_fifo_data_d1_nxt[15:12]   =  add_vlan_pcp;
                           in_fifo_ctrl_d1_nxt =  `VLAN_CTRL_WORD;
                        end 
                     end
                  else if(in_ctrl==`IO_QUEUE_STAGE_NUM)    
                  begin
                      if(nf2_action_flag & `NF2_OFPAT_OUTPUT)
                          in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] = in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] | forward_bitmask;
                      if(nf2_action_flag & `NF2_OFPAT_METER)
                          in_fifo_data_d1_nxt[`IOQ_METER_ID_POS +:`IOQ_METER_ID_LEN] = meter_id;
                      if(nf2_action_flag & `NF2_OFPAT_GOTO_TABLE) 
                      begin
                          if(next_table_id>TABLE_NUM)
                          begin
                             case(src_port)
                             0:in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] =   8'b0000_0010;
                             2:in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] =   8'b0000_1000; 
                             4:in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] =   8'b0010_0000;
                             6:in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] =   8'b1000_0000;
                             endcase
                            in_fifo_data_d1_nxt[`IOQ_DST_TABLE_ID_POS +:`IOQ_DST_TABLE_ID_LEN] =next_table_id;
                          end
                          else  in_fifo_data_d1_nxt[`IOQ_DST_TABLE_ID_POS +:`IOQ_DST_TABLE_ID_LEN] = next_table_id;
                      end
                      else if(nf2_action_flag == 0 && actions_hit) 
                           in_fifo_data_d1_nxt[`IOQ_DST_TABLE_ID_POS+:`IOQ_DST_TABLE_ID_LEN] =8'hff;
                      else if(nf2_action_flag == 0 && !actions_hit)
                      begin
                         in_fifo_data_d1_nxt[`IOQ_DST_TABLE_ID_POS +:`IOQ_DST_TABLE_ID_LEN] = CURRENT_TABLE_ID + 1;
                         /*if((CURRENT_TABLE_ID + 1)>TABLE_NUM)
                                 case(src_port)
                                 0:in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] =   8'b0000_0010;
                                 2:in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] =   8'b0000_1000; 
                                 4:in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] =   8'b0010_0000;
                                 6:in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] =   8'b1000_0000;
                                 endcase*/
                      end
                      else in_fifo_data_d1_nxt[`IOQ_DST_TABLE_ID_POS +:`IOQ_DST_TABLE_ID_LEN] = 8'hFF;
                  end
              end
              else if(cur_st==PKT_HEAD)
                  begin
                      if(nf2_action_flag & `NF2_OFPAT_OUTPUT)
                          in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] = in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] | forward_bitmask;
                      if(nf2_action_flag & `NF2_OFPAT_METER)
                          in_fifo_data_d1_nxt[`IOQ_METER_ID_POS +:`IOQ_METER_ID_LEN] = meter_id;
                      if(nf2_action_flag & `NF2_OFPAT_GOTO_TABLE) 
                      begin
                          if(next_table_id>TABLE_NUM)
                          begin
                             case(src_port)
                             0:in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] =   8'b0000_0010;
                             2:in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] =   8'b0000_1000; 
                             4:in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] =   8'b0010_0000;
                             6:in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] =   8'b1000_0000;
                             endcase
                            in_fifo_data_d1_nxt[`IOQ_DST_TABLE_ID_POS +:`IOQ_DST_TABLE_ID_LEN] =8'hff;
                          end
                          else  in_fifo_data_d1_nxt[`IOQ_DST_TABLE_ID_POS +:`IOQ_DST_TABLE_ID_LEN] = next_table_id;
                      end
                      else if(nf2_action_flag == 0 && actions_hit) 
                           in_fifo_data_d1_nxt[`IOQ_DST_TABLE_ID_POS +:`IOQ_DST_TABLE_ID_LEN] =8'hff;
                      else if(nf2_action_flag == 0 && !actions_hit)
                      begin
                         in_fifo_data_d1_nxt[`IOQ_DST_TABLE_ID_POS +:`IOQ_DST_TABLE_ID_LEN] = CURRENT_TABLE_ID + 1;
                        /* if((CURRENT_TABLE_ID + 1)>TABLE_NUM)
                                 case(src_port)
                                 0:in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] =   8'b0000_0010;
                                 2:in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] =   8'b0000_1000; 
                                 4:in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] =   8'b0010_0000;
                                 6:in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] =   8'b1000_0000;
                                 endcase*/
                      end
                  end
              else if(cur_st==PKT_METADATA)
                  begin
                      if(nf2_action_flag & `SET_METADATA)
                          begin
                               in_fifo_data_d1_nxt[`METADATA_PRIO_POS+:`METADATA_PRIO_LEN] = set_metadata;
                               in_fifo_data_d1_nxt[`METADATA_TABLE_ID_POS+:`METADATA_TABLE_ID_LEN] = CURRENT_TABLE_ID;
                          end
                      if(nf2_action_flag & `NF2_OFPAT_SET_QOS)
                         in_fifo_data_d1_nxt[`METADATA_QOS_QUEUE_POS +:`METADATA_QOS_QUEUE_LEN] = set_queue;                                
                  end
              else if(cur_st==PKT_DATA_0 )
                  begin
                      if(nf2_action_flag & `NF2_OFPAT_SET_DL_DST)
                          in_fifo_data_d1_nxt[63:16]=set_dl_dst;
                      if(nf2_action_flag & `NF2_OFPAT_SET_DL_SRC)
                          in_fifo_data_d1_nxt[15:0]=set_dl_src[47:32];
                  end
              else if(cur_st==PKT_DATA_1)
                  begin
                      if(nf2_action_flag & `NF2_OFPAT_SET_DL_SRC)
                          in_fifo_data_d1_nxt[63:32]=set_dl_src[31:0];
                      if(nf2_action_flag & `NF2_OFPAT_SET_NW_TOS)
                          in_fifo_data_d1_nxt[7:2]=set_nw_tos[7:0];
                  end      
              else if(cur_st==PKT_DATA_3)
                  begin
                      if(nf2_action_flag & `NF2_OFPAT_SET_NW_SRC)
                          in_fifo_data_d1_nxt[47:16]=set_nw_src;
                      if(nf2_action_flag & `NF2_OFPAT_SET_NW_DST)
                          in_fifo_data_d1_nxt[15:0]=set_nw_dst[31:16];
                  end
              else if(cur_st==PKT_DATA_4)
                  begin
                      if(nf2_action_flag & `NF2_OFPAT_SET_NW_DST)
                          in_fifo_data_d1_nxt[63:48]=set_nw_dst[15:0];
                  end
            else if(cur_st==PKT_HEAD_D && in_fifo_ctrl_d1==`IO_QUEUE_STAGE_NUM)   
                begin
                  in_fifo_data_d1_nxt=in_fifo_data_d1;
                  in_fifo_ctrl_d1_nxt=in_fifo_ctrl_d1;
                  in_fifo_wr_d1_nxt=in_wr_d1;                
                   if(nf2_action_flag & `NF2_OFPAT_OUTPUT)
                       in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] = in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] | forward_bitmask;
                   if(nf2_action_flag & `NF2_OFPAT_METER)
                       in_fifo_data_d1_nxt[`IOQ_METER_ID_POS +:`IOQ_METER_ID_LEN] = meter_id;
                   if(nf2_action_flag & `NF2_OFPAT_GOTO_TABLE) 
                   begin
                       if(next_table_id>TABLE_NUM)
                       begin
                          case(src_port)
                          0:in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] =   8'b0000_0010;
                          2:in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] =   8'b0000_1000; 
                          4:in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] =   8'b0010_0000;
                          6:in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] =   8'b1000_0000;
                          endcase
                         in_fifo_data_d1_nxt[`IOQ_DST_TABLE_ID_POS +:`IOQ_DST_TABLE_ID_LEN] =8'hff;
                       end
                       else  in_fifo_data_d1_nxt[`IOQ_DST_TABLE_ID_POS +:`IOQ_DST_TABLE_ID_LEN] = next_table_id;
                   end
                   else if(nf2_action_flag == 0 && actions_hit) 
                        in_fifo_data_d1_nxt[`IOQ_DST_TABLE_ID_POS+:`IOQ_DST_TABLE_ID_LEN] =8'hff;
                   else if(nf2_action_flag == 0 && !actions_hit)
                   begin
                      in_fifo_data_d1_nxt[`IOQ_DST_TABLE_ID_POS +:`IOQ_DST_TABLE_ID_LEN] = CURRENT_TABLE_ID + 1;
                      /*if((CURRENT_TABLE_ID + 1)>TABLE_NUM)
                              case(src_port)
                              0:in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] =   8'b0000_0010;
                              2:in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] =   8'b0000_1000; 
                              4:in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] =   8'b0010_0000;
                              6:in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+7:`IOQ_DST_PORT_POS] =   8'b1000_0000;
                              endcase*/
                   end
               end
          else if(cur_st==PKT_METADATA_D &&  in_fifo_ctrl_d1==`METEDATA_NUM)
               begin
                   in_fifo_data_d1_nxt=in_fifo_data_d1;
                   in_fifo_ctrl_d1_nxt=in_fifo_ctrl_d1;
                   in_fifo_wr_d1_nxt=in_wr_d1;
                   if(nf2_action_flag & `SET_METADATA)
                       begin
                            in_fifo_data_d1_nxt[`METADATA_PRIO_POS+:`METADATA_PRIO_LEN] = set_metadata;
                            in_fifo_data_d1_nxt[`METADATA_TABLE_ID_POS+:`METADATA_TABLE_ID_LEN] = CURRENT_TABLE_ID;
                       end
                   if(nf2_action_flag & `NF2_OFPAT_SET_QOS)
                      in_fifo_data_d1_nxt[`METADATA_QOS_QUEUE_POS +:`METADATA_QOS_QUEUE_LEN] = set_queue;                                
               end
            else if(cur_st==PKT_DATA_0_D)
                begin
                    in_fifo_data_d1_nxt=in_fifo_data_d1;
                    in_fifo_ctrl_d1_nxt=in_fifo_ctrl_d1;
                    in_fifo_wr_d1_nxt=in_wr_d1;
                    if(nf2_action_flag & `NF2_OFPAT_SET_DL_DST)
                        in_fifo_data_d1_nxt[63:16]=set_dl_dst;
                    if(nf2_action_flag & `NF2_OFPAT_SET_DL_SRC)
                        in_fifo_data_d1_nxt[15:0]=set_dl_src[47:32];
                end
            else if(cur_st==PKT_DATA_1_D)
                
                begin
                   in_fifo_data_d1_nxt=in_fifo_data_d1;
                   in_fifo_ctrl_d1_nxt=in_fifo_ctrl_d1;
                   in_fifo_wr_d1_nxt=in_wr_d1;
                    if(nf2_action_flag & `NF2_OFPAT_SET_DL_SRC)
                        in_fifo_data_d1_nxt[63:32]=set_dl_src[31:0];
                    if(nf2_action_flag & `NF2_OFPAT_SET_NW_TOS)
                        in_fifo_data_d1_nxt[7:2]=set_nw_tos[7:0];
                end      
            else if(cur_st==PKT_DATA_3_D)
                begin
                    in_fifo_data_d1_nxt=in_fifo_data_d1;
                    in_fifo_ctrl_d1_nxt=in_fifo_ctrl_d1;
                    in_fifo_wr_d1_nxt=in_wr_d1;
                    if(nf2_action_flag & `NF2_OFPAT_SET_NW_SRC)
                        in_fifo_data_d1_nxt[47:16]=set_nw_src;
                    if(nf2_action_flag & `NF2_OFPAT_SET_NW_DST)
                        in_fifo_data_d1_nxt[15:0]=set_nw_dst[31:16];
                end
            else if(cur_st==PKT_DATA_4_D)
                begin
                    in_fifo_data_d1_nxt=in_fifo_data_d1;
                    in_fifo_ctrl_d1_nxt=in_fifo_ctrl_d1;
                    in_fifo_wr_d1_nxt=in_wr_d1;
                    if(nf2_action_flag & `NF2_OFPAT_SET_NW_DST)
                        in_fifo_data_d1_nxt[63:48]=set_nw_dst[15:0];
                end
            else if(cur_st==WAIT_EOP_D)
               begin
                  in_fifo_data_d1_nxt=in_fifo_data_d1;
                  in_fifo_ctrl_d1_nxt=in_fifo_ctrl_d1;
                  in_fifo_wr_d1_nxt=in_wr_d1;
               end
            end
        end 
                    
        
                    
                    
                    
            
    
    
endmodule
