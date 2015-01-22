///////////////////////////////////////////////////////////////////////////////
//mac_queue.v
// Derived from NetFPGA Project.
///////////////////////////////////////////////////////////////////////////////

module eth_queue
#(
   parameter DATA_WIDTH = 64,
   parameter CTRL_WIDTH=DATA_WIDTH/8,
   parameter ENABLE_HEADER = 0,
   parameter STAGE_NUMBER = 'hff,
   parameter PORT_NUMBER = 0
)(// --- register interface
   input                                  mac_grp_reg_req,
   input                                  mac_grp_reg_rd_wr_L,
   input  [31:0]                          mac_grp_reg_addr,
   input  [31:0]                          mac_grp_reg_wr_data,
   output [31:0]                          mac_grp_reg_rd_data,
   output                                 mac_grp_reg_ack,

   // --- output to data path interface
   output [DATA_WIDTH-1:0]                out_data,
   output [CTRL_WIDTH-1:0]                out_ctrl,
   output                                 out_wr,
   input                                  out_rdy,

   // --- input from data path interface
   input  [DATA_WIDTH-1:0]                in_data,
   input  [CTRL_WIDTH-1:0]                in_ctrl,
   input                                  in_wr,
   output                                 in_rdy,

   // --- input from mac interface
   input  [31:0]                          s_rx_axis_tdata,
   input                                  s_rx_axis_tvalid,
   input                                  s_rx_axis_tlast,
   output                                 s_rx_axis_tready,
   input  [3:0]                           s_rx_axis_tkeep,
   // --- output to mac interface
   output                                 m_tx_axis_tvalid,
   output [31:0]                          m_tx_axis_tdata,
   output                                 m_tx_axis_tlast,
   output [3:0]                           m_tx_axis_tkeep,
   input                                  m_tx_axis_tready,

   //--- misc
   output [11:0]                          tx_pkt_byte_cnt,
   output                                 tx_pkt_byte_cnt_vld,
   input                                  axis_aclk,
   input                                  clk,
   input                                  reset
);

   //wire [11:0]    tx_pkt_byte_cnt;
   wire [9:0]     tx_pkt_word_cnt;

   wire [11:0]    rx_pkt_byte_cnt;
   wire [9:0]     rx_pkt_word_cnt;

   rx_queue
   #(
      .DATA_WIDTH(DATA_WIDTH),
      .CTRL_WIDTH(CTRL_WIDTH),
      .ENABLE_HEADER(ENABLE_HEADER),
      .STAGE_NUMBER(STAGE_NUMBER),
      .PORT_NUMBER(PORT_NUMBER)
   ) rx_queue
   (  // user data path interface
      .out_ctrl                        (out_ctrl),
      .out_wr                          (out_wr),
      .out_data                        (out_data),
      .out_rdy                         (out_rdy),
      // gmac interface
      .s_rx_axis_aclk                  (axis_aclk),
      .s_rx_axis_tdata                 (s_rx_axis_tdata),
      .s_rx_axis_tvalid                (s_rx_axis_tvalid),
      .s_rx_axis_tlast                 (s_rx_axis_tlast),
      .s_rx_axis_tkeep                 (s_rx_axis_tkeep),
      .s_rx_axis_tready                (s_rx_axis_tready),
      // reg signals
      .rx_pkt_good                     (rx_pkt_good),
      .rx_pkt_bad                      (rx_pkt_bad),
      .rx_pkt_dropped                  (rx_pkt_dropped),
      .rx_pkt_byte_cnt                 (rx_pkt_byte_cnt),
      .rx_pkt_word_cnt                 (rx_pkt_word_cnt),
      .rx_pkt_pulled                   (rx_pkt_pulled),
      .rx_queue_en                     (rx_queue_en),
      // misc
      .reset                           (reset),
      .clk                             (clk)
   );

   tx_queue
   #(
      .DATA_WIDTH(DATA_WIDTH),
      .CTRL_WIDTH(CTRL_WIDTH),
      .ENABLE_HEADER(ENABLE_HEADER),
      .STAGE_NUMBER(STAGE_NUMBER)
   ) tx_queue
     (// data path interface
      .in_ctrl                         (in_ctrl),
      .in_wr                           (in_wr),
      .in_data                         (in_data),
      .in_rdy                          (in_rdy),
      // gmac interface
      .m_tx_axis_aclk                  (axis_aclk),
      .m_tx_axis_tdata                 (m_tx_axis_tdata),
      .m_tx_axis_tvalid                (m_tx_axis_tvalid),
      .m_tx_axis_tlast                 (m_tx_axis_tlast),   
      .m_tx_axis_tkeep                 (m_tx_axis_tkeep),
      .m_tx_axis_tready                (m_tx_axis_tready),
      // reg signals
      .tx_queue_en                     (tx_queue_en),
      .tx_pkt_sent                     (tx_pkt_sent),
      .tx_pkt_stored                   (tx_pkt_stored),
      .tx_pkt_byte_cnt                 (tx_pkt_byte_cnt),
      .tx_pkt_byte_cnt_vld             (tx_pkt_byte_cnt_vld),
      .tx_pkt_word_cnt                 (tx_pkt_word_cnt),
      // misc
      .reset                           (reset),
      .clk                             (clk)
   );

   eth_queue_regs
   #(
      .CTRL_WIDTH(CTRL_WIDTH)
   ) eth_queue_regs
   (
      .mac_grp_reg_req                 (mac_grp_reg_req),
      .mac_grp_reg_rd_wr_L             (mac_grp_reg_rd_wr_L),
      .mac_grp_reg_addr                (mac_grp_reg_addr),
      .mac_grp_reg_wr_data             (mac_grp_reg_wr_data),

      .mac_grp_reg_rd_data             (mac_grp_reg_rd_data),
      .mac_grp_reg_ack                 (mac_grp_reg_ack),

      // interface to rx queue
      .rx_pkt_good                     (rx_pkt_good),
      .rx_pkt_bad                      (rx_pkt_bad),
      .rx_pkt_dropped                  (rx_pkt_dropped),
      .rx_pkt_byte_cnt                 (rx_pkt_byte_cnt),
      .rx_pkt_word_cnt                 (rx_pkt_word_cnt),
      .rx_pkt_pulled                   (rx_pkt_pulled),

      .rx_queue_en                     (rx_queue_en),

      // interface to tx queue
      .tx_queue_en                     (tx_queue_en),
      .tx_pkt_sent                     (tx_pkt_sent),
      .tx_pkt_stored                   (tx_pkt_stored),
      .tx_pkt_byte_cnt                 (tx_pkt_byte_cnt),
      .tx_pkt_word_cnt                 (tx_pkt_word_cnt),

      .clk                             (clk),
      .reset                           (reset)
   );

endmodule // nf2_mac_grp
