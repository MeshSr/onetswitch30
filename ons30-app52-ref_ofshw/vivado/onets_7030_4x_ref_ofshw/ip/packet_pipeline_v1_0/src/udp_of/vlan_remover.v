///////////////////////////////////////////////////////////////////////////////
// $Id$
//
// Module: vlan_remover.v
// Project: NF2.1 OpenFlow Switch
// Author: Jad Naous <jnaous@stanford.edu>
// Description: removes the VLAN info if existing and puts it in a module header.
///////////////////////////////////////////////////////////////////////////////

  module vlan_remover
    #(parameter DATA_WIDTH = 64,
      parameter CTRL_WIDTH = DATA_WIDTH/8
      )
   (// --- Interface to the previous stage
    input  [DATA_WIDTH-1:0]                in_data,
    input  [CTRL_WIDTH-1:0]                in_ctrl,
    input                                  in_wr,
    output                                 in_rdy,

    // --- Interface to the next stage
    output reg [DATA_WIDTH-1:0]            out_data,
    output reg [CTRL_WIDTH-1:0]            out_ctrl,
    output reg                             out_wr,
    input                                  out_rdy,

    // --- Misc
    input                                  reset,
    input                                  clk
   );

   `CEILDIV_FUNC

   //------------------ Internal Parameters --------------------------
   localparam SKIP_HDRS              = 1,
              CHECK_VLAN             = 2,
              GET_VLAN_TAG           = 4,
              WAIT_EOP               = 8;

   localparam NUM_STATES             = 7;
   localparam WAIT_PREPROCESS        = 1,
              ADD_MODULE_HEADER      = 2,
              WRITE_MODULE_HEADERS   = 4,
              REMOVE_VLAN            = 8,
              WRITE_MODIFIED_PKT     = 16,
              WRITE_LAST_WORD        = 32,
              SEND_UNMODIFIED_PKT    = 64;

   //---------------------- Wires/Regs -------------------------------
   wire [DATA_WIDTH-1:0] fifo_data_out;
   wire [CTRL_WIDTH-1:0] fifo_ctrl_out;

   reg [3:0]             preprocess_state;
   reg [15:0]            vlan_tag;
   reg                   tag_vld, tag_found;

   reg [NUM_STATES-1:0]  process_state_nxt, process_state;
   reg                   fifo_rd_en;
   reg                   out_wr_nxt;
   reg [DATA_WIDTH-1:0]  out_data_nxt;
   reg [CTRL_WIDTH-1:0]  out_ctrl_nxt;
   reg [DATA_WIDTH-1:0]  fifo_data_out_d1;
   reg [CTRL_WIDTH-1:0]  fifo_ctrl_out_d1;

   //----------------------- Modules ---------------------------------
   fallthrough_small_fifo
     #(.WIDTH(CTRL_WIDTH+DATA_WIDTH), .MAX_DEPTH_BITS(3))
     input_fifo
       (.din           ({in_ctrl, in_data}),  // Data in
        .wr_en         (in_wr),             // Write enable
        .rd_en         (fifo_rd_en),    // Read the next word
        .dout          ({fifo_ctrl_out, fifo_data_out}),
        .full          (),
        .prog_full     (),
        .nearly_full   (fifo_nearly_full),
        .empty         (fifo_empty),
        .reset         (reset),
        .clk           (clk)
        );


   //------------------------ Logic ----------------------------------

   assign in_rdy = !fifo_nearly_full;

   /* This state machine checks if there is a VLAN id and gets it */
   always @(posedge clk) begin
      if(reset) begin
         preprocess_state    <= SKIP_HDRS;
         vlan_tag            <= 0;
         tag_vld             <= 0;
         tag_found           <= 0;
      end
      else begin
         case (preprocess_state)
            SKIP_HDRS: begin
               if (in_wr && in_ctrl==0) begin
                  preprocess_state <= CHECK_VLAN;
               end
            end

            CHECK_VLAN: begin
               if(in_wr) begin
                  if(in_data[31:16] == `VLAN_ETHERTYPE) begin
                     vlan_tag            <= in_data[15:0];
                     preprocess_state    <= GET_VLAN_TAG;
                  end
                  else begin
                     preprocess_state    <= WAIT_EOP;
                     tag_vld             <= 1'b1;
                     tag_found           <= 1'b0;
                  end
               end
            end

            GET_VLAN_TAG: begin
               if(in_wr) begin
                  tag_vld             <= 1'b1;
                  tag_found           <= 1'b1;
                  preprocess_state    <= WAIT_EOP;
               end
            end

            WAIT_EOP: begin
               if(in_wr && in_ctrl != 0) begin
                  tag_vld             <= 0;
                  preprocess_state    <= SKIP_HDRS;
               end
            end
         endcase // case(preprocess_state)
      end // else: !if(reset)
   end // always @ (posedge clk)

   /* This state machine will remove the VLAN info from the pkt */
   always @(*) begin
      process_state_nxt   = process_state;
      fifo_rd_en          = 0;
      out_wr_nxt          = 0;
      out_data_nxt        = fifo_data_out;
      out_ctrl_nxt        = fifo_ctrl_out;

      case (process_state)
         WAIT_PREPROCESS: begin
            if(tag_vld) begin
               if(tag_found) begin
                  process_state_nxt = ADD_MODULE_HEADER;
               end
               else begin
                  process_state_nxt = SEND_UNMODIFIED_PKT;
               end
            end // if (tag_vld)
         end // case: WAIT_PREPROCESS

         ADD_MODULE_HEADER: begin
            if(out_rdy) begin
               fifo_rd_en          = 1;
               out_wr_nxt          = 1;
               out_data_nxt        = {{(DATA_WIDTH-16){1'b0}}, vlan_tag};
               out_ctrl_nxt        = `VLAN_CTRL_WORD;
               process_state_nxt   = WRITE_MODULE_HEADERS;
            end
         end

         WRITE_MODULE_HEADERS: begin
            if(out_rdy) begin
               fifo_rd_en     = 1;
               out_wr_nxt     = 1;
               out_data_nxt   = fifo_data_out_d1;
               out_ctrl_nxt   = fifo_ctrl_out_d1;
               if(fifo_ctrl_out_d1 == `IO_QUEUE_STAGE_NUM) begin
                  // Decrement byte-count and word-count in IOQ since we will remove vlan tags
                  out_data_nxt[`IOQ_BYTE_LEN_POS+15:`IOQ_BYTE_LEN_POS]
                     = fifo_data_out_d1[`IOQ_BYTE_LEN_POS+15:`IOQ_BYTE_LEN_POS] - 4;
                  out_data_nxt[`IOQ_WORD_LEN_POS+15:`IOQ_WORD_LEN_POS]
                     = ceildiv((fifo_data_out_d1[`IOQ_BYTE_LEN_POS+15:`IOQ_BYTE_LEN_POS] - 4), 8);
               end
               if(fifo_ctrl_out_d1 == 0) begin
                  process_state_nxt   = REMOVE_VLAN;
               end
            end
         end // case: WRITE_MODULE_HEADERS

         REMOVE_VLAN: begin
            if(out_rdy) begin
               process_state_nxt   = WRITE_MODIFIED_PKT;
               fifo_rd_en          = 1;
               out_wr_nxt          = 1;
               out_data_nxt        = {fifo_data_out_d1[63:32], fifo_data_out[63:32]};
               out_ctrl_nxt        = fifo_ctrl_out_d1;
            end
         end // case: REMOVE_VLAN

         WRITE_MODIFIED_PKT: begin
            if(out_rdy && !fifo_empty) begin
               fifo_rd_en          = 1;
               out_wr_nxt          = 1;
               out_data_nxt        = {fifo_data_out_d1[31:0], fifo_data_out[63:32]};
               out_ctrl_nxt        = fifo_ctrl_out_d1;
               if(fifo_ctrl_out != 0) begin
                  if(fifo_ctrl_out[7:4] != 0) begin
                     out_ctrl_nxt = (fifo_ctrl_out >> 4);
                  end
                  // We will write one more word in any case
                  process_state_nxt = WRITE_LAST_WORD;
               end
            end
         end // case: WRITE_MODIFIED_PKT

         WRITE_LAST_WORD: begin
            if(out_rdy) begin
               out_wr_nxt          = 1;
               out_data_nxt        = {fifo_data_out_d1[31:0], 32'h600d_f00d};
               if(fifo_ctrl_out_d1[3:0] != 0) begin
                  out_ctrl_nxt = (fifo_ctrl_out_d1 << 4);
               end
               else begin
                  // The data on this stage doesn't have meaningful contents.
                  // Put no-meaning value here.
                  out_ctrl_nxt = 1;
               end
               if(tag_vld && tag_found) begin
                  process_state_nxt = ADD_MODULE_HEADER;
               end
               else if(tag_vld && !tag_found) begin
                  process_state_nxt = SEND_UNMODIFIED_PKT;
               end
               else begin
                  process_state_nxt = WAIT_PREPROCESS;
               end
            end // if (out_rdy)
         end // case: WRITE_LAST_WORD

         SEND_UNMODIFIED_PKT: begin
            if(out_rdy && !fifo_empty) begin
               if(fifo_ctrl_out_d1 == 0 && fifo_ctrl_out != 0) begin
                  if(tag_vld && tag_found) begin
                     process_state_nxt = ADD_MODULE_HEADER;
                  end
                  else if(tag_vld && !tag_found) begin
                     process_state_nxt = SEND_UNMODIFIED_PKT;
                  end
                  else begin
                     process_state_nxt = WAIT_PREPROCESS;
                  end
               end
               fifo_rd_en          = 1;
               out_wr_nxt          = 1;
               out_data_nxt        = fifo_data_out;
               out_ctrl_nxt        = fifo_ctrl_out;
            end
         end // case: SEND_UNMODIFIED_PKT

      endcase // case(process_state)
   end // always @ (*)

   always @(posedge clk) begin
      if(reset) begin
         process_state    <= WAIT_PREPROCESS;
         out_wr           <= 0;
         out_data         <= 0;
         out_ctrl         <= 1;
         fifo_data_out_d1 <= 0;
         fifo_ctrl_out_d1 <= 1;
      end
      else begin
         process_state    <= process_state_nxt;
         out_wr           <= out_wr_nxt;
         out_data         <= out_data_nxt;
         out_ctrl         <= out_ctrl_nxt;
         if(fifo_rd_en) begin
            fifo_data_out_d1 <= fifo_data_out;
            fifo_ctrl_out_d1 <= fifo_ctrl_out;
         end
      end // else: !if(reset)
   end // always @ (posedge clk)

endmodule // vlan_remover

