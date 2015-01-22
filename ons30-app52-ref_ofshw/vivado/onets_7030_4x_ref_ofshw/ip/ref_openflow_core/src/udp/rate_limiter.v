///////////////////////////////////////////////////////////////////////////////
// vim:set shiftwidth=3 softtabstop=3 expandtab:
// $Id: rate_limiter.v 5803 2009-08-04 21:23:10Z g9coving $
//
// Module: rate_limiter.v
// Project: rate_limiter
// Description: Limits the rate at which packets pass through
//
// Modified to allow more fine-grained control. Uses a token-bucket flow
// control mechanism to allow very fine-grained control.
//
// Note: Disabling the rate limiter will clear any pending delay
//
///////////////////////////////////////////////////////////////////////////////

module rate_limiter
  #(
      parameter DATA_WIDTH = 64,
      parameter CTRL_WIDTH = DATA_WIDTH/8,
      parameter UDP_REG_SRC_WIDTH = 2,
      parameter IOQ_STAGE_NUM = `IO_QUEUE_STAGE_NUM,
      parameter PKT_LEN_WIDTH = 11,
      parameter RATE_LIMIT_BLOCK_TAG = `RATE_LIMIT_0_BLOCK_ADDR,
      parameter DEFAULT_TOKEN_INTERVAL = 2
   )

   (output reg [DATA_WIDTH-1:0]        out_data,
    output reg [CTRL_WIDTH-1:0]        out_ctrl,
    output reg                         out_wr,
    input                              out_rdy,

    input  [DATA_WIDTH-1:0]            in_data,
    input  [CTRL_WIDTH-1:0]            in_ctrl,
    input                              in_wr,
    output                             in_rdy,

    // --- Register interface
    input                              reg_req_in,
    input                              reg_ack_in,
    input                              reg_rd_wr_L_in,
    input  [`UDP_REG_ADDR_WIDTH-1:0]   reg_addr_in,
    input  [`CPCI_NF2_DATA_WIDTH-1:0]  reg_data_in,
    input  [UDP_REG_SRC_WIDTH-1:0]     reg_src_in,

    output                             reg_req_out,
    output                             reg_ack_out,
    output                             reg_rd_wr_L_out,
    output  [`UDP_REG_ADDR_WIDTH-1:0]  reg_addr_out,
    output  [`CPCI_NF2_DATA_WIDTH-1:0] reg_data_out,
    output  [UDP_REG_SRC_WIDTH-1:0]    reg_src_out,

    // --- Misc
    input                              clk,
    input                              reset);



   //----------------------- local parameter ---------------------------
   localparam WAIT_FOR_PKT       = 0;
   localparam READ_HDR           = 1;
   localparam READ_PKT           = 2;

   localparam PREAMBLE           = 8;
   localparam INTER_PKT_GAP      = 12;
   localparam FCS                = 4;
   localparam OVERHEAD           = PREAMBLE + INTER_PKT_GAP;


   //----------------------- wires/regs---------------------------------
   wire                                enable_rate_limit;
   wire [19:0]                         token_interval;
   wire [7:0]                          token_increment;
   reg [19:0]                          token_interval_d1;
   wire                                include_overhead;

   wire                                out_eop;

   reg [10:0]                          tokens;
   reg [10:0]                          new_pkt_len;
   reg [10:0]                          new_pkt_len_next;
   reg [10:0]                          pkt_len;
   reg [10:0]                          pkt_len_next;
   wire [10:0]                         extra_bytes;

   reg [20:0]                          counter;

   reg                                 seen_len;
   reg                                 seen_len_next;

   reg                                 reset_bucket;

   reg                                 in_fifo_rd_en;
   reg                                 data_good;
   reg                                 out_wr_next;

   reg [1:0]                           state, state_next;

   wire [CTRL_WIDTH-1:0]               limiter_out_ctrl;
   wire [DATA_WIDTH-1:0]               limiter_out_data;
   wire                                limiter_in_rdy;

   //------------------------ Modules ----------------------------------
   rate_limiter_regs
     #(.UDP_REG_SRC_WIDTH    (UDP_REG_SRC_WIDTH),
       .RATE_LIMIT_BLOCK_TAG (RATE_LIMIT_BLOCK_TAG),
       .DEFAULT_TOKEN_INTERVAL (DEFAULT_TOKEN_INTERVAL)
   ) rate_limiter_regs
   (
      // Registers
      .reg_req_in       (reg_req_in),
      .reg_ack_in       (reg_ack_in),
      .reg_rd_wr_L_in   (reg_rd_wr_L_in),
      .reg_addr_in      (reg_addr_in),
      .reg_data_in      (reg_data_in),
      .reg_src_in       (reg_src_in),

      .reg_req_out      (reg_req_out),
      .reg_ack_out      (reg_ack_out),
      .reg_rd_wr_L_out  (reg_rd_wr_L_out),
      .reg_addr_out     (reg_addr_out),
      .reg_data_out     (reg_data_out),
      .reg_src_out      (reg_src_out),

      // Outputs
      .token_interval                   (token_interval),
      .token_increment                  (token_increment),
      .enable_rate_limit                (enable_rate_limit),
      .include_overhead                 (include_overhead),

      // Inputs
      .clk                              (clk),
      .reset                            (reset)
   );

   small_fifo #(.WIDTH(CTRL_WIDTH+DATA_WIDTH), .MAX_DEPTH_BITS(2), .PROG_FULL_THRESHOLD(3))
      input_fifo
        (.din           ({in_ctrl, in_data}),  // Data in
         .wr_en         (in_wr),             // Write enable
         .rd_en         (in_fifo_rd_en),    // Read the next word
         .dout          ({limiter_out_ctrl, limiter_out_data}),
         .full          (),
         .nearly_full   (in_fifo_nearly_full),
         .empty         (in_fifo_empty),
         .reset         (reset),
         .clk           (clk)
         );

   //----------------------- Output logic -----------------------
   always @(posedge clk) begin
      /* output */
      out_wr <= out_wr_next;
      out_data <= limiter_out_data;
      out_ctrl <= limiter_out_ctrl;
   end // always @ (*)

   assign in_rdy = limiter_in_rdy;

   //----------------------- Rate limiting logic -----------------------

   assign limiter_in_rdy = !in_fifo_nearly_full;
   assign rate_good = tokens >= pkt_len;
   assign out_eop = limiter_out_ctrl != 'h0;
   assign extra_bytes = include_overhead ? OVERHEAD + FCS : FCS;

   /*
    * Wait until a packet starts arriving, then count its
    * length. When the packet is done, wait the pkt's length
    * shifted by the user specified amount
    */
   always @(*) begin
      state_next = state;
      in_fifo_rd_en = 0;
      out_wr_next = 0;
      new_pkt_len_next = new_pkt_len;
      pkt_len_next = enable_rate_limit ? pkt_len : 'h0;
      seen_len_next = 0;
      reset_bucket = 0;

      case(state)
         WAIT_FOR_PKT: begin
            if (!in_fifo_empty) begin
               state_next     = READ_HDR;
               in_fifo_rd_en  = 1;
               seen_len_next  = 0;
            end
         end // case: WAIT_FOR_PKT

         READ_HDR: begin
            // Attempt to identify the packet length
            if (data_good) begin
               if (limiter_out_ctrl == IOQ_STAGE_NUM && !seen_len) begin
                  new_pkt_len_next = extra_bytes + limiter_out_data[PKT_LEN_WIDTH+`IOQ_BYTE_LEN_POS:`IOQ_BYTE_LEN_POS];
                  seen_len_next = 1;
               end

               // Sent output to next stage when in the header or
               // when the curr_delay flag has expired
               if (limiter_out_ctrl == 'h0 && (rate_good || !enable_rate_limit) ||
                   limiter_out_ctrl != 'h0 && (rate_good || !enable_rate_limit)) begin
                  in_fifo_rd_en    = out_rdy && !in_fifo_empty;
                  out_wr_next      = out_rdy;
               end

               if (limiter_out_ctrl == 'h0 && (rate_good || !enable_rate_limit)) begin
                  state_next = READ_PKT;
                  reset_bucket = 1;
                  pkt_len_next = new_pkt_len;
               end
            end
            else begin
               in_fifo_rd_en = !in_fifo_empty;
            end
         end // case: READ_HDR

         READ_PKT: begin
            out_wr_next = out_rdy & data_good;
            if(out_rdy) begin
               if(out_eop) begin
                  if(!in_fifo_empty) begin
                     state_next     = READ_HDR;
                     in_fifo_rd_en  = 1;
                     seen_len_next  = 0;
                  end
                  else begin
                     state_next = WAIT_FOR_PKT;
                  end
               end
            end
            in_fifo_rd_en = out_rdy && !in_fifo_empty;
         end // case: READ_PKT
      endcase // case(state)
   end // always @ (*)

   always @(posedge clk) begin
      if(reset) begin
         new_pkt_len    <= 0;
         pkt_len        <= 0;
         state          <= WAIT_FOR_PKT;
         data_good      <= 0;
         seen_len       <= 0;
      end
      else begin
         new_pkt_len    <= new_pkt_len_next;
         pkt_len        <= pkt_len_next;
         state          <= state_next;
         data_good      <= in_fifo_rd_en || (data_good && !out_wr_next);
         seen_len       <= seen_len_next;
      end // else: !if(reset)
   end // always @ (posedge clk)

   // Leaky token bucket logic
   always @(posedge clk) begin
      if (reset || reset_bucket || token_interval != token_interval_d1) begin
         if (reset) begin
            tokens <= 'h0;
            counter <= 'h0;
         end
         else begin
            if (token_interval == 'h1) begin
               tokens <= token_increment;
               counter <= 'h0;
            end
            else begin
               tokens <= 'h0;
               counter <= 'h1;
            end
         end
      end
      else begin
         if (counter == token_interval - 'h1) begin
            if (tokens <= pkt_len)
               tokens <= tokens + token_increment;
            counter <= 'h0;
         end
         else begin
            counter <= counter + 'h1;
         end
      end
      token_interval_d1 <= token_interval;
   end

endmodule // rate_limiter
