///////////////////////////////////////////////////////////////////////////////
// $Id$
//
// Module: vlan_adder.v
// Project: NF2.1 OpenFlow Switch
// Author: Jad Naous <jnaous@stanford.edu> / Tatsuya Yabe <tyabe@stanford.edu>
// Description: adds the VLAN tag if it finds it in a module header. If there
//              are multiple ones, it only uses the first one it finds.
//
///////////////////////////////////////////////////////////////////////////////

  module vlan_adder
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
   localparam NUM_STATES         = 5;
   localparam FIND_VLAN_HDR      = 1,
              WAIT_SOP           = 2,
              ADD_VLAN           = 4,
              WRITE_MODIFIED_PKT = 8,
              WRITE_LAST_PKT     = 16;

   //---------------------- Wires/Regs -------------------------------

   wire [DATA_WIDTH-1:0] fifo_data_out;
   wire [CTRL_WIDTH-1:0] fifo_ctrl_out;

   reg [15:0]            vlan_tag_nxt, vlan_tag;
   reg [31:0]            latch_data_nxt, latch_data;
   reg [7:0]             latch_ctrl_nxt, latch_ctrl;

   reg [NUM_STATES-1:0]  process_state_nxt, process_state;
   reg                   fifo_rd_en;
   reg                   out_wr_nxt;
   reg [DATA_WIDTH-1:0]  out_data_nxt;
   reg [CTRL_WIDTH-1:0]  out_ctrl_nxt;

   //----------------------- Modules ---------------------------------

   fallthrough_small_fifo
     #(.WIDTH(CTRL_WIDTH+DATA_WIDTH), .MAX_DEPTH_BITS(3))
     input_fifo
       (.din           ({in_ctrl, in_data}),  // Data in
        .wr_en         (in_wr),             // Write enable
        .rd_en         (fifo_rd_en),    // Read the next word
        .dout          ({fifo_ctrl_out, fifo_data_out}),
        .full          (),
        .nearly_full   (fifo_nearly_full),
        .empty         (fifo_empty),
        .reset         (reset),
        .clk           (clk)
        );

   //------------------------ Logic ----------------------------------

   assign in_rdy = !fifo_nearly_full;

   always @(*) begin
      process_state_nxt = process_state;
      fifo_rd_en        = 0;
      out_wr_nxt        = 0;
      out_data_nxt      = fifo_data_out;
      out_ctrl_nxt      = fifo_ctrl_out;
      vlan_tag_nxt      = vlan_tag;
      latch_data_nxt    = latch_data;
      latch_ctrl_nxt    = latch_ctrl;

      case (process_state)

         FIND_VLAN_HDR: begin
            if (out_rdy && !fifo_empty) begin
               fifo_rd_en = 1;
               if (fifo_ctrl_out == `VLAN_CTRL_WORD) begin
                  out_wr_nxt        = 0;
                  vlan_tag_nxt      = fifo_data_out[15:0];
                  process_state_nxt = WAIT_SOP;
               end
               else begin
                  out_wr_nxt = 1;
               end
            end
         end // case: FIND_VLAN_HDR

         WAIT_SOP: begin
            if (out_rdy && !fifo_empty) begin
               fifo_rd_en = 1;
               out_wr_nxt = 1;
               if (fifo_ctrl_out == `IO_QUEUE_STAGE_NUM) begin
                  // Increment byte-count and word-count since we will add vlan tags
                  out_data_nxt[`IOQ_BYTE_LEN_POS+15:`IOQ_BYTE_LEN_POS]
                     = fifo_data_out[`IOQ_BYTE_LEN_POS+15:`IOQ_BYTE_LEN_POS] + 4;
                  out_data_nxt[`IOQ_WORD_LEN_POS+15:`IOQ_WORD_LEN_POS]
                     = ceildiv((fifo_data_out[`IOQ_BYTE_LEN_POS+15:`IOQ_BYTE_LEN_POS] + 4), 8);
               end
               else if (fifo_ctrl_out == 0) begin
                  process_state_nxt = ADD_VLAN;
               end
            end
         end // case: WAIT_SOP

         ADD_VLAN: begin
            if (out_rdy && !fifo_empty) begin
               //insert vlan_tag into second word
               fifo_rd_en        = 1;
               out_wr_nxt        = 1;
               if (fifo_ctrl_out == 0) begin
                  out_data_nxt      = {fifo_data_out[63:32], `VLAN_ETHERTYPE, vlan_tag};
                  latch_data_nxt    = fifo_data_out[31:0];
                  latch_ctrl_nxt    = fifo_ctrl_out;
                  process_state_nxt = WRITE_MODIFIED_PKT;
               end
               // Abnormal condition.
               // fifo_ctrl_out should be zero on this state but if it isn't
               // then give up continueing and go back to initial state
               else begin
                  process_state_nxt = FIND_VLAN_HDR;
               end
            end
         end // case: ADD_VLAN

         WRITE_MODIFIED_PKT: begin
            if (out_rdy && !fifo_empty) begin
               fifo_rd_en     = 1;
               out_wr_nxt     = 1;
               out_data_nxt   = {latch_data, fifo_data_out[63:32]};
               latch_data_nxt = fifo_data_out[31:0];
               latch_ctrl_nxt = fifo_ctrl_out;
               if (fifo_ctrl_out[7:4] != 0) begin
                  out_ctrl_nxt = (fifo_ctrl_out >> 4);
                  process_state_nxt = FIND_VLAN_HDR;
               end
               else if (fifo_ctrl_out[3:0] != 0) begin
                  out_ctrl_nxt = 0;
                  process_state_nxt = WRITE_LAST_PKT;
               end
            end
         end // case: WRITE_MODIFIED_PKT

         WRITE_LAST_PKT: begin
            if (out_rdy) begin
               out_wr_nxt     = 1;
               out_data_nxt   = {latch_data, 32'h0};
               out_ctrl_nxt   = latch_ctrl << 4;
               process_state_nxt = FIND_VLAN_HDR;
            end
         end // case: WRITE_LAST_PKT

      endcase // case(process_state)
   end // always @ (*)

   always @(posedge clk) begin
      if(reset) begin
         process_state    <= FIND_VLAN_HDR;
         out_wr           <= 0;
         out_data         <= 0;
         out_ctrl         <= 1;
         latch_data       <= 0;
         latch_ctrl       <= 0;
         vlan_tag         <= 0;
      end
      else begin
         process_state    <= process_state_nxt;
         out_wr           <= out_wr_nxt;
         out_data         <= out_data_nxt;
         out_ctrl         <= out_ctrl_nxt;
         latch_data       <= latch_data_nxt;
         latch_ctrl       <= latch_ctrl_nxt;
         vlan_tag         <= vlan_tag_nxt;
      end // else: !if(reset)
   end // always @ (posedge clk)

endmodule // vlan_remover
