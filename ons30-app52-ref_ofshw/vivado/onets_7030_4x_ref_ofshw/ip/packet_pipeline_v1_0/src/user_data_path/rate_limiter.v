///////////////////////////////////////////////////////////////////////////////
// vim:set shiftwidth=3 softtabstop=3 expandtab:
// $Id: rate_limiter.v 5803 2009-08-04 21:23:10Z g9coving $
//
// Module: rate_limiter.v
// Project: rate_limiter
// Description: Limits the rate at which packets pass through
//
// Modified to allow more fine-grained control. Uses a token-bucket flow
// control mechanism to allow very fine-grained control.
//
// Note: Disabling the rate limiter will clear any pending delay
//
///////////////////////////////////////////////////////////////////////////////

module rate_limiter
  #(
      parameter DATA_WIDTH = 64,
      parameter CTRL_WIDTH = DATA_WIDTH/8,
      parameter UDP_REG_SRC_WIDTH = 2,
      //parameter IOQ_STAGE_NUM = `IO_QUEUE_STAGE_NUM,
      parameter PKT_LEN_WIDTH = 11,
      parameter RATE_LIMIT_BLOCK_TAG = `RATE_LIMIT_0_BLOCK_ADDR,
      parameter DEFAULT_TOKEN_INTERVAL = 2
   )

   (output  [DATA_WIDTH-1:0]           out_data,
    output  [CTRL_WIDTH-1:0]           out_ctrl,
    output reg                         out_wr,
    input                              out_rdy,

    input  [DATA_WIDTH-1:0]            in_data,
    input  [CTRL_WIDTH-1:0]            in_ctrl,
    input                              in_wr,
    output                             in_rdy,
    

    input                                token_interval_vld,
    input                                token_increment_vld,
    input [19:0]                         token_interval_reg,
    input [7:0]                          token_increment_reg,
    // --- Misc
    input                              clk,
    input                              reset

    );


   //----------------------- wires/regs---------------------------------
   reg                                enable_rate_limit;
   reg [19:0]                         token_interval;
   reg [7:0]                          token_increment;
   
   reg [19:0]                          token_interval_d1;


   wire                                out_eop;

   reg [10:0]                          tokens;
   reg [10:0]                          new_pkt_len;
   reg [10:0]                          new_pkt_len_next;
   reg [10:0]                          pkt_len;
   reg [10:0]                          pkt_len_next;
   wire [10:0]                         extra_bytes;

   reg [20:0]                          counter;

   reg                                 seen_len;
   reg                                 seen_len_next;

   reg                                 reset_bucket;

   reg                                 in_fifo_rd_en;
   reg                                 data_good;
   reg                                 out_wr_next;

   reg [1:0]                           state, state_next;

   wire [CTRL_WIDTH-1:0]               limiter_out_ctrl;
   wire [DATA_WIDTH-1:0]               limiter_out_data;
   wire [CTRL_WIDTH-1:0]               in_fifo_out_ctrl;
   wire [DATA_WIDTH-1:0]               in_fifo_out_data;
   wire                                limiter_in_rdy;
   
   reg                                limit_fifo_wr;
   reg                                limit_fifo_rd;
   
   wire                                 in_fifo_nearly_full;
   assign in_rdy=!in_fifo_nearly_full;
   assign out_data=limiter_out_data;
   assign out_ctrl=limiter_out_ctrl;
   reg  rate_good;

   //------------------------ Modules ----------------------------------
    always@(posedge clk)
    if(reset)
         token_interval <= 1;
    else if(token_interval_vld)
         token_interval       <= token_interval_reg   ;
    
    always@(posedge clk)
    if(reset)
      token_increment<=0;
    else  if(token_increment_vld)    
             token_increment      <= token_increment_reg;     

       
   small_fifo #(.WIDTH(CTRL_WIDTH+DATA_WIDTH), .MAX_DEPTH_BITS(3), .PROG_FULL_THRESHOLD(6))
      input_fifo
        (.din           ({in_ctrl, in_data}),  // Data in
         .wr_en         (in_wr),             // Write enable
         .rd_en         (in_fifo_rd_en),    // Read the next word
         .dout          ({in_fifo_out_ctrl, in_fifo_out_data}),
         .full          (),
         .prog_full     (in_fifo_nearly_full),
         .nearly_full   (),
         .empty         (in_fifo_empty),
         .reset         (reset),
         .clk           (clk)
         );
         
    small_fifo #(.WIDTH(CTRL_WIDTH+DATA_WIDTH), .MAX_DEPTH_BITS(3), .PROG_FULL_THRESHOLD(6))
    limit_fifo
      (.din           ({in_fifo_out_ctrl, in_fifo_out_data}),  // Data in
       .wr_en         (limit_fifo_wr),             // Write enable
       .rd_en         (limit_fifo_rd),    // Read the next word
       .dout          ({limiter_out_ctrl, limiter_out_data}),
       .full          (),
       .prog_full     (limit_fifo_nearly_full),
       .nearly_full   (),
       .empty         (limit_fifo_empty),
       .reset         (reset),
       .clk           (clk)
       );

    localparam IDLE=0;
    localparam RATE=1;
    localparam LUT_READ=2;
    localparam READ_HEAD=3;
    localparam WRITE_HEAD=4;
    localparam READ_DATA_HEAD=5;
    localparam READ_DATA=6;
    localparam WAIT_EOP=7;
    localparam EOP=8;
    reg [3:0]cur_st,nxt_st;
    
    always@(posedge clk)
        if(reset)   cur_st<=0;
        else        cur_st<=nxt_st;
   

    
    always@(*)
        begin
            nxt_st=0;
            case(cur_st)
                IDLE:
                    if(!in_fifo_empty) nxt_st=READ_HEAD;
                    else nxt_st=IDLE;
                //LUT_READ:nxt_st=READ_HEAD;
                READ_HEAD:
                    if(in_fifo_out_ctrl==`IO_QUEUE_STAGE_NUM)                    nxt_st=RATE;
                    else nxt_st=READ_HEAD;
                RATE:
                    if(rate_good)   nxt_st=READ_DATA_HEAD;
                    else            nxt_st=RATE;  
                READ_DATA_HEAD:
                  if(limiter_out_ctrl==`IO_QUEUE_STAGE_NUM) nxt_st=READ_DATA;
                  else nxt_st=READ_DATA_HEAD;
                READ_DATA:
                    if(limiter_out_ctrl==0) nxt_st=WAIT_EOP;
                    else nxt_st=READ_DATA;
                WAIT_EOP:
                    if(limiter_out_ctrl!=0) nxt_st=EOP;
                    else nxt_st=WAIT_EOP;
                EOP:nxt_st=IDLE;
                default:nxt_st=IDLE;
            endcase
        end    
    
    always@(posedge clk)
        if(reset)   pkt_len<=0;
	        else if(cur_st==READ_HEAD && in_fifo_out_ctrl==`IO_QUEUE_STAGE_NUM) pkt_len<=in_fifo_out_data[15:0];
                   
    always@(*)
        if(reset) in_fifo_rd_en=0;
        else if(   cur_st==READ_HEAD | cur_st==READ_DATA_HEAD | cur_st==READ_DATA) in_fifo_rd_en=1;  
        else if(cur_st==WAIT_EOP && in_fifo_out_ctrl!=0)    in_fifo_rd_en=0;
        else if(cur_st==WAIT_EOP) in_fifo_rd_en=1;
        else in_fifo_rd_en=0;
    
    always@(posedge clk)
      limit_fifo_wr<=in_fifo_rd_en;
    


   
    always@(posedge clk)
        if(reset) token_interval_d1<=0;
        else token_interval_d1<=token_interval;
   
    always@(*)
        if(token_interval_d1!=token_interval)   reset_bucket=1;
        else if(cur_st==RATE && rate_good)   reset_bucket=1;
        else reset_bucket=0;

    always@(*)
        if(tokens > pkt_len) rate_good=1;
        else rate_good=0;
   
   always@(*)
      if(cur_st==WAIT_EOP && limiter_out_ctrl!=0) limit_fifo_rd=0;
      else if(cur_st==READ_DATA_HEAD | cur_st==READ_DATA | cur_st==WAIT_EOP) limit_fifo_rd=1;
      else limit_fifo_rd=0;
        
   always@(posedge clk)
   if(reset)
      out_wr<=0;
   else 
      out_wr<=limit_fifo_rd;
        
   always @(posedge clk) begin
      if (reset || reset_bucket) begin
        tokens <= 'h0;
        counter <= 'h0;
      end
      else begin
         if (counter >= (token_interval - 'h1)) begin
            tokens <= tokens + token_increment;
            counter <= 'h0;
         end
         else begin
            counter <= counter + 'h1;
         end
      end
   end

endmodule // rate_limiter
