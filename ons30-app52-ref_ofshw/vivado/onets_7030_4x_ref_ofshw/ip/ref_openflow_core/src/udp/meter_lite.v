///////////////////////////////////////////////////////////////////////////////
// Module: meter_lite
// 
// Description: 
//
// 
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps


module meter_lite#(
   parameter DATA_WIDTH = 64,
   parameter CTRL_WIDTH=DATA_WIDTH/8,
   parameter UDP_REG_SRC_WIDTH = 2,
   parameter NUM_QUEUES = 4
)(
   input  [DATA_WIDTH-1:0]             in_data,
   input  [CTRL_WIDTH-1:0]             in_ctrl,
   input                               in_wr,
   output                              in_rdy,
   
   output [DATA_WIDTH-1:0]             out_data,
   output [CTRL_WIDTH-1:0]             out_ctrl,
   output                              out_wr,
   input                               out_rdy,
   
   // --- Register interface
   input                               reg_req_in,
   input                               reg_ack_in,
   input                               reg_rd_wr_L_in,
   input  [`UDP_REG_ADDR_WIDTH-1:0]    reg_addr_in,
   input  [`CPCI_NF2_DATA_WIDTH-1:0]   reg_data_in,
   input  [UDP_REG_SRC_WIDTH-1:0]      reg_src_in,

   output                              reg_req_out,
   output                              reg_ack_out,
   output                              reg_rd_wr_L_out,
   output  [`UDP_REG_ADDR_WIDTH-1:0]   reg_addr_out,
   output  [`CPCI_NF2_DATA_WIDTH-1:0]  reg_data_out,
   output  [UDP_REG_SRC_WIDTH-1:0]     reg_src_out,
   
   input                               clk,
   input                               reset
   
);

   wire [DATA_WIDTH-1:0]            rate_limiter_in_data [NUM_QUEUES - 1 : 0];
   wire [CTRL_WIDTH-1:0]            rate_limiter_in_ctrl [NUM_QUEUES - 1 : 0];
   wire [NUM_QUEUES - 1 : 0]        rate_limiter_in_wr;
   wire [NUM_QUEUES - 1 : 0]        rate_limiter_in_rdy;
   
   wire [DATA_WIDTH-1:0]            rate_limiter_out_data [NUM_QUEUES - 1 : 0];
   wire [CTRL_WIDTH-1:0]            rate_limiter_out_ctrl [NUM_QUEUES - 1 : 0];
   wire [NUM_QUEUES - 1 : 0]        rate_limiter_out_wr;
   wire [NUM_QUEUES - 1 : 0]        rate_limiter_out_rdy;
   
   wire                             rate_limiter_in_reg_req[NUM_QUEUES+1-1:0];
   wire                             rate_limiter_in_reg_ack[NUM_QUEUES+1-1:0];
   wire                             rate_limiter_in_reg_rd_wr_L[NUM_QUEUES+1-1:0];
   wire [`UDP_REG_ADDR_WIDTH-1:0]   rate_limiter_in_reg_addr[NUM_QUEUES+1-1:0];
   wire [`CPCI_NF2_DATA_WIDTH-1:0]  rate_limiter_in_reg_data[NUM_QUEUES+1-1:0];
   wire [UDP_REG_SRC_WIDTH-1:0]     rate_limiter_in_reg_src[NUM_QUEUES+1-1:0];
   
   assign rate_limiter_in_reg_req[0]      = reg_req_in;
   assign rate_limiter_in_reg_ack[0]      = reg_ack_in;
   assign rate_limiter_in_reg_rd_wr_L[0]  = reg_rd_wr_L_in;
   assign rate_limiter_in_reg_addr[0]     = reg_addr_in;
   assign rate_limiter_in_reg_data[0]     = reg_data_in;
   assign rate_limiter_in_reg_src[0]      = reg_src_in;
   
   assign reg_req_out      = rate_limiter_in_reg_req[NUM_QUEUES];
   assign reg_ack_out      = rate_limiter_in_reg_ack[NUM_QUEUES];
   assign reg_rd_wr_L_out  = rate_limiter_in_reg_rd_wr_L[NUM_QUEUES];
   assign reg_addr_out     = rate_limiter_in_reg_addr[NUM_QUEUES];
   assign reg_data_out     = rate_limiter_in_reg_data[NUM_QUEUES];
   assign reg_src_out      = rate_limiter_in_reg_src[NUM_QUEUES];
   
   queue_splitter #(
      .DATA_WIDTH(DATA_WIDTH),
      .CTRL_WIDTH(CTRL_WIDTH),
      .UDP_REG_SRC_WIDTH (UDP_REG_SRC_WIDTH),
      .NUM_QUEUES(NUM_QUEUES)
   ) queue_splitter (
      // --- Interface to the previous module
      .in_data                              (in_data),
      .in_ctrl                              (in_ctrl),
      .in_rdy                               (in_rdy),
      .in_wr                                (in_wr),
      
      .out_data_0                           (rate_limiter_in_data[0]),
      .out_ctrl_0                           (rate_limiter_in_ctrl[0]),
      .out_wr_0                             (rate_limiter_in_wr[0]),
      .out_rdy_0                            (rate_limiter_in_rdy[0]),

      .out_data_1                           (rate_limiter_in_data[1]),
      .out_ctrl_1                           (rate_limiter_in_ctrl[1]),
      .out_wr_1                             (rate_limiter_in_wr[1]),
      .out_rdy_1                            (rate_limiter_in_rdy[1]),

      .out_data_2                           (rate_limiter_in_data[2]),
      .out_ctrl_2                           (rate_limiter_in_ctrl[2]),
      .out_wr_2                             (rate_limiter_in_wr[2]),
      .out_rdy_2                            (rate_limiter_in_rdy[2]),

      .out_data_3                           (rate_limiter_in_data[3]),
      .out_ctrl_3                           (rate_limiter_in_ctrl[3]),
      .out_wr_3                             (rate_limiter_in_wr[3]),
      .out_rdy_3                            (rate_limiter_in_rdy[3]),
      
/*
      .out_data_4                           (rate_limiter_in_data[4]),
      .out_ctrl_4                           (rate_limiter_in_ctrl[4]),
      .out_wr_4                             (rate_limiter_in_wr[4]),
      .out_rdy_4                            (rate_limiter_in_rdy[4]),
 
      .out_data_5                           (rate_limiter_in_data[5]),
      .out_ctrl_5                           (rate_limiter_in_ctrl[5]),
      .out_wr_5                             (rate_limiter_in_wr[5]),
      .out_rdy_5                            (rate_limiter_in_rdy[5]),

      .out_data_6                           (rate_limiter_in_data[6]),
      .out_ctrl_6                           (rate_limiter_in_ctrl[6]),
      .out_wr_6                             (rate_limiter_in_wr[6]),
      .out_rdy_6                            (rate_limiter_in_rdy[6]),

      .out_data_7                           (rate_limiter_in_data[7]),
      .out_ctrl_7                           (rate_limiter_in_ctrl[7]),
      .out_wr_7                             (rate_limiter_in_wr[7]),
      .out_rdy_7                            (rate_limiter_in_rdy[7]),
 */
      // --- Misc
      .clk                                  (clk),
      .reset                                (reset)
   );
   
   generate
	   genvar i;
      for (i = 0; i < NUM_QUEUES; i = i + 1) begin : rate_limiter_modules
         rate_limiter #(
            .DATA_WIDTH                         (DATA_WIDTH),
            .UDP_REG_SRC_WIDTH                  (UDP_REG_SRC_WIDTH),
            .RATE_LIMIT_BLOCK_TAG               (`RATE_LIMIT_0_BLOCK_ADDR + i),
            .DEFAULT_TOKEN_INTERVAL             (1 + i)
         ) rate_limiter
           (
            .out_data                           (rate_limiter_out_data[i]),
            .out_ctrl                           (rate_limiter_out_ctrl[i]),
            .out_wr                             (rate_limiter_out_wr[i]),
            .out_rdy                            (rate_limiter_out_rdy[i]),

            .in_data                            (rate_limiter_in_data[i]),
            .in_ctrl                            (rate_limiter_in_ctrl[i]),
            .in_wr                              (rate_limiter_in_wr[i]),
            .in_rdy                             (rate_limiter_in_rdy[i]),

            // --- Register interface
            .reg_req_in                         (rate_limiter_in_reg_req[i]),
            .reg_ack_in                         (rate_limiter_in_reg_ack[i]),
            .reg_rd_wr_L_in                     (rate_limiter_in_reg_rd_wr_L[i]),
            .reg_addr_in                        (rate_limiter_in_reg_addr[i]),
            .reg_data_in                        (rate_limiter_in_reg_data[i]),
            .reg_src_in                         (rate_limiter_in_reg_src[i]),

            .reg_req_out                        (rate_limiter_in_reg_req[i+1]),
            .reg_ack_out                        (rate_limiter_in_reg_ack[i+1]),
            .reg_rd_wr_L_out                    (rate_limiter_in_reg_rd_wr_L[i+1]),
            .reg_addr_out                       (rate_limiter_in_reg_addr[i+1]),
            .reg_data_out                       (rate_limiter_in_reg_data[i+1]),
            .reg_src_out                        (rate_limiter_in_reg_src[i+1]),

            // --- Misc
            .clk                                (clk),
            .reset                              (reset)
         );
      end
   endgenerate
   
   queue_aggr #(
      .DATA_WIDTH(DATA_WIDTH),
      .CTRL_WIDTH(CTRL_WIDTH)
   ) queue_aggr (
      .out_data             (out_data),
      .out_ctrl             (out_ctrl),
      .out_wr               (out_wr),
      .out_rdy              (out_rdy),

      // --- Interface to the input queues
      .in_data_0            (rate_limiter_out_data[0]),
      .in_ctrl_0            (rate_limiter_out_ctrl[0]),
      .in_wr_0              (rate_limiter_out_wr[0]),
      .in_rdy_0             (rate_limiter_out_rdy[0]),

      .in_data_1            (rate_limiter_out_data[1]),
      .in_ctrl_1            (rate_limiter_out_ctrl[1]),
      .in_wr_1              (rate_limiter_out_wr[1]),
      .in_rdy_1             (rate_limiter_out_rdy[1]),

      .in_data_2            (rate_limiter_out_data[2]),
      .in_ctrl_2            (rate_limiter_out_ctrl[2]),
      .in_wr_2              (rate_limiter_out_wr[2]),
      .in_rdy_2             (rate_limiter_out_rdy[2]),

      .in_data_3            (rate_limiter_out_data[3]),
      .in_ctrl_3            (rate_limiter_out_ctrl[3]),
      .in_wr_3              (rate_limiter_out_wr[3]),
      .in_rdy_3             (rate_limiter_out_rdy[3]),
/* 
      .in_data_4            (in_data_4),
      .in_ctrl_4            (in_ctrl_4),
      .in_wr_4              (in_wr_4),
      .in_rdy_4             (in_rdy_4),

      .in_data_5            (in_data_5),
      .in_ctrl_5            (in_ctrl_5),
      .in_wr_5              (in_wr_5),
      .in_rdy_5             (in_rdy_5),

      .in_data_6            (in_data_6),
      .in_ctrl_6            (in_ctrl_6),
      .in_wr_6              (in_wr_6),
      .in_rdy_6             (in_rdy_6),

      .in_data_7            (in_data_7),
      .in_ctrl_7            (in_ctrl_7),
      .in_wr_7              (in_wr_7),
      .in_rdy_7             (in_rdy_7),
 */
      // --- Misc
      .reset                (reset),
      .clk                  (clk)
   );
   

endmodule // meter_lite
