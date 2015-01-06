///////////////////////////////////////////////////////////////////////////////
// vim:set shiftwidth=3 softtabstop=3 expandtab:
// $Id: opl_processor.v 5988 2010-03-09 07:04:41Z tyabe $
//
// Module: opl_processor.v
// Project: NF2.1 OpenFlow Switch
// Author: Jad Naous <jnaous@stanford.edu>
//         Tatsuya Yabe <tyabe@stanford.edu>
// Description: Appends the actions to take on a packet to the beginning of
// a packet then pushes the packet out to the next module.
// This module performs all the modify actions supported on OpenFlow v1.0,
// with checksum recalculation.
//
// Licensing: In addition to the NetFPGA license, the following license applies
//            to the source code in the OpenFlow Switch implementation on NetFPGA.
//
// Copyright (c) 2008 The Board of Trustees of The Leland Stanford Junior University
//
// We are making the OpenFlow specification and associated documentation (Software)
// available for public use and benefit with the expectation that others will use,
// modify and enhance the Software and contribute those enhancements back to the
// community. However, since we would like to make the Software available for
// broadest use, with as few restrictions as possible permission is hereby granted,
// free of charge, to any person obtaining a copy of this Software to deal in the
// Software under the copyrights without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// The name and trademarks of copyright holder(s) may NOT be used in advertising
// or publicity pertaining to the Software or any derivatives without specific,
// written prior permission.
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module opl_processor
  #(parameter NUM_OUTPUT_QUEUES = 8,
    parameter DATA_WIDTH = 64,
    parameter CTRL_WIDTH = DATA_WIDTH/8,
    parameter RESULT_WIDTH = `OPENFLOW_ACTION_WIDTH + `OPENFLOW_ENTRY_SRC_PORT_WIDTH,
    parameter CURRENT_TABLE_ID = 0
  )
  (// --- interface to results fifo
   input      [RESULT_WIDTH-1:0]           result_fifo_dout,
   output reg                              result_fifo_rd_en,
   input                                   result_fifo_empty,

   // --- interface to input fifo
   input [CTRL_WIDTH-1:0]                  in_fifo_ctrl,
   input [DATA_WIDTH-1:0]                  in_fifo_data,
   output reg                              in_fifo_rd_en,
   input                                   in_fifo_empty,

   // --- interface to output
   output reg [DATA_WIDTH-1:0]             out_data,
   output reg [CTRL_WIDTH-1:0]             out_ctrl,
   output reg                              out_wr,
   input                                   out_rdy,

   // --- interface to registers
   output reg [NUM_OUTPUT_QUEUES-1:0]      pkts_dropped,
   output reg                              wildcard_wins,
   output reg                              wildcard_lose,

   // --- Misc
   input                                   clk,
   input                                   reset);

   `LOG2_FUNC
   `CEILDIV_FUNC

   //-------------------- Internal Parameters ------------------------
   localparam NUM_STATES = 9;
   localparam WAIT_FOR_INPUT           = 1,
              WRITE_REPLACEMENTS       = 2,
              WRITE_OUTPUT_DESTINATION = 4,
              WRITE_IO_HDR             = 8,
              HDR_1ST                  = 16,
              HDR_CONT                 = 32,
              WRITE_PACKET             = 64,
              DROP_PKT                 = 128,
              WRITE_LAST_WORD          = 256;

   localparam CNTR_SIZE = 3;
   localparam NUM_HDR_REPLACE = 5;
   localparam HDR_2ND = 1,
              HDR_3RD = 2,
              HDR_4TH = 4,
              HDR_5TH = 8,
              HDR_6TH = 16;

   localparam NUM_POST_STATES = 2;
   localparam FOLLOW_PREP_STATE = 1,
              REPLACE_REST      = 2;

   localparam NUM_TP_HDR_CNTR = 11;
   localparam TP_HDR_WAIT  = 1,
              TP_HDR_2_ODD = 2,
              TP_HDR_3_ODD = 4,
              TP_HDR_4_ODD = 8,
              TP_HDR_5_ODD = 16,
              TP_HDR_6_ODD = 32,
              TP_HDR_2_EVN = 64,
              TP_HDR_3_EVN = 128,
              TP_HDR_4_EVN = 256,
              TP_HDR_5_EVN = 512,
              TP_HDR_6_EVN = 1024;
   localparam NUM_IP_HDR_CNTR = 4;
   localparam IP_HDR_REST_1 = 1,
              IP_HDR_REST_2 = 2,
              IP_HDR_REST_3 = 4,
              IP_HDR_STOP   = 8;

   localparam TYPE_IP  = 16'h0800;
   localparam TYPE_UDP = 16'h11;
   localparam TYPE_TCP = 16'h6;

   //------------------------ Wires/Regs -----------------------------
   wire [log2(NUM_OUTPUT_QUEUES)-1:0]          src_port;
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
   wire [`OPENFLOW_NEXT_TABLE_ID_WIDTH-1:0]    pkt_dst_table_id;

   reg [15:0]  src_port_decoded;
   
   reg [`OPENFLOW_METER_ID_WIDTH-1:0]          meter_id;
   
   reg [NUM_STATES-1:0]  state, state_nxt;

   reg                   out_wr_prep1, out_wr_prep1_nxt;
   reg                   out_wr_prep2, out_wr_prep2_nxt;
   reg                   out_wr_prep3, out_wr_prep3_nxt;
   reg                   out_wr_nxt;

   reg [CTRL_WIDTH-1:0]  in_fifo_ctrl_d1, in_fifo_ctrl_d1_nxt;
   reg [CTRL_WIDTH-1:0]  in_fifo_ctrl_d2, in_fifo_ctrl_d2_nxt;
   reg [CTRL_WIDTH-1:0]  in_fifo_ctrl_d3, in_fifo_ctrl_d3_nxt;
   reg [CTRL_WIDTH-1:0]  out_ctrl_nxt;

   reg [DATA_WIDTH-1:0]  in_fifo_data_d1, in_fifo_data_d1_nxt;
   reg [DATA_WIDTH-1:0]  out_data_ioq, out_data_ioq_nxt;
   reg [DATA_WIDTH-1:0]  in_fifo_data_d2, in_fifo_data_d2_nxt;
   reg [DATA_WIDTH-1:0]  in_fifo_data_d3, in_fifo_data_d3_nxt;
   reg                   out_data_enb;


   reg [NUM_OUTPUT_QUEUES-1:0]  pkts_dropped_nxt;
   reg                          vlan_proc_done, vlan_proc_done_nxt;
   reg [NUM_HDR_REPLACE-1:0]    hdr_replace_cntr, hdr_replace_cntr_nxt;

   wire  is_eop;
   reg   is_ip, is_ip_nxt;
   reg   is_udp, is_udp_nxt;
   reg   is_tcp, is_tcp_nxt;

   reg [3:0]  ip_hdr_len, ip_hdr_len_nxt;
   reg [1:0]  last_word_cnt, last_word_cnt_nxt;

   reg [NUM_POST_STATES-1:0]  post_state, post_state_nxt;
   reg [NUM_TP_HDR_CNTR-1:0]  tp_hdr_cntr, tp_hdr_cntr_nxt;
   reg [NUM_IP_HDR_CNTR-1:0]  ip_hdr_cntr, ip_hdr_cntr_nxt;

   reg [16:0]  nw_src_h_diff, nw_src_h_diff_nxt;
   reg [16:0]  nw_src_l_diff, nw_src_l_diff_nxt;
   reg [16:0]  nw_src_diff, nw_src_diff_nxt;
   reg [16:0]  nw_dst_h_diff, nw_dst_h_diff_nxt;
   reg [16:0]  nw_dst_l_diff, nw_dst_l_diff_nxt;
   reg [16:0]  nw_dst_diff, nw_dst_diff_nxt;
   reg [16:0]  nw_all_diff, nw_all_diff_nxt;
   reg [17:0]  nw_chksum_new, nw_chksum_new_nxt;

   reg [16:0]  tp_src_diff, tp_src_diff_nxt;
   reg [16:0]  tp_dst_diff, tp_dst_diff_nxt;
   reg [15:0]  tp_chksum_org_inv, tp_chksum_org_inv_nxt;
   reg [16:0]  tp_chksum_new, tp_chksum_new_nxt;

   reg [DATA_WIDTH-1:0]  out_data_nxt;

   //-------------------------- Logic --------------------------------
   assign src_port = result_fifo_dout[RESULT_WIDTH-1 -: `OPENFLOW_ENTRY_SRC_PORT_WIDTH];

   /* decode source port
    */
   always @(*) begin
      src_port_decoded = 0;
      src_port_decoded[src_port] = 1'b1;
   end

   /* always take out the src port from the output destinations
    */
   assign forward_bitmask
       = (result_fifo_dout[`OPENFLOW_FORWARD_BITMASK_POS +: `OPENFLOW_FORWARD_BITMASK_WIDTH]);
   assign nf2_action_flag
       = (result_fifo_dout[`OPENFLOW_NF2_ACTION_FLAG_POS +: `OPENFLOW_NF2_ACTION_FLAG_WIDTH]);
   assign set_vlan_vid = (result_fifo_dout[`OPENFLOW_SET_VLAN_VID_POS +: `OPENFLOW_SET_VLAN_VID_WIDTH]);
   assign set_vlan_pcp = (result_fifo_dout[`OPENFLOW_SET_VLAN_PCP_POS +: `OPENFLOW_SET_VLAN_PCP_WIDTH]);
   assign set_dl_src   = (result_fifo_dout[`OPENFLOW_SET_DL_SRC_POS +: `OPENFLOW_SET_DL_SRC_WIDTH]);
   assign set_dl_dst   = (result_fifo_dout[`OPENFLOW_SET_DL_DST_POS +: `OPENFLOW_SET_DL_DST_WIDTH]);
   assign set_nw_src   = (result_fifo_dout[`OPENFLOW_SET_NW_SRC_POS +: `OPENFLOW_SET_NW_SRC_WIDTH]);
   assign set_nw_dst   = (result_fifo_dout[`OPENFLOW_SET_NW_DST_POS +: `OPENFLOW_SET_NW_DST_WIDTH]);
   assign set_nw_tos   = (result_fifo_dout[`OPENFLOW_SET_NW_TOS_POS +: `OPENFLOW_SET_NW_TOS_WIDTH]);
   assign set_tp_src   = (result_fifo_dout[`OPENFLOW_SET_TP_SRC_POS +: `OPENFLOW_SET_TP_SRC_WIDTH]);
   assign set_tp_dst   = (result_fifo_dout[`OPENFLOW_SET_TP_DST_POS +: `OPENFLOW_SET_TP_DST_WIDTH]);
   assign meter_id_undecoded = (result_fifo_dout[`OPENFLOW_METER_ID_POS +: `OPENFLOW_METER_ID_WIDTH]);
   assign next_table_id = (result_fifo_dout[`OPENFLOW_NEXT_TABLE_ID_POS +: `OPENFLOW_NEXT_TABLE_ID_WIDTH]); 
   assign pkt_dst_table_id = in_fifo_data[`IOQ_DST_TABLE_ID_POS +: `IOQ_DST_TABLE_ID_LEN];
   assign is_eop = (in_fifo_ctrl && !in_fifo_ctrl_d1);
   
   always @(*) begin
      meter_id = 0;
      meter_id[meter_id_undecoded] = 1'b1;
   end

   /* This state machine parses the action from the flow table,
    * then stores the forwarding port info into header modules of the packet.
    * It writes vlan tag header into a module header if the VLAN
    * modify-action is requested.
    * Then Continue parsing packet for processing other modify-actions.
    * (Those modify-actions are processed in the other state machine)
    */
   always @(*) begin
      state_nxt            = state;
      result_fifo_rd_en    = 0;
      in_fifo_rd_en        = 0;

      out_wr_prep1_nxt     = 0;
      out_wr_prep2_nxt     = out_wr_prep2;
      out_wr_prep3_nxt     = out_wr_prep3;
      out_wr_nxt           = 0;

      in_fifo_ctrl_d1_nxt  = in_fifo_ctrl_d1;
      in_fifo_ctrl_d2_nxt  = in_fifo_ctrl_d2;
      in_fifo_ctrl_d3_nxt  = in_fifo_ctrl_d3;
      out_ctrl_nxt         = out_ctrl;

      in_fifo_data_d1_nxt  = in_fifo_data_d1;
      out_data_ioq_nxt     = out_data_ioq;
      in_fifo_data_d2_nxt  = in_fifo_data_d2;
      in_fifo_data_d3_nxt  = in_fifo_data_d3;

      out_data_enb         = 0;

      pkts_dropped_nxt     = 0;
      vlan_proc_done_nxt   = vlan_proc_done;
      hdr_replace_cntr_nxt = hdr_replace_cntr;

      is_ip_nxt            = is_ip;
      is_udp_nxt           = is_udp;
      is_tcp_nxt           = is_tcp;

      ip_hdr_len_nxt       = ip_hdr_len;
      last_word_cnt_nxt    = last_word_cnt;

      wildcard_wins        = 0;
      wildcard_lose        = 0;
      
      case (state)
         /* wait until the lookup is done and we have the actions we
          * need to do
          */
         WAIT_FOR_INPUT: begin
            if (!result_fifo_empty) begin
               result_fifo_rd_en = 1;
               state_nxt         = WRITE_REPLACEMENTS;
            end
         end

         /* check if an output is specified
          */
         WRITE_REPLACEMENTS: begin
            /* Initialize parameters
             */
            vlan_proc_done_nxt   = 0;
            hdr_replace_cntr_nxt = HDR_2ND;
            is_ip_nxt            = 0;
            is_udp_nxt           = 0;
            is_tcp_nxt           = 0;
            ip_hdr_len_nxt       = 0;
            last_word_cnt_nxt    = 0;
            /* no destination so drop packet
             */
            /*if (forward_bitmask == 0) begin
               state_nxt = DROP_PKT;
            end
            else*/ if (out_rdy) begin
               state_nxt = WRITE_OUTPUT_DESTINATION;
            end
         end // case: WRITE_REPLACEMENTS

         /* write out all the module headers and search for the
          * I/O queue header to insert the destination output queues
          */
         WRITE_OUTPUT_DESTINATION: begin
            if (out_rdy && !in_fifo_empty) begin
               in_fifo_rd_en       = 1'b1;

               out_wr_prep1_nxt    = 1'b1;
               out_wr_prep2_nxt    = out_wr_prep1;
               out_wr_prep3_nxt    = out_wr_prep2;
               out_wr_nxt          = out_wr_prep3;

               in_fifo_ctrl_d1_nxt = in_fifo_ctrl;
               in_fifo_ctrl_d2_nxt = in_fifo_ctrl_d1;
               in_fifo_ctrl_d3_nxt = in_fifo_ctrl_d2;
               out_ctrl_nxt        = in_fifo_ctrl_d3;

               in_fifo_data_d1_nxt = in_fifo_data;
               out_data_ioq_nxt    = in_fifo_data;
               in_fifo_data_d2_nxt = in_fifo_data_d1;
               in_fifo_data_d3_nxt = in_fifo_data_d2;

               out_data_enb        = 1;

               if (in_fifo_ctrl == `VLAN_CTRL_WORD) begin
                  /* Check if we need to do something about VLAN tag.
                   * We'll stay this state to wait for IOQ at the next clock
                   */
                  if (nf2_action_flag & `NF2_OFPAT_STRIP_VLAN) begin
                     /* Invalidate VLAN tag
                      */
                     in_fifo_ctrl_d1_nxt = 8'hEF;
                  end
                  else begin
                     /* Replace VLAN tag resided in a module header
                      * VLAN tag module header comes BEFORE IO_QUEUE header
                      */
                     if (nf2_action_flag & `NF2_OFPAT_SET_VLAN_VID) begin
                        in_fifo_data_d1_nxt[11:0] = set_vlan_vid[11:0];
                     end
                     if (nf2_action_flag & `NF2_OFPAT_SET_VLAN_PCP) begin
                        in_fifo_data_d1_nxt[15:13] = set_vlan_pcp[2:0];
                     end
                  end
                  vlan_proc_done_nxt = 1;
               end
               else if (in_fifo_ctrl == `IO_QUEUE_STAGE_NUM) begin
                  if ((vlan_proc_done != 1) &&
                     ((nf2_action_flag & `NF2_OFPAT_SET_VLAN_VID) ||
                      (nf2_action_flag & `NF2_OFPAT_SET_VLAN_PCP))) begin
                     /* replace one word(data/ctrl) with VLAN_CTRL_HDR
                      */
                     in_fifo_ctrl_d1_nxt = `VLAN_CTRL_WORD;
                     in_fifo_data_d1_nxt = 0;
                     wildcard_lose = 1;
                     if (nf2_action_flag & `NF2_OFPAT_SET_VLAN_VID) begin
                        in_fifo_data_d1_nxt[11:0] = set_vlan_vid[11:0];
                     end
                     if (nf2_action_flag & `NF2_OFPAT_SET_VLAN_PCP) begin
                        in_fifo_data_d1_nxt[15:13] = set_vlan_pcp[2:0];
                     end
                     vlan_proc_done_nxt = 1;
                     state_nxt = WRITE_IO_HDR;
                  end
                  else begin
                     /* nothing to do about VLAN tagging.
                      * Set output port on IOQ
                      */
                     if(pkt_dst_table_id == CURRENT_TABLE_ID) begin
                        if(nf2_action_flag & `NF2_OFPAT_OUTPUT)
                           in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+15:`IOQ_DST_PORT_POS] = in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+15:`IOQ_DST_PORT_POS] | forward_bitmask;
                        if(nf2_action_flag & `NF2_OFPAT_METER)
                           in_fifo_data_d1_nxt[`IOQ_METER_ID_POS +:`IOQ_METER_ID_LEN] = meter_id;
                        else if(in_fifo_data[`IOQ_METER_ID_POS +:`IOQ_METER_ID_LEN] == 0) in_fifo_data_d1_nxt[`IOQ_METER_ID_POS +:`IOQ_METER_ID_LEN] = 1;
                        if(nf2_action_flag & `NF2_OFPAT_GOTO_TABLE)
                           in_fifo_data_d1_nxt[`IOQ_DST_TABLE_ID_POS +:`IOQ_DST_TABLE_ID_LEN] = next_table_id;
                        else in_fifo_data_d1_nxt[`IOQ_DST_TABLE_ID_POS +:`IOQ_DST_TABLE_ID_LEN] = 8'hFF;
                        if(nf2_action_flag == 0) begin
                           in_fifo_data_d1_nxt[`IOQ_DST_TABLE_ID_POS +:`IOQ_DST_TABLE_ID_LEN] = CURRENT_TABLE_ID + 1; //go to next table as default.
                           wildcard_lose = 1;
                        end
                        else wildcard_wins = 1;
                        state_nxt = HDR_1ST;
                     end
                     else if(pkt_dst_table_id > CURRENT_TABLE_ID) begin
                        wildcard_lose = 1;
                        state_nxt = WRITE_PACKET;
                     end
                     else state_nxt = DROP_PKT;
                  end
               end
               // synthesis translate_off
               else if (in_fifo_ctrl==0 || in_fifo_empty) begin
                  $display ("%t %m ERROR: Could not find IOQ module header", $time);
                  $stop;
               end
               // synthesis translate_on
            end // if (out_rdy && !in_fifo_empty)
         end // case: WRITE_OUTPUT_DESTINATION

         /* Supplemental process when vlan tag is added.
          * Stop reading from FIFO and write out the stored data(containing IOQ)
          */
         WRITE_IO_HDR: begin
            if (out_rdy) begin
               out_wr_prep1_nxt    = 1'b1;
               out_wr_prep2_nxt    = out_wr_prep1;
               out_wr_prep3_nxt    = out_wr_prep2;
               out_wr_nxt          = out_wr_prep3;

               in_fifo_ctrl_d1_nxt = `IO_QUEUE_STAGE_NUM;
               in_fifo_ctrl_d2_nxt = in_fifo_ctrl_d1;
               in_fifo_ctrl_d3_nxt = in_fifo_ctrl_d2;
               out_ctrl_nxt        = in_fifo_ctrl_d3;

               in_fifo_data_d1_nxt = out_data_ioq;
               in_fifo_data_d1_nxt[`IOQ_DST_PORT_POS+15:`IOQ_DST_PORT_POS]
                   = forward_bitmask;
               in_fifo_data_d2_nxt = in_fifo_data_d1;
               in_fifo_data_d3_nxt = in_fifo_data_d2;

               out_data_enb        = 1;

               state_nxt           = HDR_1ST;
            end
         end // case: WRITE_IO_HDR

         /* All the other replacement processes will be done in
          * the other state machine. From here, we check the type and
          * length of each packet
          */
         HDR_1ST: begin
            if (out_rdy && !in_fifo_empty) begin
               in_fifo_rd_en       = 1'b1;

               out_wr_prep1_nxt    = 1'b1;
               out_wr_prep2_nxt    = out_wr_prep1;
               out_wr_prep3_nxt    = out_wr_prep2;
               out_wr_nxt          = out_wr_prep3;

               in_fifo_ctrl_d1_nxt = in_fifo_ctrl;
               in_fifo_ctrl_d2_nxt = in_fifo_ctrl_d1;
               in_fifo_ctrl_d3_nxt = in_fifo_ctrl_d2;
               out_ctrl_nxt        = in_fifo_ctrl_d3;

               in_fifo_data_d1_nxt = in_fifo_data;
               in_fifo_data_d2_nxt = in_fifo_data_d1;
               in_fifo_data_d3_nxt = in_fifo_data_d2;

               out_data_enb        = 1;

               if (in_fifo_ctrl == 0) begin
                  hdr_replace_cntr_nxt = HDR_2ND;
                  state_nxt            = HDR_CONT;
               end
               else if (is_eop) begin
                  state_nxt            = WRITE_LAST_WORD;
               end
            end // if (out_rdy && !in_fifo_empty)
         end // case: HDR_1ST

         HDR_CONT: begin
            if (out_rdy && !in_fifo_empty) begin
               in_fifo_rd_en       = 1'b1;

               out_wr_prep1_nxt    = 1'b1;
               out_wr_prep2_nxt    = out_wr_prep1;
               out_wr_prep3_nxt    = out_wr_prep2;
               out_wr_nxt          = out_wr_prep3;

               in_fifo_ctrl_d1_nxt = in_fifo_ctrl;
               in_fifo_ctrl_d2_nxt = in_fifo_ctrl_d1;
               in_fifo_ctrl_d3_nxt = in_fifo_ctrl_d2;
               out_ctrl_nxt        = in_fifo_ctrl_d3;

               in_fifo_data_d1_nxt = in_fifo_data;
               in_fifo_data_d2_nxt = in_fifo_data_d1;
               in_fifo_data_d3_nxt = in_fifo_data_d2;

               out_data_enb        = 1;

               /* If 'end of the packet' is detected,
                * goto the last state in any case
                * at the next clock
                */
               if (is_eop) begin
                  state_nxt = WRITE_LAST_WORD;
               end

               case (hdr_replace_cntr)
                  HDR_2ND: begin
                     /* Get ether_type and ip_hdr_length
                      */
                     if (in_fifo_data[31:16] == TYPE_IP) begin
                        is_ip_nxt = 1;
                     end
                     ip_hdr_len_nxt = in_fifo_data[11:8];
                     hdr_replace_cntr_nxt = HDR_3RD;
                  end
                  HDR_3RD: begin
                     /* Get TP type
                      */
                     if (is_ip) begin
                        if (in_fifo_data[7:0] == TYPE_UDP) begin
                           is_udp_nxt = 1;
                        end
                        else if (in_fifo_data[7:0] == TYPE_TCP) begin
                           is_tcp_nxt = 1;
                        end
                     end
                     hdr_replace_cntr_nxt = HDR_4TH;
                  end
                  HDR_4TH: begin
                     /* Nothing to do
                      */
                     hdr_replace_cntr_nxt = HDR_5TH;
                  end
                  HDR_5TH: begin
                     /* Start decrementing IP length
                      * until it reaches 5 or 6
                      */
                     if (!is_ip || (ip_hdr_len < 7)) begin
                        if (!is_eop) begin
                           state_nxt = WRITE_PACKET;
                        end
                     end
                     else begin
                       ip_hdr_len_nxt = ip_hdr_len - 2;
                       hdr_replace_cntr_nxt = HDR_6TH;
                     end
                  end
                  HDR_6TH: begin
                     /* Continue decrementing IP length and
                      * wait until it reaches 5 or 6
                      */
                     if (ip_hdr_len < 7) begin
                        if (!is_eop) begin
                           state_nxt = WRITE_PACKET;
                        end
                     end
                     else begin
                       ip_hdr_len_nxt = ip_hdr_len - 2;
                     end
                  end
               endcase
            end // if (out_rdy && !in_fifo_empty)
         end // case: HDR_CONT

         /* write the rest of the packet data
          */
         WRITE_PACKET: begin
            if (out_rdy && !in_fifo_empty) begin
               in_fifo_rd_en       = 1'b1;

               out_wr_prep1_nxt    = 1'b1;
               out_wr_prep2_nxt    = out_wr_prep1;
               out_wr_prep3_nxt    = out_wr_prep2;
               out_wr_nxt          = out_wr_prep3;

               in_fifo_ctrl_d1_nxt = in_fifo_ctrl;
               in_fifo_ctrl_d2_nxt = in_fifo_ctrl_d1;
               in_fifo_ctrl_d3_nxt = in_fifo_ctrl_d2;
               out_ctrl_nxt        = in_fifo_ctrl_d3;

               in_fifo_data_d1_nxt = in_fifo_data;
               in_fifo_data_d2_nxt = in_fifo_data_d1;
               in_fifo_data_d3_nxt = in_fifo_data_d2;

               out_data_enb        = 1;

               if (is_eop) begin
                  state_nxt = WRITE_LAST_WORD;
               end
            end // if (out_rdy)
         end // case: WRITE_PACKET

         /* drop the packet
          */
         DROP_PKT: begin
            if (!in_fifo_empty) begin
               in_fifo_rd_en       = 1'b1;
               in_fifo_ctrl_d1_nxt = in_fifo_ctrl;

               if (is_eop) begin
                  pkts_dropped_nxt = src_port_decoded;
                  if (!result_fifo_empty) begin
                     result_fifo_rd_en = 1;
                     state_nxt         = WRITE_REPLACEMENTS;
                  end
                  else begin
                     state_nxt = WAIT_FOR_INPUT;
                  end
               end
            end // if (!in_fifo_empty)
         end // case: DROP_PKT

         /* push out buffered words
          */
         WRITE_LAST_WORD: begin
            if (out_rdy) begin
               out_wr_prep1_nxt    = 0;
               out_wr_prep2_nxt    = 0;
               out_wr_prep3_nxt    = 0;
               out_wr_nxt          = 1'b1;

               in_fifo_ctrl_d2_nxt = in_fifo_ctrl_d1;
               in_fifo_ctrl_d3_nxt = in_fifo_ctrl_d2;
               out_ctrl_nxt        = in_fifo_ctrl_d3;

               in_fifo_data_d2_nxt = in_fifo_data_d1;
               in_fifo_data_d3_nxt = in_fifo_data_d2;

               out_data_enb        = 1;

               if (last_word_cnt < 2) begin
                  last_word_cnt_nxt = last_word_cnt + 1;
               end
               else begin
                  if (!result_fifo_empty) begin
                     result_fifo_rd_en = 1;
                     state_nxt         = WRITE_REPLACEMENTS;
                  end
                  else begin
                     state_nxt = WAIT_FOR_INPUT;
                  end
               end

            end
         end // case: WRITE_LAST_WORD
      endcase // case(state)
   end // always @ (*)

   always @(posedge clk) begin
      if (reset) begin
         state            <= WAIT_FOR_INPUT;

         out_wr_prep1     <= 0;
         out_wr_prep2     <= 0;
         out_wr_prep3     <= 0;
         out_wr           <= 0;

         in_fifo_ctrl_d1  <= 1;
         in_fifo_ctrl_d2  <= 1;
         in_fifo_ctrl_d3  <= 1;
         out_ctrl         <= 1;

         in_fifo_data_d1  <= 0;
         out_data_ioq     <= 0;
         in_fifo_data_d2  <= 0;
         in_fifo_data_d3  <= 0;

         pkts_dropped     <= 0;
         vlan_proc_done   <= 0;
         hdr_replace_cntr <= HDR_2ND;

         is_ip            <= 0;
         is_udp           <= 0;
         is_tcp           <= 0;

         ip_hdr_len       <= 0;
         last_word_cnt    <= 0;
      end
      else begin
         state            <= state_nxt;

         out_wr_prep1     <= out_wr_prep1_nxt;
         out_wr_prep2     <= out_wr_prep2_nxt;
         out_wr_prep3     <= out_wr_prep3_nxt;
         out_wr           <= out_wr_nxt;

         in_fifo_ctrl_d1  <= in_fifo_ctrl_d1_nxt;
         in_fifo_ctrl_d2  <= in_fifo_ctrl_d2_nxt;
         in_fifo_ctrl_d3  <= in_fifo_ctrl_d3_nxt;
         out_ctrl         <= out_ctrl_nxt;

         in_fifo_data_d1  <= in_fifo_data_d1_nxt;
         out_data_ioq     <= out_data_ioq_nxt;
         in_fifo_data_d2  <= in_fifo_data_d2_nxt;
         in_fifo_data_d3  <= in_fifo_data_d3_nxt;

         pkts_dropped     <= pkts_dropped_nxt;
         vlan_proc_done   <= vlan_proc_done_nxt;
         hdr_replace_cntr <= hdr_replace_cntr_nxt;

         is_ip            <= is_ip_nxt;
         is_udp           <= is_udp_nxt;
         is_tcp           <= is_tcp_nxt;

         ip_hdr_len       <= ip_hdr_len_nxt;
         last_word_cnt    <= last_word_cnt_nxt;
      end // else: !if (reset)
   end // always @ (posedge clk)


   /* This state machine handles IP header parsing,
    * UDP/TCP header parsing, recalculates IP and
    * UDP/TCP checksums.
    * It also handles overwriting L2, IP, UDP/TCP
    * fields if those actions are required.
    * RFC1624 is used for checksum recalculation.
    * NewChecksum
    *  =  ~(~OldChecksum
    *       + (~OldData1 + NewData1) + ... + (~OldDataX + NewDataX))
    */
   always @(*) begin

      post_state_nxt  = post_state;
      tp_hdr_cntr_nxt = tp_hdr_cntr;
      ip_hdr_cntr_nxt = ip_hdr_cntr;

      nw_src_h_diff_nxt = nw_src_h_diff;
      nw_src_l_diff_nxt = nw_src_l_diff;
      nw_src_diff_nxt   = nw_src_diff;
      nw_dst_h_diff_nxt = nw_dst_h_diff;
      nw_dst_l_diff_nxt = nw_dst_l_diff;
      nw_dst_diff_nxt   = nw_dst_diff;
      nw_all_diff_nxt   = nw_all_diff;
      nw_chksum_new_nxt = nw_chksum_new;

      tp_src_diff_nxt       = tp_src_diff;
      tp_dst_diff_nxt       = tp_dst_diff;
      tp_chksum_org_inv_nxt = tp_chksum_org_inv;
      tp_chksum_new_nxt     = tp_chksum_new;

      if (out_data_enb) begin
         out_data_nxt = in_fifo_data_d3;
      end
      else begin
         out_data_nxt = out_data;
      end

      case (post_state)

         FOLLOW_PREP_STATE: begin
            tp_hdr_cntr_nxt = TP_HDR_2_ODD;
            ip_hdr_cntr_nxt = IP_HDR_REST_1;

            if ((state == HDR_CONT) && out_data_enb) begin
               case (hdr_replace_cntr)
                  HDR_2ND: begin
                     /* -- NW header handling -- */
                     /* Diff 16bit-width tos field, store it and fold.
                      * We use only 6bits of the field
                      */
                     if (nf2_action_flag & `NF2_OFPAT_SET_NW_TOS) begin
                        nw_chksum_new_nxt = {10'h00, set_nw_tos[7:2], 2'b00}
                                          + {10'hFF, ~(in_fifo_data[7:2]), 2'b11};
                        nw_chksum_new_nxt = {2'b00, nw_chksum_new_nxt[15:0]}
                                          + {16'h0, nw_chksum_new_nxt[17:16]};
                     end
                     else begin
                        nw_chksum_new_nxt = 0;
                     end
                  end

                  HDR_4TH: begin
                     /* -- DL header handlilng -- */
                     /* Overwrite new values if requested
                      */
                     if (nf2_action_flag & `NF2_OFPAT_SET_DL_DST) begin
                        out_data_nxt[63:16] = set_dl_dst;
                     end
                     if (nf2_action_flag & `NF2_OFPAT_SET_DL_SRC) begin
                        out_data_nxt[15:0] = set_dl_src[47:32];
                     end

                     /* -- NW header handling -- */
                     nw_chksum_new_nxt = nw_chksum_new
                                       + {2'b00, ~in_fifo_data[63:48]};
                     nw_chksum_new_nxt = {2'b00, nw_chksum_new_nxt[15:0]}
                                       + {16'h0, nw_chksum_new_nxt[17:16]};
                     /* Diff NW src address, store it and fold
                      */
                     if (nf2_action_flag & `NF2_OFPAT_SET_NW_SRC) begin
                        nw_src_h_diff_nxt = {1'b0, set_nw_src[31:16]}
                                          + {1'b0, ~(in_fifo_data[47:32])};
                        nw_src_h_diff_nxt = {1'b0, nw_src_h_diff_nxt[15:0]}
                                          + {16'h0, nw_src_h_diff_nxt[16]};
                        nw_src_l_diff_nxt = {1'b0, set_nw_src[15:0]}
                                          + {1'b0, ~(in_fifo_data[31:16])};
                        nw_src_l_diff_nxt = {1'b0, nw_src_l_diff_nxt[15:0]}
                                          + {16'h0, nw_src_l_diff_nxt[16]};
                     end
                     else begin
                        nw_src_h_diff_nxt = 0;
                        nw_src_l_diff_nxt = 0;
                     end
                     /* Diff higher half of NW dst address, store it and fold
                      */
                     if (nf2_action_flag & `NF2_OFPAT_SET_NW_DST) begin
                        nw_dst_h_diff_nxt = {1'b0, set_nw_dst[31:16]}
                                          + {1'b0, ~(in_fifo_data[15:0])};
                        nw_dst_h_diff_nxt = {1'b0, nw_dst_h_diff_nxt[15:0]}
                                          + {16'h0, nw_dst_h_diff_nxt[16]};
                     end
                     else begin
                        nw_dst_h_diff_nxt = 0;
                     end
                  end

                  HDR_5TH: begin
                     /* -- DL header handling -- */
                     /* Overwrite new values if requested
                      */
                     if (nf2_action_flag & `NF2_OFPAT_SET_DL_SRC) begin
                        out_data_nxt[63:32] = set_dl_src[31:0];
                     end

                     /* -- NW header handling -- */
                     nw_chksum_new_nxt = nw_chksum_new
                                       + {1'b0, nw_dst_h_diff};
                     nw_chksum_new_nxt = {2'b00, nw_chksum_new_nxt[15:0]}
                                       + {16'h0, nw_chksum_new_nxt[17:16]};
                     /* Add up diff'ed info and fold
                      */
                     nw_src_diff_nxt = nw_src_l_diff + nw_src_h_diff;
                     nw_src_diff_nxt = {1'b0, nw_src_diff_nxt[15:0]}
                                     + {16'h0, nw_src_diff_nxt[16]};
                     /* Diff lower half of NW dst address, store it and fold
                      */
                     if (nf2_action_flag & `NF2_OFPAT_SET_NW_DST) begin
                        nw_dst_l_diff_nxt = {1'b0, set_nw_dst[15:0]}
                                          + {1'b0, ~(in_fifo_data[63:48])};
                        nw_dst_l_diff_nxt = {1'b0, nw_dst_l_diff_nxt[15:0]}
                                          + {16'h0, nw_dst_l_diff_nxt[16]};
                     end
                     else begin
                        nw_dst_l_diff_nxt = 0;
                     end

                     /* Overwrite new values if requested
                      */
                     if (is_ip) begin
                        if (nf2_action_flag & `NF2_OFPAT_SET_NW_TOS) begin
                           // We replace only 6bits of the TOS field
                           out_data_nxt[7:2] = set_nw_tos[7:2];
                        end
                     end

                     /* -- TP header handling -- */
                     if (ip_hdr_len == 5) begin
                        /* Diff each field, store it and fold
                         */
                        if (nf2_action_flag & `NF2_OFPAT_SET_TP_SRC) begin
                           tp_src_diff_nxt = {1'b0, set_tp_src}
                                           + {1'b0, ~(in_fifo_data[47:32])};
                           tp_src_diff_nxt = {1'b0, tp_src_diff_nxt[15:0]}
                                           + {16'h0, tp_src_diff_nxt[16]};
                        end
                        else begin
                           tp_src_diff_nxt = 0;
                        end
                        if (nf2_action_flag & `NF2_OFPAT_SET_TP_DST) begin
                           tp_dst_diff_nxt = {1'b0, set_tp_dst}
                                           + {1'b0, ~(in_fifo_data[31:16])};
                           tp_dst_diff_nxt = {1'b0, tp_dst_diff_nxt[15:0]}
                                           + {16'h0, tp_dst_diff_nxt[16]};
                        end
                        else begin
                           tp_dst_diff_nxt = 0;
                        end

                        tp_hdr_cntr_nxt = TP_HDR_2_ODD;
                     end
                     else if (ip_hdr_len == 6) begin
                        /* Diff each field, store it and fold
                         */
                        if (nf2_action_flag & `NF2_OFPAT_SET_TP_SRC) begin
                           tp_src_diff_nxt = {1'b0, set_tp_src}
                                           + {1'b0, ~(in_fifo_data[15:0])};
                           tp_src_diff_nxt = {1'b0, tp_src_diff_nxt[15:0]}
                                           + {16'h0, tp_src_diff_nxt[16]};
                        end
                        else begin
                           tp_src_diff_nxt = 0;
                        end

                        tp_hdr_cntr_nxt = TP_HDR_2_EVN;
                     end
                     else begin
                        /* Packet has more than one option.
                           Present data doesn't contain TP header.
                           Diff nothing here
                         */
                        tp_hdr_cntr_nxt = TP_HDR_WAIT;
                     end

                     ip_hdr_cntr_nxt = IP_HDR_REST_1;
                     post_state_nxt  = REPLACE_REST;
                  end
               endcase
            end
         end

         REPLACE_REST: begin
            if (state == WRITE_REPLACEMENTS) begin
               post_state_nxt = FOLLOW_PREP_STATE;
            end
            else if (out_data_enb) begin
               /* Here we need two interal state machines
                * to insulate IP header option length variance
                */
               case (ip_hdr_cntr)
                  IP_HDR_REST_1: begin
                     /* Add up each diff'ed info and fold once
                      */
                     nw_chksum_new_nxt = nw_chksum_new
                                       + {1'b0, nw_dst_l_diff}
                                       + {1'b0, nw_src_diff};
                     nw_chksum_new_nxt = {2'b00, nw_chksum_new_nxt[15:0]}
                                       + {16'h0, nw_chksum_new_nxt[17:16]};

                     /* This is needed to calculate TP layer checksum
                      */
                     nw_dst_diff_nxt = nw_dst_l_diff + nw_dst_h_diff;
                     nw_dst_diff_nxt = {1'b0, nw_dst_diff_nxt[15:0]}
                                     + {16'h0, nw_dst_diff_nxt[16]};

                     ip_hdr_cntr_nxt = IP_HDR_REST_2;
                  end

                  IP_HDR_REST_2: begin
                     /* Fold agin and write out new NW checksum.
                        Also overwrite other fields if requested
                      */
                     nw_chksum_new_nxt = {2'b00, nw_chksum_new_nxt[15:0]}
                                       + {16'h0, nw_chksum_new_nxt[17:16]};
                     if (is_ip) begin
                        out_data_nxt[63:48] = ~(nw_chksum_new_nxt[15:0]);
                        if (nf2_action_flag & `NF2_OFPAT_SET_NW_SRC) begin
                           out_data_nxt[47:16] = set_nw_src;
                        end
                        if (nf2_action_flag & `NF2_OFPAT_SET_NW_DST) begin
                           out_data_nxt[15:0] = set_nw_dst[31:16];
                        end
                     end

                     /* This is needed to calculate TP layer checksum
                      */
                     nw_all_diff_nxt = nw_dst_diff + nw_src_diff;
                     nw_all_diff_nxt = {1'b0, nw_all_diff_nxt[15:0]}
                                     + {16'h0, nw_all_diff_nxt[16]};

                     ip_hdr_cntr_nxt = IP_HDR_REST_3;
                  end

                  IP_HDR_REST_3: begin
                     /* Overwrite new value if requested
                      */
                     if (is_ip) begin
                        if (nf2_action_flag & `NF2_OFPAT_SET_NW_DST) begin
                           out_data_nxt[63:48] = set_nw_dst[15:0];
                        end
                     end

                     ip_hdr_cntr_nxt = IP_HDR_STOP;
                  end

                  IP_HDR_STOP: begin
                     /* IP header handling has been finished and do nothing
                      * here. Wait for the other internal state machine
                      */
                     ip_hdr_cntr_nxt = IP_HDR_STOP;
                  end
               endcase

               case (tp_hdr_cntr)
                  TP_HDR_WAIT: begin
                     if (ip_hdr_len == 5) begin
                        /* Diff each field, store it and fold
                         */
                        if (nf2_action_flag & `NF2_OFPAT_SET_TP_SRC) begin
                           tp_src_diff_nxt = {1'b0, set_tp_src}
                                           + {1'b0, ~(in_fifo_data[47:32])};
                           tp_src_diff_nxt = {1'b0, tp_src_diff_nxt[15:0]}
                                           + {16'h0, tp_src_diff_nxt[16]};
                        end
                        else begin
                           tp_src_diff_nxt = 0;
                        end
                        if (nf2_action_flag & `NF2_OFPAT_SET_TP_DST) begin
                           tp_dst_diff_nxt = {1'b0, set_tp_dst}
                                           + {1'b0, ~(in_fifo_data[31:16])};
                           tp_dst_diff_nxt = {1'b0, tp_dst_diff_nxt[15:0]}
                                           + {16'h0, tp_dst_diff_nxt[16]};
                        end
                        else begin
                           tp_dst_diff_nxt = 0;
                        end

                        tp_hdr_cntr_nxt = TP_HDR_2_ODD;
                     end
                     else if (ip_hdr_len == 6) begin
                        /* Diff field, store it and fold
                         */
                        if (nf2_action_flag & `NF2_OFPAT_SET_TP_SRC) begin
                           tp_src_diff_nxt = {1'b0, set_tp_src}
                                           + {1'b0, ~(in_fifo_data[15:0])};
                           tp_src_diff_nxt = {1'b0, tp_src_diff_nxt[15:0]}
                                           + {16'h0, tp_src_diff_nxt[16]};
                        end
                        else begin
                           tp_src_diff_nxt = 0;
                        end

                        tp_hdr_cntr_nxt = TP_HDR_2_EVN;
                     end
                     else begin
                        /* Packet still has more than one option,
                         * meaning present data doesn't contain TP header.
                         * Wait for the last word of IP header
                         */
                        tp_hdr_cntr_nxt = TP_HDR_WAIT;
                     end
                  end

                  TP_HDR_2_ODD: begin
                     if (is_udp) begin
                        tp_chksum_org_inv_nxt = ~in_fifo_data[63:48];
                     end

                     /* Add diff'ed info and fold it
                      */
                     tp_chksum_new_nxt = tp_src_diff + tp_dst_diff;
                     tp_chksum_new_nxt = {1'b0, tp_chksum_new_nxt[15:0]}
                                       + {16'h0, tp_chksum_new_nxt[16]};

                     tp_hdr_cntr_nxt = TP_HDR_3_ODD;
                  end

                  TP_HDR_3_ODD: begin
                     if (is_tcp) begin
                        tp_chksum_org_inv_nxt = ~in_fifo_data[47:32];
                     end

                     /* Add diff'ed info and fold it
                      */
                     tp_chksum_new_nxt = tp_chksum_new
                                       + {1'b0, tp_chksum_org_inv_nxt};
                     tp_chksum_new_nxt = {1'b0, tp_chksum_new_nxt[15:0]}
                                       + {16'h0, tp_chksum_new_nxt[16]};

                     tp_hdr_cntr_nxt = TP_HDR_4_ODD;
                  end

                  TP_HDR_4_ODD: begin
                     /* Add diff'ed info and fold it
                      */
                     tp_chksum_new_nxt = tp_chksum_new + nw_all_diff;
                     tp_chksum_new_nxt = {1'b0, tp_chksum_new_nxt[15:0]}
                                       + {16'h0, tp_chksum_new_nxt[16]};

                     /* Overwrite new values if requested
                      */
                     if (is_udp || is_tcp) begin
                        if (nf2_action_flag & `NF2_OFPAT_SET_TP_SRC) begin
                           out_data_nxt[47:32] = set_tp_src;
                        end
                        if (nf2_action_flag & `NF2_OFPAT_SET_TP_DST) begin
                           out_data_nxt[31:16] = set_tp_dst;
                        end
                     end

                     tp_hdr_cntr_nxt = TP_HDR_5_ODD;
                  end

                  TP_HDR_5_ODD: begin
                     /* Overwrite new values if requested and if it is UDP.
                      * If it is UDP, the modification process will finish
                      * here
                      */
                     if (is_udp) begin
                        out_data_nxt[63:48] = ~(tp_chksum_new[15:0]);
                        post_state_nxt = FOLLOW_PREP_STATE;
                     end
                     else begin
                        tp_hdr_cntr_nxt = TP_HDR_6_ODD;
                     end
                  end

                  TP_HDR_6_ODD: begin
                     /* Overwrite new values if requested and if it is TCP.
                      * The modification process will finish here anyway
                      */
                     if (is_tcp) begin
                        out_data_nxt[47:32] = ~(tp_chksum_new[15:0]);
                     end
                     post_state_nxt = FOLLOW_PREP_STATE;
                  end

                  TP_HDR_2_EVN: begin
                     if (is_udp) begin
                        tp_chksum_org_inv_nxt = ~in_fifo_data[31:16];
                     end

                     /* Diff a field, store it and fold
                      */
                     if (nf2_action_flag & `NF2_OFPAT_SET_TP_DST) begin
                        tp_dst_diff_nxt = {1'b0, set_tp_dst}
                                        + {1'b0, ~(in_fifo_data[63:48])};
                        tp_dst_diff_nxt = {1'b0, tp_dst_diff_nxt[15:0]}
                                        + {16'h0, tp_dst_diff_nxt[16]};
                     end
                     else begin
                        tp_dst_diff_nxt = 0;
                     end

                     tp_hdr_cntr_nxt = TP_HDR_3_EVN;
                  end

                  TP_HDR_3_EVN: begin
                     if (is_tcp) begin
                        tp_chksum_org_inv_nxt = ~in_fifo_data[15:0];
                     end

                     /* Add diff'ed info and fold it
                      */
                     tp_chksum_new_nxt = tp_src_diff + tp_dst_diff;
                     tp_chksum_new_nxt = {1'b0, tp_chksum_new_nxt[15:0]}
                                       + {16'h0, tp_chksum_new_nxt[16]};

                     tp_hdr_cntr_nxt = TP_HDR_4_EVN;
                  end

                  TP_HDR_4_EVN: begin
                     /* Add diff'ed info and fold it
                      */
                     tp_chksum_new_nxt = tp_chksum_new
                                       + {1'b0, tp_chksum_org_inv};
                     tp_chksum_new_nxt = {1'b0, tp_chksum_new_nxt[15:0]}
                                       + {16'h0, tp_chksum_new_nxt[16]};

                     /* Overwrite new values if requested and if it is TCP/UDP
                      */
                     if (is_udp || is_tcp) begin
                        if (nf2_action_flag & `NF2_OFPAT_SET_TP_SRC) begin
                           out_data_nxt[15:0] = set_tp_src;
                        end
                     end

                     tp_hdr_cntr_nxt = TP_HDR_5_EVN;
                  end

                  TP_HDR_5_EVN: begin
                     /* Diff a field, store it and fold
                      */
                     tp_chksum_new_nxt = tp_chksum_new + nw_all_diff;
                     tp_chksum_new_nxt = {1'b0, tp_chksum_new_nxt[15:0]}
                                       + {16'h0, tp_chksum_new_nxt[16]};

                     /* Overwrite new values if requested and if it is TCP/UDP.
                      */
                     if (is_udp || is_tcp) begin
                        if (nf2_action_flag & `NF2_OFPAT_SET_TP_DST) begin
                           out_data_nxt[63:48] = set_tp_dst;
                        end
                     end

                     /* Overwrite new values if requested and if it is UDP.
                      * If it is UDP, the modification process will finish
                      * here
                      */
                     if (is_udp) begin
                        out_data_nxt[31:16] = ~(tp_chksum_new_nxt[15:0]);
                        post_state_nxt = FOLLOW_PREP_STATE;
                     end
                     else begin
                        tp_hdr_cntr_nxt = TP_HDR_6_EVN;
                     end
                  end

                  TP_HDR_6_EVN: begin
                     /* Overwrite new values if requested and if it is TCP.
                      * The modification process will finish here anyway
                      */
                     if (is_tcp) begin
                        out_data_nxt[15:0] = ~(tp_chksum_new[15:0]);
                     end
                     post_state_nxt = FOLLOW_PREP_STATE;
                  end
               endcase
            end
         end
      endcase
   end

   always @(posedge clk) begin
      if (reset) begin
         post_state <= FOLLOW_PREP_STATE;
         tp_hdr_cntr <= TP_HDR_2_ODD;
         ip_hdr_cntr <= IP_HDR_REST_1;

         out_data <= 0;

         nw_src_h_diff <= 0;
         nw_src_l_diff <= 0;
         nw_src_diff   <= 0;
         nw_dst_h_diff <= 0;
         nw_dst_l_diff <= 0;
         nw_dst_diff   <= 0;
         nw_all_diff   <= 0;
         nw_chksum_new <= 0;

         tp_src_diff       <= 0;
         tp_dst_diff       <= 0;
         tp_chksum_org_inv <= 0;
         tp_chksum_new     <= 0;
      end
      else begin
         post_state  <= post_state_nxt;
         tp_hdr_cntr <= tp_hdr_cntr_nxt;
         ip_hdr_cntr <= ip_hdr_cntr_nxt;

         out_data <= out_data_nxt;

         nw_src_h_diff <= nw_src_h_diff_nxt;
         nw_src_l_diff <= nw_src_l_diff_nxt;
         nw_src_diff   <= nw_src_diff_nxt;
         nw_dst_h_diff <= nw_dst_h_diff_nxt;
         nw_dst_l_diff <= nw_dst_l_diff_nxt;
         nw_dst_diff   <= nw_dst_diff_nxt;
         nw_all_diff   <= nw_all_diff_nxt;
         nw_chksum_new <= nw_chksum_new_nxt;

         tp_src_diff       <= tp_src_diff_nxt;
         tp_dst_diff       <= tp_dst_diff_nxt;
         tp_chksum_org_inv <= tp_chksum_org_inv_nxt;
         tp_chksum_new     <= tp_chksum_new_nxt;
      end
   end

   
   wire [73:0] debug_data_input;
   assign debug_data_input = { 
							in_fifo_empty, // 1bits
							in_fifo_rd_en, // 1bits
							in_fifo_data,  // 64bit
							in_fifo_ctrl   // 8bit
   };
   wire [73:0] debug_data_output;
   assign debug_data_output = { 
							out_rdy, // 1bits
							out_wr, // 1bits
							out_data,  // 64bit
							out_ctrl   // 8bit
   };   
   wire [156:0] debug_int_signals;
   assign debug_int_signals = { 
							src_port, // 3bits
							pkt_dst_table_id, // 8bits
							in_fifo_data_d1,  // 64bit
							in_fifo_data_d1_nxt,   // 64bit
                     state, //9bits
                     state_nxt //9bits
   };  
   
/*   
   `ifndef SIM

   wire [35:0] control0;

   chipscope_icon icon_inst (
      .CONTROL0 (control0)
   );
   
   chipscope_ila ila_inst (
      .CONTROL(control0),
      .CLK(clk),

      .TRIG0(debug_data_input),
      .TRIG1(debug_data_output),
      .TRIG2(debug_int_signals)
   );
`endif
*/

endmodule // opl_processor
