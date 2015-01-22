module axi_to_reg_bus
(
   
   input             reset, 
   input             clk,  //register bus clk
   input             s_axi_aclk, //axi interface clk
   input             s_axi_aresetn,
   //------------------------------//
   //AXI-lite Slave interface
   //------------------------------//
   // Write address channel
   input [31:0]      s_axi_awaddr,
   input [2:0]	      s_axi_awprot,
   input             s_axi_awvalid,
   output            s_axi_awready,

   // Write Data Channel
   input [31:0]      s_axi_wdata, 
   input [3:0]       s_axi_wstrb,
   input             s_axi_wvalid,
   output            s_axi_wready,


   // Write Response Channel
   output [1:0]      s_axi_bresp,
   output            s_axi_bvalid,
   input             s_axi_bready,

   // Read Address channel
   input [31:0]      s_axi_araddr,
   input [2:0]       s_axi_arprot,
   input             s_axi_arvalid,
   output            s_axi_arready,

   // Read Data Channel
   output [31:0]     s_axi_rdata,
   output [1:0]      s_axi_rresp,
   output            s_axi_rvalid,
   input             s_axi_rready, 
   
   //------------------------------//
   //Register bus
   //------------------------------//
   output reg        reg_req,
   output reg        reg_rd_wr_L,
   output reg [31:0] reg_addr,
   output reg [31:0] reg_wr_data,
   
   input             reg_ack,
   input [31:0]      reg_rd_data
   
);


   //------------------------------//
   //AXI-lite Slave interface
   //------------------------------//
   // Write address channel
   wire [31:0]       awaddr;
   wire [2:0]	      awprot;
   wire              awvalid;
   reg               awready;

   // Write Data Channel
   wire [31:0]       wdata;
   wire [3:0]        wstrb;
   wire              wvalid;
   reg               wready;


   // Write Response Channel
   reg [1:0]         bresp;
   reg               bvalid;
   wire              bready;

   // Read Address channel
   wire [31:0]       araddr;
   wire [2:0]        arprot;
   wire              arvalid;
   reg               arready;

   // Read Data Channel
   reg [31:0]        rdata;
   reg [1:0]         rresp;
   reg               rvalid;
   wire              rready;
   
	reg_access_fifo reg_access_fifo (
		.m_aclk           (clk), 
		.s_aclk           (s_axi_aclk), 
		.s_aresetn        (s_axi_aresetn), 
      
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
      
		.m_axi_awaddr     (awaddr), 
		.m_axi_awprot     (awprot), 
		.m_axi_awvalid    (awvalid), 
		.m_axi_awready    (awready), 
      
		.m_axi_wdata      (wdata), 
		.m_axi_wstrb      (wstrb), 
		.m_axi_wvalid     (wvalid), 
		.m_axi_wready     (wready), 
      
		.m_axi_bresp      (bresp), 
		.m_axi_bvalid     (bvalid), 
		.m_axi_bready     (bready), 

		.m_axi_araddr     (araddr), 
		.m_axi_arprot     (arprot), 
		.m_axi_arvalid    (arvalid), 
		.m_axi_arready    (arready), 
      
		.m_axi_rdata      (rdata), 
		.m_axi_rresp      (rresp), 
		.m_axi_rvalid     (rvalid), 
		.m_axi_rready     (rready)
	);
   
   
   reg         reg_req_i;
   reg         reg_rd_wr_L_i;
   reg [31:0]  reg_addr_i;
   reg [3:0]   state;
   localparam AXI_IDLE	= 4'h0;
   localparam AXI_WD   	= 4'h1;
   localparam AXI_B    	= 4'h2;
   localparam AXI_B_RET = 4'h3;
   localparam AXI_RD   	= 4'h4;
   localparam AXI_RD_RET = 4'h5;
   
   always @(posedge clk)begin
      if (reset) begin
         awready <= 1'b0;
         wready  <= 1'b0;
         bvalid	<= 1'b0;
         bresp	<= 2'b00;
         arready <= 1'b0;
         rvalid	<= 1'b0;
         rresp	<= 2'b00;
         rdata	<= 32'h0;
         
         reg_req <= 1'b0;
         reg_rd_wr_L <= 1'b1;
         reg_addr <= 32'b0;
         reg_wr_data <= 32'b0;
         
         reg_req_i <= 1'b0;
         reg_rd_wr_L_i <= 1'b1;
         reg_addr_i <= 32'b0;
         
         state <= AXI_IDLE;
      end
      else begin
         
         case (state) 
            AXI_IDLE : begin
               awready <= 1'b1;
               arready <= 1'b1;
               if (awvalid) begin
                  awready <= 1'b0;
                  
                  reg_req_i <= 1'b1;
                  reg_rd_wr_L_i <= 1'b0;
                  reg_addr_i <= awaddr;
                  
                  state <= AXI_WD;
                  wready <= 1'b1;
               end
               else if (arvalid) begin
                  arready <= 1'b0;
                  
                  reg_req <= 1'b1;
                  reg_rd_wr_L <= 1'b1;
                  reg_addr <= araddr;
                  
                  state <= AXI_RD;
               end
            end
            AXI_WD : begin
               if (wvalid) begin
                  reg_req <= reg_req_i;
                  reg_rd_wr_L <= reg_rd_wr_L_i;
                  reg_addr <= reg_addr_i;
                  reg_wr_data <= wdata;
                  
                  reg_req_i <= 1'b0;
                  
                  wready <= 1'b0;
                  
                  state <= AXI_B;
               end
             end
            AXI_B : begin
               if(reg_ack) begin
                  reg_req <= 1'b0; //disable after ack is valid.
                  
                  bvalid <= 1'b1;
                  state <=AXI_B_RET;
               end
            end
            AXI_B_RET:begin
               if(bready) begin
                  bvalid <= 1'b0;
                  
                  state <= AXI_IDLE;
                  awready <= 1'b1;
                  arready <= 1'b1;
               end
             end
            AXI_RD : begin 
               if(reg_ack) begin 
                  reg_req <= 1'b0; //disable after ack is valid.
                  
                  rvalid  <= 1'b1;
                  rdata <= reg_rd_data;
                  state <= AXI_RD_RET;
               end
            end
            AXI_RD_RET:begin
               if(rready) begin
                  rvalid  <= 1'b0;
                  rdata <= 32'h0;
                  
                  state <= AXI_IDLE;
                  awready <= 1'b1;
                  arready <= 1'b1;               
               end
            end
         endcase
      end
   end
endmodule
