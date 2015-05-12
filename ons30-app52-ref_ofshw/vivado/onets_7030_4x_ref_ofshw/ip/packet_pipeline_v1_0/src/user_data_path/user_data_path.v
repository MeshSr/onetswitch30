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
     input  [31:0]                      reg_addr,
     output [`CPCI_NF2_DATA_WIDTH-1:0]  reg_rd_data,
     input [`CPCI_NF2_DATA_WIDTH-1:0]   reg_wr_data,

     // misc
     input                              reset,
     input                              clk,
     
     input                              sim_start
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
   wire [CTRL_WIDTH-1:0]            op_lut_in_ctrl[3:0];
   wire [DATA_WIDTH-1:0]            op_lut_in_data[3:0];
   wire                             op_lut_in_wr  [3:0];
   wire                             op_lut_in_rdy [3:0];


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
   
      //------- output port lut wires/regs ------
   wire [CTRL_WIDTH-1:0]            op_lut_in_ctrl_3;
   wire [DATA_WIDTH-1:0]            op_lut_in_data_3;
   wire                             op_lut_in_wr_3;
   wire                             op_lut_in_rdy_3;

   wire                             op_lut_in_reg_req_3;
   wire                             op_lut_in_reg_ack_3;
   wire                             op_lut_in_reg_rd_wr_L_3;
   wire [`UDP_REG_ADDR_WIDTH-1:0]   op_lut_in_reg_addr_3;
   wire [`CPCI_NF2_DATA_WIDTH-1:0]  op_lut_in_reg_data_3;
   wire [UDP_REG_SRC_WIDTH-1:0]     op_lut_in_reg_src_3;
   
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
   /*wire                             udp_reg_req_in;
   wire                             udp_reg_ack_in;
   wire                             udp_reg_rd_wr_L_in;
   wire [`UDP_REG_ADDR_WIDTH-1:0]   udp_reg_addr_in;
   wire [`CPCI_NF2_DATA_WIDTH-1:0]  udp_reg_data_in;
   wire [UDP_REG_SRC_WIDTH-1:0]     udp_reg_src_in;*/
   
   wire   [31:0]                    data_output_port_lookup_o [2:0];
   wire   [31:0]                    addr_output_port_lookup_o [2:0];
   wire                             req_output_port_lookup_o  [2:0];
   wire                             rw_output_port_lookup_o   [2:0]; 
   wire                             ack_output_port_lookup_i  [2:0];  
   wire   [31:0]                    data_output_port_lookup_i [2:0];
    wire   [31:0]                    data_output_port_lookup_0_o ;
    wire   [31:0]                    data_output_port_lookup_1_o ;
    wire   [31:0]                    data_output_port_lookup_2_o ;
    wire   [31:0]                    data_meter_o                ;
    wire   [31:0]                    data_output_queues_o        ;
    
    wire   [31:0]                    addr_output_port_lookup_0_o ;
    wire   [31:0]                    addr_output_port_lookup_1_o ;
    wire   [31:0]                    addr_output_port_lookup_2_o ;
    wire   [31:0]                    addr_meter_o                ;
    wire   [31:0]                    addr_output_queues_o        ;
    
    wire                             req_output_port_lookup_0_o  ;
    wire                             req_output_port_lookup_1_o  ;
    wire                             req_output_port_lookup_2_o  ;
    wire                             req_meter_o                 ;
    wire                             req_output_queues_o         ;
    
    wire                             rw_output_port_lookup_0_o   ;
    wire                             rw_output_port_lookup_1_o   ;
    wire                             rw_output_port_lookup_2_o   ;
    wire                             rw_meter_o                  ;
    wire                             rw_output_queues_o          ;
          
    wire                             ack_output_port_lookup_0_i  ;
    wire                             ack_output_port_lookup_1_i  ;
    wire                             ack_output_port_lookup_2_i  ;
    wire                             ack_meter_i                 ;
    wire                             ack_output_queues_i         ;     
    
    wire   [31:0]                     data_output_port_lookup_0_i;
    wire   [31:0]                     data_output_port_lookup_1_i;
    wire   [31:0]                     data_output_port_lookup_2_i;
    wire   [31:0]                     data_meter_i               ;
    wire   [31:0]                     data_output_queues_i       ;
   
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
/*    .reg_req_in           (in_arb_in_reg_req),
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
    .reg_src_out           (op_lut_in_reg_src),*/

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
          .out_data           (op_lut_in_data[0]),
          .out_ctrl           (op_lut_in_ctrl[0]),
          .out_wr             (op_lut_in_wr  [0]),
          .out_rdy            (op_lut_in_rdy [0]),


          // --- Misc
          .reset              (reset),
          .clk                (clk)
          );

   assign data_output_port_lookup_o [0] = data_output_port_lookup_0_o   ;
   assign addr_output_port_lookup_o [0] = addr_output_port_lookup_0_o   ;
   assign req_output_port_lookup_o  [0] = req_output_port_lookup_0_o    ;
   assign rw_output_port_lookup_o   [0] = rw_output_port_lookup_0_o     ;
   assign ack_output_port_lookup_0_i    = ack_output_port_lookup_i  [0] ;
   assign data_output_port_lookup_0_i   = data_output_port_lookup_i [0] ;

   assign data_output_port_lookup_o [1] = data_output_port_lookup_1_o   ;
   assign addr_output_port_lookup_o [1] = addr_output_port_lookup_1_o   ;
   assign req_output_port_lookup_o  [1] = req_output_port_lookup_1_o    ;
   assign rw_output_port_lookup_o   [1] = rw_output_port_lookup_1_o     ;
   assign ack_output_port_lookup_1_i    = ack_output_port_lookup_i  [1] ;
   assign data_output_port_lookup_1_i   = data_output_port_lookup_i [1] ;

   assign data_output_port_lookup_o [2] = data_output_port_lookup_2_o   ;
   assign addr_output_port_lookup_o [2] = addr_output_port_lookup_2_o   ;
   assign req_output_port_lookup_o  [2] = req_output_port_lookup_2_o    ;
   assign rw_output_port_lookup_o   [2] = rw_output_port_lookup_2_o     ;
   assign ack_output_port_lookup_2_i    = ack_output_port_lookup_i  [2] ;
   assign data_output_port_lookup_2_i   = data_output_port_lookup_i [2] ;   
      
   generate 
      genvar i;
      for(i = 0; i < `TABLE_NUM; i = i + 1)
      begin : output_port_lookup
         output_port_lookup
         #(
            .DATA_WIDTH                               (DATA_WIDTH),
            .CTRL_WIDTH                               (CTRL_WIDTH),
            .UDP_REG_SRC_WIDTH                        (UDP_REG_SRC_WIDTH),
            .STAGE_NUM                                (OP_LUT_STAGE_NUM),
            .NUM_OUTPUT_QUEUES                        (NUM_OUTPUT_QUEUES),
            .NUM_IQ_BITS                              (NUM_IQ_BITS),
            .OPENFLOW_LOOKUP_REG_ADDR_WIDTH           (`T0_OPENFLOW_LOOKUP_REG_ADDR_WIDTH),
            .OPENFLOW_LOOKUP_BLOCK_ADDR               (`T0_OPENFLOW_LOOKUP_BLOCK_ADDR+i),
            .OPENFLOW_WILDCARD_LOOKUP_REG_ADDR_WIDTH  (`T0_OPENFLOW_WILDCARD_LOOKUP_REG_ADDR_WIDTH),
            .OPENFLOW_WILDCARD_LOOKUP_BLOCK_ADDR      (`T0_OPENFLOW_WILDCARD_LOOKUP_BLOCK_ADDR+i),
            .OPENFLOW_ENTRY_WIDTH                     (`T0_OPENFLOW_ENTRY_WIDTH),
            .OPENFLOW_WILDCARD_TABLE_SIZE             (`T0_OPENFLOW_WILDCARD_TABLE_SIZE),
            .CURRENT_TABLE_ID                         (i),
            .TABLE_NUM                                (`TABLE_NUM-1)
         )
         output_port_lookup
          (// --- Interface to next module
           .out_data          (op_lut_in_data [i+1]),
           .out_ctrl          (op_lut_in_ctrl [i+1]),
           .out_wr            (op_lut_in_wr   [i+1]),
           .out_rdy           (op_lut_in_rdy  [i+1]),

           // --- Interface to previous module
           .in_data           (op_lut_in_data [i]),
           .in_ctrl           (op_lut_in_ctrl [i]),
           .in_wr             (op_lut_in_wr   [i]),
           .in_rdy            (op_lut_in_rdy  [i]),

           // --- Register interface
           .data_output_port_lookup_i  (data_output_port_lookup_o[i]) ,
           .addr_output_port_lookup_i  (addr_output_port_lookup_o[i]) ,
           .req_output_port_lookup_i   (req_output_port_lookup_o [i]) ,
           .rw_output_port_lookup_i    (rw_output_port_lookup_o  [i]) ,
           .ack_output_port_lookup_o   (ack_output_port_lookup_i [i]) ,
           .data_output_port_lookup_o  (data_output_port_lookup_i[i]) ,
           

           // --- watchdog interface
           .table_flush       (1'b0),

           // --- Misc
           .clk               (clk),
           .reset             (reset)
         );         
      end
   endgenerate  
/*
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
      .CURRENT_TABLE_ID (0),
      .TABLE_NUM(`TABLE_NUM-1)
   )
   output_port_lookup_0
    (// --- Interface to next module
     .out_data          (op_lut_in_data_2),
     .out_ctrl          (op_lut_in_ctrl_2),
     .out_wr            (op_lut_in_wr_2),
     .out_rdy           (op_lut_in_rdy_2),

     // --- Interface to previous module
     .in_data           (op_lut_in_data),
     .in_ctrl           (op_lut_in_ctrl),
     .in_wr             (op_lut_in_wr),
     .in_rdy            (op_lut_in_rdy),

     // --- Register interface
     .data_output_port_lookup_i  (data_output_port_lookup_0_o) ,
     .addr_output_port_lookup_i  (addr_output_port_lookup_0_o) ,
     .req_output_port_lookup_i   (req_output_port_lookup_0_o ) ,
     .rw_output_port_lookup_i    (rw_output_port_lookup_0_o  ) ,
     .ack_output_port_lookup_o   (ack_output_port_lookup_0_i ) ,
     .data_output_port_lookup_o  (data_output_port_lookup_0_i) ,
     

     // --- watchdog interface
     .table_flush       (1'b0),

     // --- Misc
     .clk               (clk),
     .reset             (reset)
   );
   output_port_lookup
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
      .CURRENT_TABLE_ID (1),
      .TABLE_NUM(`TABLE_NUM-1)
   )
   output_port_lookup_1
    (// --- Interface to next module
     .out_data          (op_lut_in_data_3),
     .out_ctrl          (op_lut_in_ctrl_3),
     .out_wr            (op_lut_in_wr_3),
     .out_rdy           (op_lut_in_rdy_3),

     // --- Interface to previous module
     .in_data           (op_lut_in_data_2),
     .in_ctrl           (op_lut_in_ctrl_2),
     .in_wr             (op_lut_in_wr_2),
     .in_rdy            (op_lut_in_rdy_2),

     // --- Register interface
     .data_output_port_lookup_i  (data_output_port_lookup_1_o) ,
     .addr_output_port_lookup_i  (addr_output_port_lookup_1_o),
     .req_output_port_lookup_i   (req_output_port_lookup_1_o ),
     .rw_output_port_lookup_i    (rw_output_port_lookup_1_o  ),
     .ack_output_port_lookup_o   (ack_output_port_lookup_1_i ),
     .data_output_port_lookup_o  (data_output_port_lookup_1_i),
     
     // --- watchdog interface
     .table_flush       (1'b0),

     // --- Misc
     .clk               (clk),
     .reset             (reset)
   );
   
      output_port_lookup
   #(.DATA_WIDTH(DATA_WIDTH),
      .CTRL_WIDTH(CTRL_WIDTH),
      .UDP_REG_SRC_WIDTH (UDP_REG_SRC_WIDTH),
      .STAGE_NUM(OP_LUT_STAGE_NUM),
      .NUM_OUTPUT_QUEUES(NUM_OUTPUT_QUEUES),
      .NUM_IQ_BITS(NUM_IQ_BITS),
      .OPENFLOW_LOOKUP_REG_ADDR_WIDTH(`T2_OPENFLOW_LOOKUP_REG_ADDR_WIDTH),
      .OPENFLOW_LOOKUP_BLOCK_ADDR(`T2_OPENFLOW_LOOKUP_BLOCK_ADDR),
      .OPENFLOW_WILDCARD_LOOKUP_REG_ADDR_WIDTH(`T2_OPENFLOW_WILDCARD_LOOKUP_REG_ADDR_WIDTH),
      .OPENFLOW_WILDCARD_LOOKUP_BLOCK_ADDR(`T2_OPENFLOW_WILDCARD_LOOKUP_BLOCK_ADDR),
      .OPENFLOW_ENTRY_WIDTH (`T2_OPENFLOW_ENTRY_WIDTH),
      .OPENFLOW_WILDCARD_TABLE_SIZE (`T2_OPENFLOW_WILDCARD_TABLE_SIZE),
      .CURRENT_TABLE_ID (2),
      .TABLE_NUM(`TABLE_NUM-1)
   )
  output_port_lookup_2
   (// --- Interface t o next module
     .out_data          (vlan_add_in_data),
     .out_ctrl          (vlan_add_in_ctrl),
     .out_wr            (vlan_add_in_wr),
     .out_rdy           (vlan_add_in_rdy),

     // --- Interface to previous module
     .in_data           (op_lut_in_data_3),
     .in_ctrl           (op_lut_in_ctrl_3),
     .in_wr             (op_lut_in_wr_3),
     .in_rdy            (op_lut_in_rdy_3),

     // --- Register interface
     .data_output_port_lookup_i  (data_output_port_lookup_2_o) ,
     .addr_output_port_lookup_i  (addr_output_port_lookup_2_o),
     .req_output_port_lookup_i   (req_output_port_lookup_2_o ),
     .rw_output_port_lookup_i    (rw_output_port_lookup_2_o  ),
     .ack_output_port_lookup_o   (ack_output_port_lookup_2_i ),
     .data_output_port_lookup_o  (data_output_port_lookup_2_i),


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
/*          .in_data            (vlan_add_in_data),
          .in_ctrl            (vlan_add_in_ctrl),
          .in_wr              (vlan_add_in_wr),
          .in_rdy             (vlan_add_in_rdy),*/
          .in_data            (op_lut_in_data[`TABLE_NUM]),
          .in_ctrl            (op_lut_in_ctrl[`TABLE_NUM]),
          .in_wr              (op_lut_in_wr  [`TABLE_NUM]),
          .in_rdy             (op_lut_in_rdy [`TABLE_NUM]),

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
     
      .data_meter_i    (data_meter_o) ,
      .addr_meter_i    (addr_meter_o) ,
      .req_meter_i     (req_meter_o ) ,
      .rw_meter_i      (rw_meter_o  ) ,
      .ack_meter_o     (ack_meter_i ) ,
      .data_meter_o    (data_meter_i) ,
     
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
    .data_output_queues_i  (data_output_queues_o),
    .addr_output_queues_i  (addr_output_queues_o),
    .req_output_queues_i   (req_output_queues_o),
    .rw_output_queues_i    (rw_output_queues_o),
    .ack_output_queues_o   (ack_output_queues_i),
    .data_output_queues_o  (data_output_queues_i),

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



   udp_reg_master  udp_reg_master 
   (
     .reg_req_in                            (reg_req),
     .reg_ack                               (reg_ack),
     .reg_rd_wr_L_in                        (reg_rd_wr_L),
     .reg_addr_in                           (reg_addr),
     .reg_data_in                           (reg_wr_data),
     .reg_rd_data                           (reg_rd_data),

     .data_output_port_lookup_0_o            (data_output_port_lookup_0_o) ,
     .data_output_port_lookup_1_o            (data_output_port_lookup_1_o) ,
     .data_output_port_lookup_2_o            (data_output_port_lookup_2_o) ,
     .data_meter_o                           (data_meter_o               ) ,
     .data_output_queues_o                   (data_output_queues_o       ) ,
                                            
     .addr_output_port_lookup_0_o            (addr_output_port_lookup_0_o) ,
     .addr_output_port_lookup_1_o            (addr_output_port_lookup_1_o) ,
     .addr_output_port_lookup_2_o            (addr_output_port_lookup_2_o) ,
     .addr_meter_o                           (addr_meter_o               ) ,
     .addr_output_queues_o                   (addr_output_queues_o       ) ,
                                            
     .req_output_port_lookup_0_o             (req_output_port_lookup_0_o ),
     .req_output_port_lookup_1_o             (req_output_port_lookup_1_o ),
     .req_output_port_lookup_2_o             (req_output_port_lookup_2_o ),
     .req_meter_o                            (req_meter_o                ) ,
     .req_output_queues_o                    (req_output_queues_o        ) ,
                                            
     .rw_output_port_lookup_0_o              (rw_output_port_lookup_0_o  ) ,
     .rw_output_port_lookup_1_o              (rw_output_port_lookup_1_o  ) ,
     .rw_output_port_lookup_2_o              (rw_output_port_lookup_2_o  ) ,
     .rw_meter_o                             (rw_meter_o                 ) ,
     .rw_output_queues_o                     (rw_output_queues_o         ) ,
                                            
     .ack_output_port_lookup_0_i             (ack_output_port_lookup_0_i ) ,
     .ack_output_port_lookup_1_i             (ack_output_port_lookup_1_i ) ,
     .ack_output_port_lookup_2_i             (ack_output_port_lookup_2_i ) ,
     .ack_meter_i                            (ack_meter_i                ) ,
     .ack_output_queues_i                    (ack_output_queues_i        ) ,     
                                            
     .data_output_port_lookup_0_i            (data_output_port_lookup_0_i) ,
     .data_output_port_lookup_1_i            (data_output_port_lookup_1_i) ,
     .data_output_port_lookup_2_i            (data_output_port_lookup_2_i) ,
     .data_meter_i                           (data_meter_i               ) ,
     .data_output_queues_i                   (data_output_queues_i       ) ,
    
     //
     .clk                                   (clk),
     .reset                                 (reset)
     );
          

     
     
     /*monitor_reg monitor_reg
     (
         .clk   (clk),
         .reset (reset),
         .in_data_0_out    (out_data_0),
         .in_ctrl_0_out    (out_ctrl_0),
         .in_data_1_out    (out_data_1),
         .in_ctrl_1_out    (out_ctrl_1),
         .in_data_2_out    (out_data_2),
         .in_ctrl_2_out    (out_ctrl_2),
         .in_data_3_out    (out_data_3),
         .in_ctrl_3_out    (out_ctrl_3),
         .in_data_4_out    (out_data_4),
         .in_ctrl_4_out    (out_ctrl_4),
         .in_data_5_out    (out_data_5),
         .in_ctrl_5_out    (out_ctrl_5),
         .in_data_6_out    (out_data_6),
         .in_ctrl_6_out    (out_ctrl_6),
         .in_data_7_out    (out_data_7),
         .in_ctrl_7_out    (out_ctrl_7),
         
         .in_ctrl_0_in     (in_ctrl_0),
         .in_ctrl_1_in     (in_ctrl_2),
         .in_ctrl_2_in     (in_ctrl_4),
         .in_ctrl_3_in     (in_ctrl_6),
         
         .reg_monitor_vld   (reg_monitor_vld),
         .reg_data_out_monitor_vld  (reg_data_out_monitor_vld),
         .reg_data_out_monitor  (reg_data_out_monitor),
         
         .reg_rw            (reg_rw),
         .reg_data          (reg_data),
         .reg_addr_actions  (reg_addr_actions)
         
     );*/
     
     
     /*
     core_reg_master#
        
     core_reg_master(
          .core_reg_req                          (reg_req),
           .core_reg_ack                          (reg_ack),
           .core_reg_rd_wr_L                      (reg_rd_wr_L),
     
           .core_reg_addr                         (reg_addr),
     
           .core_reg_rd_data                      (reg_rd_data),
           .core_reg_wr_data                      (reg_wr_data),
                      .clk                                   (clk),
                 .reset                                 (reset)
   );*/
     
/*
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
   );*/
/*
// synthesis translate_off
    integer file;
    initial begin
        file=$fopen("D:/work_project/IP_program/pipeline_3_level_7045_tb/pipeline_patch.txt");
    end

    reg [31:0]counter;
    reg [15:0]pkt_counter;
    always@(posedge clk)
        if(reset)
            counter<=0;
        else
            counter<=counter+1;
    
    reg [3:0]state;
            
    always@(posedge clk)
        if(reset)
            begin
                state<=0;
                pkt_counter<=1;
            end
        else case(state)
            0:       
                    if(sim_start)
                        state<=1;
            1:
                if(in_wr_0 | in_wr_1 | in_wr_2 | in_wr_3| in_wr_4 | in_wr_5 | in_wr_6 | in_wr_7 )
                    begin
                        //$display("pkt arrives input_arbiter at %d",counter);
                        $fwrite(file,"pkt arrives input_arbiter at %d\n",counter);
                        state<=2;
                    end
            2:
                if(vlan_rm_in_wr)
                    begin
                        //$display("pkt arrives vlan_remover at %d",counter);
                        $fwrite(file,"pkt arrives vlan_remover at %d\n",counter);
                        state<=3;
                    end
            3:
                if(op_lut_in_wr)
                    begin
                        //$display("pkt arrives lookup0 at %d",counter);
                        $fwrite(file,"pkt arrives lookup0 at %d\n",counter);
                        state<=4;
                    end
            4:
                if(op_lut_in_wr_2)
                    begin
                        //$display("pkt arrives lookup1 at %d",counter);   
                        $fwrite(file,"pkt arrives lookup1 at %d\n",counter); 
                        state<=5;
                    end
            5:
                if(op_lut_in_wr_3)
                    begin
                        //$display("pkt arrives lookup2 at %d",counter);   
                        $fwrite(file,"pkt arrives lookup2 at %d\n",counter);   
                        state<=6;
                    end
            6:
                if(vlan_add_in_wr)
                    begin
                        //$display("pkt arrives vlan_adder at %d",counter); 
                        $fwrite(file,"pkt arrives vlan_adder at %d\n",counter); 
                        state<=7;
                    end
            7:
                if(rate_limiter_in_wr)
                    begin
                        //$display("pkt arrives meter at %d",counter);
                        $fwrite(file,"pkt arrives meter at %d\n",counter);
                        state<=8;
                    end
            8:        
                if(oq_in_wr)
                    begin
                       // $display("pkt arrives output_queues at %d",counter);
                        $fwrite(file,"pkt arrives output_queues at %d\n",counter);
                        state<=9;
                    end
            9:
                if( out_wr_0 | out_wr_1 | out_wr_2 | out_wr_3 | out_wr_4 | out_wr_5 | out_wr_6 | out_wr_7)
                    begin
                       //$display("pkt leaves output_queues at %d",counter);
                       $fwrite(file,"pkt leaves output_queues at %d\n",counter);
                       state<=10;
                    end
            10:
                begin
                    //$display("PKT %d ENDS",pkt_counter);
                    pkt_counter<=pkt_counter+1;
                    state<=0;
                end
            default:state<=0;
        endcase
*/            
// synthesis translate_on
endmodule // user_data_path

