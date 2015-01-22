module axis_control_if
#(
   parameter   C_s_axis_TDATA_WIDTH	= 32,
   parameter   C_m_axis_TDATA_WIDTH	= 32,
   parameter   C_m_axis_START_COUNT	= 32,
   parameter   C_S_AXIS_RXS_TDATA_WIDTH	= 32,
   parameter   C_M_AXIS_TXC_TDATA_WIDTH	= 32,
   parameter   C_m_axis_txc_START_COUNT	= 32,
   parameter   ENABLE_LEN	= 1
)
(

   // Ports of Axi Master Bus Interface m_axis
   input       m_axis_txd_tvalid,
   input       m_axis_txd_tlast,
   input       m_axis_txd_tready,
   input [11:0] tx_pkt_byte_cnt,
   input       tx_pkt_byte_cnt_vld,
   
   input       s_axis_rxs_aclk,
   input       s_axis_rxs_aresetn,
   output      s_axis_rxs_tready,
   input [C_S_AXIS_RXS_TDATA_WIDTH-1 : 0]       s_axis_rxs_tdata,
   input [(C_S_AXIS_RXS_TDATA_WIDTH/8)-1 : 0]   s_axis_rxs_tkeep,
   input       s_axis_rxs_tlast,
   input       s_axis_rxs_tvalid,
   
   input       m_axis_txc_aclk,
   input       m_axis_txc_aresetn,
   output reg     m_axis_txc_tvalid,
   output reg [C_M_AXIS_TXC_TDATA_WIDTH-1 : 0]      m_axis_txc_tdata,
   output reg [(C_M_AXIS_TXC_TDATA_WIDTH/8)-1 : 0]  m_axis_txc_tkeep,
   output reg  m_axis_txc_tlast,
   input      m_axis_txc_tready
);

reg [2:0]   tx_ctrl_state;
localparam  WAIT_FOR_REQ = 1,
            SEND_CTRL_PKTS = 2,
            WAIT_FOR_NXT = 4;
            
reg [7:0] send_ctrl_words;
localparam  WORD0 = 1,
            WORD1 = 2,
            WORD2 = 4,
            WORD3 = 8,
            WORD4 = 16,
            WORD5 = 32;

assign s_axis_rxs_tready = 1'b1;


reg len_fifo_rd_en;
wire [11:0] len_fifo_dout;
generate
   if(ENABLE_LEN)begin
      pkt_len_fifo_12x32 pkt_len_fifo
      (
         .clk(m_axis_txc_aclk), 
         .rst(!m_axis_txc_aresetn), 
         .din(tx_pkt_byte_cnt), 
         .wr_en(tx_pkt_byte_cnt_vld), 
         .rd_en(len_fifo_rd_en), 
         .dout(len_fifo_dout), 
         .full( ),  
         .empty( ) 
      );
   end
   else begin
      assign len_fifo_dout = 12'hFFF;
   end
endgenerate

always @(posedge m_axis_txc_aclk)
   if(!m_axis_txc_aresetn)begin
      tx_ctrl_state <= WAIT_FOR_REQ;
      send_ctrl_words <= WORD0;
      m_axis_txc_tvalid <= 1'b0;
      m_axis_txc_tdata <= 32'hFF_FF_FF_FF;
      m_axis_txc_tkeep <= 4'hF;
      m_axis_txc_tlast <= 1'b0;
      len_fifo_rd_en <= 1'b0;
   end
   else begin
      m_axis_txc_tvalid <= 1'b0;
      m_axis_txc_tdata <= {24'h50000,len_fifo_dout};
      m_axis_txc_tkeep <= 4'hF;
      m_axis_txc_tlast <= 1'b0;
      len_fifo_rd_en <= 1'b0;
      case (tx_ctrl_state)
         WAIT_FOR_REQ: begin
            if(m_axis_txd_tvalid) begin
               m_axis_txc_tvalid <= 1'b1;
               tx_ctrl_state <= SEND_CTRL_PKTS;
            end
         end
         SEND_CTRL_PKTS: begin
             m_axis_txc_tvalid <= 1'b1;
            if(m_axis_txc_tready) begin
               case (send_ctrl_words)
                  WORD0: send_ctrl_words <= WORD1;
                  WORD1: send_ctrl_words <= WORD2;
                  WORD2: send_ctrl_words <= WORD3;
                  WORD3: send_ctrl_words <= WORD4;
                  WORD4: begin 
                     send_ctrl_words <= WORD0;
                     m_axis_txc_tlast <= 1'b1;
                     len_fifo_rd_en <= 1'b1;
                     tx_ctrl_state <= WAIT_FOR_NXT;
                  end
               endcase
            end
         end
         WAIT_FOR_NXT: begin
            if(m_axis_txd_tready && m_axis_txd_tlast)tx_ctrl_state <= WAIT_FOR_REQ;
         end
      endcase
   end
endmodule