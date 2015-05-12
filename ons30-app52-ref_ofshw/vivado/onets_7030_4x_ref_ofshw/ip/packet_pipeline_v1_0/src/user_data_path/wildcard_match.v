///////////////////////////////////////////////////////////////////////////////
// $Id: wildcard_match.v 5697 2009-06-17 22:32:11Z tyabe $
//
// Module: wildcard_match.v
// Project: NF2.1 OpenFlow Switch
// Author: Jad Naous <jnaous@stanford.edu>
// Description: matches a flow entry allowing a wildcard
//   Uses a register block to maintain counters associated with the table
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


  module wildcard_match
    #(parameter NUM_OUTPUT_QUEUES = 8,                  // obvious
      parameter PKT_SIZE_WIDTH = 12,                    // number of bits for pkt size
      parameter UDP_REG_SRC_WIDTH = 2,                   // identifies which module started this request
      parameter OPENFLOW_WILDCARD_LOOKUP_REG_ADDR_WIDTH = 10,
      parameter OPENFLOW_WILDCARD_LOOKUP_BLOCK_ADDR = 13'h1,
      parameter OPENFLOW_ENTRY_WIDTH = 64,
      parameter OPENFLOW_WILDCARD_TABLE_SIZE = 16,
      parameter CURRENT_TABLE_ID = 0
      )
   (// --- Interface for lookups
    input [OPENFLOW_ENTRY_WIDTH-1:0]       flow_entry,
    input                                  flow_entry_vld,
    input [PKT_SIZE_WIDTH-1:0]             pkt_size,
    output                                 wildcard_match_rdy,
    //input [`OPENFLOW_ENTRY_SRC_PORT_WIDTH-1:0] flow_entry_src_port_parsed,

    // --- Interface to arbiter
    output                                 wildcard_hit,
    //output                                 wildcard_miss,
    output [`OPENFLOW_ACTION_WIDTH-1:0]    wildcard_data,
    //output [`OPENFLOW_ENTRY_SRC_PORT_WIDTH-1:0] flow_entry_src_port,
    output                                 wildcard_data_vld,
    //input                                  wildcard_wins,
    //input                                  wildcard_loses,
    
    input tcam_we,
    input [`PRIO_WIDTH+`ACTION_WIDTH-1:0] tcam_addr,
    output [31:0]tcam_data_out, 
    input [31:0]tcam_data_in,
    
    input bram_cs,
    input bram_we,
    input [`PRIO_WIDTH-1:0]bram_addr,
    input [319:0]lut_actions_in,  
    output [319:0]lut_actions_out,
    
    input [3:0] counter_addr_in,
    input counter_addr_rd,
    output [31:0]pkt_counter_out,
    output [31:0]byte_counter_out,
   
   input                            skip_lookup,

    // --- Interface to Watchdog Timer
    input                                  table_flush,

    // --- Misc
    input [31:0]                           openflow_timer,
    input                                  reset,
    input                                  clk,
    output [3:0]            wildcard_address
   );

   `LOG2_FUNC
   `CEILDIV_FUNC

   //-------------------- Internal Parameters ------------------------
   localparam WILDCARD_NUM_DATA_WORDS_USED = ceildiv(`OPENFLOW_ACTION_WIDTH,`CPCI_NF2_DATA_WIDTH);
   localparam WILDCARD_NUM_CMP_WORDS_USED  = ceildiv(OPENFLOW_ENTRY_WIDTH, `CPCI_NF2_DATA_WIDTH);
   localparam WILDCARD_NUM_REGS_USED = (2 // for the read and write address registers
                                        + WILDCARD_NUM_DATA_WORDS_USED // for data associated with an entry
                                        + WILDCARD_NUM_CMP_WORDS_USED  // for the data to match on
                                        + WILDCARD_NUM_CMP_WORDS_USED  // for the don't cares
                                        );

   localparam LUT_DEPTH_BITS = log2(OPENFLOW_WILDCARD_TABLE_SIZE);
   localparam METADATA_WIDTH = LUT_DEPTH_BITS;

   localparam SIMULATION = 0
	      // synthesis translate_off
	      || 1
	      // synthesis translate_on
	      ;

    
   //---------------------- Wires and regs----------------------------
   wire                                                      cam_busy;
   wire                                                      cam_match;
   wire [LUT_DEPTH_BITS-1:0]                                 cam_match_addr;

   wire [OPENFLOW_ENTRY_WIDTH-1:0]                           cam_din;

   //wire [WILDCARD_NUM_CMP_WORDS_USED-1:0]                    cam_busy_ind;


   //wire [LUT_DEPTH_BITS-1:0]                                 wildcard_address;
   wire [LUT_DEPTH_BITS-1:0]                                 dout_wildcard_address;

   reg [OPENFLOW_WILDCARD_TABLE_SIZE-1:0]                    wildcard_hit_address_decoded;
   wire [OPENFLOW_WILDCARD_TABLE_SIZE*PKT_SIZE_WIDTH - 1:0]  wildcard_hit_address_decoded_expanded;
   wire [OPENFLOW_WILDCARD_TABLE_SIZE*PKT_SIZE_WIDTH - 1:0]  wildcard_entry_hit_byte_size;
   wire [OPENFLOW_WILDCARD_TABLE_SIZE*32 - 1:0]              wildcard_entry_last_seen_timestamps;

   wire [PKT_SIZE_WIDTH-1:0]                                 dout_pkt_size;

   reg [PKT_SIZE_WIDTH-1:0]                                  wildcard_entry_hit_byte_size_word [OPENFLOW_WILDCARD_TABLE_SIZE-1:0];
   reg [31:0]                                                wildcard_entry_last_seen_timestamps_words[OPENFLOW_WILDCARD_TABLE_SIZE-1:0];

   integer                                                   i;
   wire [2 * OPENFLOW_WILDCARD_TABLE_SIZE * OPENFLOW_ENTRY_WIDTH - 1 :0]  lut_linear;
   
   wire [OPENFLOW_ENTRY_WIDTH-1:0]cam_cmp_din;
   //------------------------- Modules -------------------------------
   assign wildcard_match_rdy = 1;

   wildcard_lut_action
     #(.CMP_WIDTH (OPENFLOW_ENTRY_WIDTH),
       .DATA_WIDTH (`OPENFLOW_ACTION_WIDTH),
       .LUT_DEPTH  (OPENFLOW_WILDCARD_TABLE_SIZE),
       .TAG (OPENFLOW_WILDCARD_LOOKUP_BLOCK_ADDR),
       .REG_ADDR_WIDTH (OPENFLOW_WILDCARD_LOOKUP_REG_ADDR_WIDTH),
       .CURRENT_TABLE_ID(CURRENT_TABLE_ID)
       )wildcard_lut_action
         (// --- Interface for lookups
          .lookup_req          (flow_entry_vld),
          .lookup_cmp_data     (flow_entry),
//          .lookup_cmp_dmask    ({OPENFLOW_ENTRY_WIDTH{1'b0}}),
          .lookup_ack          (wildcard_data_vld),
          .lookup_hit          (wildcard_hit),
          .lookup_data         (wildcard_data),
          .lookup_address      (wildcard_address),

          // --- Interface to registers
          .bram_cs                               (bram_cs        ),
          .bram_we                               (bram_we        ),
          .bram_addr                             (bram_addr      ),
          .lut_actions_in                        (lut_actions_in ),
          .lut_actions_out                       (lut_actions_out),

          // --- CAM interface
          .cam_busy            (cam_busy),
          .cam_match           (cam_match),
          .cam_match_addr      (cam_match_addr),
          .cam_cmp_din         (cam_cmp_din),


          // --- Watchdog Timer Interface
          .table_flush         (table_flush),

          // --- Misc
          .reset               (reset),
          .clk                 (clk),
          
          .skip_lookup          (skip_lookup)
          );

   wildcard_tcam 
   #(
      .CMP_WIDTH (OPENFLOW_ENTRY_WIDTH),
      .DEPTH (OPENFLOW_WILDCARD_TABLE_SIZE),
      .DEPTH_BITS (log2(OPENFLOW_WILDCARD_TABLE_SIZE)),
      .ENCODE (0),
      .CURRENT_TABLE_ID(CURRENT_TABLE_ID)
   ) wildcard_tcam
   (
      // Outputs
      .busy                             (cam_busy),
      .match                            (cam_match),
      .match_addr                       (cam_match_addr),
      // Inputs
      .clk                              (clk),
      .reset                            (reset),
      .cmp_din                          (cam_cmp_din),
      .cmp_req                          (flow_entry_vld),

         .tcam_addr           (tcam_addr),
         .tcam_data_in        (tcam_data_in),
         .we                  (tcam_we      ),
         .tcam_data_out       ( tcam_data_out)
   );

   small_fifo
     #(.WIDTH(PKT_SIZE_WIDTH),
       .MAX_DEPTH_BITS(3))
      pkt_size_fifo
        (.din           (pkt_size),
         .wr_en         (flow_entry_vld),
         .rd_en         (fifo_rd_en),
         .dout          (dout_pkt_size),
         .full          (),
         .prog_full     (),
         .nearly_full   (),
         .empty         (pkt_size_fifo_empty),
         .reset         (reset),
         .clk           (clk)
         );

    wildcard_counter
    #(.ADDR_WIDTH(LUT_DEPTH_BITS),
      .PKT_WIDTH(PKT_SIZE_WIDTH),
      .LUT_DEPTH(OPENFLOW_WILDCARD_TABLE_SIZE),
      .DEPTH_BITS (log2(OPENFLOW_WILDCARD_TABLE_SIZE))
      )
     wildcard_counter
    (
      .clk                    (clk),
      .reset                    (reset),
      .fifo_rd_en             (fifo_rd_en),
      .dout_pkt_size          (dout_pkt_size),
      .wildcard_data_vld          (wildcard_data_vld),
      .wildcard_hit          (wildcard_hit),
      .wildcard_address      (wildcard_address),
      .counter_addr_in (counter_addr_in),
      .counter_addr_rd  (counter_addr_rd),
      .pkt_counter_out   (pkt_counter_out),
      .byte_counter_out  (byte_counter_out)
      
    );

         
         
  /* fallthrough_small_fifo
     #(.WIDTH(`OPENFLOW_ENTRY_SRC_PORT_WIDTH),
       .MAX_DEPTH_BITS(3))
      src_port_fifo
        (.din           (flow_entry_src_port_parsed),     // Data in
         .wr_en         (flow_entry_vld),                 // Write enable
         .rd_en         (wildcard_data_vld),              // Read the next word
         .dout          (flow_entry_src_port),
         .full          (),
         .nearly_full   (),
         .empty         (),
         .reset         (reset),
         .clk           (clk)
   );*/
   //-------------------------- Logic --------------------------------
  // assign wildcard_miss = wildcard_data_vld & !wildcard_hit;
   //assign fifo_rd_en = wildcard_wins || wildcard_loses;

   /* update the generic register interface if wildcard matching
    * wins the arbitration */
    /*
   always @(*) begin
      wildcard_hit_address_decoded = 0;
      for(i=0; i<OPENFLOW_WILDCARD_TABLE_SIZE; i=i+1) begin
         wildcard_entry_hit_byte_size_word[i] = 0;
      end
      if(wildcard_wins) begin
         wildcard_hit_address_decoded[dout_wildcard_address] = 1;
         wildcard_entry_hit_byte_size_word[dout_wildcard_address]
           = dout_pkt_size;
      end
   end 

   generate
      genvar gi;
      for(gi=0; gi<OPENFLOW_WILDCARD_TABLE_SIZE; gi=gi+1) begin:concat
         assign wildcard_entry_hit_byte_size[gi*PKT_SIZE_WIDTH +: PKT_SIZE_WIDTH]
                = wildcard_entry_hit_byte_size_word[gi];
         assign wildcard_entry_last_seen_timestamps[gi*32 +: 32]
                = wildcard_entry_last_seen_timestamps_words[gi];
         assign wildcard_hit_address_decoded_expanded[gi*PKT_SIZE_WIDTH +: PKT_SIZE_WIDTH]
                ={{(PKT_SIZE_WIDTH-1){1'b0}}, wildcard_hit_address_decoded[gi]};
      end
   endgenerate

   // update the timestamp of the entry
   always @(posedge clk) begin
      if(cam_we) begin
         wildcard_entry_last_seen_timestamps_words[cam_wr_addr] <= openflow_timer;
      end
      else if(wildcard_wins) begin
         wildcard_entry_last_seen_timestamps_words[dout_wildcard_address] <= openflow_timer;
      end
   end */

