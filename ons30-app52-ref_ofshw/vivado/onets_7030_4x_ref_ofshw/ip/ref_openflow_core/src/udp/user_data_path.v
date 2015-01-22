///////////////////////////////////////////////////////////////////////////////
// vim:set shiftwidth=3 softtabstop=3 expandtab:
// $Id: user_data_path.v 5697 2009-06-17 22:32:11Z tyabe $
//
// Module: user_data_path.v
// Project: NF2.1
// Author: Jad Naous <jnaous@stanford.edu>
// Description: contains all the user instantiated modules
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

/******************************************************
 * Even numbered ports are IO sinks/sources
 * Odd numbered ports are CPU ports corresponding to
 * IO sinks/sources to rpovide direct access to them
 ******************************************************/
module user_data_path
  #(parameter DATA_WIDTH = 64,
    parameter CTRL_WIDTH=DATA_WIDTH/8,
    parameter UDP_REG_SRC_WIDTH = 2,
    parameter NUM_OUTPUT_QUEUES = 8,
    parameter NUM_INPUT_QUEUES = 8
   )
   (
    input  [DATA_WIDTH-1:0]            in_data_0,
    input  [CTRL_WIDTH-1:0]            in_ctrl_0,
    input                              in_wr_0,
    output                             in_rdy_0,

    input  [DATA_WIDTH-1:0]            in_data_1,
    input  [CTRL_WIDTH-1:0]            in_ctrl_1,
    input                              in_wr_1,
    output                             in_rdy_1,

    input  [DATA_WIDTH-1:0]            in_data_2,
    input  [CTRL_WIDTH-1:0]            in_ctrl_2,
    input                              in_wr_2,
    output                             in_rdy_2,

    input  [DATA_WIDTH-1:0]            in_data_3,
    input  [CTRL_WIDTH-1:0]            in_ctrl_3,
    input                              in_wr_3,
    output                             in_rdy_3,

    input  [DATA_WIDTH-1:0]            in_data_4,
    input  [CTRL_WIDTH-1:0]            in_ctrl_4,
    input                              in_wr_4,
    output                             in_rdy_4,

    input  [DATA_WIDTH-1:0]            in_data_5,
    input  [CTRL_WIDTH-1:0]            in_ctrl_5,
    input                              in_wr_5,
    output                             in_rdy_5,

    input  [DATA_WIDTH-1:0]            in_data_6,
    input  [CTRL_WIDTH-1:0]            in_ctrl_6,
    input                              in_wr_6,
    output                             in_rdy_6,

    input  [DATA_WIDTH-1:0]            in_data_7,
    input  [CTRL_WIDTH-1:0]            in_ctrl_7,
    input                              in_wr_7,
    output                             in_rdy_7,

    output  [DATA_WIDTH-1:0]           out_data_0,
    output  [CTRL_WIDTH-1:0]           out_ctrl_0,
    output                             out_wr_0,
    input                              out_rdy_0,

    output  [DATA_WIDTH-1:0]           out_data_1,
    output  [CTRL_WIDTH-1:0]           out_ctrl_1,
    output                             out_wr_1,
    input                              out_rdy_1,

    output  [DATA_WIDTH-1:0]           out_data_2,
    output  [CTRL_WIDTH-1:0]           out_ctrl_2,
    output                             out_wr_2,
    input                              out_rdy_2,

    output  [DATA_WIDTH-1:0]           out_data_3,
    output  [CTRL_WIDTH-1:0]           out_ctrl_3,
    output                             out_wr_3,
    input                              out_rdy_3,

    output  [DATA_WIDTH-1:0]           out_data_4,
    output  [CTRL_WIDTH-1:0]           out_ctrl_4,
    output                             out_wr_4,
    input                              out_rdy_4,

    output  [DATA_WIDTH-1:0]           out_data_5,
    output  [CTRL_WIDTH-1:0]           out_ctrl_5,
    output                             out_wr_5,
    input                              out_rdy_5,

    output  [DATA_WIDTH-1:0]           out_data_6,
    output  [CTRL_WIDTH-1:0]           out_ctrl_6,
    output                             out_wr_6,
    input                              out_rdy_6,

    output  [DATA_WIDTH-1:0]           out_data_7,
    output  [CTRL_WIDTH-1:0]           out_ctrl_7,
    output                             out_wr_7,
    input                              out_rdy_7,

     // register interface
     input                              reg_req,
     output                             reg_ack,
     input                              reg_rd_wr_L,
     input [`UDP_REG_ADDR_WIDTH-1:0]    reg_addr,
     output [`CPCI_NF2_DATA_WIDTH-1:0]  reg_rd_data,
     input [`CPCI_NF2_DATA_WIDTH-1:0]   reg_wr_data,

     // misc
     input                              reset,
     input                              clk);


   function integer log2;
      input integer number;
      begin
         log2=0;
         while(2**log2<number) begin
            log2=log2+1;
         end
      end
   endfunction // log2

   //---------- Internal parameters -----------

   localparam NUM_IQ_BITS = log2(NUM_INPUT_QUEUES);

   localparam IN_ARB_STAGE_NUM = 2;
   localparam OP_LUT_STAGE_NUM = 4;
   localparam OQ_STAGE_NUM     = 6;

   //-------- Input arbiter wires/regs -------
   wire                             in_arb_in_reg_req;
   wire                             in_arb_in_reg_ack;
   wire                             in_arb_in_reg_rd_wr_L;
   wire [`UDP_REG_ADDR_WIDTH-1:0]   in_arb_in_reg_addr;
   wire [`CPCI_NF2_DATA_WIDTH-1:0]  in_arb_in_reg_data;
   wire [UDP_REG_SRC_WIDTH-1:0]     in_arb_in_reg_src;

   //------- VLAN removeer wires/regs ------
   wire [CTRL_WIDTH-1:0]            vlan_rm_in_ctrl;
   wire [DATA_WIDTH-1:0]            vlan_rm_in_data;
   wire                             vlan_rm_in_wr;
   wire                             vlan_rm_in_rdy;

   //------- output port lut wires/regs ------
   wire [CTRL_WIDTH-1:0]            op_lut_in_ctrl;
   wire [DATA_WIDTH-1:0]            op_lut_in_data;
   wire                             op_lut_in_wr;
   wire                             op_lut_in_rdy;

   wire                             op_lut_in_reg_req;
   wire                             op_lut_in_reg_ack;
   wire                             op_lut_in_reg_rd_wr_L;
   wire [`UDP_REG_ADDR_WIDTH-1:0]   op_lut_in_reg_addr;
   wire [`CPCI_NF2_DATA_WIDTH-1:0]  op_lut_in_reg_data;
   wire [UDP_REG_SRC_WIDTH-1:0]     op_lut_in_reg_src;

   //------- output port lut wires/regs ------
   wire [CTRL_WIDTH-1:0]            op_lut_in_ctrl_2;
   wire [DATA_WIDTH-1:0]            op_lut_in_data_2;
   wire                             op_lut_in_wr_2;
   wire                             op_lut_in_rdy_2;

   wire                             op_lut_in_reg_req_2;
   wire                             op_lut_in_reg_ack_2;
   wire                             op_lut_in_reg_rd_wr_L_2;
   wire [`UDP_REG_ADDR_WIDTH-1:0]   op_lut_in_reg_addr_2;
   wire [`CPCI_NF2_DATA_WIDTH-1:0]  op_lut_in_reg_data_2;
   wire [UDP_REG_SRC_WIDTH-1:0]     op_lut_in_reg_src_2;
   
   //------- VLAN adder wires/regs ------
   wire [CTRL_WIDTH-1:0]            vlan_add_in_ctrl;
   wire [DATA_WIDTH-1:0]            vlan_add_in_data;
   wire                             vlan_add_in_wr;
   wire                             vlan_add_in_rdy;
   //------- rate limiter wires/regs ------
   wire [CTRL_WIDTH-1:0]            rate_limiter_in_ctrl;
   wire [DATA_WIDTH-1:0]            rate_limiter_in_data;
   wire                             rate_limiter_in_wr;
   wire                             rate_limiter_in_rdy;

   wire                             rate_limiter_in_reg_req;
   wire                             rate_limiter_in_reg_ack;
   wire                             rate_limiter_in_reg_rd_wr_L;
   wire [`UDP_REG_ADDR_WIDTH-1:0]   rate_limiter_in_reg_addr;
   wire [`CPCI_NF2_DATA_WIDTH-1:0]  rate_limiter_in_reg_data;
   wire [UDP_REG_SRC_WIDTH-1:0]     rate_limiter_in_reg_src;

   //------- output queues wires/regs ------
   wire [CTRL_WIDTH-1:0]            oq_in_ctrl;
   wire [DATA_WIDTH-1:0]            oq_in_data;
   wire                             oq_in_wr;
   wire                             oq_in_rdy;

   wire                             oq_in_reg_req;
   wire                             oq_in_reg_ack;
   wire                             oq_in_reg_rd_wr_L;
   wire [`UDP_REG_ADDR_WIDTH-1:0]   oq_in_reg_addr;
   wire [`CPCI_NF2_DATA_WIDTH-1:0]  oq_in_reg_data;
   wire [UDP_REG_SRC_WIDTH-1:0]     oq_in_reg_src;

   //-------- UDP register master wires/regs -------
   wire                             udp_reg_req_in;
   wire                             udp_reg_ack_in;
   wire                             udp_reg_rd_wr_L_in;
   wire [`UDP_REG_ADDR_WIDTH-1:0]   udp_reg_addr_in;
   wire [`CPCI_NF2_DATA_WIDTH-1:0]  udp_reg_data_in;
   wire [UDP_REG_SRC_WIDTH-1:0]     udp_reg_src_in;


   //--------- Connect the data path -----------

   input_arbiter
     #(.DATA_WIDTH(DATA_WIDTH),
       .CTRL_WIDTH(CTRL_WIDTH),
       .UDP_REG_SRC_WIDTH (UDP_REG_SRC_WIDTH),
       .STAGE_NUMBER(IN_ARB_STAGE_NUM))
   input_arbiter
     (
    .out_data             (vlan_rm_in_data),
    .out_ctrl             (vlan_rm_in_ctrl),
    .out_wr               (vlan_rm_in_wr),
    .out_rdy              (vlan_rm_in_rdy),

      // --- Interface to the input queues
    .in_data_0            (in_data_0),
    .in_ctrl_0            (in_ctrl_0),
    .in_wr_0              (in_wr_0),
    .in_rdy_0             (in_rdy_0),

    .in_data_1            (in_data_1),
    .in_ctrl_1            (in_ctrl_1),
    .in_wr_1              (in_wr_1),
    .in_rdy_1             (in_rdy_1),

    .in_data_2            (in_data_2),
    .in_ctrl_2            (in_ctrl_2),
    .in_wr_2              (in_wr_2),
    .in_rdy_2             (in_rdy_2),

    .in_data_3            (in_data_3),
    .in_ctrl_3            (in_ctrl_3),
    .in_wr_3              (in_wr_3),
    .in_rdy_3             (in_rdy_3),

    .in_data_4            (in_data_4),
    .in_ctrl_4            (in_ctrl_4),
    .in_wr_4              (in_wr_4),
    .in_rdy_4             (in_rdy_4),

    .in_data_5            (in_data_5),
    .in_ctrl_5            (in_ctrl_5),
    .in_wr_5              (in_wr_5),
    .in_rdy_5             (in_rdy_5),

    .in_data_6            (in_data_6),
    .in_ctrl_6            (in_ctrl_6),
    .in_wr_6              (in_wr_6),
    .in_rdy_6             (in_rdy_6),

    .in_data_7            (in_data_7),
    .in_ctrl_7            (in_ctrl_7),
    .in_wr_7              (in_wr_7),
    .in_rdy_7             (in_rdy_7),

      // --- Register interface
    .reg_req_in           (in_arb_in_reg_req),
    .reg_ack_in           (in_arb_in_reg_ack),
    .reg_rd_wr_L_in       (in_arb_in_reg_rd_wr_L),
    .reg_addr_in          (in_arb_in_reg_addr),
    .reg_data_in          (in_arb_in_reg_data),
    .reg_src_in           (in_arb_in_reg_src),

    .reg_req_out           (op_lut_in_reg_req),
    .reg_ack_out           (op_lut_in_reg_ack),
    .reg_rd_wr_L_out       (op_lut_in_reg_rd_wr_L),
    .reg_addr_out          (op_lut_in_reg_addr),
    .reg_data_out          (op_lut_in_reg_data),
    .reg_src_out           (op_lut_in_reg_src),

      // --- Misc
    .reset                (reset),
    .clk                  (clk)
    );

   vlan_remover
     #(.DATA_WIDTH(DATA_WIDTH),
       .CTRL_WIDTH(CTRL_WIDTH))
       vlan_remover
         (// --- Interface to previous module
          .in_data            (vlan_rm_in_data),
          .in_ctrl            (vlan_rm_in_ctrl),
          .in_wr              (vlan_rm_in_wr),
          .in_rdy             (vlan_rm_in_rdy),

          // --- Interface to next module
          .out_data           (op_lut_in_data),
          .out_ctrl           (op_lut_in_ctrl),
          .out_wr             (op_lut_in_wr),
          .out_rdy            (op_lut_in_rdy),

          // --- Misc
          .reset              (reset),
          .clk                (clk)
          );

   output_port_lookup
   #(.DATA_WIDTH(DATA_WIDTH),
      .CTRL_WIDTH(CTRL_WIDTH),
      .UDP_REG_SRC_WIDTH (UDP_REG_SRC_WIDTH),
      .STAGE_NUM(OP_LUT_STAGE_NUM),
      .NUM_OUTPUT_QUEUES(NUM_OUTPUT_QUEUES),
      .NUM_IQ_BITS(NUM_IQ_BITS),
      .OPENFLOW_LOOKUP_REG_ADDR_WIDTH(`T0_OPENFLOW_LOOKUP_REG_ADDR_WIDTH),
      .OPENFLOW_LOOKUP_BLOCK_ADDR(`T0_OPENFLOW_LOOKUP_BLOCK_ADDR),
      .OPENFLOW_WILDCARD_LOOKUP_REG_ADDR_WIDTH(`T0_OPENFLOW_WILDCARD_LOOKUP_REG_ADDR_WIDTH),
      .OPENFLOW_WILDCARD_LOOKUP_BLOCK_ADDR(`T0_OPENFLOW_WILDCARD_LOOKUP_BLOCK_ADDR),
      .OPENFLOW_ENTRY_WIDTH (`T0_OPENFLOW_ENTRY_WIDTH),
      .OPENFLOW_WILDCARD_TABLE_SIZE (`T0_OPENFLOW_WILDCARD_TABLE_SIZE),
      .CURRENT_TABLE_ID (0)
   )
   output_port_lookup_0
    (// --- Interface to next module
     .out_data          (vlan_add_in_data),
     .out_ctrl          (vlan_add_in_ctrl),
     .out_wr            (vlan_add_in_wr),
     .out_rdy           (vlan_add_in_rdy),

     /*.out_data          (op_lut_in_data_2),
     .out_ctrl          (op_lut_in_ctrl_2),
     .out_wr            (op_lut_in_wr_2),
     .out_rdy           (op_lut_in_rdy_2),*/

     // --- Interface to previous module
     .in_data           (op_lut_in_data),
     .in_ctrl           (op_lut_in_ctrl),
     .in_wr             (op_lut_in_wr),
     .in_rdy            (op_lut_in_rdy),

     // --- Register interface
     .reg_req_in        (op_lut_in_reg_req),
     .reg_ack_in        (op_lut_in_reg_ack),
     .reg_rd_wr_L_in    (op_lut_in_reg_rd_wr_L),
     .reg_addr_in       (op_lut_in_reg_addr),
     .reg_data_in       (op_lut_in_reg_data),
     .reg_src_in        (op_lut_in_reg_src),

     .reg_req_out       (rate_limiter_in_reg_req),
     .reg_ack_out       (rate_limiter_in_reg_ack),
     .reg_rd_wr_L_out   (rate_limiter_in_reg_rd_wr_L),
     .reg_addr_out      (rate_limiter_in_reg_addr),
     .reg_data_out      (rate_limiter_in_reg_data),
     .reg_src_out       (rate_limiter_in_reg_src),

/*     .reg_req_out       (op_lut_in_reg_req_2),
     .reg_ack_out       (op_lut_in_reg_ack_2),
     .reg_rd_wr_L_out   (op_lut_in_reg_rd_wr_L_2),
     .reg_addr_out      (op_lut_in_reg_addr_2),
     .reg_data_out      (op_lut_in_reg_data_2),
     .reg_src_out       (op_lut_in_reg_src_2),*/

     // --- watchdog interface
     .table_flush       (1'b0),

     // --- Misc
     .clk               (clk),
     .reset             (reset)
   );
/*   output_port_lookup
   #(.DATA_WIDTH(DATA_WIDTH),
      .CTRL_WIDTH(CTRL_WIDTH),
      .UDP_REG_SRC_WIDTH (UDP_REG_SRC_WIDTH),
      .STAGE_NUM(OP_LUT_STAGE_NUM),
      .NUM_OUTPUT_QUEUES(NUM_OUTPUT_QUEUES),
      .NUM_IQ_BITS(NUM_IQ_BITS),
      .OPENFLOW_LOOKUP_REG_ADDR_WIDTH(`T1_OPENFLOW_LOOKUP_REG_ADDR_WIDTH),
      .OPENFLOW_LOOKUP_BLOCK_ADDR(`T1_OPENFLOW_LOOKUP_BLOCK_ADDR),
      .OPENFLOW_WILDCARD_LOOKUP_REG_ADDR_WIDTH(`T1_OPENFLOW_WILDCARD_LOOKUP_REG_ADDR_WIDTH),
      .OPENFLOW_WILDCARD_LOOKUP_BLOCK_ADDR(`T1_OPENFLOW_WILDCARD_LOOKUP_BLOCK_ADDR),
      .OPENFLOW_ENTRY_WIDTH (`T1_OPENFLOW_ENTRY_WIDTH),
      .OPENFLOW_WILDCARD_TABLE_SIZE (`T1_OPENFLOW_WILDCARD_TABLE_SIZE),
      .CURRENT_TABLE_ID (1)
   )
   output_port_lookup_1
    (// --- Interface to next module
     .out_data          (vlan_add_in_data),
     .out_ctrl          (vlan_add_in_ctrl),
     .out_wr            (vlan_add_in_wr),
     .out_rdy           (vlan_add_in_rdy),

     // --- Interface to previous module
     .in_data           (op_lut_in_data_2),
     .in_ctrl           (op_lut_in_ctrl_2),
     .in_wr             (op_lut_in_wr_2),
     .in_rdy            (op_lut_in_rdy_2),

     // --- Register interface
     .reg_req_in        (op_lut_in_reg_req_2),
     .reg_ack_in        (op_lut_in_reg_ack_2),
     .reg_rd_wr_L_in    (op_lut_in_reg_rd_wr_L_2),
     .reg_addr_in       (op_lut_in_reg_addr_2),
     .reg_data_in       (op_lut_in_reg_data_2),
     .reg_src_in        (op_lut_in_reg_src_2),

     .reg_req_out       (rate_limiter_in_reg_req),
     .reg_ack_out       (rate_limiter_in_reg_ack),
     .reg_rd_wr_L_out   (rate_limiter_in_reg_rd_wr_L),
     .reg_addr_out      (rate_limiter_in_reg_addr),
     .reg_data_out      (rate_limiter_in_reg_data),
     .reg_src_out       (rate_limiter_in_reg_src),

     // --- watchdog interface
     .table_flush       (1'b0),

     // --- Misc
     .clk               (clk),
     .reset             (reset)
   );*/
   vlan_adder
     #(.DATA_WIDTH(DATA_WIDTH),
       .CTRL_WIDTH(CTRL_WIDTH))
       vlan_adder
         (// --- Interface to previous module
          .in_data            (vlan_add_in_data),
          .in_ctrl            (vlan_add_in_ctrl),
          .in_wr              (vlan_add_in_wr),
          .in_rdy             (vlan_add_in_rdy),

          // --- Interface to next module
         .out_data             (rate_limiter_in_data),
         .out_ctrl             (rate_limiter_in_ctrl),
         .out_wr               (rate_limiter_in_wr),
         .out_rdy              (rate_limiter_in_rdy),

          // --- Misc
          .reset              (reset),
          .clk                (clk)
          );
   meter_lite meter_lite (
      // --- Interface to the previous module
      .in_data                            (rate_limiter_in_data),
      .in_ctrl                            (rate_limiter_in_ctrl),
      .in_rdy                             (rate_limiter_in_rdy),
      .in_wr                              (rate_limiter_in_wr),
      
      .out_data                           (oq_in_data),
      .out_ctrl                           (oq_in_ctrl),
      .out_wr                             (oq_in_wr),
      .out_rdy                            (oq_in_rdy),
      
     .reg_req_in           (rate_limiter_in_reg_req),
     .reg_ack_in           (rate_limiter_in_reg_ack),
     .reg_rd_wr_L_in       (rate_limiter_in_reg_rd_wr_L),
     .reg_addr_in          (rate_limiter_in_reg_addr),
     .reg_data_in          (rate_limiter_in_reg_data),
     .reg_src_in           (rate_limiter_in_reg_src),

     .reg_req_out          (oq_in_reg_req),
     .reg_ack_out          (oq_in_reg_ack),
     .reg_rd_wr_L_out      (oq_in_reg_rd_wr_L),
     .reg_addr_out         (oq_in_reg_addr),
     .reg_data_out         (oq_in_reg_data),
     .reg_src_out          (oq_in_reg_src),

      // --- Misc
      .clk                                (clk),
      .reset                              (reset)

   );

   output_queues
   #(.DATA_WIDTH(DATA_WIDTH),
       .CTRL_WIDTH(CTRL_WIDTH),
       .UDP_REG_SRC_WIDTH (UDP_REG_SRC_WIDTH),
       .OP_LUT_STAGE_NUM(OP_LUT_STAGE_NUM),
       .NUM_OUTPUT_QUEUES(NUM_OUTPUT_QUEUES)
   )
   output_queues
     (// --- data path interface
    .out_data_0       (out_data_0),
    .out_ctrl_0       (out_ctrl_0),
    .out_wr_0         (out_wr_0),
    .out_rdy_0        (out_rdy_0),

    .out_data_1       (out_data_1),
    .out_ctrl_1       (out_ctrl_1),
    .out_wr_1         (out_wr_1),
    .out_rdy_1        (out_rdy_1),

    .out_data_2       (out_data_2),
    .out_ctrl_2       (out_ctrl_2),
    .out_wr_2         (out_wr_2),
    .out_rdy_2        (out_rdy_2),

    .out_data_3       (out_data_3),
    .out_ctrl_3       (out_ctrl_3),
    .out_wr_3         (out_wr_3),
    .out_rdy_3        (out_rdy_3),

    .out_data_4       (out_data_4),
    .out_ctrl_4       (out_ctrl_4),
    .out_wr_4         (out_wr_4),
    .out_rdy_4        (out_rdy_4),

    .out_data_5       (out_data_5),
    .out_ctrl_5       (out_ctrl_5),
    .out_wr_5         (out_wr_5),
    .out_rdy_5        (out_rdy_5),

    .out_data_6       (out_data_6),
    .out_ctrl_6       (out_ctrl_6),
    .out_wr_6         (out_wr_6),
    .out_rdy_6        (out_rdy_6),

    .out_data_7       (out_data_7),
    .out_ctrl_7       (out_ctrl_7),
    .out_wr_7         (out_wr_7),
    .out_rdy_7        (out_rdy_7),

      // --- Interface to the previous module
    .in_data          (oq_in_data),
    .in_ctrl          (oq_in_ctrl),
    .in_rdy           (oq_in_rdy),
    .in_wr            (oq_in_wr),

      // --- Register interface
    .reg_req_in       (oq_in_reg_req),
    .reg_ack_in       (oq_in_reg_ack),
    .reg_rd_wr_L_in   (oq_in_reg_rd_wr_L),
    .reg_addr_in      (oq_in_reg_addr),
    .reg_data_in      (oq_in_reg_data),
    .reg_src_in       (oq_in_reg_src),

    .reg_req_out      (udp_reg_req_in),
    .reg_ack_out      (udp_reg_ack_in),
    .reg_rd_wr_L_out  (udp_reg_rd_wr_L_in),
    .reg_addr_out     (udp_reg_addr_in),
    .reg_data_out     (udp_reg_data_in),
    .reg_src_out      (udp_reg_src_in),

      // --- Misc
    .clk              (clk),
    .reset            (reset));


   //--------------------------------------------------
   //
   // --- User data path register master
   //
   //     Takes the register accesses from core,
   //     sends them around the User Data Path module
   //     ring and then returns the replies back
   //     to the core
   //
   //--------------------------------------------------

   udp_reg_master #(
      .UDP_REG_SRC_WIDTH (UDP_REG_SRC_WIDTH)
   ) udp_reg_master (
      // Core register interface signals
      .core_reg_req                          (reg_req),
      .core_reg_ack                          (reg_ack),
      .core_reg_rd_wr_L                      (reg_rd_wr_L),

      .core_reg_addr                         (reg_addr),

      .core_reg_rd_data                      (reg_rd_data),
      .core_reg_wr_data                      (reg_wr_data),

      // UDP register interface signals (output)
      .reg_req_out                           (in_arb_in_reg_req),
      .reg_ack_out                           (in_arb_in_reg_ack),
      .reg_rd_wr_L_out                       (in_arb_in_reg_rd_wr_L),

      .reg_addr_out                          (in_arb_in_reg_addr),
      .reg_data_out                          (in_arb_in_reg_data),

      .reg_src_out                           (in_arb_in_reg_src),

      // UDP register interface signals (input)
      .reg_req_in                            (udp_reg_req_in),
      .reg_ack_in                            (udp_reg_ack_in),
      .reg_rd_wr_L_in                        (udp_reg_rd_wr_L_in),

      .reg_addr_in                           (udp_reg_addr_in),
      .reg_data_in                           (udp_reg_data_in),

      .reg_src_in                            (udp_reg_src_in),

      //
      .clk                                   (clk),
      .reset                                 (reset)
   );


endmodule // user_data_path

