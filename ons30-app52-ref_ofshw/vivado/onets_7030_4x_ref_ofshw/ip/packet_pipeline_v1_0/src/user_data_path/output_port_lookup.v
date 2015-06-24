///////////////////////////////////////////////////////////////////////////////
// vim:set shiftwidth=3 softtabstop=3 expandtab:
// $Id: output_port_lookup.v 5697 2009-06-17 22:32:11Z tyabe $
//
// Module: output_port_lookup.v
// Project: NF2.1 OpenFlow Switch
// Author: Jad Naous <jnaous@stanford.edu>
//
// Description: Implements type 0 switching.
// This module brings together the modules that make up the openflow-specific
// functionality. When a packet comes in, the header parser gets the packet size
// and assembles the flow header to match against. The flow header is sent to
// the wildcard and the exact match modules which compare it against their
// entries. The result is then sent to the match_arbiter which decides which
// entry should be used (chooses exact over wildcard) and writes the actions
// into the result_fifo. The opl_processor reads the result_fifo, and writes
// the actions into the module headers. If the packet has no forwarding action
// or doesn't match any entries, it is dropped.
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
  module output_port_lookup
    #(parameter DATA_WIDTH = 64,
      parameter CTRL_WIDTH=DATA_WIDTH/8,
      parameter NUM_OUTPUT_QUEUES = 8,
      parameter OPENFLOW_ENTRY_WIDTH = 64,
      parameter OPENFLOW_WILDCARD_TABLE_SIZE = 16,
      parameter CURRENT_TABLE_ID = 0,
      parameter TABLE_NUM=2
   )

   (// --- data path interface
    output     [DATA_WIDTH-1:0]        out_data,
    output     [CTRL_WIDTH-1:0]        out_ctrl,
    output                             out_wr,
    input                              out_rdy,

    input  [DATA_WIDTH-1:0]            in_data,
    input  [CTRL_WIDTH-1:0]            in_ctrl,
    input                              in_wr,
    output                             in_rdy,
    
    // --- Register interface
    input [31:0]                       data_output_port_lookup_i,
    input [31:0]                       addr_output_port_lookup_i,
    input                              req_output_port_lookup_i,
    input                              rw_output_port_lookup_i,
    output                             ack_output_port_lookup_o,
    output [31:0]                      data_output_port_lookup_o,

    input                           config_sw_ok,
    // --- Watchdog Timer Interface
    input                              table_flush,

    // --- Misc
    input                              clk,
    input                              reset);

   `LOG2_FUNC
   `CEILDIV_FUNC

   //-------------------- Internal Parameters ------------------------
   localparam PKT_SIZE_WIDTH                 = 12;
   localparam OPENFLOW_WILDCARD_TABLE_DEPTH  = log2(OPENFLOW_WILDCARD_TABLE_SIZE);
   localparam OPENFLOW_ACTION_WIDTH          = `OPENFLOW_ACTION_WIDTH ;
   localparam OPENFLOW_ENTRY_SRC_PORT_WIDTH  = `OPENFLOW_ENTRY_SRC_PORT_WIDTH ;
   localparam PRIO_WIDTH                     = `PRIO_WIDTH ;
   localparam ACTION_WIDTH                   = `ACTION_WIDTH ;
   localparam OPENFLOW_ENTRY_WIDTH_ALL       = `OPENFLOW_ENTRY_WIDTH_ALL ;

   //------------------------ Wires/Regs -----------------------------
   // size is the action + input port
   wire  [DATA_WIDTH-1:0]                             wildcard_out_data    ;
   wire  [CTRL_WIDTH-1:0]                             wildcard_out_ctrl    ;
   wire                                               wildcard_out_wr      ;
   wire                                               wildcard_out_rdy     ;
   
   wire  [OPENFLOW_ACTION_WIDTH-1:0]                  actions              ;
   wire                                               actions_en           ;
   
   wire  [OPENFLOW_ACTION_WIDTH-1:0]                  exact_data;
   wire  [OPENFLOW_ACTION_WIDTH-1:0]                  wildcard_data;       

   wire  [CTRL_WIDTH-1:0]                             in_fifo_ctrl         ;
   wire  [DATA_WIDTH-1:0]                             in_fifo_data         ;

   wire  [OPENFLOW_ENTRY_WIDTH+31:0]                   flow_entry                 ;
   wire  [OPENFLOW_ENTRY_SRC_PORT_WIDTH-1:0]          flow_entry_src_port_parsed ;
   wire  [OPENFLOW_ENTRY_SRC_PORT_WIDTH-1:0]          flow_entry_src_port        ;
   wire  [PKT_SIZE_WIDTH-1:0]                         pkt_size                   ;

   reg   [31:0]                                       s_counter            ;
   reg   [27:0]                                       ns_counter           ;

   wire  [OPENFLOW_ACTION_WIDTH-1:0]                  result_fifo_dout     ;

   wire  [NUM_OUTPUT_QUEUES-1:0]                      pkts_dropped         ;
   
   //wire                                                         wildcard_loses;
   wire                                               wildcard_wins        ;
   
   wire  [OPENFLOW_WILDCARD_TABLE_DEPTH-1:0]          wildcard_address     ;
   wire  [OPENFLOW_WILDCARD_TABLE_DEPTH-1:0]          metadata_fifo_dout   ;
   
   wire                                               skip_lookup          ;

   wire                                               bram_cs              ;
   wire                                               bram_we              ;
   wire  [`PRIO_WIDTH-1:0]                             bram_addr            ;
   wire  [319:0]                                      lut_actions_in       ;
   wire  [319:0]                                      lut_actions_out      ;   
   
   wire  [`PRIO_WIDTH - 1:0]                           tcam_addr_out        ;
   wire  [OPENFLOW_ENTRY_WIDTH+31:0]                             tcam_data_out        ;
   wire  [OPENFLOW_ENTRY_WIDTH-1:0]                              tcam_data_mask_out   ;
   wire                                               tcam_we              ;
   wire  [OPENFLOW_ENTRY_WIDTH+31:0]                             tcam_data_in         ;
   wire  [OPENFLOW_ENTRY_WIDTH-1:0]                              tcam_data_mask_in    ;   
   
   wire  [7:0]                                        head_combine         ;
   
   wire  [OPENFLOW_WILDCARD_TABLE_DEPTH-1:0]          counter_addr_out     ;
   wire                                               counter_addr_rd      ;
   wire  [31:0]                                       pkt_counter_in       ;
   wire  [31:0]                                       byte_counter_in      ;  
   wire                                               wildcard_hit_dout    ;
   wire                                               actions_hit          ;
   wire  [3:0]                                        src_port             ;
   
   //------------------------- Modules -------------------------------

   /* each pkt can have up to:
    * - 18 bytes of Eth header including VLAN
    * - 15*4 = 60 bytes IP header including max number of options
    * - at least 4 bytes of tcp/udp header
    * total = 82 bytes approx 4 bits (8 bytes x 2^4 = 128 bytes)
    */
    
   /*fallthrough_small_fifo #(.WIDTH(CTRL_WIDTH+DATA_WIDTH), .MAX_DEPTH_BITS(4))
      input_fifo
        (.din           ({in_ctrl, in_data}),  // Data in
         .wr_en         (in_wr),             // Write enable
         .rd_en         (in_fifo_rd_en),    // Read the next word
         .dout          ({in_fifo_ctrl, in_fifo_data}),
         .prog_full     (),
         .full          (),
         .nearly_full   (in_fifo_nearly_full),
         .empty         (in_fifo_empty),
         .reset         (reset),
         .clk           (clk)
         );*/

    small_fifo 
    #(.WIDTH            (DATA_WIDTH+CTRL_WIDTH),
      .MAX_DEPTH_BITS   (5)
    )input_fifo
    (
      .din           ({in_ctrl, in_data}),  // Data in
      .wr_en         (in_wr),             // Write enable
      .rd_en         (in_fifo_rd_en),    // Read the next word
      .dout          ({in_fifo_ctrl, in_fifo_data}),
      .full          (),
      .prog_full     (),
      .nearly_full   (in_fifo_nearly_full),
      .empty         (in_fifo_empty),
      .reset         (reset),
      .clk           (clk)
    );


   header_parser
   #(.DATA_WIDTH                  (DATA_WIDTH),
     .CTRL_WIDTH                  (CTRL_WIDTH),
     .PKT_SIZE_WIDTH              (PKT_SIZE_WIDTH),
     .ADDITIONAL_WORD_SIZE        (`OPENFLOW_ENTRY_VLAN_ID_WIDTH),
     .ADDITIONAL_WORD_POS         (`OPENFLOW_ENTRY_VLAN_ID_POS),
     .ADDITIONAL_WORD_BITMASK     (16'hEFFF),  // --- PCP:3bits VID:12bits
     .ADDITIONAL_WORD_CTRL        (`VLAN_CTRL_WORD),
     .ADDITIONAL_WORD_DEFAULT     (16'hFFFF),
     .FLOW_ENTRY_SIZE_ALL         (OPENFLOW_ENTRY_WIDTH_ALL),
     .OPENFLOW_ENTRY_WIDTH        (OPENFLOW_ENTRY_WIDTH+32),
     .CURRENT_TABLE_ID            (CURRENT_TABLE_ID)
   )
   header_parser
   ( // --- Interface to the previous stage
      .in_data                   (in_data),
      .in_ctrl                   (in_ctrl),
      .in_wr                     (in_wr),
   
      // --- Interface to matchers
      .flow_entry                (flow_entry),
      //.flow_entry_src_port       (flow_entry_src_port_parsed),
      .pkt_size                  (pkt_size),
      .flow_entry_vld            (flow_entry_vld),
      
      .skip_lookup                 (skip_lookup),
      
      .head_combine              (head_combine),
      // --- Misc
      .reset                     (reset),
      .clk                       (clk)             
   );

   wildcard_match
   #(.NUM_OUTPUT_QUEUES             (NUM_OUTPUT_QUEUES),
     .PKT_SIZE_WIDTH                (PKT_SIZE_WIDTH),
     .OPENFLOW_ENTRY_WIDTH          (OPENFLOW_ENTRY_WIDTH+32),
     .OPENFLOW_WILDCARD_TABLE_SIZE  (OPENFLOW_WILDCARD_TABLE_SIZE),
     .CURRENT_TABLE_ID              (CURRENT_TABLE_ID),
     .OPENFLOW_WILDCARD_TABLE_DEPTH (OPENFLOW_WILDCARD_TABLE_DEPTH),
     .CMP_WIDTH                     (OPENFLOW_ENTRY_WIDTH+32)

   ) wildcard_match
   ( // --- Interface to flow entry collector
      .flow_entry                           (flow_entry),          // size OPENFLOW_ENTRY_WIDTH
      .flow_entry_vld                       (flow_entry_vld),
      .wildcard_match_rdy                   (wildcard_match_rdy),
      .pkt_size                             (pkt_size),            // size 12
 
      // --- Interface to arbiter
      .wildcard_hit                          (wildcard_hit),
      .wildcard_data                         (wildcard_data[OPENFLOW_ACTION_WIDTH-1 : 0]),
      .wildcard_data_vld                     (wildcard_data_vld),
      
      .skip_lookup                           (skip_lookup),
      
      .openflow_timer                        (s_counter), // bus size 32
 
      // --- Interface to Watchdog Timer
     // .table_flush                           (table_flush),
 
      .clk                                   (clk),
      .reset                                 (reset),
      .wildcard_address                      (wildcard_address),
    
      .bram_cs                               (bram_cs        ),
      .bram_we                               (bram_we        ),
      .bram_addr                             (bram_addr      ),
      .lut_actions_in                        (lut_actions_in ),
      .lut_actions_out                       (lut_actions_out),
      
      .tcam_addr                             (tcam_addr_out),
      .tcam_data_in                          (tcam_data_out),
      .tcam_data_mask_in                     (tcam_data_mask_out),
      .tcam_we                               (tcam_we      ),
      .tcam_data_out                         (tcam_data_in ),
      .tcam_data_mask_out                    (tcam_data_mask_in),
      
      .counter_addr_in                       (counter_addr_out),
      .counter_addr_rd                       (counter_addr_rd),
      .pkt_counter_out                       (pkt_counter_in),
      .byte_counter_out                      (byte_counter_in)
       
   );
   
   small_fifo
   #( .WIDTH                           (OPENFLOW_ACTION_WIDTH),
      .MAX_DEPTH_BITS                  (3)
    )result_fifo
    (
      .din           ({wildcard_data}), // Data in
      .wr_en         (wildcard_data_vld),   // Write enable
      .rd_en         (result_fifo_rd_en),   // Read the next word
      .dout          (result_fifo_dout),
      .full          (),
      .nearly_full   (result_fifo_nearly_full),
      .prog_full     (),
      .empty         (result_fifo_empty),
      .reset         (reset),
      .clk           (clk)
   );
    
   small_fifo
   #( .WIDTH               (1),
      .MAX_DEPTH_BITS      (3)
   )wildcard_hit_fifo
   (
      .din           (wildcard_hit), // Data in
      .wr_en         (wildcard_data_vld),   // Write enable
      .rd_en         (result_fifo_rd_en),   // Read the next word
      .dout          (wildcard_hit_dout),
      .full          (),
      .nearly_full   (result_fifo_nearly_full),
      .prog_full     (),
      .empty         (result_fifo_empty),
      .reset         (reset),
      .clk           (clk)
   );
                     
   small_fifo
   #(.WIDTH            (OPENFLOW_WILDCARD_TABLE_DEPTH),
     .MAX_DEPTH_BITS   (3)
    )metadata_fifo
   (
      .din           (wildcard_address), // Data in
      .wr_en         (wildcard_data_vld),   // Write enable
      .rd_en         (result_fifo_rd_en),   // Read the next word
      .dout          (metadata_fifo_dout),
      .full          (),
      .nearly_full   (metadata_fifo_nearly_full),
      .prog_full     (),
      .empty         (metadata_fifo_empty),
      .reset         (reset),
      .clk           (clk)
   );


    wildcard_processor
    #(
      .TABLE_NUM        (TABLE_NUM),
      .CURRENT_TABLE_ID (CURRENT_TABLE_ID)
    )wildcard_processor
    (
      .result_fifo_dout    (result_fifo_dout),
      .result_fifo_rd_en   (result_fifo_rd_en),
      .result_fifo_empty   (result_fifo_empty),
      
      // --- interface to input fifo
      .in_fifo_ctrl        (in_fifo_ctrl),
      .in_fifo_data        (in_fifo_data),
      .in_fifo_rd_en       (in_fifo_rd_en),
      .in_fifo_empty       (in_fifo_empty),
      
      // --- interface to output
      .out_wr              (wildcard_out_wr),
      .out_rdy             (wildcard_out_rdy),
      .out_data            (wildcard_out_data),
      .out_ctrl            (wildcard_out_ctrl),
      
      .actions             (actions),
      .actions_en          (actions_en),
      .actions_hit         (actions_hit),
      .wildcard_hit_dout   (wildcard_hit_dout),
      .src_port            (src_port),
      
      .clk                 (clk),
      .reset               (reset),
      
      .skip_lookup         (skip_lookup)
   );
    
   action_processor 
   #(
       .TABLE_NUM        (TABLE_NUM),
       .CURRENT_TABLE_ID (CURRENT_TABLE_ID)
   )action_processor
   (
       .actions_en       (actions_en),
       .actions_hit      (actions_hit),
       .actions          (actions),  
       .src_port         (src_port),
               
       .in_ctrl          (wildcard_out_ctrl),  
       .in_data          (wildcard_out_data),
       .in_rdy           (wildcard_out_rdy),   
       .in_wr            (wildcard_out_wr),
                    
       .out_data         (out_data),         
       .out_ctrl         (out_ctrl),
       .out_wr           (out_wr  ),
       .out_rdy          (out_rdy ),
       
       .config_sw_ok     (config_sw_ok),
                
       .clk              (clk),      
       .reset            (reset)
       
   );
     
   output_port_lookup_reg_master 
   #(
      .CMP_WIDTH  (OPENFLOW_ENTRY_WIDTH),
      .LUT_DEPTH(OPENFLOW_WILDCARD_TABLE_SIZE),
      .TABLE_NUM(TABLE_NUM-1),
      .CURRENT_TABLE_ID (CURRENT_TABLE_ID)
   )
   output_port_lookup_reg_master
   (
   .data_output_port_lookup_i    (data_output_port_lookup_i),
   .addr_output_port_lookup_i    (addr_output_port_lookup_i),
   .req_output_port_lookup_i     (req_output_port_lookup_i ),
   .rw_output_port_lookup_i      (rw_output_port_lookup_i  ),
   .ack_output_port_lookup_o     (ack_output_port_lookup_o ),
   .data_output_port_lookup_o    (data_output_port_lookup_o  ),
   
   .bram_cs                      (bram_cs),
   .bram_we                      (bram_we),
   .bram_addr                    (bram_addr),
   .lut_actions_in               (lut_actions_in),
   .lut_actions_out              (lut_actions_out),
                
   .tcam_addr_out                (tcam_addr_out),
   .tcam_data_out                (tcam_data_out),
   .tcam_data_mask_out           (tcam_data_mask_out),
   .tcam_we                      (tcam_we),
   .tcam_data_in                 (tcam_data_in),
   .tcam_data_mask_in            (tcam_data_mask_in),
   
   .counter_addr_out             (counter_addr_out),
   .counter_addr_rd              (counter_addr_rd),
   .pkt_counter_in               (pkt_counter_in),
   .byte_counter_in              (byte_counter_in),
   
   .head_combine                 (head_combine),
      
   .clk                          (clk),
   .reset                        (reset)
   );