/*
   generic_regs
     #(.UDP_REG_SRC_WIDTH (UDP_REG_SRC_WIDTH),
       .TAG (OPENFLOW_WILDCARD_LOOKUP_BLOCK_ADDR),
       .REG_ADDR_WIDTH (OPENFLOW_WILDCARD_LOOKUP_REG_ADDR_WIDTH),
       .NUM_COUNTERS (OPENFLOW_WILDCARD_TABLE_SIZE  // for number of bytes
                      +OPENFLOW_WILDCARD_TABLE_SIZE // for number of packets
                      ),

       .RESET_ON_READ (SIMULATION),
       .NUM_SOFTWARE_REGS (2),
       .NUM_HARDWARE_REGS (OPENFLOW_WILDCARD_TABLE_SIZE), // for last seen timestamps
       .COUNTER_INPUT_WIDTH (PKT_SIZE_WIDTH), // max pkt size
       .REG_START_ADDR (WILDCARD_NUM_REGS_USED) // used for the access to the cam/lut
       )
   generic_regs
     (
      .reg_req_in        (cam_reg_req_out),
      .reg_ack_in        (cam_reg_ack_out),
      .reg_rd_wr_L_in    (cam_reg_rd_wr_L_out),
      .reg_addr_in       (cam_reg_addr_out),
      .reg_data_in       (cam_reg_data_out),
      .reg_src_in        (cam_reg_src_out),

      .reg_req_out       (reg_req_out),
      .reg_ack_out       (reg_ack_out),
      .reg_rd_wr_L_out   (reg_rd_wr_L_out),
      .reg_addr_out      (reg_addr_out),
      .reg_data_out      (reg_data_out),
      .reg_src_out       (reg_src_out),

      // --- counters interface
      .counter_updates   ({wildcard_hit_address_decoded_expanded,
                           wildcard_entry_hit_byte_size}
                          ),
      .counter_decrement ({(2*OPENFLOW_WILDCARD_TABLE_SIZE){1'b0}}),

      // --- SW regs interface
      .software_regs     (),

      // --- HW regs interface
      .hardware_regs     ({wildcard_entry_last_seen_timestamps}),

      .clk               (clk),
      .reset             (reset));*/

   /* we might receive four input packets simultaneously from ethernet. In addition,
    * we might receive a pkt from DMA. So we need at least 5 spots. */

endmodule // wildcard_match


