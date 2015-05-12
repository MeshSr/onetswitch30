///////////////////////////////////////////////////////////////////////////////
// tx_queue.v. Derived from NetFPGA project.
// vim:set shiftwidth=3 softtabstop=3 expandtab:
// $Id: tx_queue.v 2080 2007-08-02 17:19:29Z grg $
//
// Module: tx_queue.v
// Project: NF2.1
// Description: Instantiates the speed matching FIFO that accepts
//              packets from the core and sends it to the MAC
//
// On the read side is the 125/12.5/1.25MHz MAC clock which reads
// data 9 bits wide from the fifo (bit 8 is EOP).
//
///////////////////////////////////////////////////////////////////////////////

module dma_tx_queue
   #(
      parameter DATA_WIDTH = 64,
      parameter CTRL_WIDTH = DATA_WIDTH/8,
      parameter ENABLE_HEADER = 1,
      parameter STAGE_NUMBER = 'hff,
      parameter AXI_DATA_WIDTH  = 32,
      parameter AXI_KEEP_WIDTH  = AXI_DATA_WIDTH/8
   )

   (input  [DATA_WIDTH-1:0]              in_data,
    input  [CTRL_WIDTH-1:0]              in_ctrl,
    input                                in_wr,
    output                               in_rdy,
    
    // --- MAC side signals (m_tx_axis_aclk domain)
    input                                m_tx_axis_aclk,
    output reg                           m_tx_axis_tvalid,
    output [AXI_DATA_WIDTH - 1 : 0]      m_tx_axis_tdata,
    output reg                           m_tx_axis_tlast,
    output reg [AXI_KEEP_WIDTH - 1 : 0]  m_tx_axis_tkeep,
    input                                m_tx_axis_tready,
    // --- Register interface
    //input                                tx_queue_en,
    //output                               tx_pkt_sent,
    output reg                           tx_pkt_stored,
    output reg [11:0]                    tx_pkt_byte_cnt,
    output reg                           tx_pkt_byte_cnt_vld,
    output reg [9:0]                     tx_pkt_word_cnt,

    // --- Misc

    input                                reset,
    input                                clk
    
   );

   // ------------ Internal Params --------

   //state machine states (one-hot)
   localparam IDLE = 1;
   localparam WAIT_FOR_READY = 2;
   localparam WAIT_FOR_EOP = 4;
   
   localparam INPUT_IDLE = 1;
   localparam INPUT_PKTS = 2;

   // Number of packets waiting:
   //
   // 4096 / 64 = 64 = 2**6
   //
   // so, need 7 bits to represent the number of packets waiting
   localparam NUM_PKTS_WAITING_WIDTH = 7;

   // ------------- Regs/ wires -----------

   wire [DATA_WIDTH+CTRL_WIDTH - 1 : 0] tx_fifo_din;
   
   wire [AXI_DATA_WIDTH - 1 : 0]    tx_fifo_out_data;
   wire [AXI_KEEP_WIDTH - 1 : 0]    tx_fifo_out_ctrl;
   reg                              tx_fifo_rd_en;
   wire                             tx_fifo_empty;
   wire                             tx_fifo_almost_full;

   reg                              reset_txclk;

   reg                              pkt_sent_txclk; // pulses when a packet has been removed
   reg [4:0]                        tx_mac_state_nxt, tx_mac_state;
   reg                              m_tx_axis_tvalid_nxt;

   reg                              tx_queue_en_txclk;

   reg [NUM_PKTS_WAITING_WIDTH-1:0] txf_num_pkts_waiting;
   wire                             txf_pkts_avail;

   reg [4:0]                        tx_input_state, tx_input_state_nxt;
   reg                              tx_fifo_wr_en;
   reg                              need_clear_padding;
   
   assign in_rdy = ~tx_fifo_almost_full;
   //--------------------------------------------------------------
   // synchronize
   //--------------------------------------------------------------
   // extend reset over to MAC domain
   reg reset_long;
   // synthesis attribute ASYNC_REG of reset_long is TRUE ;
   always @(posedge clk) begin
      if (reset) reset_long <= 1;
      else if (reset_txclk) reset_long <= 0;
   end
   always @(posedge m_tx_axis_aclk) reset_txclk <= reset_long;
   
   //---------------------------------------------------------------
   // packet fifo input and output logic
   //---------------------------------------------------------------
   
   assign tx_fifo_din = {in_ctrl[7:4], in_data[63:32],in_ctrl[3:0], in_data[31:0]};
   
   /*fifo_72_to_36 #(.WIDTH(DATA_WIDTH+CTRL_WIDTH),.MAX_DEPTH_BITS(5))
   fifo_72_to_36
      (        .din           (tx_fifo_din),  // Data in
               .wr_en         (tx_fifo_wr_en),             // Write enable
               .rd_en         (tx_fifo_rd_en),    // Read the next word
               .dout          ({tx_fifo_out_ctrl, tx_fifo_out_data}),
               .full          (),
               .prog_full     (tx_fifo_almost_full),
               .nearly_full   (),
               .empty         (tx_fifo_empty),
               .reset         (reset),
               .clk           (clk)
               );*/
                   txfifo_512x72_to_36 gmac_tx_fifo
                  (
                     .din        (tx_fifo_din),
                     .wr_en      (tx_fifo_wr_en),
                     .wr_clk     (clk),
               
                     .dout       ({tx_fifo_out_ctrl,tx_fifo_out_data}),
                     .rd_en      (tx_fifo_rd_en),
                     .rd_clk     (m_tx_axis_aclk),
                
                     .empty      (tx_fifo_empty),
                     .full       (),
                     .almost_full(tx_fifo_almost_full),
                     .rst        (reset)
                  );        
   // Reorder the output: AXI-S uses little endian, the User Data Path uses big endian
   generate
      genvar k;
      for(k=0; k<AXI_KEEP_WIDTH; k=k+1) begin: reorder_endianness
         assign m_tx_axis_tdata[8*k+:8] = tx_fifo_out_data[AXI_DATA_WIDTH-8-8*k+:8];
      end
   endgenerate
   //----------------------------------------------------------
   //input state machine.
   //Following is in core clock domain (62MHz/125 MHz)
   //----------------------------------------------------------
   
   always @(*)begin
      tx_fifo_wr_en = 0;
      tx_pkt_stored = 0;
      tx_pkt_byte_cnt = 0;
      tx_pkt_byte_cnt_vld = 0;
      tx_pkt_word_cnt = 0;
      tx_input_state_nxt = tx_input_state;
      case (tx_input_state)
         INPUT_IDLE: begin
            if(in_wr && in_ctrl == STAGE_NUMBER)begin
               
               tx_pkt_byte_cnt = in_data[`IOQ_BYTE_LEN_POS +: 16]+8;
               tx_pkt_word_cnt = in_data[`IOQ_WORD_LEN_POS +: 16]+2;
               tx_pkt_byte_cnt_vld = 1'b1;
            end
            else if(in_wr && in_ctrl == 8'hee)
                tx_fifo_wr_en = 1'b1;
            else if(in_wr && in_ctrl == 0)begin //just ignore other module header
               tx_fifo_wr_en = 1'b1;
               tx_input_state_nxt = INPUT_PKTS;
            end
         end
         INPUT_PKTS: begin
            if(in_wr)begin
               tx_fifo_wr_en = 1'b1;
               if(|in_ctrl) begin
                  //tx_pkt_stored = 1'b1;
                  tx_input_state_nxt = INPUT_IDLE;
               end
            end
         end
      endcase
   end
   
   always @(posedge clk) begin
      if(reset) begin
         tx_input_state <= INPUT_IDLE;
      end
      else tx_input_state <= tx_input_state_nxt;
   end



   always @* begin
      tx_mac_state_nxt = tx_mac_state;
      tx_fifo_rd_en = 1'b0;
      m_tx_axis_tvalid_nxt = 1'b0;
      pkt_sent_txclk = 1'b0;
      case (tx_mac_state)
         IDLE: if ( !tx_fifo_empty  ) begin //txf_pkts_avail &
            tx_fifo_rd_en = 1;   // this will make DOUT of FIFO valid after the NEXT clock
            m_tx_axis_tvalid_nxt = 1;
            tx_mac_state_nxt = WAIT_FOR_READY;
         end
         WAIT_FOR_READY:begin
            m_tx_axis_tvalid_nxt = 1;
            if(!tx_fifo_empty && m_tx_axis_tready)begin 
               tx_fifo_rd_en = 1;
               if(tx_fifo_out_ctrl==0)
                    tx_mac_state_nxt = WAIT_FOR_EOP;
            end
         end
         WAIT_FOR_EOP: begin
            m_tx_axis_tvalid_nxt = 1;
            if(|tx_fifo_out_ctrl) begin
               pkt_sent_txclk = 1;
               m_tx_axis_tvalid_nxt = 0;
               tx_mac_state_nxt = IDLE;
               if (need_clear_padding) begin // the last data byte was the last of the word so we are done.
                  tx_fifo_rd_en = 1;            
               end
               else tx_fifo_rd_en = 0;
            end
            else if(!tx_fifo_empty && m_tx_axis_tready)begin // Not EOP - keep reading!
               tx_fifo_rd_en = 1;
               //m_tx_axis_tvalid_nxt = 1;
            end
        end
      endcase
   end 
   always @(*)begin
      if(tx_mac_state == WAIT_FOR_READY || tx_mac_state == WAIT_FOR_EOP)begin
         case (tx_fifo_out_ctrl)
            4'b1000: begin 
               m_tx_axis_tkeep = 4'b0001;
               m_tx_axis_tlast = 1'b1;
            end
            4'b0100: begin
               m_tx_axis_tkeep = 4'b0011;
               m_tx_axis_tlast = 1'b1;
            end
            4'b0010: begin 
               m_tx_axis_tkeep = 4'b0111;
               m_tx_axis_tlast = 1'b1;
            end
            4'b0001: begin 
               m_tx_axis_tkeep = 4'b1111;
               m_tx_axis_tlast = 1'b1;
            end
            default: begin
               m_tx_axis_tlast = 1'b0;
               m_tx_axis_tkeep = 4'b1111;
            end
         endcase
      end
      else begin
         m_tx_axis_tkeep = 1'b0;
         m_tx_axis_tlast = 1'b0;
      end
   end
   // update sequential elements
   always @(posedge m_tx_axis_aclk) begin
      if (reset_txclk) begin
         tx_mac_state <= IDLE;
         m_tx_axis_tvalid <= 0;
         need_clear_padding <= 0;
      end
      else begin
         tx_mac_state <= tx_mac_state_nxt;
         m_tx_axis_tvalid <= m_tx_axis_tvalid_nxt;
         if(tx_fifo_rd_en) need_clear_padding <= !need_clear_padding;
      end
   end // always @ (posedge m_tx_axis_aclk)


endmodule // tx_queue