/*
   generic_regs
     #(.UDP_REG_SRC_WIDTH (UDP_REG_SRC_WIDTH),
       .TAG (OPENFLOW_LOOKUP_BLOCK_ADDR),
       .REG_ADDR_WIDTH (OPENFLOW_LOOKUP_REG_ADDR_WIDTH),
       .NUM_COUNTERS (2*2                               // hits and misses for both tables
                      + NUM_OUTPUT_QUEUES               // num dropped per port
                      ),
       .NUM_SOFTWARE_REGS (2),
       .NUM_HARDWARE_REGS (2),
       .COUNTER_INPUT_WIDTH (1)
       )
   generic_regs
     (
      .reg_req_in        (wildcard_reg_req_out),
      .reg_ack_in        (wildcard_reg_ack_out),
      .reg_rd_wr_L_in    (wildcard_reg_rd_wr_L_out),
      .reg_addr_in       (wildcard_reg_addr_out),
      .reg_data_in       (wildcard_reg_data_out),
      .reg_src_in        (wildcard_reg_src_out),

      .reg_req_out       (reg_req_out),
      .reg_ack_out       (reg_ack_out),
      .reg_rd_wr_L_out   (reg_rd_wr_L_out),
      .reg_addr_out      (reg_addr_out),
      .reg_data_out      (reg_data_out),
      .reg_src_out       (reg_src_out),

      // --- counters interface
      .counter_updates   ({pkts_dropped,
                           1'b0,//exact_wins,
                           1'b0,//exact_miss,
                           wildcard_wins,
                           wildcard_loses}
                          ),
      .counter_decrement ({(4+NUM_OUTPUT_QUEUES){1'b0}}),

      // --- SW regs interface
      .software_regs     (),

      // --- HW regs interface
      .hardware_regs     ({32'h0,
                           s_counter}),

      .clk               (clk),
      .reset             (reset));
*/
   //--------------------------- Logic ------------------------------
   assign in_rdy = !in_fifo_nearly_full && wildcard_match_rdy ;

   // timer
   always @(posedge clk) begin
      if(reset) begin
         ns_counter <= 0;
         s_counter  <= 0;
      end
      else begin
         if(ns_counter == (1_000_000_000/`FAST_CLOCK_PERIOD - 1'b1)) begin
            s_counter  <= s_counter + 1'b1;
            ns_counter <= 0;
         end
         else begin
            ns_counter <= ns_counter + 1'b1;
         end
      end // else: !if(reset)
   end // always @ (posedge clk)


endmodule // router_output_port
