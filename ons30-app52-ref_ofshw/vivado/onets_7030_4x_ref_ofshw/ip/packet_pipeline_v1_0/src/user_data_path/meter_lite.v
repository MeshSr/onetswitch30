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
   parameter UDP_REG_SRC_WIDTH = 2
   
)(
   input  [DATA_WIDTH-1:0]             in_data,
   input  [CTRL_WIDTH-1:0]             in_ctrl,
   input                               in_wr,
   output                              in_rdy,
   
   output [DATA_WIDTH-1:0]             out_data,
   output [CTRL_WIDTH-1:0]             out_ctrl,
   output                              out_wr,
   input                               out_rdy,
   
   input   [31:0] data_meter_i,
   input   [31:0] addr_meter_i,
   input          req_meter_i,
   input          rw_meter_i,
   output         ack_meter_o,
   output  [31:0] data_meter_o,
   
   input                               clk,
   input                               reset
   
);
   localparam NUM_QUEUES = 4;
   wire [DATA_WIDTH-1:0]            rate_limiter_in_data [NUM_QUEUES - 1 : 0];
   wire [CTRL_WIDTH-1:0]            rate_limiter_in_ctrl [NUM_QUEUES - 1 : 0];
   wire [NUM_QUEUES - 1 : 0]        rate_limiter_in_wr;
   wire [NUM_QUEUES - 1 : 0]        rate_limiter_in_rdy;
   
   wire [DATA_WIDTH-1:0]            rate_limiter_pass_data;
   wire [CTRL_WIDTH-1:0]            rate_limiter_pass_ctrl;
   wire                             rate_limiter_pass_wr;
   wire                             rate_limiter_pass_rdy;
   
   wire [DATA_WIDTH-1:0]            rate_limiter_out_data [NUM_QUEUES - 1 : 0];
   wire [CTRL_WIDTH-1:0]            rate_limiter_out_ctrl [NUM_QUEUES - 1 : 0];
   wire [NUM_QUEUES - 1 : 0]        rate_limiter_out_wr;
   wire [NUM_QUEUES - 1 : 0]        rate_limiter_out_rdy;
   
   wire [19:0]                  token_interval   ;
   wire [7:0]                   token_increment  ;
   wire [NUM_QUEUES-1:0]                    token_interval_vld;
   wire [NUM_QUEUES-1:0]                    token_increment_vld;
   
   wire [31:0]                      pass_pkt_counter_0   ;
   wire [31:0]                      pass_pkt_counter_1   ;
   wire [31:0]                      pass_pkt_counter_2   ;
   wire [31:0]                      pass_pkt_counter_3   ;
   wire [31:0]                      pass_pkt_counter_4   ;

   wire [31:0]                      pass_byte_counter_0  ;
   wire [31:0]                      pass_byte_counter_1  ;
   wire [31:0]                      pass_byte_counter_2  ;
   wire [31:0]                      pass_byte_counter_3  ;
   wire [31:0]                      pass_byte_counter_4  ;

   wire [31:0]                      drop_pkt_counter_0   ;
   wire [31:0]                      drop_pkt_counter_1   ;
   wire [31:0]                      drop_pkt_counter_2   ;
   wire [31:0]                      drop_pkt_counter_3   ;
   wire [31:0]                      drop_pkt_counter_4   ;

   wire [31:0]                      drop_byte_counter_0  ;
   wire [31:0]                      drop_byte_counter_1  ;
   wire [31:0]                      drop_byte_counter_2  ;
   wire [31:0]                      drop_byte_counter_3  ;
   wire [31:0]                      drop_byte_counter_4  ;
   
   queue_splitter #(
      .DATA_WIDTH(DATA_WIDTH),
      .CTRL_WIDTH(CTRL_WIDTH),
      .UDP_REG_SRC_WIDTH (UDP_REG_SRC_WIDTH),
      .NUM_QUEUES(NUM_QUEUES+1)
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
      
      .out_data_4                           (rate_limiter_pass_data),
      .out_ctrl_4                           (rate_limiter_pass_ctrl),
      .out_wr_4                             (rate_limiter_pass_wr),
      .out_rdy_4                            (rate_limiter_pass_rdy),
      
      // --- Misc
      .clk                                  (clk),
      .reset                                (reset),
      
      .pass_pkt_counter_0  (pass_pkt_counter_0 ),
      .pass_pkt_counter_1  (pass_pkt_counter_1 ),
      .pass_pkt_counter_2  (pass_pkt_counter_2 ),
      .pass_pkt_counter_3  (pass_pkt_counter_3 ),
      .pass_pkt_counter_4  (pass_pkt_counter_4 ),
         
      .pass_byte_counter_0 (pass_byte_counter_0),
      .pass_byte_counter_1 (pass_byte_counter_1),
      .pass_byte_counter_2 (pass_byte_counter_2),
      .pass_byte_counter_3 (pass_byte_counter_3),
      .pass_byte_counter_4 (pass_byte_counter_4),
              
      .drop_pkt_counter_0  (drop_pkt_counter_0 ),
      .drop_pkt_counter_1  (drop_pkt_counter_1 ),
      .drop_pkt_counter_2  (drop_pkt_counter_2 ),
      .drop_pkt_counter_3  (drop_pkt_counter_3 ),
      .drop_pkt_counter_4  (drop_pkt_counter_4 ),
           
      .drop_byte_counter_0 (drop_byte_counter_0),
      .drop_byte_counter_1 (drop_byte_counter_1),
      .drop_byte_counter_2 (drop_byte_counter_2),
      .drop_byte_counter_3 (drop_byte_counter_3),
      .drop_byte_counter_4 (drop_byte_counter_4)
      
   );

   generate
	   genvar i;
      for (i = 0; i < NUM_QUEUES; i = i + 1) begin : rate_limiter_modules
         rate_limiter #(
            .DATA_WIDTH                         (DATA_WIDTH),
            .UDP_REG_SRC_WIDTH                  (UDP_REG_SRC_WIDTH),
            .RATE_LIMIT_BLOCK_TAG               ( i),
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
            
            .token_interval_vld                   (token_interval_vld[i]),
            .token_increment_vld                  (token_increment_vld[i]),
            .token_interval_reg                     (token_interval   ),
            .token_increment_reg                    (token_increment  ),

            
            
            // --- Misc
            .clk                                (clk),
            .reset                              (reset)
         );
      end
   endgenerate
  

  rate_limiter_regs
     #(
      .NUM_QUEUES(NUM_QUEUES)
     )
    rate_limiter_regs
   (
      .data_meter_i    (data_meter_i) ,
      .addr_meter_i    (addr_meter_i) ,
      .req_meter_i     (req_meter_i ) ,
      .rw_meter_i      (rw_meter_i  ) ,
      .ack_meter_o     (ack_meter_o ) ,
      .data_meter_o    (data_meter_o) , 

      // Outputs
      .token_interval                   (token_interval),
      .token_increment                  (token_increment),
      .token_interval_vld                   (token_interval_vld),
      .token_increment_vld                  (token_increment_vld),
      //.include_overhead                 (include_overhead),

      // Inputs
      .clk                              (clk),
      .reset                            (reset),
      
      .pass_pkt_counter_0  (pass_pkt_counter_0 ),
      .pass_pkt_counter_1  (pass_pkt_counter_1 ),
      .pass_pkt_counter_2  (pass_pkt_counter_2 ),
      .pass_pkt_counter_3  (pass_pkt_counter_3 ),
      .pass_pkt_counter_4  (pass_pkt_counter_4 ),
         
      .pass_byte_counter_0 (pass_byte_counter_0),
      .pass_byte_counter_1 (pass_byte_counter_1),
      .pass_byte_counter_2 (pass_byte_counter_2),
      .pass_byte_counter_3 (pass_byte_counter_3),
      .pass_byte_counter_4 (pass_byte_counter_4),
              
      .drop_pkt_counter_0  (drop_pkt_counter_0 ),
      .drop_pkt_counter_1  (drop_pkt_counter_1 ),
      .drop_pkt_counter_2  (drop_pkt_counter_2 ),
      .drop_pkt_counter_3  (drop_pkt_counter_3 ),
      .drop_pkt_counter_4  (drop_pkt_counter_4 ),
           
      .drop_byte_counter_0 (drop_byte_counter_0),
      .drop_byte_counter_1 (drop_byte_counter_1),
      .drop_byte_counter_2 (drop_byte_counter_2),
      .drop_byte_counter_3 (drop_byte_counter_3),
      .drop_byte_counter_4 (drop_byte_counter_4)
   );
    
               
   queue_aggr #(
      .NUM_QUEUES(NUM_QUEUES+1),
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
 
      .in_data_4            (rate_limiter_pass_data),
      .in_ctrl_4            (rate_limiter_pass_ctrl),
      .in_wr_4              (rate_limiter_pass_wr),  
      .in_rdy_4             (rate_limiter_pass_rdy), 
/*
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
