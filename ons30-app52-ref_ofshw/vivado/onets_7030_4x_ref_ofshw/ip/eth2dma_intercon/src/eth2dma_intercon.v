
module eth2dma_intercon
(
   input aclk,
   input aresetn,
   input s_rxs0_axis_tvalid,
   input s_rxs1_axis_tvalid,
   input s_rxs2_axis_tvalid,
   input s_rxs3_axis_tvalid,
   output s_rxs0_axis_tready,
   output s_rxs1_axis_tready,
   output s_rxs2_axis_tready,
   output s_rxs3_axis_tready,
   input [31 : 0] s_rxs0_axis_tdata,
   input [31 : 0] s_rxs1_axis_tdata,
   input [31 : 0] s_rxs2_axis_tdata,
   input [31 : 0] s_rxs3_axis_tdata,
   input [3 : 0] s_rxs0_axis_tkeep,
   input [3 : 0] s_rxs1_axis_tkeep,
   input [3 : 0] s_rxs2_axis_tkeep,
   input [3 : 0] s_rxs3_axis_tkeep,
   input s_rxs0_axis_tlast,
   input s_rxs1_axis_tlast,
   input s_rxs2_axis_tlast,
   input s_rxs3_axis_tlast,
/*   input [1 : 0] s_rxs0_axis_tid,
   input [1 : 0] s_rxs1_axis_tid,
   input [1 : 0] s_rxs2_axis_tid,
   input [1 : 0] s_rxs3_axis_tid,*/

   output m_rxs_axis_tvalid,
   input m_rxs_axis_tready,
   output reg [31 : 0] m_rxs_axis_tdata,
   output [3 : 0] m_rxs_axis_tkeep,
   output m_rxs_axis_tlast,
//   output [1 : 0] m_rxs_axis_tid,
   
   input s_rxd0_axis_tvalid,
   input s_rxd1_axis_tvalid,
   input s_rxd2_axis_tvalid,
   input s_rxd3_axis_tvalid,
   output s_rxd0_axis_tready,
   output s_rxd1_axis_tready,
   output s_rxd2_axis_tready,
   output s_rxd3_axis_tready,
   input [31 : 0] s_rxd0_axis_tdata,
   input [31 : 0] s_rxd1_axis_tdata,
   input [31 : 0] s_rxd2_axis_tdata,
   input [31 : 0] s_rxd3_axis_tdata,
   input [3 : 0] s_rxd0_axis_tkeep,
   input [3 : 0] s_rxd1_axis_tkeep,
   input [3 : 0] s_rxd2_axis_tkeep,
   input [3 : 0] s_rxd3_axis_tkeep,
   input s_rxd0_axis_tlast,
   input s_rxd1_axis_tlast,
   input s_rxd2_axis_tlast,
   input s_rxd3_axis_tlast,
/*   input [1 : 0] s_rxd0_axis_tid,
   input [1 : 0] s_rxd1_axis_tid,
   input [1 : 0] s_rxd2_axis_tid,
   input [1 : 0] s_rxd3_axis_tid,*/
   
   output reg m_rxd_axis_tvalid,
   input m_rxd_axis_tready,
   output reg [31 : 0] m_rxd_axis_tdata,
   output reg [3 : 0] m_rxd_axis_tkeep,
   output reg m_rxd_axis_tlast,
   output reg [1 : 0] m_rxd_axis_tid
   
);
   wire [1:0] m_rxs_axis_tid;
   wire [31 : 0] m_rxs_axis_tdata_i;
   reg [1:0] m_rxs_axis_tid_r, m_rxs_axis_tid_r_nxt;
   reg m_rxs_axis_tid_fifo_wr;
   
   reg [7:0] rxs_state, rxs_state_nxt;
   localparam  RXS_IDLE = 1,
               RXS_APP0 = 2,
               RXS_APP_REST = 4;
   localparam  CH0 = 2'b00,
               CH1 = 2'b01,
               CH2 = 2'b10,
               CH3 = 2'b11;
               
	axis_intercon_421 axis_intercon_421 (
      .ACLK                (aclk), 
		.ARESETN             (aresetn), 
		.S00_AXIS_ACLK       (aclk), 
		.S01_AXIS_ACLK       (aclk), 
		.S02_AXIS_ACLK       (aclk), 
		.S03_AXIS_ACLK       (aclk), 
		.S00_AXIS_ARESETN    (aresetn), 
		.S01_AXIS_ARESETN    (aresetn), 
		.S02_AXIS_ARESETN    (aresetn), 
		.S03_AXIS_ARESETN    (aresetn), 
		.S00_AXIS_TVALID     (s_rxs0_axis_tvalid), 
		.S01_AXIS_TVALID     (s_rxs1_axis_tvalid), 
		.S02_AXIS_TVALID     (s_rxs2_axis_tvalid), 
		.S03_AXIS_TVALID     (s_rxs3_axis_tvalid), 
		.S00_AXIS_TREADY     (s_rxs0_axis_tready), 
		.S01_AXIS_TREADY     (s_rxs1_axis_tready), 
		.S02_AXIS_TREADY     (s_rxs2_axis_tready), 
		.S03_AXIS_TREADY     (s_rxs3_axis_tready), 
		.S00_AXIS_TDATA      (s_rxs0_axis_tdata), 
		.S01_AXIS_TDATA      (s_rxs1_axis_tdata), 
		.S02_AXIS_TDATA      (s_rxs2_axis_tdata), 
		.S03_AXIS_TDATA      (s_rxs3_axis_tdata), 
		.S00_AXIS_TKEEP      (s_rxs0_axis_tkeep), 
		.S01_AXIS_TKEEP      (s_rxs1_axis_tkeep), 
		.S02_AXIS_TKEEP      (s_rxs2_axis_tkeep), 
		.S03_AXIS_TKEEP      (s_rxs3_axis_tkeep), 
		.S00_AXIS_TLAST      (s_rxs0_axis_tlast), 
		.S01_AXIS_TLAST      (s_rxs1_axis_tlast), 
		.S02_AXIS_TLAST      (s_rxs2_axis_tlast), 
		.S03_AXIS_TLAST      (s_rxs3_axis_tlast), 
		.S00_AXIS_TID        (CH0), 
		.S01_AXIS_TID        (CH1), 
		.S02_AXIS_TID        (CH2), 
		.S03_AXIS_TID        (CH3), 
		.M00_AXIS_ACLK       (aclk), 
		.M00_AXIS_ARESETN    (aresetn), 
		.M00_AXIS_TVALID     (m_rxs_axis_tvalid), 
		.M00_AXIS_TREADY     (m_rxs_axis_tready), 
		.M00_AXIS_TDATA      (m_rxs_axis_tdata_i), 
		.M00_AXIS_TKEEP      (m_rxs_axis_tkeep), 
		.M00_AXIS_TLAST      (m_rxs_axis_tlast), 
		.M00_AXIS_TID        (m_rxs_axis_tid), 
		.S00_ARB_REQ_SUPPRESS(0), 
		.S01_ARB_REQ_SUPPRESS(0), 
		.S02_ARB_REQ_SUPPRESS(0), 
		.S03_ARB_REQ_SUPPRESS(0)
	);

   wire rxs_tid_fifo_full;
   wire rxs_tid_fifo_empty;
   wire [1:0] m_rxs_axis_tid_dout;
   reg m_rxs_axis_tid_fifo_rd;
   rxs_tid_fifo_8x16 rxs_tid_fifo(
      .clk     (aclk),
      .rst     (!aresetn),
      .din     ({6'b0,m_rxs_axis_tid_r_nxt}),
      .wr_en   (m_rxs_axis_tid_fifo_wr & !rxs_tid_fifo_full),
      .rd_en   (m_rxs_axis_tid_fifo_rd),
      .dout    (m_rxs_axis_tid_dout),
      .full    (rxs_tid_fifo_full),
      .empty   (rxs_tid_fifo_empty)
   );
   
   //--------------------------------------
   //rxs state machine
   //--------------------------------------
   always @(*) begin
      if(!aresetn)begin
         m_rxs_axis_tdata = 0;
         rxs_state_nxt = 0;
         m_rxs_axis_tid_r_nxt = 0;
         m_rxs_axis_tid_fifo_wr = 0;
      end
      else begin
         rxs_state_nxt = rxs_state;
         m_rxs_axis_tid_r_nxt = m_rxs_axis_tid_r;
         m_rxs_axis_tdata = m_rxs_axis_tdata_i;
         m_rxs_axis_tid_fifo_wr = 0;
         
         case(rxs_state)
            RXS_IDLE: begin 
               if(m_rxs_axis_tvalid && m_rxs_axis_tready) begin 
                  m_rxs_axis_tid_r_nxt = m_rxs_axis_tid;
                  m_rxs_axis_tid_fifo_wr = 1;
                  rxs_state_nxt = RXS_APP0;
               end
            end
            RXS_APP0: begin
               m_rxs_axis_tdata[31:16] = m_rxs_axis_tid_r;
               if(m_rxs_axis_tvalid && m_rxs_axis_tready)rxs_state_nxt = RXS_APP_REST;
            end
            RXS_APP_REST: begin
               if(m_rxs_axis_tvalid && m_rxs_axis_tlast && m_rxs_axis_tready)rxs_state_nxt = RXS_IDLE;
            end
         endcase
      end
   end
   
   always @(posedge aclk)begin
      if(!aresetn)begin
         rxs_state <= RXS_IDLE;
         m_rxs_axis_tid_r <= 0;
      end
      else begin
         rxs_state <= rxs_state_nxt;
         m_rxs_axis_tid_r <= m_rxs_axis_tid_r_nxt;
      end
   end
   
   //--------------------------------------
   //rxd state machine
   //--------------------------------------
   
   wire [3:0] s_rxd_axis_tvalid;
   wire [31:0] s_rxd_axis_tdata[3:0] ;
   wire [3:0] s_rxd_axis_tkeep[3:0];
   wire [3:0] s_rxd_axis_tlast;
//   wire [1:0] s_rxd_axis_tid[3:0];
   reg [3:0] s_rxd_axis_tready ;
   
   always @(*)begin
      if(!aresetn) begin
         m_rxd_axis_tvalid = 0;
         m_rxd_axis_tdata = 0;
         m_rxd_axis_tkeep = 0;
         m_rxd_axis_tlast = 0;
         m_rxd_axis_tid = 0;
         s_rxd_axis_tready = 0;
      end
      else begin
         m_rxd_axis_tvalid = 0;
         m_rxd_axis_tdata = 0;
         m_rxd_axis_tkeep = 0;
         m_rxd_axis_tlast = 0;
         m_rxd_axis_tid = 0;
         s_rxd_axis_tready = 0;
         if(!rxs_tid_fifo_empty)begin
            m_rxd_axis_tvalid = s_rxd_axis_tvalid[m_rxs_axis_tid_dout];
            m_rxd_axis_tdata = s_rxd_axis_tdata[m_rxs_axis_tid_dout];
            m_rxd_axis_tkeep = s_rxd_axis_tkeep[m_rxs_axis_tid_dout];
            m_rxd_axis_tlast = s_rxd_axis_tlast[m_rxs_axis_tid_dout];
//            m_rxd_axis_tid = s_rxd_axis_tid[m_rxs_axis_tid_dout];
            s_rxd_axis_tready[m_rxs_axis_tid_dout] = m_rxd_axis_tready;
         end
      end
   end
   
   always @(*) begin
      if(!aresetn) begin
         m_rxs_axis_tid_fifo_rd = 0;
      end
      else begin 
         if(!rxs_tid_fifo_empty && m_rxd_axis_tlast && m_rxd_axis_tready)
            m_rxs_axis_tid_fifo_rd = 1;
         else m_rxs_axis_tid_fifo_rd = 0;
      end
   end

   assign s_rxd_axis_tvalid[0] = s_rxd0_axis_tvalid;
   assign s_rxd_axis_tdata[0] = s_rxd0_axis_tdata;
   assign s_rxd_axis_tkeep[0] = s_rxd0_axis_tkeep;
   assign s_rxd_axis_tlast[0] = s_rxd0_axis_tlast;
//   assign s_rxd_axis_tid[0] = s_rxd0_axis_tid;
   assign s_rxd0_axis_tready = s_rxd_axis_tready[0];
   
   assign s_rxd_axis_tvalid[1] = s_rxd1_axis_tvalid;
   assign s_rxd_axis_tdata[1] = s_rxd1_axis_tdata;
   assign s_rxd_axis_tkeep[1] = s_rxd1_axis_tkeep;
   assign s_rxd_axis_tlast[1] = s_rxd1_axis_tlast;
//   assign s_rxd_axis_tid[1] = s_rxd1_axis_tid;
   assign s_rxd1_axis_tready = s_rxd_axis_tready[1];
   
   assign s_rxd_axis_tvalid[2] = s_rxd2_axis_tvalid;
   assign s_rxd_axis_tdata[2] = s_rxd2_axis_tdata;
   assign s_rxd_axis_tkeep[2] = s_rxd2_axis_tkeep;
   assign s_rxd_axis_tlast[2] = s_rxd2_axis_tlast;
//   assign s_rxd_axis_tid[2] = s_rxd2_axis_tid;
   assign s_rxd2_axis_tready = s_rxd_axis_tready[2];
   
   assign s_rxd_axis_tvalid[3] = s_rxd3_axis_tvalid;
   assign s_rxd_axis_tdata[3] = s_rxd3_axis_tdata;
   assign s_rxd_axis_tkeep[3] = s_rxd3_axis_tkeep;
   assign s_rxd_axis_tlast[3] = s_rxd3_axis_tlast;
//   assign s_rxd_axis_tid[3] = s_rxd3_axis_tid;
   assign s_rxd3_axis_tready = s_rxd_axis_tready[3];



endmodule


  
  
