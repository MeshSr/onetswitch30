//-------------------------------------------------------------------
// AXI4 interface wrapper for packet processing pipeline.
//-------------------------------------------------------------------
module packet_pipeline#(
    // Parameters of Axi Slave Bus Interface S_AXI_LITE
    parameter integer C_S_AXI_LITE_DATA_WIDTH	= 32,
    parameter integer C_S_AXI_LITE_ADDR_WIDTH	= 27,
    // Parameters of Axi Slave Bus Interface S_AXIS_RXD_0
    parameter integer C_S_AXIS_RXD_0_TDATA_WIDTH	= 32,
    // Parameters of Axi Master Bus Interface M_AXIS_TXD_0
    parameter integer C_M_AXIS_TXD_0_TDATA_WIDTH	= 32,
    // Parameters of Axi Slave Bus Interface S_AXIS_MM2S_0
    parameter integer C_S_AXIS_MM2S_0_TDATA_WIDTH	= 32,
    // Parameters of Axi Master Bus Interface M_AXIS_S2MM_0
    parameter integer C_M_AXIS_S2MM_0_TDATA_WIDTH	= 32,
    
    // Parameters of Axi Slave Bus Interface S_AXIS_RXD_1
    parameter integer C_S_AXIS_RXD_1_TDATA_WIDTH	= 32,
    // Parameters of Axi Master Bus Interface M_AXIS_TXD_1
    parameter integer C_M_AXIS_TXD_1_TDATA_WIDTH	= 32,
    // Parameters of Axi Slave Bus Interface S_AXIS_MM2S_1
    parameter integer C_S_AXIS_MM2S_1_TDATA_WIDTH	= 32,
    // Parameters of Axi Master Bus Interface M_AXIS_S2MM_1
    parameter integer C_M_AXIS_S2MM_1_TDATA_WIDTH	= 32,
    
    // Parameters of Axi Slave Bus Interface S_AXIS_RXD_2
    parameter integer C_S_AXIS_RXD_2_TDATA_WIDTH	= 32,
    // Parameters of Axi Master Bus Interface M_AXIS_TXD_2
    parameter integer C_M_AXIS_TXD_2_TDATA_WIDTH	= 32,
    // Parameters of Axi Slave Bus Interface S_AXIS_MM2S_2
    parameter integer C_S_AXIS_MM2S_2_TDATA_WIDTH	= 32,
    // Parameters of Axi Master Bus Interface M_AXIS_S2MM_2
    parameter integer C_M_AXIS_S2MM_2_TDATA_WIDTH	= 32,
    
    // Parameters of Axi Slave Bus Interface S_AXIS_RXD_3
    parameter integer C_S_AXIS_RXD_3_TDATA_WIDTH	= 32,
    // Parameters of Axi Master Bus Interface M_AXIS_TXD_3
    parameter integer C_M_AXIS_TXD_3_TDATA_WIDTH	= 32,
    // Parameters of Axi Slave Bus Interface S_AXIS_MM2S_3
    parameter integer C_S_AXIS_MM2S_3_TDATA_WIDTH	= 32,
    // Parameters of Axi Master Bus Interface M_AXIS_S2MM_3
    parameter integer C_M_AXIS_S2MM_3_TDATA_WIDTH	= 32,
    
    parameter integer C_S_AXIS_RXS_TDATA_WIDTH	= 32,
    parameter integer C_M_AXIS_TXC_TDATA_WIDTH	= 32
)
(
    // Users to add ports here
    input wire s_axis_rxd_aclk,
    input wire s_axis_rxd_aresetn,
    input wire s_axis_txd_aclk,
    input wire s_axis_txd_aresetn,
    input wire s_axis_mm2s_aclk,
    input wire s_axis_mm2s_aresetn,
    input wire s_axis_s2mm_aclk,
    input wire s_axis_s2mm_aresetn,
    // User ports ends
    // Do not modify the ports beyond this line

    // Ports of Axi Slave Bus Interface S_AXI_LITE
    input wire  s_axi_lite_aclk,
    input wire  s_axi_lite_aresetn,
    input wire [C_S_AXI_LITE_ADDR_WIDTH-1 : 0] s_axi_lite_awaddr,
    input wire [2 : 0] s_axi_lite_awprot,
    input wire  s_axi_lite_awvalid,
    output wire  s_axi_lite_awready,
    input wire [C_S_AXI_LITE_DATA_WIDTH-1 : 0] s_axi_lite_wdata,
    input wire [(C_S_AXI_LITE_DATA_WIDTH/8)-1 : 0] s_axi_lite_wstrb,
    input wire  s_axi_lite_wvalid,
    output wire  s_axi_lite_wready,
    output wire [1 : 0] s_axi_lite_bresp,
    output wire  s_axi_lite_bvalid,
    input wire  s_axi_lite_bready,
    input wire [C_S_AXI_LITE_ADDR_WIDTH-1 : 0] s_axi_lite_araddr,
    input wire [2 : 0] s_axi_lite_arprot,
    input wire  s_axi_lite_arvalid,
    output wire  s_axi_lite_arready,
    output wire [C_S_AXI_LITE_DATA_WIDTH-1 : 0] s_axi_lite_rdata,
    output wire [1 : 0] s_axi_lite_rresp,
    output wire  s_axi_lite_rvalid,
    input wire  s_axi_lite_rready,

    // Ports of Axi Slave Bus Interface S_AXIS_RXD_0-----ETH0(M_AXIS_RXD)
    output wire  s_axis_rxd_0_tready,
    input wire [C_S_AXIS_RXD_0_TDATA_WIDTH-1 : 0] s_axis_rxd_0_tdata,
    input wire [(C_S_AXIS_RXD_0_TDATA_WIDTH/8)-1 : 0] s_axis_rxd_0_tkeep,
    input wire  s_axis_rxd_0_tlast,
    input wire  s_axis_rxd_0_tvalid,
    // Ports of Axi Master Bus Interface M_AXIS_TXD_0------ETH0(S_AXIS_TXD)
    output wire  m_axis_txd_0_tvalid,
    output wire [C_M_AXIS_TXD_0_TDATA_WIDTH-1 : 0] m_axis_txd_0_tdata,
    output wire [(C_M_AXIS_TXD_0_TDATA_WIDTH/8)-1 : 0] m_axis_txd_0_tkeep,
    output wire  m_axis_txd_0_tlast,
    input wire  m_axis_txd_0_tready,
    
    // Ports of Axi Slave Bus Interface S_AXIS_RXD_1-----ETH1(M_AXIS_RXD)
    //output      s_axis_rxd_1_aresetn_out,//to eth1 rxd_resetn
    output wire  s_axis_rxd_1_tready,
    input wire [C_S_AXIS_RXD_1_TDATA_WIDTH-1 : 0] s_axis_rxd_1_tdata,
    input wire [(C_S_AXIS_RXD_1_TDATA_WIDTH/8)-1 : 0] s_axis_rxd_1_tkeep,
    input wire  s_axis_rxd_1_tlast,
    input wire  s_axis_rxd_1_tvalid,
    // Ports of Axi Master Bus Interface M_AXIS_TXD_1------ETH1(S_AXIS_TXD)
    output wire  m_axis_txd_1_tvalid,
    output wire [C_M_AXIS_TXD_1_TDATA_WIDTH-1 : 0] m_axis_txd_1_tdata,
    output wire [(C_M_AXIS_TXD_1_TDATA_WIDTH/8)-1 : 0] m_axis_txd_1_tkeep,
    output wire  m_axis_txd_1_tlast,
    input wire  m_axis_txd_1_tready,
    
    // Ports of Axi Slave Bus Interface S_AXIS_RXD_2-----ETH2(M_AXIS_RXD)
    output wire  s_axis_rxd_2_tready,
    input wire [C_S_AXIS_RXD_2_TDATA_WIDTH-1 : 0] s_axis_rxd_2_tdata,
    input wire [(C_S_AXIS_RXD_2_TDATA_WIDTH/8)-1 : 0] s_axis_rxd_2_tkeep,
    input wire  s_axis_rxd_2_tlast,
    input wire  s_axis_rxd_2_tvalid,
    // Ports of Axi Master Bus Interface M_AXIS_TXD_2------ETH2(S_AXIS_TXD)
    output wire  m_axis_txd_2_tvalid,
    output wire [C_M_AXIS_TXD_2_TDATA_WIDTH-1 : 0] m_axis_txd_2_tdata,
    output wire [(C_M_AXIS_TXD_2_TDATA_WIDTH/8)-1 : 0] m_axis_txd_2_tkeep,
    output wire  m_axis_txd_2_tlast,
    input wire  m_axis_txd_2_tready,
    
    // Ports of Axi Slave Bus Interface S_AXIS_RXD_3-----ETH3(M_AXIS_RXD)
    output wire  s_axis_rxd_3_tready,
    input wire [C_S_AXIS_RXD_3_TDATA_WIDTH-1 : 0] s_axis_rxd_3_tdata,
    input wire [(C_S_AXIS_RXD_3_TDATA_WIDTH/8)-1 : 0] s_axis_rxd_3_tkeep,
    input wire  s_axis_rxd_3_tlast,
    input wire  s_axis_rxd_3_tvalid,
    // Ports of Axi Master Bus Interface M_AXIS_TXD_3------ETH3(S_AXIS_TXD)
    output wire  m_axis_txd_3_tvalid,
    output wire [C_M_AXIS_TXD_3_TDATA_WIDTH-1 : 0] m_axis_txd_3_tdata,
    output wire [(C_M_AXIS_TXD_3_TDATA_WIDTH/8)-1 : 0] m_axis_txd_3_tkeep,
    output wire  m_axis_txd_3_tlast,
    input wire  m_axis_txd_3_tready,

    // Ports of Axi Slave Bus Interface S_AXIS_MM2S_0-----DMA0(M_AXIS_MM2S)
    output wire  s_axis_mm2s_0_tready,
    input wire [C_S_AXIS_MM2S_0_TDATA_WIDTH-1 : 0] s_axis_mm2s_0_tdata,
    input wire [(C_S_AXIS_MM2S_0_TDATA_WIDTH/8)-1 : 0] s_axis_mm2s_0_tkeep,
    input wire  s_axis_mm2s_0_tlast,
    input wire  s_axis_mm2s_0_tvalid,
    
    output wire  s_axis_mm2s_ctrl_0_tready,
    input wire [C_S_AXIS_MM2S_0_TDATA_WIDTH-1 : 0] s_axis_mm2s_ctrl_0_tdata,
    input wire [(C_S_AXIS_MM2S_0_TDATA_WIDTH/8)-1 : 0] s_axis_mm2s_ctrl_0_tkeep,
    input wire  s_axis_mm2s_ctrl_0_tlast,
    input wire  s_axis_mm2s_ctrl_0_tvalid,
    // Ports of Axi Master Bus Interface M_AXIS_S2MM_0------DMA0(S_AXIS_S2MM)
    output wire  m_axis_s2mm_0_tvalid,
    output wire [C_M_AXIS_S2MM_0_TDATA_WIDTH-1 : 0] m_axis_s2mm_0_tdata,
    output wire [(C_M_AXIS_S2MM_0_TDATA_WIDTH/8)-1 : 0] m_axis_s2mm_0_tkeep,
    output wire  m_axis_s2mm_0_tlast,
    input wire  m_axis_s2mm_0_tready,

    output wire  m_axis_s2mm_sts_0_tvalid,
    output wire [C_M_AXIS_S2MM_0_TDATA_WIDTH-1 : 0] m_axis_s2mm_sts_0_tdata,
    output wire [(C_M_AXIS_S2MM_0_TDATA_WIDTH/8)-1 : 0] m_axis_s2mm_sts_0_tkeep,
    output wire  m_axis_s2mm_sts_0_tlast,
    input wire  m_axis_s2mm_sts_0_tready,
    // Ports of Axi Slave Bus Interface S_AXIS_MM2S_1-----DMA1(M_AXIS_MM2S)
    output wire  s_axis_mm2s_1_tready,
    input wire [C_S_AXIS_MM2S_1_TDATA_WIDTH-1 : 0] s_axis_mm2s_1_tdata,
    input wire [(C_S_AXIS_MM2S_1_TDATA_WIDTH/8)-1 : 0] s_axis_mm2s_1_tkeep,
    input wire  s_axis_mm2s_1_tlast,
    input wire  s_axis_mm2s_1_tvalid,

    output wire  s_axis_mm2s_ctrl_1_tready,
    input wire [C_S_AXIS_MM2S_0_TDATA_WIDTH-1 : 0] s_axis_mm2s_ctrl_1_tdata,
    input wire [(C_S_AXIS_MM2S_0_TDATA_WIDTH/8)-1 : 0] s_axis_mm2s_ctrl_1_tkeep,
    input wire  s_axis_mm2s_ctrl_1_tlast,
    input wire  s_axis_mm2s_ctrl_1_tvalid,
    // Ports of Axi Master Bus Interface M_AXIS_S2MM_1------DMA1(S_AXIS_S2MM)

    output wire  m_axis_s2mm_1_tvalid,
    output wire [C_M_AXIS_S2MM_1_TDATA_WIDTH-1 : 0] m_axis_s2mm_1_tdata,
    output wire [(C_M_AXIS_S2MM_1_TDATA_WIDTH/8)-1 : 0] m_axis_s2mm_1_tkeep,
    output wire  m_axis_s2mm_1_tlast,
    input wire  m_axis_s2mm_1_tready,
    
    output wire  m_axis_s2mm_sts_1_tvalid,
    output wire [C_M_AXIS_S2MM_0_TDATA_WIDTH-1 : 0] m_axis_s2mm_sts_1_tdata,
    output wire [(C_M_AXIS_S2MM_0_TDATA_WIDTH/8)-1 : 0] m_axis_s2mm_sts_1_tkeep,
    output wire  m_axis_s2mm_sts_1_tlast,
    input wire  m_axis_s2mm_sts_1_tready,
    // Ports of Axi Slave Bus Interface S_AXIS_MM2S_2-----DMA2(M_AXIS_MM2S)
    output wire  s_axis_mm2s_2_tready,
    input wire [C_S_AXIS_MM2S_2_TDATA_WIDTH-1 : 0] s_axis_mm2s_2_tdata,
    input wire [(C_S_AXIS_MM2S_2_TDATA_WIDTH/8)-1 : 0] s_axis_mm2s_2_tkeep,
    input wire  s_axis_mm2s_2_tlast,
    input wire  s_axis_mm2s_2_tvalid,
    
    output wire  s_axis_mm2s_ctrl_2_tready,
    input wire [C_S_AXIS_MM2S_0_TDATA_WIDTH-1 : 0] s_axis_mm2s_ctrl_2_tdata,
    input wire [(C_S_AXIS_MM2S_0_TDATA_WIDTH/8)-1 : 0] s_axis_mm2s_ctrl_2_tkeep,
    input wire  s_axis_mm2s_ctrl_2_tlast,
    input wire  s_axis_mm2s_ctrl_2_tvalid,
    // Ports of Axi Master Bus Interface M_AXIS_S2MM_2------DMA2(S_AXIS_S2MM)
    output wire  m_axis_s2mm_2_tvalid,
    output wire [C_M_AXIS_S2MM_2_TDATA_WIDTH-1 : 0] m_axis_s2mm_2_tdata,
    output wire [(C_M_AXIS_S2MM_0_TDATA_WIDTH/8)-1 : 0] m_axis_s2mm_2_tkeep,
    output wire  m_axis_s2mm_2_tlast,
    input wire  m_axis_s2mm_2_tready,
    
    output wire  m_axis_s2mm_sts_2_tvalid,
    output wire [C_M_AXIS_S2MM_0_TDATA_WIDTH-1 : 0] m_axis_s2mm_sts_2_tdata,
    output wire [(C_M_AXIS_S2MM_0_TDATA_WIDTH/8)-1 : 0] m_axis_s2mm_sts_2_tkeep,
    output wire  m_axis_s2mm_sts_2_tlast,
    input wire  m_axis_s2mm_sts_2_tready,
    // Ports of Axi Slave Bus Interface S_AXIS_MM2S_3-----DMA3(M_AXIS_MM2S)
    output wire  s_axis_mm2s_3_tready,
    input wire [C_S_AXIS_MM2S_3_TDATA_WIDTH-1 : 0] s_axis_mm2s_3_tdata,
    input wire [(C_S_AXIS_MM2S_3_TDATA_WIDTH/8)-1 : 0] s_axis_mm2s_3_tkeep,
    input wire  s_axis_mm2s_3_tlast,
    input wire  s_axis_mm2s_3_tvalid,

    output wire  s_axis_mm2s_ctrl_3_tready,
    input wire [C_S_AXIS_MM2S_0_TDATA_WIDTH-1 : 0] s_axis_mm2s_ctrl_3_tdata,
    input wire [(C_S_AXIS_MM2S_0_TDATA_WIDTH/8)-1 : 0] s_axis_mm2s_ctrl_3_tkeep,
    input wire  s_axis_mm2s_ctrl_3_tlast,
    input wire  s_axis_mm2s_ctrl_3_tvalid,
    
    // Ports of Axi Master Bus Interface M_AXIS_S2MM_3------DMA3(S_AXIS_S2MM)
    output wire  m_axis_s2mm_3_tvalid,
    output wire [C_M_AXIS_S2MM_3_TDATA_WIDTH-1 : 0] m_axis_s2mm_3_tdata,
    output wire [(C_M_AXIS_S2MM_3_TDATA_WIDTH/8)-1 : 0] m_axis_s2mm_3_tkeep,
    output wire  m_axis_s2mm_3_tlast,
    input wire  m_axis_s2mm_3_tready,
    
    output wire  m_axis_s2mm_sts_3_tvalid,
    output wire [C_M_AXIS_S2MM_0_TDATA_WIDTH-1 : 0] m_axis_s2mm_sts_3_tdata,
    output wire [(C_M_AXIS_S2MM_0_TDATA_WIDTH/8)-1 : 0] m_axis_s2mm_sts_3_tkeep,
    output wire  m_axis_s2mm_sts_3_tlast,
    input wire  m_axis_s2mm_sts_3_tready,
   // Ports of Axi Master Bus Interface S_AXIS_RXS_0------ETH0(S_AXIS_RXS_0)
   // Ports of Axi Master Bus Interface S_AXIS_TXC_0------ETH0(S_AXIS_TXC_0)
   output      s_axis_rxs_0_tready,
   input [C_S_AXIS_RXS_TDATA_WIDTH-1 : 0]       s_axis_rxs_0_tdata,
   input [(C_S_AXIS_RXS_TDATA_WIDTH/8)-1 : 0]   s_axis_rxs_0_tkeep,
   input       s_axis_rxs_0_tlast,
   input       s_axis_rxs_0_tvalid,
   
   output      m_axis_txc_0_tvalid,
   output [C_M_AXIS_TXC_TDATA_WIDTH-1 : 0]      m_axis_txc_0_tdata,
   output [(C_M_AXIS_TXC_TDATA_WIDTH/8)-1 : 0]  m_axis_txc_0_tkeep,
   output     m_axis_txc_0_tlast,
   input      m_axis_txc_0_tready,
   // Ports of Axi Master Bus Interface S_AXIS_RXS_1------ETH1(S_AXIS_RXS_1)
   // Ports of Axi Master Bus Interface S_AXIS_TXC_1------ETH1(S_AXIS_TXC_1)
   output      s_axis_rxs_1_tready,
   input [C_S_AXIS_RXS_TDATA_WIDTH-1 : 0]       s_axis_rxs_1_tdata,
   input [(C_S_AXIS_RXS_TDATA_WIDTH/8)-1 : 0]   s_axis_rxs_1_tkeep,
   input       s_axis_rxs_1_tlast,
   input       s_axis_rxs_1_tvalid,
   
   output      m_axis_txc_1_tvalid,
   output [C_M_AXIS_TXC_TDATA_WIDTH-1 : 0]      m_axis_txc_1_tdata,
   output [(C_M_AXIS_TXC_TDATA_WIDTH/8)-1 : 0]  m_axis_txc_1_tkeep,
   output     m_axis_txc_1_tlast,
   input      m_axis_txc_1_tready,
   // Ports of Axi Master Bus Interface S_AXIS_RXS_2------ETH2(S_AXIS_RXS_2)
   // Ports of Axi Master Bus Interface S_AXIS_TXC_2------ETH2(S_AXIS_TXC_2)
   output      s_axis_rxs_2_tready,
   input [C_S_AXIS_RXS_TDATA_WIDTH-1 : 0]       s_axis_rxs_2_tdata,
   input [(C_S_AXIS_RXS_TDATA_WIDTH/8)-1 : 0]   s_axis_rxs_2_tkeep,
   input       s_axis_rxs_2_tlast,
   input       s_axis_rxs_2_tvalid,
   
   output      m_axis_txc_2_tvalid,
   output [C_M_AXIS_TXC_TDATA_WIDTH-1 : 0]      m_axis_txc_2_tdata,
   output [(C_M_AXIS_TXC_TDATA_WIDTH/8)-1 : 0]  m_axis_txc_2_tkeep,
   output     m_axis_txc_2_tlast,
   input      m_axis_txc_2_tready,
   // Ports of Axi Master Bus Interface S_AXIS_RXS_3------ETH3(S_AXIS_RXS_3)
   // Ports of Axi Master Bus Interface S_AXIS_TXC_3------ETH3(S_AXIS_TXC_3)
   output      s_axis_rxs_3_tready,
   input [C_S_AXIS_RXS_TDATA_WIDTH-1 : 0]       s_axis_rxs_3_tdata,
   input [(C_S_AXIS_RXS_TDATA_WIDTH/8)-1 : 0]   s_axis_rxs_3_tkeep,
   input       s_axis_rxs_3_tlast,
   input       s_axis_rxs_3_tvalid,
   
   output      m_axis_txc_3_tvalid,
   output [C_M_AXIS_TXC_TDATA_WIDTH-1 : 0]      m_axis_txc_3_tdata,
   output [(C_M_AXIS_TXC_TDATA_WIDTH/8)-1 : 0]  m_axis_txc_3_tkeep,
   output     m_axis_txc_3_tlast,
   input      m_axis_txc_3_tready
   );
   
   wire [4*12 - 1 : 0]   dma_tx_pkt_byte_cnt;
   wire [4*1 - 1 : 0]    dma_tx_pkt_byte_cnt_vld;
   
   wire axis_aclk = s_axis_rxd_aclk;
   wire axis_aresetn = s_axis_rxd_aresetn;
   onet_core_logic onet_core_logic_inst (
      .clk                          (axis_aclk), 
      .reset                        (~axis_aresetn), 
      //axi lite  
      .s_axi_aclk                   (s_axi_lite_aclk), 
      .s_axi_aresetn                (s_axi_lite_aresetn), 
      .s_axi_awaddr                 (s_axi_lite_awaddr), 
      .s_axi_awprot                 (s_axi_lite_awprot), 
      .s_axi_awvalid                (s_axi_lite_awvalid), 
      .s_axi_awready                (s_axi_lite_awready), 
      .s_axi_wdata                  (s_axi_lite_wdata), 
      .s_axi_wstrb                  (s_axi_lite_wstrb), 
      .s_axi_wvalid                 (s_axi_lite_wvalid), 
      .s_axi_wready                 (s_axi_lite_wready), 
      .s_axi_bresp                  (s_axi_lite_bresp), 
      .s_axi_bvalid                 (s_axi_lite_bvalid), 
      .s_axi_bready                 (s_axi_lite_bready), 
      .s_axi_araddr                 (s_axi_lite_araddr), 
      .s_axi_arprot                 (s_axi_lite_arprot), 
      .s_axi_arvalid                (s_axi_lite_arvalid), 
      .s_axi_arready                (s_axi_lite_arready), 
      .s_axi_rdata                  (s_axi_lite_rdata), 
      .s_axi_rresp                  (s_axi_lite_rresp), 
      .s_axi_rvalid                 (s_axi_lite_rvalid), 
      .s_axi_rready                 (s_axi_lite_rready),
      
      .s_axis_eth_aclk_0            (axis_aclk),    
      .s_axis_eth_rx_tdata_0        (s_axis_rxd_0_tdata), 
      .s_axis_eth_rx_tvalid_0       (s_axis_rxd_0_tvalid), 
      .s_axis_eth_rx_tlast_0        (s_axis_rxd_0_tlast), 
      .s_axis_eth_rx_tkeep_0        (s_axis_rxd_0_tkeep), 
      .s_axis_eth_rx_tready_0       (s_axis_rxd_0_tready),      
      .m_axis_eth_tx_tdata_0        (m_axis_txd_0_tdata), 
      .m_axis_eth_tx_tvalid_0       (m_axis_txd_0_tvalid), 
      .m_axis_eth_tx_tlast_0        (m_axis_txd_0_tlast), 
      .m_axis_eth_tx_tkeep_0        (m_axis_txd_0_tkeep), 
      .m_axis_eth_tx_tready_0       (m_axis_txd_0_tready), 

      .s_axis_eth_aclk_1            (axis_aclk),      
      .s_axis_eth_rx_tdata_1        (s_axis_rxd_1_tdata), 
      .s_axis_eth_rx_tvalid_1       (s_axis_rxd_1_tvalid), 
      .s_axis_eth_rx_tlast_1        (s_axis_rxd_1_tlast), 
      .s_axis_eth_rx_tkeep_1        (s_axis_rxd_1_tkeep), 
      .s_axis_eth_rx_tready_1       (s_axis_rxd_1_tready),      
      .m_axis_eth_tx_tdata_1        (m_axis_txd_1_tdata), 
      .m_axis_eth_tx_tvalid_1       (m_axis_txd_1_tvalid), 
      .m_axis_eth_tx_tlast_1        (m_axis_txd_1_tlast), 
      .m_axis_eth_tx_tkeep_1        (m_axis_txd_1_tkeep), 
      .m_axis_eth_tx_tready_1       (m_axis_txd_1_tready), 
      
      .s_axis_eth_aclk_2            (axis_aclk), 
      .s_axis_eth_rx_tdata_2        (s_axis_rxd_2_tdata), 
      .s_axis_eth_rx_tvalid_2       (s_axis_rxd_2_tvalid), 
      .s_axis_eth_rx_tlast_2        (s_axis_rxd_2_tlast), 
      .s_axis_eth_rx_tkeep_2        (s_axis_rxd_2_tkeep), 
      .s_axis_eth_rx_tready_2       (s_axis_rxd_2_tready), 
      .m_axis_eth_tx_tdata_2        (m_axis_txd_2_tdata), 
      .m_axis_eth_tx_tvalid_2       (m_axis_txd_2_tvalid), 
      .m_axis_eth_tx_tlast_2        (m_axis_txd_2_tlast), 
      .m_axis_eth_tx_tkeep_2        (m_axis_txd_2_tkeep), 
      .m_axis_eth_tx_tready_2       (m_axis_txd_2_tready), 
      
      .s_axis_eth_aclk_3            (axis_aclk), 
      .s_axis_eth_rx_tdata_3        (s_axis_rxd_3_tdata), 
      .s_axis_eth_rx_tvalid_3       (s_axis_rxd_3_tvalid), 
      .s_axis_eth_rx_tlast_3        (s_axis_rxd_3_tlast), 
      .s_axis_eth_rx_tkeep_3        (s_axis_rxd_3_tkeep), 
      .s_axis_eth_rx_tready_3       (s_axis_rxd_3_tready), 
      .m_axis_eth_tx_tdata_3        (m_axis_txd_3_tdata), 
      .m_axis_eth_tx_tvalid_3       (m_axis_txd_3_tvalid), 
      .m_axis_eth_tx_tlast_3        (m_axis_txd_3_tlast), 
      .m_axis_eth_tx_tkeep_3        (m_axis_txd_3_tkeep), 
      .m_axis_eth_tx_tready_3       (m_axis_txd_3_tready), 
      
      .s_axis_dma_aclk_0            (axis_aclk), 
      .s_axis_dma_rx_tdata_0        (s_axis_mm2s_0_tdata), 
      .s_axis_dma_rx_tvalid_0       (s_axis_mm2s_0_tvalid), 
      .s_axis_dma_rx_tlast_0        (s_axis_mm2s_0_tlast), 
      .s_axis_dma_rx_tkeep_0        (s_axis_mm2s_0_tkeep), 
      .s_axis_dma_rx_tready_0       (s_axis_mm2s_0_tready), 
      .m_axis_dma_tx_tdata_0        (m_axis_s2mm_0_tdata), 
      .m_axis_dma_tx_tvalid_0       (m_axis_s2mm_0_tvalid), 
      .m_axis_dma_tx_tlast_0        (m_axis_s2mm_0_tlast), 
      .m_axis_dma_tx_tkeep_0        (m_axis_s2mm_0_tkeep), 
      .m_axis_dma_tx_tready_0       (m_axis_s2mm_0_tready), 
      
      .s_axis_dma_aclk_1            (axis_aclk), 
      .s_axis_dma_rx_tdata_1        (s_axis_mm2s_1_tdata), 
      .s_axis_dma_rx_tvalid_1       (s_axis_mm2s_1_tvalid), 
      .s_axis_dma_rx_tlast_1        (s_axis_mm2s_1_tlast), 
      .s_axis_dma_rx_tkeep_1        (s_axis_mm2s_1_tkeep), 
      .s_axis_dma_rx_tready_1       (s_axis_mm2s_1_tready), 
      .m_axis_dma_tx_tdata_1        (m_axis_s2mm_1_tdata), 
      .m_axis_dma_tx_tvalid_1       (m_axis_s2mm_1_tvalid), 
      .m_axis_dma_tx_tlast_1        (m_axis_s2mm_1_tlast), 
      .m_axis_dma_tx_tkeep_1        (m_axis_s2mm_1_tkeep), 
      .m_axis_dma_tx_tready_1       (m_axis_s2mm_1_tready), 
      
      .s_axis_dma_aclk_2            (axis_aclk), 
      .s_axis_dma_rx_tdata_2        (s_axis_mm2s_2_tdata), 
      .s_axis_dma_rx_tvalid_2       (s_axis_mm2s_2_tvalid), 
      .s_axis_dma_rx_tlast_2        (s_axis_mm2s_2_tlast), 
      .s_axis_dma_rx_tkeep_2        (s_axis_mm2s_2_tkeep), 
      .s_axis_dma_rx_tready_2       (s_axis_mm2s_2_tready), 
      .m_axis_dma_tx_tdata_2        (m_axis_s2mm_2_tdata), 
      .m_axis_dma_tx_tvalid_2       (m_axis_s2mm_2_tvalid), 
      .m_axis_dma_tx_tlast_2        (m_axis_s2mm_2_tlast), 
      .m_axis_dma_tx_tkeep_2        (m_axis_s2mm_2_tkeep), 
      .m_axis_dma_tx_tready_2       (m_axis_s2mm_2_tready), 
      
      .s_axis_dma_aclk_3            (axis_aclk), 
      .s_axis_dma_rx_tdata_3        (s_axis_mm2s_3_tdata), 
      .s_axis_dma_rx_tvalid_3       (s_axis_mm2s_3_tvalid), 
      .s_axis_dma_rx_tlast_3        (s_axis_mm2s_3_tlast), 
      .s_axis_dma_rx_tkeep_3        (s_axis_mm2s_3_tkeep), 
      .s_axis_dma_rx_tready_3       (s_axis_mm2s_3_tready), 
      .m_axis_dma_tx_tdata_3        (m_axis_s2mm_3_tdata), 
      .m_axis_dma_tx_tvalid_3       (m_axis_s2mm_3_tvalid), 
      .m_axis_dma_tx_tlast_3        (m_axis_s2mm_3_tlast), 
      .m_axis_dma_tx_tkeep_3        (m_axis_s2mm_3_tkeep), 
      .m_axis_dma_tx_tready_3       (m_axis_s2mm_3_tready),
      
      .dma_tx_pkt_byte_cnt          (dma_tx_pkt_byte_cnt),
      .dma_tx_pkt_byte_cnt_vld      (dma_tx_pkt_byte_cnt_vld)
   );
   
   axis_control_if  
   #(
      .ENABLE_LEN    (0)
   )eth_axis_control_if_0 (
      .m_axis_txd_tvalid            (m_axis_txd_0_tvalid), 
      .m_axis_txd_tlast             (m_axis_txd_0_tlast), 
      .m_axis_txd_tready            (m_axis_txd_0_tready), 

      .s_axis_rxs_aclk              (axis_aclk), 
      .s_axis_rxs_aresetn           (axis_aresetn), 
      .s_axis_rxs_tready            (s_axis_rxs_0_tready), 
      .s_axis_rxs_tdata             (s_axis_rxs_0_tdata), 
      .s_axis_rxs_tkeep             (s_axis_rxs_0_tkeep), 
      .s_axis_rxs_tlast             (s_axis_rxs_0_tlast), 
      .s_axis_rxs_tvalid            (s_axis_rxs_0_tvalid), 
      
      .m_axis_txc_aclk              (axis_aclk), 
      .m_axis_txc_aresetn           (axis_aresetn), 
      .m_axis_txc_tvalid            (m_axis_txc_0_tvalid), 
      .m_axis_txc_tdata             (m_axis_txc_0_tdata), 
      .m_axis_txc_tkeep             (m_axis_txc_0_tkeep), 
      .m_axis_txc_tlast             (m_axis_txc_0_tlast), 
      .m_axis_txc_tready            (m_axis_txc_0_tready),
      
      .tx_pkt_byte_cnt              (),
      .tx_pkt_byte_cnt_vld          ()
    );
   axis_control_if  
   #(
      .ENABLE_LEN    (0)
   )eth_axis_control_if_1(
      .m_axis_txd_tvalid            (m_axis_txd_1_tvalid), 
      .m_axis_txd_tlast             (m_axis_txd_1_tlast), 
      .m_axis_txd_tready            (m_axis_txd_1_tready), 

      .s_axis_rxs_aclk              (axis_aclk), 
      .s_axis_rxs_aresetn           (axis_aresetn), 
      .s_axis_rxs_tready            (s_axis_rxs_1_tready), 
      .s_axis_rxs_tdata             (s_axis_rxs_1_tdata), 
      .s_axis_rxs_tkeep             (s_axis_rxs_1_tkeep), 
      .s_axis_rxs_tlast             (s_axis_rxs_1_tlast), 
      .s_axis_rxs_tvalid            (s_axis_rxs_1_tvalid), 
      
      .m_axis_txc_aclk              (axis_aclk), 
      .m_axis_txc_aresetn           (axis_aresetn), 
      .m_axis_txc_tvalid            (m_axis_txc_1_tvalid), 
      .m_axis_txc_tdata             (m_axis_txc_1_tdata), 
      .m_axis_txc_tkeep             (m_axis_txc_1_tkeep), 
      .m_axis_txc_tlast             (m_axis_txc_1_tlast), 
      .m_axis_txc_tready            (m_axis_txc_1_tready),
      
      .tx_pkt_byte_cnt              (),
      .tx_pkt_byte_cnt_vld          ()
    );
   axis_control_if  
   #(
      .ENABLE_LEN    (0)
   )eth_axis_control_if_2(
      .m_axis_txd_tvalid            (m_axis_txd_2_tvalid), 
      .m_axis_txd_tlast             (m_axis_txd_2_tlast), 
      .m_axis_txd_tready            (m_axis_txd_2_tready), 

      .s_axis_rxs_aclk              (axis_aclk), 
      .s_axis_rxs_aresetn           (axis_aresetn), 
      .s_axis_rxs_tready            (s_axis_rxs_2_tready), 
      .s_axis_rxs_tdata             (s_axis_rxs_2_tdata), 
      .s_axis_rxs_tkeep             (s_axis_rxs_2_tkeep), 
      .s_axis_rxs_tlast             (s_axis_rxs_2_tlast), 
      .s_axis_rxs_tvalid            (s_axis_rxs_2_tvalid), 
      
      .m_axis_txc_aclk              (axis_aclk), 
      .m_axis_txc_aresetn           (axis_aresetn), 
      .m_axis_txc_tvalid            (m_axis_txc_2_tvalid), 
      .m_axis_txc_tdata             (m_axis_txc_2_tdata), 
      .m_axis_txc_tkeep             (m_axis_txc_2_tkeep), 
      .m_axis_txc_tlast             (m_axis_txc_2_tlast), 
      .m_axis_txc_tready            (m_axis_txc_2_tready),
      
      .tx_pkt_byte_cnt              (),
      .tx_pkt_byte_cnt_vld          ()
    );
   axis_control_if  
   #(
      .ENABLE_LEN    (0)
   )eth_axis_control_if_3(
      .m_axis_txd_tvalid            (m_axis_txd_3_tvalid), 
      .m_axis_txd_tlast             (m_axis_txd_3_tlast), 
      .m_axis_txd_tready            (m_axis_txd_3_tready), 

      .s_axis_rxs_aclk              (axis_aclk), 
      .s_axis_rxs_aresetn           (axis_aresetn), 
      .s_axis_rxs_tready            (s_axis_rxs_3_tready), 
      .s_axis_rxs_tdata             (s_axis_rxs_3_tdata), 
      .s_axis_rxs_tkeep             (s_axis_rxs_3_tkeep), 
      .s_axis_rxs_tlast             (s_axis_rxs_3_tlast), 
      .s_axis_rxs_tvalid            (s_axis_rxs_3_tvalid), 
      
      .m_axis_txc_aclk              (axis_aclk), 
      .m_axis_txc_aresetn           (axis_aresetn), 
      .m_axis_txc_tvalid            (m_axis_txc_3_tvalid), 
      .m_axis_txc_tdata             (m_axis_txc_3_tdata), 
      .m_axis_txc_tkeep             (m_axis_txc_3_tkeep), 
      .m_axis_txc_tlast             (m_axis_txc_3_tlast), 
      .m_axis_txc_tready            (m_axis_txc_3_tready),
      
      .tx_pkt_byte_cnt              (),
      .tx_pkt_byte_cnt_vld          ()
    );
   
   axis_control_if 
   #(
      .ENABLE_LEN    (1)
   )dma_axis_control_if_0(
      .m_axis_txd_tvalid            (m_axis_s2mm_0_tvalid), 
      .m_axis_txd_tlast             (m_axis_s2mm_0_tlast), 
      .m_axis_txd_tready            (m_axis_s2mm_0_tready), 

      .s_axis_rxs_aclk              (axis_aclk), 
      .s_axis_rxs_aresetn           (axis_aresetn), 
      .s_axis_rxs_tready            (s_axis_mm2s_ctrl_0_tready), 
      .s_axis_rxs_tdata             (s_axis_mm2s_ctrl_0_tdata), 
      .s_axis_rxs_tkeep             (s_axis_mm2s_ctrl_0_tkeep), 
      .s_axis_rxs_tlast             (s_axis_mm2s_ctrl_0_tlast), 
      .s_axis_rxs_tvalid            (s_axis_mm2s_ctrl_0_tvalid), 
      
      .m_axis_txc_aclk              (axis_aclk), 
      .m_axis_txc_aresetn           (axis_aresetn), 
      .m_axis_txc_tvalid            (m_axis_s2mm_sts_0_tvalid), 
      .m_axis_txc_tdata             (m_axis_s2mm_sts_0_tdata), 
      .m_axis_txc_tkeep             (m_axis_s2mm_sts_0_tkeep), 
      .m_axis_txc_tlast             (m_axis_s2mm_sts_0_tlast), 
      .m_axis_txc_tready            (m_axis_s2mm_sts_0_tready),
      
      .tx_pkt_byte_cnt              (dma_tx_pkt_byte_cnt[0*12 +: 12]),
      .tx_pkt_byte_cnt_vld          (dma_tx_pkt_byte_cnt_vld[0*1 +: 1])
    );
    axis_control_if 
   #(
      .ENABLE_LEN    (1)
   )dma_axis_control_if_1(
      .m_axis_txd_tvalid            (m_axis_s2mm_1_tvalid), 
      .m_axis_txd_tlast             (m_axis_s2mm_1_tlast), 
      .m_axis_txd_tready            (m_axis_s2mm_1_tready), 

      .s_axis_rxs_aclk              (axis_aclk), 
      .s_axis_rxs_aresetn           (axis_aresetn), 
      .s_axis_rxs_tready            (s_axis_mm2s_ctrl_1_tready), 
      .s_axis_rxs_tdata             (s_axis_mm2s_ctrl_1_tdata), 
      .s_axis_rxs_tkeep             (s_axis_mm2s_ctrl_1_tkeep), 
      .s_axis_rxs_tlast             (s_axis_mm2s_ctrl_1_tlast), 
      .s_axis_rxs_tvalid            (s_axis_mm2s_ctrl_1_tvalid), 
      
      .m_axis_txc_aclk              (axis_aclk), 
      .m_axis_txc_aresetn           (axis_aresetn), 
      .m_axis_txc_tvalid            (m_axis_s2mm_sts_1_tvalid), 
      .m_axis_txc_tdata             (m_axis_s2mm_sts_1_tdata), 
      .m_axis_txc_tkeep             (m_axis_s2mm_sts_1_tkeep), 
      .m_axis_txc_tlast             (m_axis_s2mm_sts_1_tlast), 
      .m_axis_txc_tready            (m_axis_s2mm_sts_1_tready),
      
      .tx_pkt_byte_cnt              (dma_tx_pkt_byte_cnt[1*12 +: 12]),
      .tx_pkt_byte_cnt_vld          (dma_tx_pkt_byte_cnt_vld[1*1 +: 1])
    );
      axis_control_if 
   #(
      .ENABLE_LEN    (1)
   )dma_axis_control_if_2(
      .m_axis_txd_tvalid            (m_axis_s2mm_2_tvalid), 
      .m_axis_txd_tlast             (m_axis_s2mm_2_tlast), 
      .m_axis_txd_tready            (m_axis_s2mm_2_tready), 

      .s_axis_rxs_aclk              (axis_aclk), 
      .s_axis_rxs_aresetn           (axis_aresetn), 
      .s_axis_rxs_tready            (s_axis_mm2s_ctrl_2_tready), 
      .s_axis_rxs_tdata             (s_axis_mm2s_ctrl_2_tdata), 
      .s_axis_rxs_tkeep             (s_axis_mm2s_ctrl_2_tkeep), 
      .s_axis_rxs_tlast             (s_axis_mm2s_ctrl_2_tlast), 
      .s_axis_rxs_tvalid            (s_axis_mm2s_ctrl_2_tvalid), 
      
      .m_axis_txc_aclk              (axis_aclk), 
      .m_axis_txc_aresetn           (axis_aresetn), 
      .m_axis_txc_tvalid            (m_axis_s2mm_sts_2_tvalid), 
      .m_axis_txc_tdata             (m_axis_s2mm_sts_2_tdata), 
      .m_axis_txc_tkeep             (m_axis_s2mm_sts_2_tkeep), 
      .m_axis_txc_tlast             (m_axis_s2mm_sts_2_tlast), 
      .m_axis_txc_tready            (m_axis_s2mm_sts_2_tready),
      
      .tx_pkt_byte_cnt              (dma_tx_pkt_byte_cnt[2*12 +: 12]),
      .tx_pkt_byte_cnt_vld          (dma_tx_pkt_byte_cnt_vld[2*1 +: 1])
    );
   axis_control_if 
   #(
      .ENABLE_LEN    (1)
   )dma_axis_control_if_3(
      .m_axis_txd_tvalid            (m_axis_s2mm_3_tvalid), 
      .m_axis_txd_tlast             (m_axis_s2mm_3_tlast), 
      .m_axis_txd_tready            (m_axis_s2mm_3_tready), 

      .s_axis_rxs_aclk              (axis_aclk), 
      .s_axis_rxs_aresetn           (axis_aresetn), 
      .s_axis_rxs_tready            (s_axis_mm2s_ctrl_3_tready), 
      .s_axis_rxs_tdata             (s_axis_mm2s_ctrl_3_tdata), 
      .s_axis_rxs_tkeep             (s_axis_mm2s_ctrl_3_tkeep), 
      .s_axis_rxs_tlast             (s_axis_mm2s_ctrl_3_tlast), 
      .s_axis_rxs_tvalid            (s_axis_mm2s_ctrl_3_tvalid), 
      
      .m_axis_txc_aclk              (axis_aclk), 
      .m_axis_txc_aresetn           (axis_aresetn), 
      .m_axis_txc_tvalid            (m_axis_s2mm_sts_3_tvalid), 
      .m_axis_txc_tdata             (m_axis_s2mm_sts_3_tdata), 
      .m_axis_txc_tkeep             (m_axis_s2mm_sts_3_tkeep), 
      .m_axis_txc_tlast             (m_axis_s2mm_sts_3_tlast), 
      .m_axis_txc_tready            (m_axis_s2mm_sts_3_tready),
      
      .tx_pkt_byte_cnt              (dma_tx_pkt_byte_cnt[3*12 +: 12]),
      .tx_pkt_byte_cnt_vld          (dma_tx_pkt_byte_cnt_vld[3*1 +: 1])
    );
endmodule
