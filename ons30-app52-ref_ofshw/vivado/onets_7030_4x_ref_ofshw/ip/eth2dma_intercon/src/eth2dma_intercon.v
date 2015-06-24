
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

   output reg m_rxs_axis_tvalid,
   input m_rxs_axis_tready,
   output reg [31 : 0] m_rxs_axis_tdata,
   output reg [3 : 0] m_rxs_axis_tkeep,
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
   output m_rxd_axis_tlast,
   output reg [1 : 0] m_rxd_axis_tid
   
);
   wire [3:0]   s_rxs_axis_tvalid;
   reg [3:0]   s_rxs_axis_tready;
   wire [31:0]  s_rxs_axis_tdata[3:0];
   wire [3:0]   s_rxs_axis_tkeep[3:0];
   wire [3:0]   s_rxs_axis_tlast;
   
   wire [3:0]   s_rxd_axis_tvalid;
   reg [3:0]   s_rxd_axis_tready;
   wire [31:0]  s_rxd_axis_tdata[3:0];
   wire [3:0]   s_rxd_axis_tkeep[3:0];
   wire [3:0]   s_rxd_axis_tlast;
   
   assign s_rxs_axis_tvalid[0]=s_rxs0_axis_tvalid;
   assign s_rxs_axis_tvalid[1]=s_rxs1_axis_tvalid;
   assign s_rxs_axis_tvalid[2]=s_rxs2_axis_tvalid;
   assign s_rxs_axis_tvalid[3]=s_rxs3_axis_tvalid;
   
   assign s_rxs0_axis_tready=s_rxs_axis_tready[0];
   assign s_rxs1_axis_tready=s_rxs_axis_tready[1];
   assign s_rxs2_axis_tready=s_rxs_axis_tready[2];
   assign s_rxs3_axis_tready=s_rxs_axis_tready[3];
   
   assign s_rxs_axis_tdata[0]=s_rxs0_axis_tdata;
   assign s_rxs_axis_tdata[1]=s_rxs1_axis_tdata;
   assign s_rxs_axis_tdata[2]=s_rxs2_axis_tdata;
   assign s_rxs_axis_tdata[3]=s_rxs3_axis_tdata;
   
   assign s_rxs_axis_tlast[0]=s_rxs0_axis_tlast;
   assign s_rxs_axis_tlast[1]=s_rxs1_axis_tlast;
   assign s_rxs_axis_tlast[2]=s_rxs2_axis_tlast;
   assign s_rxs_axis_tlast[3]=s_rxs3_axis_tlast;   
   
   assign s_rxs_axis_tkeep[0]=s_rxs0_axis_tkeep;
   assign s_rxs_axis_tkeep[1]=s_rxs1_axis_tkeep;
   assign s_rxs_axis_tkeep[2]=s_rxs2_axis_tkeep;
   assign s_rxs_axis_tkeep[3]=s_rxs3_axis_tkeep;  
   
   
      
   
   assign s_rxd_axis_tvalid[0]=s_rxd0_axis_tvalid;
   assign s_rxd_axis_tvalid[1]=s_rxd1_axis_tvalid;
   assign s_rxd_axis_tvalid[2]=s_rxd2_axis_tvalid;
   assign s_rxd_axis_tvalid[3]=s_rxd3_axis_tvalid;
   
   assign s_rxd0_axis_tready=s_rxd_axis_tready[0];
   assign s_rxd1_axis_tready=s_rxd_axis_tready[1];
   assign s_rxd2_axis_tready=s_rxd_axis_tready[2];
   assign s_rxd3_axis_tready=s_rxd_axis_tready[3];
   
   assign s_rxd_axis_tdata[0]=s_rxd0_axis_tdata;
   assign s_rxd_axis_tdata[1]=s_rxd1_axis_tdata;
   assign s_rxd_axis_tdata[2]=s_rxd2_axis_tdata;
   assign s_rxd_axis_tdata[3]=s_rxd3_axis_tdata;
   
   assign s_rxd_axis_tlast[0]=s_rxd0_axis_tlast;
   assign s_rxd_axis_tlast[1]=s_rxd1_axis_tlast;
   assign s_rxd_axis_tlast[2]=s_rxd2_axis_tlast;
   assign s_rxd_axis_tlast[3]=s_rxd3_axis_tlast;   
   
   assign s_rxd_axis_tkeep[0]=s_rxd0_axis_tkeep;
   assign s_rxd_axis_tkeep[1]=s_rxd1_axis_tkeep;
   assign s_rxd_axis_tkeep[2]=s_rxd2_axis_tkeep;
   assign s_rxd_axis_tkeep[3]=s_rxd3_axis_tkeep;     
   
 
   
   localparam  //IDLE=0,
               WAIT_FOR_RXS=0,
               WAIT_FOR_RXS_1=1,
               WAIT_FOR_RXS_2=2,
               WAIT_FOR_RXS_EOP=3,
               WAIT_FOR_RXD=4,
               WAIT_FOR_RXD_EOP=5,
               ADD_QUEUE=6;
   
   reg [3:0]cur_st,nxt_st;
   reg [1:0]cur_queue;
   
   always@(posedge aclk)
      if(~aresetn)
         cur_st<=0;
      else cur_st<=nxt_st;
      
   always@(*)
   begin
      nxt_st=cur_st;
      case(cur_st)
         /*IDLE:
            nxt_st=WAIT_FOR_RXS;*/
         WAIT_FOR_RXS:
            if(s_rxs_axis_tvalid[cur_queue]) nxt_st=WAIT_FOR_RXS_1;
            else nxt_st=ADD_QUEUE;
         WAIT_FOR_RXS_1:if(s_rxs_axis_tvalid[cur_queue]) nxt_st=WAIT_FOR_RXS_2;
         WAIT_FOR_RXS_2:if(s_rxs_axis_tvalid[cur_queue]) nxt_st=WAIT_FOR_RXS_EOP;
         WAIT_FOR_RXS_EOP:
            if(s_rxs_axis_tlast[cur_queue]) nxt_st=WAIT_FOR_RXD;
         WAIT_FOR_RXD:
            if(s_rxd_axis_tvalid[cur_queue]) nxt_st=WAIT_FOR_RXD_EOP;
         WAIT_FOR_RXD_EOP:
            if(s_rxd_axis_tlast[cur_queue]) nxt_st=ADD_QUEUE;
         ADD_QUEUE:
            nxt_st=WAIT_FOR_RXS;
         default:nxt_st=WAIT_FOR_RXS;
      endcase
   end

   always@(posedge aclk)
      if(~aresetn)
         cur_queue<=0;
      else if(cur_st==ADD_QUEUE)
      begin
         if(cur_queue==3)
            cur_queue<=0;
         else cur_queue<=cur_queue+1;
      end
   
   always@(*)
   begin
      s_rxs_axis_tready=0;
      if(cur_st==WAIT_FOR_RXS_EOP | cur_st==WAIT_FOR_RXS_1 | cur_st==WAIT_FOR_RXS_2)
         s_rxs_axis_tready[cur_queue]=m_rxs_axis_tready;
   end
   
   always@(*)
   begin
      m_rxs_axis_tvalid=0;
      if(cur_st==WAIT_FOR_RXS_EOP | cur_st==WAIT_FOR_RXS_1 | cur_st==WAIT_FOR_RXS_2)
         m_rxs_axis_tvalid=s_rxs_axis_tvalid[cur_queue];
   end
   
   always@(*)
   begin
      m_rxs_axis_tdata=0;
      if(cur_st==WAIT_FOR_RXS_EOP | cur_st==WAIT_FOR_RXS_1)
         m_rxs_axis_tdata=s_rxs_axis_tdata[cur_queue];
      else if(cur_st==WAIT_FOR_RXS_2)
      begin
         m_rxs_axis_tdata[15:0]=s_rxs_axis_tdata[cur_queue][15:0];
         m_rxs_axis_tdata[31:16]={14'h0,cur_queue};
      end
   end
   
   always@(*)
   begin
      m_rxs_axis_tkeep=0;
      if(cur_st==WAIT_FOR_RXS_EOP | cur_st==WAIT_FOR_RXS_1 | cur_st==WAIT_FOR_RXS_2)
         m_rxs_axis_tkeep=s_rxd_axis_tkeep[cur_queue];
   end
   
   
   assign m_rxs_axis_tlast=s_rxs_axis_tlast[cur_queue];
   
   always@(*)
   begin
      s_rxd_axis_tready=0;
      if(cur_st==WAIT_FOR_RXD_EOP)
         s_rxd_axis_tready[cur_queue]=m_rxd_axis_tready;
   end
   
   always@(*)
   begin
      m_rxd_axis_tvalid=0;
      if(cur_st==WAIT_FOR_RXD_EOP)
         m_rxd_axis_tvalid=s_rxd_axis_tvalid[cur_queue];
   end
   
   always@(*)
   begin
      m_rxd_axis_tkeep=0;
      if(cur_st==WAIT_FOR_RXD_EOP)
         m_rxd_axis_tkeep=s_rxd_axis_tkeep[cur_queue];
   end
   
   always@(*)
   begin
      m_rxd_axis_tdata=0;
      if(cur_st==WAIT_FOR_RXD_EOP) m_rxd_axis_tdata=s_rxd_axis_tdata[cur_queue];
   end
   
  assign m_rxd_axis_tlast=s_rxd_axis_tlast[cur_queue];   
      

endmodule


  
  
