
module dma2eth_intercon
(
   input aclk,
   input aresetn,
   
   output m_txc0_axis_tvalid,
   output m_txc1_axis_tvalid,
   output m_txc2_axis_tvalid,
   output m_txc3_axis_tvalid,
   input m_txc0_axis_tready,
   input m_txc1_axis_tready,
   input m_txc2_axis_tready,
   input m_txc3_axis_tready,
   output [31 : 0] m_txc0_axis_tdata,
   output [31 : 0] m_txc1_axis_tdata,
   output [31 : 0] m_txc2_axis_tdata,
   output [31 : 0] m_txc3_axis_tdata,
   output [3 : 0] m_txc0_axis_tkeep,
   output [3 : 0] m_txc1_axis_tkeep,
   output [3 : 0] m_txc2_axis_tkeep,
   output [3 : 0] m_txc3_axis_tkeep,
   output m_txc0_axis_tlast,
   output m_txc1_axis_tlast,
   output m_txc2_axis_tlast,
   output m_txc3_axis_tlast,
/*   output [1 : 0] m_txc0_axis_tid,
   output [1 : 0] m_txc1_axis_tid,
   output [1 : 0] m_txc2_axis_tid,
   output [1 : 0] m_txc3_axis_tid,*/

   input s_txc_axis_tvalid,
   output reg s_txc_axis_tready,
   input [31 : 0] s_txc_axis_tdata,
   input [3 : 0] s_txc_axis_tkeep,
   input s_txc_axis_tlast,
//   input [1 : 0] s_txc_axis_tid,
   
   output m_txd0_axis_tvalid,
   output m_txd1_axis_tvalid,
   output m_txd2_axis_tvalid,
   output m_txd3_axis_tvalid,
   input m_txd0_axis_tready,
   input m_txd1_axis_tready,
   input m_txd2_axis_tready,
   input m_txd3_axis_tready,
   output [31 : 0] m_txd0_axis_tdata,
   output [31 : 0] m_txd1_axis_tdata,
   output [31 : 0] m_txd2_axis_tdata,
   output [31 : 0] m_txd3_axis_tdata,
   output [3 : 0] m_txd0_axis_tkeep,
   output [3 : 0] m_txd1_axis_tkeep,
   output [3 : 0] m_txd2_axis_tkeep,
   output [3 : 0] m_txd3_axis_tkeep,
   output m_txd0_axis_tlast,
   output m_txd1_axis_tlast,
   output m_txd2_axis_tlast,
   output m_txd3_axis_tlast,
/*   output [1 : 0] m_txd0_axis_tid,
   output [1 : 0] m_txd1_axis_tid,
   output [1 : 0] m_txd2_axis_tid,
   output [1 : 0] m_txd3_axis_tid,*/

   input s_txd_axis_tvalid,
   output reg s_txd_axis_tready,
   input [31 : 0] s_txd_axis_tdata,
   input [3 : 0] s_txd_axis_tkeep,
   input s_txd_axis_tlast
//   input [1 : 0] s_txd_axis_tid
   
);

   
   reg s_txc_axis_tready_nxt;
   reg [1:0] s_txc_axis_tid_r, s_txc_axis_tid_r_nxt;
   
   reg [7:0] txc_state, txc_state_nxt;
   localparam  TXC_IDLE = 1,
               TXC_APP0 = 2,
               TXC_APP_REST = 4;
   
   
   wire tid_fifo_full;
   wire tid_fifo_empty;
   wire [1:0] tid_fifo_dout;
   reg tid_fifo_rd;
   reg tid_fifo_wr;
   
   rxs_tid_fifo_8x16 txc_tid_fifo(
      .clk     (aclk),
      .rst     (!aresetn),
      .din     ({6'b0,s_txc_axis_tid_r_nxt}),
      .wr_en   (tid_fifo_wr & !tid_fifo_full),
      .rd_en   (tid_fifo_rd),
      .dout    (tid_fifo_dout),
      .full    (tid_fifo_full),
      .empty   (tid_fifo_empty)
   );

   //--------------------------------------
   //txc state machine :Extract tdest
   //--------------------------------------
   always @(*) begin
      if(!aresetn)begin
         s_txc_axis_tready_nxt = 0;
         
         txc_state_nxt = 0;
         s_txc_axis_tid_r_nxt = 0;
         tid_fifo_wr = 0;
      end
      else begin
         txc_state_nxt = txc_state;
         s_txc_axis_tid_r_nxt = s_txc_axis_tid_r;
         s_txc_axis_tready_nxt = s_txc_axis_tready;
         tid_fifo_wr = 0;
         
         case(txc_state)
            TXC_IDLE: begin 
               if(s_txc_axis_tvalid && s_txc_axis_tready) begin 
                  txc_state_nxt = TXC_APP0;
               end
            end
            TXC_APP0: begin
               if(s_txc_axis_tvalid && s_txc_axis_tready) begin
                  txc_state_nxt = TXC_APP_REST;
                  s_txc_axis_tid_r_nxt = s_txc_axis_tdata[31:16];
                  tid_fifo_wr = 1;
               end
            end
            TXC_APP_REST: begin
               if(s_txc_axis_tvalid && s_txc_axis_tlast && s_txc_axis_tready) begin 
                  txc_state_nxt = TXC_IDLE;
                  s_txc_axis_tready_nxt = !tid_fifo_full;
               end
            end
         endcase
      end
   end
   
   always @(posedge aclk)begin
      if(!aresetn)begin
         txc_state <= TXC_IDLE;
         s_txc_axis_tid_r <= 0;
         s_txc_axis_tready <= 1;
      end
      else begin
         txc_state <= txc_state_nxt;
         s_txc_axis_tid_r <= s_txc_axis_tid_r_nxt;
         s_txc_axis_tready <= s_txc_axis_tready_nxt;
      end
   end
   
   //--------------------------------------
   //txd state machine
   //--------------------------------------
   
   reg [3:0] m_txd_axis_tvalid;
   reg [31:0] m_txd_axis_tdata[3:0];
   reg [3:0] m_txd_axis_tkeep[3:0];
   reg [3:0] m_txd_axis_tlast;
   reg [1:0] m_txd_axis_tid[3:0];
   wire [3:0] m_txd_axis_tready;
   
   always @(*)begin
      if(!aresetn) begin
         m_txd_axis_tvalid[0] = 0;
         m_txd_axis_tvalid[1] = 0;
         m_txd_axis_tvalid[2] = 0;
         m_txd_axis_tvalid[3] = 0;
         
         m_txd_axis_tdata[0] = 0;
         m_txd_axis_tdata[1] = 0;
         m_txd_axis_tdata[2] = 0;
         m_txd_axis_tdata[3] = 0;
         
         m_txd_axis_tkeep[0] = 0;
         m_txd_axis_tkeep[1] = 0;
         m_txd_axis_tkeep[2] = 0;
         m_txd_axis_tkeep[3] = 0;
         
         m_txd_axis_tlast[0] = 0;
         m_txd_axis_tlast[1] = 0;
         m_txd_axis_tlast[2] = 0;
         m_txd_axis_tlast[3] = 0;
         
/*         m_txd_axis_tid[0] = 0;
         m_txd_axis_tid[1] = 0;
         m_txd_axis_tid[2] = 0;
         m_txd_axis_tid[3] = 0;*/
         
         s_txd_axis_tready = 0;

      end
      else begin
         m_txd_axis_tvalid[0] = 0;
         m_txd_axis_tvalid[1] = 0;
         m_txd_axis_tvalid[2] = 0;
         m_txd_axis_tvalid[3] = 0;
         
         m_txd_axis_tdata[0] = 0;
         m_txd_axis_tdata[1] = 0;
         m_txd_axis_tdata[2] = 0;
         m_txd_axis_tdata[3] = 0;
         
         m_txd_axis_tkeep[0] = 0;
         m_txd_axis_tkeep[1] = 0;
         m_txd_axis_tkeep[2] = 0;
         m_txd_axis_tkeep[3] = 0;
         
         m_txd_axis_tlast[0] = 0;
         m_txd_axis_tlast[1] = 0;
         m_txd_axis_tlast[2] = 0;
         m_txd_axis_tlast[3] = 0;
         
/*         m_txd_axis_tid[0] = 0;
         m_txd_axis_tid[1] = 0;
         m_txd_axis_tid[2] = 0;
         m_txd_axis_tid[3] = 0;*/
         
         s_txd_axis_tready = 0;
         
         if(!tid_fifo_empty)begin
            m_txd_axis_tvalid[tid_fifo_dout] = s_txd_axis_tvalid;
            m_txd_axis_tdata[tid_fifo_dout] = s_txd_axis_tdata;
            m_txd_axis_tkeep[tid_fifo_dout] = s_txd_axis_tkeep;
            m_txd_axis_tlast[tid_fifo_dout] = s_txd_axis_tlast;
//            m_txd_axis_tid[tid_fifo_dout] = s_txd_axis_tid;
            s_txd_axis_tready = m_txd_axis_tready[tid_fifo_dout];
         end
      end
   end
   always @(*) begin
      if(!aresetn) begin
         tid_fifo_rd = 0;
      end
      else begin 
         if(!tid_fifo_empty && s_txd_axis_tlast && s_txd_axis_tready)
            tid_fifo_rd = 1;
         else tid_fifo_rd = 0;
      end
   end
   
   assign m_txd0_axis_tvalid = m_txd_axis_tvalid[0];
   assign m_txd0_axis_tdata = m_txd_axis_tdata[0];
   assign m_txd0_axis_tkeep = m_txd_axis_tkeep[0];
   assign m_txd0_axis_tlast = m_txd_axis_tlast[0];
//   assign m_txd0_axis_tid = m_txd_axis_tid[0];
   assign m_txd_axis_tready[0] = m_txd0_axis_tready;
   
   assign m_txd1_axis_tvalid = m_txd_axis_tvalid[1];
   assign m_txd1_axis_tdata = m_txd_axis_tdata[1];
   assign m_txd1_axis_tkeep = m_txd_axis_tkeep[1];
   assign m_txd1_axis_tlast = m_txd_axis_tlast[1];
//   assign m_txd1_axis_tid = m_txd_axis_tid[1];
   assign m_txd_axis_tready[1] = m_txd1_axis_tready;
   
   assign m_txd2_axis_tvalid = m_txd_axis_tvalid[2];
   assign m_txd2_axis_tdata = m_txd_axis_tdata[2];
   assign m_txd2_axis_tkeep = m_txd_axis_tkeep[2];
   assign m_txd2_axis_tlast = m_txd_axis_tlast[2];
//   assign m_txd2_axis_tid = m_txd_axis_tid[2];
   assign m_txd_axis_tready[2] = m_txd2_axis_tready;
   
   assign m_txd3_axis_tvalid = m_txd_axis_tvalid[3];
   assign m_txd3_axis_tdata = m_txd_axis_tdata[3];
   assign m_txd3_axis_tkeep = m_txd_axis_tkeep[3];
   assign m_txd3_axis_tlast = m_txd_axis_tlast[3];
//   assign m_txd3_axis_tid = m_txd_axis_tid[3];
   assign m_txd_axis_tready[3] = m_txd3_axis_tready;

   //------------------------------------------
   //generate txc interface
   //------------------------------------------
   wire [3:0] m_txc_axis_tvalid;
   wire [31:0] m_txc_axis_tdata[3:0];
   wire [3:0] m_txc_axis_tkeep[3:0];
   wire [3:0] m_txc_axis_tlast;
   wire [1:0] m_txc_axis_tid[3:0];
   wire [3:0] m_txc_axis_tready;
   
   assign m_txc0_axis_tvalid = m_txc_axis_tvalid[0];
   assign m_txc0_axis_tdata = m_txc_axis_tdata[0];
   assign m_txc0_axis_tkeep = m_txc_axis_tkeep[0];
   assign m_txc0_axis_tlast = m_txc_axis_tlast[0];
   assign m_txc0_axis_tid = m_txc_axis_tid[0];
   assign m_txc_axis_tready[0] = m_txc0_axis_tready;
   
   assign m_txc1_axis_tvalid = m_txc_axis_tvalid[1];
   assign m_txc1_axis_tdata = m_txc_axis_tdata[1];
   assign m_txc1_axis_tkeep = m_txc_axis_tkeep[1];
   assign m_txc1_axis_tlast = m_txc_axis_tlast[1];
   assign m_txc1_axis_tid = m_txc_axis_tid[1];
   assign m_txc_axis_tready[1] = m_txc1_axis_tready;
   
   assign m_txc2_axis_tvalid = m_txc_axis_tvalid[2];
   assign m_txc2_axis_tdata = m_txc_axis_tdata[2];
   assign m_txc2_axis_tkeep = m_txc_axis_tkeep[2];
   assign m_txc2_axis_tlast = m_txc_axis_tlast[2];
   assign m_txc2_axis_tid = m_txc_axis_tid[2];
   assign m_txc_axis_tready[2] = m_txc2_axis_tready;
   
   assign m_txc3_axis_tvalid = m_txc_axis_tvalid[3];
   assign m_txc3_axis_tdata = m_txc_axis_tdata[3];
   assign m_txc3_axis_tkeep = m_txc_axis_tkeep[3];
   assign m_txc3_axis_tlast = m_txc_axis_tlast[3];
   assign m_txc3_axis_tid = m_txc_axis_tid[3];
   assign m_txc_axis_tready[3] = m_txc3_axis_tready;
   
   generate 
      genvar i;
      for(i=0; i<4; i=i+1)begin:m_txc_ifs
         dma_axis_control_if  
         #(
            .ENABLE_LEN    (0)
         )dma_axis_control_if(
            .m_axis_txd_tvalid            (m_txd_axis_tvalid[i]), 
            .m_axis_txd_tlast             (m_txd_axis_tlast[i]), 
            .m_axis_txd_tready            (m_txd_axis_tready[i]), 
            
            .m_axis_txc_aclk              (aclk), 
            .m_axis_txc_aresetn           (aresetn), 
            .m_axis_txc_tvalid            (m_txc_axis_tvalid[i]), 
            .m_axis_txc_tdata             (m_txc_axis_tdata[i]), 
            .m_axis_txc_tkeep             (m_txc_axis_tkeep[i]), 
            .m_axis_txc_tlast             (m_txc_axis_tlast[i]), 
            .m_axis_txc_tready            (m_txc_axis_tready[i])
         );
      end
   endgenerate

endmodule


  
  
