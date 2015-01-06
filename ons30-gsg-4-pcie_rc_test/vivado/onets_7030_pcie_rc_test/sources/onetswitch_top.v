`timescale 1 ps / 1 ps

module onetswitch_top(
   inout [14:0]         DDR_addr,
   inout [2:0]          DDR_ba,
   inout                DDR_cas_n,
   inout                DDR_ck_n,
   inout                DDR_ck_p,
   inout                DDR_cke,
   inout                DDR_cs_n,
   inout [3:0]          DDR_dm,
   inout [31:0]         DDR_dq,
   inout [3:0]          DDR_dqs_n,
   inout [3:0]          DDR_dqs_p,
   inout                DDR_odt,
   inout                DDR_ras_n,
   inout                DDR_reset_n,
   inout                DDR_we_n,
   inout                FIXED_IO_ddr_vrn,
   inout                FIXED_IO_ddr_vrp,
   inout [53:0]         FIXED_IO_mio,
   inout                FIXED_IO_ps_clk,
   inout                FIXED_IO_ps_porb,
   inout                FIXED_IO_ps_srstb,

   input                sgmii_refclk_p,
   input                sgmii_refclk_n,

   output               gtx_pcie_txp ,
   output               gtx_pcie_txn ,
   input                gtx_pcie_rxp ,
   input                gtx_pcie_rxn ,
   input                gtx_pcie_clk_100m_p ,
   input                gtx_pcie_clk_100m_n ,
   
   input                pcie_wake_b ,
   input                pcie_clkreq_b ,
   output               pcie_perst_b ,
   output               pcie_w_disable_b ,   

   output [1:0]         pl_led,
   output [1:0]         pl_pmod,
   input                pl_btn
);

   wire bd_fclk0_125m ;
   wire bd_fclk1_75m  ;
   wire bd_fclk2_200m ;
   wire bd_aresetn ;

   wire sgmii_refclk_se;
   
   wire pcie_dbg_clk ;
   wire pcie_dbg_mmcm_lock ;   
   wire gtx_pcie_refclk;     

   reg [23:0] cnt_0;
   reg [23:0] cnt_1;
   reg [23:0] cnt_2;
   reg [23:0] cnt_3;

   always @(posedge bd_fclk0_125m) begin
     cnt_0 <= cnt_0 + 1'b1;
   end
   always @(posedge bd_fclk1_75m) begin
     cnt_1 <= cnt_1 + 1'b1;
   end
   always @(posedge sgmii_refclk_se) begin
     cnt_2 <= cnt_2 + 1'b1;
   end
   always @(posedge pcie_dbg_clk) begin
     cnt_3 <= cnt_3 + 1'b1;
   end


   assign pl_led[0]  = pcie_dbg_mmcm_lock;
   assign pl_led[1]  = bd_aresetn;
   assign pl_pmod[0] = cnt_2[23];
   assign pl_pmod[1] = cnt_3[23];

   // sgmii ref clk
   IBUFDS #(
      .DIFF_TERM("FALSE"),       // Differential Termination
      .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE"
      .IOSTANDARD("LVDS_25")     // Specify the input I/O standard
   ) IBUFDS_i_sgmii_refclk (
      .O    (sgmii_refclk_se),    // Buffer output
      .I    (sgmii_refclk_p),     // Diff_p buffer input (connect directly to top-level port)
      .IB   (sgmii_refclk_n)      // Diff_n buffer input (connect directly to top-level port)
   );

   assign pcie_perst_b = bd_aresetn ;
   assign pcie_w_disable_b = bd_aresetn ;
   IBUFDS_GTE2 refclk_ibuf_pcie (.O(gtx_pcie_refclk), .ODIV2(), .I(gtx_pcie_clk_100m_p), .CEB(1'b0), .IB(gtx_pcie_clk_100m_n));

onets_bd_wrapper i_onets_bd_wrapper(
   .DDR_addr               (DDR_addr),
   .DDR_ba                 (DDR_ba),
   .DDR_cas_n              (DDR_cas_n),
   .DDR_ck_n               (DDR_ck_n),
   .DDR_ck_p               (DDR_ck_p),
   .DDR_cke                (DDR_cke),
   .DDR_cs_n               (DDR_cs_n),
   .DDR_dm                 (DDR_dm),
   .DDR_dq                 (DDR_dq),
   .DDR_dqs_n              (DDR_dqs_n),
   .DDR_dqs_p              (DDR_dqs_p),
   .DDR_odt                (DDR_odt),
   .DDR_ras_n              (DDR_ras_n),
   .DDR_reset_n            (DDR_reset_n),
   .DDR_we_n               (DDR_we_n),
   .FIXED_IO_ddr_vrn       (FIXED_IO_ddr_vrn),
   .FIXED_IO_ddr_vrp       (FIXED_IO_ddr_vrp),
   .FIXED_IO_mio           (FIXED_IO_mio),
   .FIXED_IO_ps_clk        (FIXED_IO_ps_clk),
   .FIXED_IO_ps_porb       (FIXED_IO_ps_porb),
   .FIXED_IO_ps_srstb      (FIXED_IO_ps_srstb),

   .pcie_7x_mgt_rxn        ( gtx_pcie_rxn ),
   .pcie_7x_mgt_rxp        ( gtx_pcie_rxp ),
   .pcie_7x_mgt_txn        ( gtx_pcie_txn ),
   .pcie_7x_mgt_txp        ( gtx_pcie_txp ),
   .pcie_msi_en            ( 'b0),
   .pcie_msi_gnt           ( ),
   .pcie_msi_req           ( 'b0 ),
   .pcie_msi_vec_num       ( 'b0),
   .pcie_msi_vec_width     ( ),
   .pcie_refclk            ( gtx_pcie_refclk ),
   .pcie_dbg_clk           ( pcie_dbg_clk ),
   .pcie_dbg_mmcm_lock     ( pcie_dbg_mmcm_lock ),

   .bd_fclk0_125m       ( bd_fclk0_125m   ),
   .bd_fclk1_75m        ( bd_fclk1_75m    ),
   .bd_fclk2_200m       ( bd_fclk2_200m   ),
   .bd_aresetn          ( bd_aresetn      ),
   .ext_rst             ( pl_btn )
);

endmodule