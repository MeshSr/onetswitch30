//-----------------------------------------------------------------//
//packet_processing_pipeline.v
//
//-----------------------------------------------------------------//
module onet_core_logic(
      input          clk,                       //system clk
      input          reset,                     //system reset
      //------------------------------//
      //MAC interface
      //Four axi-stream master-slave pairs.
      //Note that s_axis_eth_aclk_x is used as clock by both slave and master interfaces.
      //------------------------------//  

      //ethernet port 0
      input          s_axis_eth_aclk_0,
      output         s_axis_eth_rx_aresetn_0,
      input [31:0]   s_axis_eth_rx_tdata_0,
      input          s_axis_eth_rx_tvalid_0,
      input          s_axis_eth_rx_tlast_0,
      input [3:0]    s_axis_eth_rx_tkeep_0,
      output         s_axis_eth_rx_tready_0,
      
      output         m_axis_eth_tx_aresetn_0,
      output [31:0]  m_axis_eth_tx_tdata_0,
      output         m_axis_eth_tx_tvalid_0,
      output         m_axis_eth_tx_tlast_0,
      output [3:0]   m_axis_eth_tx_tkeep_0,
      input          m_axis_eth_tx_tready_0,
      
      //ethernet port 1
      input          s_axis_eth_aclk_1,
      output         s_axis_eth_rx_aresetn_1,
      input [31:0]   s_axis_eth_rx_tdata_1,
      input          s_axis_eth_rx_tvalid_1,
      input          s_axis_eth_rx_tlast_1,
      input [3:0]    s_axis_eth_rx_tkeep_1,
      output         s_axis_eth_rx_tready_1,
      
      output         m_axis_eth_tx_aresetn_1,
      output [31:0]  m_axis_eth_tx_tdata_1,
      output         m_axis_eth_tx_tvalid_1,
      output         m_axis_eth_tx_tlast_1,
      output [3:0]   m_axis_eth_tx_tkeep_1,
      input          m_axis_eth_tx_tready_1,
      
      //ethernet port 2
      input          s_axis_eth_aclk_2,
      output         s_axis_eth_rx_aresetn_2,
      input [31:0]   s_axis_eth_rx_tdata_2,
      input          s_axis_eth_rx_tvalid_2,
      input          s_axis_eth_rx_tlast_2,
      input [3:0]    s_axis_eth_rx_tkeep_2,
      output         s_axis_eth_rx_tready_2,
      
      output         m_axis_eth_tx_aresetn_2,
      output [31:0]  m_axis_eth_tx_tdata_2,
      output         m_axis_eth_tx_tvalid_2,
      output         m_axis_eth_tx_tlast_2,
      output [3:0]   m_axis_eth_tx_tkeep_2,
      input          m_axis_eth_tx_tready_2,
      
      //ethernet port 3
      input          s_axis_eth_aclk_3,
      output         s_axis_eth_rx_aresetn_3,
      input [31:0]   s_axis_eth_rx_tdata_3,
      input          s_axis_eth_rx_tvalid_3,
      input          s_axis_eth_rx_tlast_3,
      input [3:0]    s_axis_eth_rx_tkeep_3,
      output         s_axis_eth_rx_tready_3,

      output         m_axis_eth_tx_aresetn_3,
      output [31:0]  m_axis_eth_tx_tdata_3,
      output         m_axis_eth_tx_tvalid_3,
      output         m_axis_eth_tx_tlast_3,
      output [3:0]   m_axis_eth_tx_tkeep_3,
      input          m_axis_eth_tx_tready_3,
      //------------------------------//
      //DMA interface
      //Four axi-stream master-slave pairs.
      //Note that s_axis_dma_aclk_x is used as clock by both slave and master interfaces.
      //------------------------------//     
      
      //dma port 0
      input          s_axis_dma_aclk_0,
      input [31:0]   s_axis_dma_rx_tdata_0,
      input          s_axis_dma_rx_tvalid_0,
      input          s_axis_dma_rx_tlast_0,
      input [3:0]    s_axis_dma_rx_tkeep_0,
      output         s_axis_dma_rx_tready_0,
      
      output [31:0]  m_axis_dma_tx_tdata_0,
      output         m_axis_dma_tx_tvalid_0,
      output         m_axis_dma_tx_tlast_0,
      output [3:0]   m_axis_dma_tx_tkeep_0,
      input          m_axis_dma_tx_tready_0,
      
      //dma port 1
      input          s_axis_dma_aclk_1,
      input [31:0]   s_axis_dma_rx_tdata_1,
      input          s_axis_dma_rx_tvalid_1,
      input          s_axis_dma_rx_tlast_1,
      input [3:0]    s_axis_dma_rx_tkeep_1,
      output         s_axis_dma_rx_tready_1,

      output [31:0]  m_axis_dma_tx_tdata_1,
      output         m_axis_dma_tx_tvalid_1,
      output         m_axis_dma_tx_tlast_1,
      output [3:0]   m_axis_dma_tx_tkeep_1,
      input          m_axis_dma_tx_tready_1,
      
      //dma port 2
      input          s_axis_dma_aclk_2,
      input [31:0]   s_axis_dma_rx_tdata_2,
      input          s_axis_dma_rx_tvalid_2,
      input          s_axis_dma_rx_tlast_2,
      input [3:0]    s_axis_dma_rx_tkeep_2,
      output         s_axis_dma_rx_tready_2,
      
      output [31:0]  m_axis_dma_tx_tdata_2,
      output         m_axis_dma_tx_tvalid_2,
      output         m_axis_dma_tx_tlast_2,
      output [3:0]   m_axis_dma_tx_tkeep_2,
      input          m_axis_dma_tx_tready_2,
      
      //dma port 3
      input          s_axis_dma_aclk_3,
      input [31:0]   s_axis_dma_rx_tdata_3,
      input          s_axis_dma_rx_tvalid_3,
      input          s_axis_dma_rx_tlast_3,
      input [3:0]    s_axis_dma_rx_tkeep_3,
      output         s_axis_dma_rx_tready_3,

      output [31:0]  m_axis_dma_tx_tdata_3,
      output         m_axis_dma_tx_tvalid_3,
      output         m_axis_dma_tx_tlast_3,
      output [3:0]   m_axis_dma_tx_tkeep_3,
      input          m_axis_dma_tx_tready_3,
      //------------------------------//
      //AXI-lite Slave interface
      //------------------------------//
      input          s_axi_aclk,
      input          s_axi_aresetn,
      // Write address channel
      input [31:0]   s_axi_awaddr,
      input [2:0]    s_axi_awprot,
      input          s_axi_awvalid,
      output         s_axi_awready,
      // Write Data Channel
      input [31:0]   s_axi_wdata, 
      input [3:0]    s_axi_wstrb,
      input          s_axi_wvalid,
      output         s_axi_wready,
      // Write Response Channel
      output [1:0]   s_axi_bresp,
      output         s_axi_bvalid,
      input          s_axi_bready,
      // Read Address channel
      input [31:0]   s_axi_araddr,
      input [2:0]    s_axi_arprot,
      input          s_axi_arvalid,
      output         s_axi_arready,
      // Read Data Channel
      output [31:0]  s_axi_rdata,
      output [1:0]   s_axi_rresp,
      output         s_axi_rvalid,
      input          s_axi_rready,
      
      output [4*12 - 1 : 0]   dma_tx_pkt_byte_cnt,
      output [4*1 - 1 : 0]    dma_tx_pkt_byte_cnt_vld
    );
    
   //--------local parameters -------
   localparam DATA_WIDTH = 64;
   localparam CTRL_WIDTH = DATA_WIDTH/8;
   localparam NUM_QUEUES = 8;
   localparam PKT_LEN_CNT_WIDTH = 11;
   localparam UDP_REG_SRC_WIDTH = 2;
   
   // register bus decode
   wire              reg_req;
	wire              reg_rd_wr_L;
	wire [31:0]       reg_addr;
	wire [31:0]       reg_wr_data;
	wire              reg_ack;
	wire [31:0]       reg_rd_data;
   
   wire              core_reg_req;
	wire              core_reg_rd_wr_L;
	wire [31:0]       core_reg_addr;
	wire [31:0]       core_reg_wr_data;
	wire              core_reg_ack;
	wire [31:0]       core_reg_rd_data;
   
   wire              udp_reg_req;
	wire              udp_reg_rd_wr_L;
	wire [31:0]       udp_reg_addr;
	wire [31:0]       udp_reg_wr_data;
	wire              udp_reg_ack;
	wire [31:0]       udp_reg_rd_data;
   
   wire [3:0]                          core_4mb_reg_req;
   wire [3:0]                          core_4mb_reg_rd_wr_L;
   wire [3:0]                          core_4mb_reg_ack;
   wire [4 * `BLOCK_SIZE_1M_REG_ADDR_WIDTH-1:0] core_4mb_reg_addr;
   wire [4 * 32 - 1:0]                 core_4mb_reg_wr_data;
   wire [4 * 32 - 1:0]                 core_4mb_reg_rd_data;

   wire [15:0]                         core_256kb_0_reg_req;
   wire [15:0]                         core_256kb_0_reg_rd_wr_L;
   wire [15:0]                         core_256kb_0_reg_ack;
   wire [16 * `BLOCK_SIZE_64k_REG_ADDR_WIDTH-1:0] core_256kb_0_reg_addr;
   wire [16 * 32 - 1:0]                core_256kb_0_reg_wr_data;
   wire [16 * 32 - 1:0]                core_256kb_0_reg_rd_data;
   
   // data path
   wire [3:0]                          s_axis_eth_aclk_i;
   
   wire [31:0]                         s_axis_eth_rx_tdata_i   [3:0];
   wire                                s_axis_eth_rx_tvalid_i  [3:0];
   wire                                s_axis_eth_rx_tlast_i   [3:0];
   wire [3:0]                          s_axis_eth_rx_tkeep_i   [3:0];
   wire                                s_axis_eth_rx_tready_i  [3:0];
   
   wire [31:0]                         m_axis_eth_tx_tdata_i   [3:0];
   wire                                m_axis_eth_tx_tvalid_i  [3:0];
   wire                                m_axis_eth_tx_tlast_i   [3:0];
   wire [3:0]                          m_axis_eth_tx_tkeep_i   [3:0];
   wire                                m_axis_eth_tx_tready_i  [3:0]; 

   wire [3:0]                          s_axis_dma_aclk_i;
   
   wire [31:0]                         s_axis_dma_rx_tdata_i   [3:0];
   wire                                s_axis_dma_rx_tvalid_i  [3:0];
   wire                                s_axis_dma_rx_tlast_i   [3:0];
   wire [3:0]                          s_axis_dma_rx_tkeep_i   [3:0];
   wire                                s_axis_dma_rx_tready_i  [3:0];
   
   wire [31:0]                         m_axis_dma_tx_tdata_i   [3:0];
   wire                                m_axis_dma_tx_tvalid_i  [3:0];
   wire                                m_axis_dma_tx_tlast_i   [3:0];
   wire [3:0]                          m_axis_dma_tx_tkeep_i   [3:0];
   wire                                m_axis_dma_tx_tready_i  [3:0]; 
   
   wire [NUM_QUEUES-1:0]               out_wr;
   wire [NUM_QUEUES-1:0]               out_rdy;
   wire [DATA_WIDTH-1:0]               out_data [NUM_QUEUES-1:0];
   wire [CTRL_WIDTH-1:0]               out_ctrl [NUM_QUEUES-1:0];

   wire [NUM_QUEUES-1:0]               in_wr;
   wire [NUM_QUEUES-1:0]               in_rdy;
   wire [DATA_WIDTH-1:0]               in_data [NUM_QUEUES-1:0];
   wire [CTRL_WIDTH-1:0]               in_ctrl [NUM_QUEUES-1:0];
   
   //-----------------------------------------------------------
   //MAC rx and tx queues
   //use register block 8-11
   //-----------------------------------------------------------
   generate
      genvar i;
      for(i=0; i<4; i=i+1) begin: mac_queues
         eth_queue #(
            .DATA_WIDTH(DATA_WIDTH),
            .ENABLE_HEADER(1),
            .PORT_NUMBER(2 * i),
            .STAGE_NUMBER(`IO_QUEUE_STAGE_NUM)
         ) eth_queue
        (   // register interface
            .mac_grp_reg_req        (core_256kb_0_reg_req[`WORD(`MAC_QUEUE_0_BLOCK_ADDR + i,1)]),
            .mac_grp_reg_ack        (core_256kb_0_reg_ack[`WORD(`MAC_QUEUE_0_BLOCK_ADDR + i,1)]),
            .mac_grp_reg_rd_wr_L    (core_256kb_0_reg_rd_wr_L[`WORD(`MAC_QUEUE_0_BLOCK_ADDR + i,1)]),
            .mac_grp_reg_addr       (core_256kb_0_reg_addr[`WORD(`MAC_QUEUE_0_BLOCK_ADDR + i,
                                     `BLOCK_SIZE_64k_REG_ADDR_WIDTH)]),
            .mac_grp_reg_rd_data    (core_256kb_0_reg_rd_data[`WORD(`MAC_QUEUE_0_BLOCK_ADDR + i,32)]),
            .mac_grp_reg_wr_data    (core_256kb_0_reg_wr_data[`WORD(`MAC_QUEUE_0_BLOCK_ADDR + i,32)]),
            // data path interface
            .out_wr                 (in_wr[i*2]),
            .out_rdy                (in_rdy[i*2]),
            .out_data               (in_data[i*2]),
            .out_ctrl               (in_ctrl[i*2]),
            .in_wr                  (out_wr[i*2]),
            .in_rdy                 (out_rdy[i*2]),
            .in_data                (out_data[i*2]),
            .in_ctrl                (out_ctrl[i*2]),
            // mac interface
            .s_rx_axis_tdata        (s_axis_eth_rx_tdata_i[i]), 
            .s_rx_axis_tvalid       (s_axis_eth_rx_tvalid_i[i]), 
            .s_rx_axis_tlast        (s_axis_eth_rx_tlast_i[i]), 
            .s_rx_axis_tready       (s_axis_eth_rx_tready_i[i]), 
            .s_rx_axis_tkeep        (s_axis_eth_rx_tkeep_i[i]), 
            .m_tx_axis_tvalid       (m_axis_eth_tx_tvalid_i[i]), 
            .m_tx_axis_tdata        (m_axis_eth_tx_tdata_i[i]), 
            .m_tx_axis_tlast        (m_axis_eth_tx_tlast_i[i]), 
            .m_tx_axis_tkeep        (m_axis_eth_tx_tkeep_i[i]), 
            .m_tx_axis_tready       (m_axis_eth_tx_tready_i[i]), 
            // misc
            .tx_pkt_byte_cnt        (),
            .tx_pkt_byte_cnt_vld    (),
            .axis_aclk              (s_axis_eth_aclk_i[i]),
            .clk                    (clk),
            .reset                  (reset)
         );
      end 
   endgenerate
   //-----------------------------------------------------------
   //DMA rx and tx queues
   //use register block 12-15
   //-----------------------------------------------------------
   generate
      //genvar i;
      for(i=0; i<4; i=i+1) begin: dma_queues
         eth_queue #(
            .DATA_WIDTH(DATA_WIDTH),
            .ENABLE_HEADER(1),
            .PORT_NUMBER(2 * i + 1),
            .STAGE_NUMBER(`IO_QUEUE_STAGE_NUM)
         ) dma_queue
        (   // register interface
            .mac_grp_reg_req        (core_256kb_0_reg_req[`WORD(`CPU_QUEUE_0_BLOCK_ADDR + i,1)]),
            .mac_grp_reg_ack        (core_256kb_0_reg_ack[`WORD(`CPU_QUEUE_0_BLOCK_ADDR + i,1)]),
            .mac_grp_reg_rd_wr_L    (core_256kb_0_reg_rd_wr_L[`WORD(`CPU_QUEUE_0_BLOCK_ADDR + i,1)]),
            .mac_grp_reg_addr       (core_256kb_0_reg_addr[`WORD(`CPU_QUEUE_0_BLOCK_ADDR + i,
                                     `BLOCK_SIZE_64k_REG_ADDR_WIDTH)]),
            .mac_grp_reg_rd_data    (core_256kb_0_reg_rd_data[`WORD(`CPU_QUEUE_0_BLOCK_ADDR + i,32)]),
            .mac_grp_reg_wr_data    (core_256kb_0_reg_wr_data[`WORD(`CPU_QUEUE_0_BLOCK_ADDR + i,32)]),
            // data path interface
            .out_wr                 (in_wr[i*2+1]),
            .out_rdy                (in_rdy[i*2+1]),
            .out_data               (in_data[i*2+1]),
            .out_ctrl               (in_ctrl[i*2+1]),
            .in_wr                  (out_wr[i*2+1]),
            .in_rdy                 (out_rdy[i*2+1]),
            .in_data                (out_data[i*2+1]),
            .in_ctrl                (out_ctrl[i*2+1]),
            // mac interface
            .s_rx_axis_tdata        (s_axis_dma_rx_tdata_i[i]), 
            .s_rx_axis_tvalid       (s_axis_dma_rx_tvalid_i[i]), 
            .s_rx_axis_tlast        (s_axis_dma_rx_tlast_i[i]), 
            .s_rx_axis_tready       (s_axis_dma_rx_tready_i[i]), 
            .s_rx_axis_tkeep        (s_axis_dma_rx_tkeep_i[i]), 
            .m_tx_axis_tvalid       (m_axis_dma_tx_tvalid_i[i]), 
            .m_tx_axis_tdata        (m_axis_dma_tx_tdata_i[i]), 
            .m_tx_axis_tlast        (m_axis_dma_tx_tlast_i[i]), 
            .m_tx_axis_tkeep        (m_axis_dma_tx_tkeep_i[i]), 
            .m_tx_axis_tready       (m_axis_dma_tx_tready_i[i]), 
            // misc
            .tx_pkt_byte_cnt        (dma_tx_pkt_byte_cnt[i*12 +: 12]),
            .tx_pkt_byte_cnt_vld    (dma_tx_pkt_byte_cnt_vld[i*1 +: 1]),
            .axis_aclk              (s_axis_dma_aclk_i[i]),
            .clk                    (clk),
            .reset                  (reset)
         );
      end 
   endgenerate
   //------------------------------------------------------------
   //register access
   //------------------------------------------------------------
   axi_to_reg_bus axi_to_reg_bus (
		.s_axi_awaddr     (s_axi_awaddr), 
		.s_axi_awprot     (s_axi_awprot), 
		.s_axi_awvalid    (s_axi_awvalid), 
		.s_axi_awready    (s_axi_awready), 
      
		.s_axi_wdata      (s_axi_wdata), 
		.s_axi_wstrb      (s_axi_wstrb), 
		.s_axi_wvalid     (s_axi_wvalid), 
		.s_axi_wready     (s_axi_wready), 
      
		.s_axi_bresp      (s_axi_bresp), 
		.s_axi_bvalid     (s_axi_bvalid), 
		.s_axi_bready     (s_axi_bready), 
      
		.s_axi_araddr     (s_axi_araddr), 
		.s_axi_arprot     (s_axi_arprot), 
		.s_axi_arvalid    (s_axi_arvalid), 
		.s_axi_arready    (s_axi_arready),
      
		.s_axi_rdata      (s_axi_rdata), 
		.s_axi_rresp      (s_axi_rresp), 
		.s_axi_rvalid     (s_axi_rvalid), 
		.s_axi_rready     (s_axi_rready), 
      
      .reg_req          (reg_req), 
		.reg_rd_wr_L      (reg_rd_wr_L), 
		.reg_addr         (reg_addr), 
		.reg_wr_data      (reg_wr_data), 
		.reg_ack          (reg_ack), 
		.reg_rd_data      (reg_rd_data),  
      
      .s_axi_aclk       (s_axi_aclk),
      .s_axi_aresetn    (s_axi_aresetn),
      .reset            (reset), 
      .clk              (clk)
	);
   udp_reg_path_decode udp_reg_path_decode (
		.reg_req          (reg_req), 
		.reg_rd_wr_L      (reg_rd_wr_L), 
		.reg_addr         (reg_addr), 
		.reg_wr_data      (reg_wr_data), 
		.reg_ack          (reg_ack), 
		.reg_rd_data      (reg_rd_data), 
      
      .core_reg_req     (core_reg_req), 
		.core_reg_rd_wr_L (core_reg_rd_wr_L), 
		.core_reg_addr    (core_reg_addr), 
		.core_reg_wr_data (core_reg_wr_data), 
		.core_reg_ack     (core_reg_ack), 
		.core_reg_rd_data (core_reg_rd_data), 
      
		.udp_reg_req      (udp_reg_req), 
		.udp_reg_rd_wr_L  (udp_reg_rd_wr_L), 
		.udp_reg_addr     (udp_reg_addr), 
		.udp_reg_wr_data  (udp_reg_wr_data), 
		.udp_reg_ack      (udp_reg_ack), 
		.udp_reg_rd_data  (udp_reg_rd_data),
      
		.clk              (clk), 
		.reset            (reset)
	);
   
   //------------------------------------------------------------
   //user data path
   //------------------------------------------------------------
   user_data_path
   #(
      .DATA_WIDTH(DATA_WIDTH),
      .CTRL_WIDTH(CTRL_WIDTH),
      .UDP_REG_SRC_WIDTH (UDP_REG_SRC_WIDTH),
      .NUM_OUTPUT_QUEUES(NUM_QUEUES),
      .NUM_INPUT_QUEUES(NUM_QUEUES)
   )user_data_path
   (
      // interface to MAC, CPU rx queues
      .in_data_0        (in_data[0]),
      .in_ctrl_0        (in_ctrl[0]),
      .in_wr_0          (in_wr[0]),
      .in_rdy_0         (in_rdy[0]),

      .in_data_1        (in_data[1]),
      .in_ctrl_1        (in_ctrl[1]),
      .in_wr_1          (in_wr[1]),
      .in_rdy_1         (in_rdy[1]),

      .in_data_2        (in_data[2]),
      .in_ctrl_2        (in_ctrl[2]),
      .in_wr_2          (in_wr[2]),
      .in_rdy_2         (in_rdy[2]),

      .in_data_3        (in_data[3]),
      .in_ctrl_3        (in_ctrl[3]),
      .in_wr_3          (in_wr[3]),
      .in_rdy_3         (in_rdy[3]),

      .in_data_4        (in_data[4]),
      .in_ctrl_4        (in_ctrl[4]),
      .in_wr_4          (in_wr[4]),
      .in_rdy_4         (in_rdy[4]),

      .in_data_5        (in_data[5]),
      .in_ctrl_5        (in_ctrl[5]),
      .in_wr_5          (in_wr[5]),
      .in_rdy_5         (in_rdy[5]),

      .in_data_6        (in_data[6]),
      .in_ctrl_6        (in_ctrl[6]),
      .in_wr_6          (in_wr[6]),
      .in_rdy_6         (in_rdy[6]),

      .in_data_7        (in_data[7]),
      .in_ctrl_7        (in_ctrl[7]),
      .in_wr_7          (in_wr[7]),
      .in_rdy_7         (in_rdy[7]),

      // interface to MAC, CPU tx queues
      .out_data_0       (out_data[0]),
      .out_ctrl_0       (out_ctrl[0]),
      .out_wr_0         (out_wr[0]),
      .out_rdy_0        (out_rdy[0]),

      .out_data_1       (out_data[1]),
      .out_ctrl_1       (out_ctrl[1]),
      .out_wr_1         (out_wr[1]),
      .out_rdy_1        (out_rdy[1]),

      .out_data_2       (out_data[2]),
      .out_ctrl_2       (out_ctrl[2]),
      .out_wr_2         (out_wr[2]),
      .out_rdy_2        (out_rdy[2]),

      .out_data_3       (out_data[3]),
      .out_ctrl_3       (out_ctrl[3]),
      .out_wr_3         (out_wr[3]),
      .out_rdy_3        (out_rdy[3]),

      .out_data_4       (out_data[4]),
      .out_ctrl_4       (out_ctrl[4]),
      .out_wr_4         (out_wr[4]),
      .out_rdy_4        (out_rdy[4]),

      .out_data_5       (out_data[5]),
      .out_ctrl_5       (out_ctrl[5]),
      .out_wr_5         (out_wr[5]),
      .out_rdy_5        (out_rdy[5]),

      .out_data_6       (out_data[6]),
      .out_ctrl_6       (out_ctrl[6]),
      .out_wr_6         (out_wr[6]),
      .out_rdy_6        (out_rdy[6]),

      .out_data_7       (out_data[7]),
      .out_ctrl_7       (out_ctrl[7]),
      .out_wr_7         (out_wr[7]),
      .out_rdy_7        (out_rdy[7]),

      // register interface
      .reg_req          (udp_reg_req),
      .reg_ack          (udp_reg_ack),
      .reg_rd_wr_L      (udp_reg_rd_wr_L),
      .reg_addr         (udp_reg_addr),
      .reg_rd_data      (udp_reg_rd_data),
      .reg_wr_data      (udp_reg_wr_data),

      // misc
      .reset            (reset),
      .clk              (clk)
   );

   //------------------------------------------------------------
   //register address space decode
   //------------------------------------------------------------
   reg_grp #(
      .REG_ADDR_BITS(`CORE_REG_ADDR_WIDTH), //4M, 22bits
      .NUM_OUTPUTS(4)
   ) core_4mb_reg_grp
   (
      // Upstream register interface
      .reg_req             (core_reg_req),
      .reg_rd_wr_L         (core_reg_rd_wr_L),
      .reg_addr            (core_reg_addr),
      .reg_wr_data         (core_reg_wr_data),

      .reg_ack             (core_reg_ack),
      .reg_rd_data         (core_reg_rd_data),


      // Downstream register interface
      .local_reg_req       (core_4mb_reg_req),
      .local_reg_rd_wr_L   (core_4mb_reg_rd_wr_L),
      .local_reg_addr      (core_4mb_reg_addr),
      .local_reg_wr_data   (core_4mb_reg_wr_data),

      .local_reg_ack       (core_4mb_reg_ack),
      .local_reg_rd_data   (core_4mb_reg_rd_data),


      //-- misc
      .clk                 (clk),
      .reset               (reset)
   );
   reg_grp #(
      .REG_ADDR_BITS(`CORE_REG_ADDR_WIDTH - 2), //BLOCK_SIZE_1M_REG_ADDR_WIDTH
      .NUM_OUTPUTS(16)
   ) core_256kb_0_reg_grp
   (
      // Upstream register interface
      .reg_req             (core_4mb_reg_req[`WORD(1,1)]),
      .reg_ack             (core_4mb_reg_ack[`WORD(1,1)]),
      .reg_rd_wr_L         (core_4mb_reg_rd_wr_L[`WORD(1,1)]),
      .reg_addr            (core_4mb_reg_addr[`WORD(1, `BLOCK_SIZE_1M_REG_ADDR_WIDTH)]),

      .reg_rd_data         (core_4mb_reg_rd_data[`WORD(1, 32)]),
      .reg_wr_data         (core_4mb_reg_wr_data[`WORD(1, 32)]),

      // Downstream register interface
      .local_reg_req       (core_256kb_0_reg_req),
      .local_reg_rd_wr_L   (core_256kb_0_reg_rd_wr_L),
      .local_reg_addr      (core_256kb_0_reg_addr),
      .local_reg_wr_data   (core_256kb_0_reg_wr_data),

      .local_reg_ack       (core_256kb_0_reg_ack),
      .local_reg_rd_data   (core_256kb_0_reg_rd_data),

      //-- misc
      .clk                 (clk),
      .reset               (reset)
   );
   
   //--------------------------------------------------
   // --- Unused register signals
   //--------------------------------------------------
   generate
      //genvar i;
      for (i = 0; i < 4; i = i + 1) begin: unused_reg_core_1mb_groups
         if (!(i == 1))
            unused_reg #(
               .REG_ADDR_WIDTH(`BLOCK_SIZE_1M_REG_ADDR_WIDTH)
            ) unused_reg_core_1mb_x (
               // Register interface signals
               .reg_req             (core_4mb_reg_req[`WORD(i,1)]),
               .reg_ack             (core_4mb_reg_ack[`WORD(i,1)]),
               .reg_rd_wr_L         (core_4mb_reg_rd_wr_L[`WORD(i,1)]),
               .reg_addr            (core_4mb_reg_addr[`WORD(i, `BLOCK_SIZE_1M_REG_ADDR_WIDTH)]),

               .reg_rd_data         (core_4mb_reg_rd_data[`WORD(i, 32)]),
               .reg_wr_data         (core_4mb_reg_wr_data[`WORD(i, 32)]),

               .clk                 (clk),
               .reset               (reset)
            );
      end
   endgenerate
   
   generate
      //genvar i;
      for (i = 0; i < 16; i = i + 1) begin: unused_reg_core_256kb
         if (!(i >= `MAC_QUEUE_0_BLOCK_ADDR &&
               i <  `MAC_QUEUE_0_BLOCK_ADDR + NUM_QUEUES/2) &&
             !(i >= `CPU_QUEUE_0_BLOCK_ADDR &&
               i <  `CPU_QUEUE_0_BLOCK_ADDR + NUM_QUEUES/2)
            )
            unused_reg #(
               .REG_ADDR_WIDTH(`BLOCK_SIZE_64k_REG_ADDR_WIDTH)
            ) unused_reg_core_256kb_x (
               // Register interface signals
               .reg_req             (core_256kb_0_reg_req[`WORD(i,1)]),
               .reg_ack             (core_256kb_0_reg_ack[`WORD(i,1)]),
               .reg_rd_wr_L         (core_256kb_0_reg_rd_wr_L[`WORD(i,1)]),
               .reg_addr            (core_256kb_0_reg_addr[`WORD(i, `BLOCK_SIZE_64k_REG_ADDR_WIDTH)]),

               .reg_rd_data         (core_256kb_0_reg_rd_data[`WORD(i, 32)]),
               .reg_wr_data         (core_256kb_0_reg_wr_data[`WORD(i, 32)]),

               .clk                 (clk),
               .reset               (reset)
            );
      end
   endgenerate
   
   //ETHERNET PATH
   assign      s_axis_eth_aclk_i[0] = s_axis_eth_aclk_0;
   assign      s_axis_eth_aclk_i[1] = s_axis_eth_aclk_1;
   assign      s_axis_eth_aclk_i[2] = s_axis_eth_aclk_2;
   assign      s_axis_eth_aclk_i[3] = s_axis_eth_aclk_3;
   
   // 0
   assign      s_axis_eth_rx_tdata_i[0] = s_axis_eth_rx_tdata_0;
   assign      s_axis_eth_rx_tvalid_i[0] = s_axis_eth_rx_tvalid_0;
   assign      s_axis_eth_rx_tlast_i[0] = s_axis_eth_rx_tlast_0;
   assign      s_axis_eth_rx_tkeep_i[0] = s_axis_eth_rx_tkeep_0;
   assign      s_axis_eth_rx_tready_0 = s_axis_eth_rx_tready_i[0];
      
   assign      m_axis_eth_tx_tdata_0 = m_axis_eth_tx_tdata_i[0];
   assign      m_axis_eth_tx_tvalid_0 = m_axis_eth_tx_tvalid_i[0];
   assign      m_axis_eth_tx_tlast_0 = m_axis_eth_tx_tlast_i[0];
   assign      m_axis_eth_tx_tkeep_0 = m_axis_eth_tx_tkeep_i[0];
   assign      m_axis_eth_tx_tready_i[0] = m_axis_eth_tx_tready_0;
   //1
   assign      s_axis_eth_rx_tdata_i[1] = s_axis_eth_rx_tdata_1;
   assign      s_axis_eth_rx_tvalid_i[1] = s_axis_eth_rx_tvalid_1;
   assign      s_axis_eth_rx_tlast_i[1] = s_axis_eth_rx_tlast_1;
   assign      s_axis_eth_rx_tkeep_i[1] = s_axis_eth_rx_tkeep_1;
   assign      s_axis_eth_rx_tready_1 = s_axis_eth_rx_tready_i[1];
      
   assign      m_axis_eth_tx_tdata_1 = m_axis_eth_tx_tdata_i[1];
   assign      m_axis_eth_tx_tvalid_1 = m_axis_eth_tx_tvalid_i[1];
   assign      m_axis_eth_tx_tlast_1 = m_axis_eth_tx_tlast_i[1];
   assign      m_axis_eth_tx_tkeep_1 = m_axis_eth_tx_tkeep_i[1];
   assign      m_axis_eth_tx_tready_i[1] = m_axis_eth_tx_tready_1;
   //2
   assign      s_axis_eth_rx_tdata_i[2] = s_axis_eth_rx_tdata_2;
   assign      s_axis_eth_rx_tvalid_i[2] = s_axis_eth_rx_tvalid_2;
   assign      s_axis_eth_rx_tlast_i[2] = s_axis_eth_rx_tlast_2;
   assign      s_axis_eth_rx_tkeep_i[2] = s_axis_eth_rx_tkeep_2;
   assign      s_axis_eth_rx_tready_2 = s_axis_eth_rx_tready_i[2];
      
   assign      m_axis_eth_tx_tdata_2 = m_axis_eth_tx_tdata_i[2];
   assign      m_axis_eth_tx_tvalid_2 = m_axis_eth_tx_tvalid_i[2];
   assign      m_axis_eth_tx_tlast_2 = m_axis_eth_tx_tlast_i[2];
   assign      m_axis_eth_tx_tkeep_2 = m_axis_eth_tx_tkeep_i[2];
   assign      m_axis_eth_tx_tready_i[2] = m_axis_eth_tx_tready_2;
   //3
   assign      s_axis_eth_rx_tdata_i[3] = s_axis_eth_rx_tdata_3;
   assign      s_axis_eth_rx_tvalid_i[3] = s_axis_eth_rx_tvalid_3;
   assign      s_axis_eth_rx_tlast_i[3] = s_axis_eth_rx_tlast_3;
   assign      s_axis_eth_rx_tkeep_i[3] = s_axis_eth_rx_tkeep_3;
   assign      s_axis_eth_rx_tready_3 = s_axis_eth_rx_tready_i[3];
      
   assign      m_axis_eth_tx_tdata_3 = m_axis_eth_tx_tdata_i[3];
   assign      m_axis_eth_tx_tvalid_3 = m_axis_eth_tx_tvalid_i[3];
   assign      m_axis_eth_tx_tlast_3 = m_axis_eth_tx_tlast_i[3];
   assign      m_axis_eth_tx_tkeep_3 = m_axis_eth_tx_tkeep_i[3];
   assign      m_axis_eth_tx_tready_i[3] = m_axis_eth_tx_tready_3;
   // 
   //DMA PATH
   assign      s_axis_dma_aclk_i[0] = s_axis_dma_aclk_0;
   assign      s_axis_dma_aclk_i[1] = s_axis_dma_aclk_1;
   assign      s_axis_dma_aclk_i[2] = s_axis_dma_aclk_2;
   assign      s_axis_dma_aclk_i[3] = s_axis_dma_aclk_3;
   
   // 0
   assign      s_axis_dma_rx_tdata_i[0] = s_axis_dma_rx_tdata_0;
   assign      s_axis_dma_rx_tvalid_i[0] = s_axis_dma_rx_tvalid_0;
   assign      s_axis_dma_rx_tlast_i[0] = s_axis_dma_rx_tlast_0;
   assign      s_axis_dma_rx_tkeep_i[0] = s_axis_dma_rx_tkeep_0;
   assign      s_axis_dma_rx_tready_0 = s_axis_dma_rx_tready_i[0];
      
   assign      m_axis_dma_tx_tdata_0 = m_axis_dma_tx_tdata_i[0];
   assign      m_axis_dma_tx_tvalid_0 = m_axis_dma_tx_tvalid_i[0];
   assign      m_axis_dma_tx_tlast_0 = m_axis_dma_tx_tlast_i[0];
   assign      m_axis_dma_tx_tkeep_0 = m_axis_dma_tx_tkeep_i[0];
   assign      m_axis_dma_tx_tready_i[0] = m_axis_dma_tx_tready_0;
   //1
   assign      s_axis_dma_rx_tdata_i[1] = s_axis_dma_rx_tdata_1;
   assign      s_axis_dma_rx_tvalid_i[1] = s_axis_dma_rx_tvalid_1;
   assign      s_axis_dma_rx_tlast_i[1] = s_axis_dma_rx_tlast_1;
   assign      s_axis_dma_rx_tkeep_i[1] = s_axis_dma_rx_tkeep_1;
   assign      s_axis_dma_rx_tready_1 = s_axis_dma_rx_tready_i[1];
      
   assign      m_axis_dma_tx_tdata_1 = m_axis_dma_tx_tdata_i[1];
   assign      m_axis_dma_tx_tvalid_1 = m_axis_dma_tx_tvalid_i[1];
   assign      m_axis_dma_tx_tlast_1 = m_axis_dma_tx_tlast_i[1];
   assign      m_axis_dma_tx_tkeep_1 = m_axis_dma_tx_tkeep_i[1];
   assign      m_axis_dma_tx_tready_i[1] = m_axis_dma_tx_tready_1;
   //2
   assign      s_axis_dma_rx_tdata_i[2] = s_axis_dma_rx_tdata_2;
   assign      s_axis_dma_rx_tvalid_i[2] = s_axis_dma_rx_tvalid_2;
   assign      s_axis_dma_rx_tlast_i[2] = s_axis_dma_rx_tlast_2;
   assign      s_axis_dma_rx_tkeep_i[2] = s_axis_dma_rx_tkeep_2;
   assign      s_axis_dma_rx_tready_2 = s_axis_dma_rx_tready_i[2];
      
   assign      m_axis_dma_tx_tdata_2 = m_axis_dma_tx_tdata_i[2];
   assign      m_axis_dma_tx_tvalid_2 = m_axis_dma_tx_tvalid_i[2];
   assign      m_axis_dma_tx_tlast_2 = m_axis_dma_tx_tlast_i[2];
   assign      m_axis_dma_tx_tkeep_2 = m_axis_dma_tx_tkeep_i[2];
   assign      m_axis_dma_tx_tready_i[2] = m_axis_dma_tx_tready_2;
   //3
   assign      s_axis_dma_rx_tdata_i[3] = s_axis_dma_rx_tdata_3;
   assign      s_axis_dma_rx_tvalid_i[3] = s_axis_dma_rx_tvalid_3;
   assign      s_axis_dma_rx_tlast_i[3] = s_axis_dma_rx_tlast_3;
   assign      s_axis_dma_rx_tkeep_i[3] = s_axis_dma_rx_tkeep_3;
   assign      s_axis_dma_rx_tready_3 = s_axis_dma_rx_tready_i[3];
      
   assign      m_axis_dma_tx_tdata_3 = m_axis_dma_tx_tdata_i[3];
   assign      m_axis_dma_tx_tvalid_3 = m_axis_dma_tx_tvalid_i[3];
   assign      m_axis_dma_tx_tlast_3 = m_axis_dma_tx_tlast_i[3];
   assign      m_axis_dma_tx_tkeep_3 = m_axis_dma_tx_tkeep_i[3];
   assign      m_axis_dma_tx_tready_i[3] = m_axis_dma_tx_tready_3;
   
   //Adapt to the axi_ethernet ip core axi interface defination
   assign      s_axis_eth_rx_aresetn_0 = !reset;
   assign      s_axis_eth_tx_aresetn_0 = !reset;
   assign      s_axis_eth_rx_aresetn_1 = !reset;
   assign      s_axis_eth_tx_aresetn_1 = !reset;
   assign      s_axis_eth_rx_aresetn_2 = !reset;
   assign      s_axis_eth_tx_aresetn_2 = !reset;  
   assign      s_axis_eth_rx_aresetn_3 = !reset;
   assign      s_axis_eth_tx_aresetn_3 = !reset;   
   
endmodule
