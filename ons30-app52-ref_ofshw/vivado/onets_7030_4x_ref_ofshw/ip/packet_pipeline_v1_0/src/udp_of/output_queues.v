///////////////////////////////////////////////////////////////////////////////
// vim:set shiftwidth=3 softtabstop=3 expandtab:
// $Id: output_queues.v 5240 2009-03-14 01:50:42Z grg $
//
// Module: output_queues.v
// Project: NF2.1
// Description: stores incoming packets into the SRAM and implements a round
// robin arbiter to service the output queues
//
///////////////////////////////////////////////////////////////////////////////
//modified at 2014-09-11    output_fifo din     input_fifo_ctrl_out_d1 -> input_fifo_ctrl_out
  module output_queues
    #(parameter DATA_WIDTH = 64,
      parameter CTRL_WIDTH=DATA_WIDTH/8,
      parameter UDP_REG_SRC_WIDTH = 2,
      parameter OP_LUT_STAGE_NUM = 4,
      parameter NUM_OUTPUT_QUEUES = 8)

   (// --- data path interface
    output     [DATA_WIDTH-1:0]        out_data_0,
    output     [CTRL_WIDTH-1:0]        out_ctrl_0,
    input                              out_rdy_0,
    output reg                         out_wr_0,

    output     [DATA_WIDTH-1:0]        out_data_1,
    output     [CTRL_WIDTH-1:0]        out_ctrl_1,
    input                              out_rdy_1,
    output reg                         out_wr_1,

    output     [DATA_WIDTH-1:0]        out_data_2,
    output     [CTRL_WIDTH-1:0]        out_ctrl_2,
    input                              out_rdy_2,
    output reg                         out_wr_2,

    output     [DATA_WIDTH-1:0]        out_data_3,
    output     [CTRL_WIDTH-1:0]        out_ctrl_3,
    input                              out_rdy_3,
    output reg                         out_wr_3,

    output     [DATA_WIDTH-1:0]        out_data_4,
    output     [CTRL_WIDTH-1:0]        out_ctrl_4,
    input                              out_rdy_4,
    output reg                         out_wr_4,

    output  [DATA_WIDTH-1:0]           out_data_5,
    output  [CTRL_WIDTH-1:0]           out_ctrl_5,
    output reg                         out_wr_5,
    input                              out_rdy_5,

    output  [DATA_WIDTH-1:0]           out_data_6,
    output  [CTRL_WIDTH-1:0]           out_ctrl_6,
    output reg                         out_wr_6,
    input                              out_rdy_6,

    output  [DATA_WIDTH-1:0]           out_data_7,
    output  [CTRL_WIDTH-1:0]           out_ctrl_7,
    output reg                         out_wr_7,
    input                              out_rdy_7,

    // --- Interface to the previous module
    input  [DATA_WIDTH-1:0]            in_data,
    input  [CTRL_WIDTH-1:0]            in_ctrl,
    output                             in_rdy,
    input                              in_wr,

    // --- Register interface
    input                              reg_req_in,
    input                              reg_ack_in,
    input                              reg_rd_wr_L_in,
    input  [`UDP_REG_ADDR_WIDTH-1:0]   reg_addr_in,
    input  [`CPCI_NF2_DATA_WIDTH-1:0]  reg_data_in,
    input  [UDP_REG_SRC_WIDTH-1:0]     reg_src_in,

    output reg                            reg_req_out,
    output reg                            reg_ack_out,
    output reg                            reg_rd_wr_L_out,
    output reg [`UDP_REG_ADDR_WIDTH-1:0]  reg_addr_out,
    output reg [`CPCI_NF2_DATA_WIDTH-1:0] reg_data_out,
    output reg [UDP_REG_SRC_WIDTH-1:0]    reg_src_out,

    // --- Misc
    input                              clk,
    input                              reset);

   function integer log2;
      input integer number;
      begin
         log2=0;
         while(2**log2<number) begin
            log2=log2+1;
         end
      end
   endfunction // log2

   //------------- Internal Parameters ---------------
   parameter NUM_OQ_WIDTH       = log2(NUM_OUTPUT_QUEUES);
   parameter PKT_LEN_WIDTH      = 11;
   parameter PKT_WORDS_WIDTH    = PKT_LEN_WIDTH-log2(CTRL_WIDTH);
   parameter MAX_PKT            = 2048;   // allow for 2K bytes
   parameter PKT_BYTE_CNT_WIDTH = log2(MAX_PKT);
   parameter PKT_WORD_CNT_WIDTH = log2(MAX_PKT/CTRL_WIDTH);

   //--------------- Regs/Wires ----------------------


   wire                       input_fifo_rd_en;
   wire                       input_fifo_empty;
   wire [DATA_WIDTH-1:0]      input_fifo_data_out;
   wire [CTRL_WIDTH-1:0]      input_fifo_ctrl_out;
   reg [DATA_WIDTH-1:0]       input_fifo_data_out_d1;
   reg [CTRL_WIDTH-1:0]       input_fifo_ctrl_out_d1;
   reg [DATA_WIDTH-1:0]       input_fifo_data_out_d2;
   reg [CTRL_WIDTH-1:0]       input_fifo_ctrl_out_d2;
   wire                       input_fifo_nearly_full;
   wire [DATA_WIDTH+CTRL_WIDTH-1:0] output_fifo_dout[0:NUM_OUTPUT_QUEUES-1];
   reg                        input_fifo_out_vld;
   
   reg [NUM_OUTPUT_QUEUES-1:0]  output_fifo_wr_en;
   wire [NUM_OUTPUT_QUEUES-1:0] output_fifo_rd_en;
   wire [NUM_OUTPUT_QUEUES-1:0] output_fifo_empty;
   wire [NUM_OUTPUT_QUEUES-1:0] output_fifo_nearly_full;
   //---------------- Modules ------------------------

   
   data_fifo input_fifo
        (.din({in_ctrl, in_data}),  // Data in
         .wr_en         (in_wr),             // Write enable
         .rd_en         (input_fifo_rd_en),    // Read the next word
         .dout({input_fifo_ctrl_out, input_fifo_data_out}),
         .full          (),
         .prog_full     (),
         .nearly_full   (input_fifo_nearly_full),
         .empty         (input_fifo_empty),
         .reset         (reset),
         .clk           (clk)
         );
   generate genvar i;
   if(DATA_WIDTH==64) begin: output_fifo64
      for(i=0; i<NUM_OUTPUT_QUEUES; i=i+1) begin: output_fifos
         data_fifo  output_fifo
         (  .din ({input_fifo_ctrl_out_d1, input_fifo_data_out_d1}),  // Data in
            .wr_en         (output_fifo_wr_en[i]),             // Write enable
            .rd_en         (output_fifo_rd_en[i]),    // Read the next word
            .dout          (output_fifo_dout[i]),
            .full          (),
            .prog_full     (),
            .nearly_full   (output_fifo_nearly_full[i]),
            .empty         (output_fifo_empty[i]),
            .reset         (reset),
            .clk           (clk)
         );
      end // block: output_fifos
   end // block: output_fifo64
   endgenerate




   //------------------ Logic ------------------------
   
   assign in_rdy = !input_fifo_nearly_full;
   assign input_fifo_rd_en = !input_fifo_empty;
   
   assign output_fifo_rd_en[0] = !output_fifo_empty[0] && out_rdy_0;
   assign output_fifo_rd_en[1] = !output_fifo_empty[1] && out_rdy_1;
   assign output_fifo_rd_en[2] = !output_fifo_empty[2] && out_rdy_2;
   assign output_fifo_rd_en[3] = !output_fifo_empty[3] && out_rdy_3;
   assign output_fifo_rd_en[4] = !output_fifo_empty[4] && out_rdy_4;
   assign output_fifo_rd_en[5] = !output_fifo_empty[5] && out_rdy_5;
   assign output_fifo_rd_en[6] = !output_fifo_empty[6] && out_rdy_6;
   assign output_fifo_rd_en[7] = !output_fifo_empty[7] && out_rdy_7;
   
   assign {out_ctrl_0,out_data_0} = output_fifo_dout[0];
   assign {out_ctrl_1,out_data_1} = output_fifo_dout[1];
   assign {out_ctrl_2,out_data_2} = output_fifo_dout[2];
   assign {out_ctrl_3,out_data_3} = output_fifo_dout[3];
   assign {out_ctrl_4,out_data_4} = output_fifo_dout[4];
   assign {out_ctrl_5,out_data_5} = output_fifo_dout[5];
   assign {out_ctrl_6,out_data_6} = output_fifo_dout[6];
   assign {out_ctrl_7,out_data_7} = output_fifo_dout[7];

   
   always @(posedge clk) begin
      if(reset) begin
         out_wr_0 <= 0;
         out_wr_1 <= 0;
         out_wr_2 <= 0;
         out_wr_3 <= 0;
         out_wr_4 <= 0;
         out_wr_5 <= 0;
         out_wr_6 <= 0;
         out_wr_7 <= 0;
      end
      else begin
         out_wr_0 <= output_fifo_rd_en[0];
         out_wr_1 <= output_fifo_rd_en[1];
         out_wr_2 <= output_fifo_rd_en[2];
         out_wr_3 <= output_fifo_rd_en[3];
         out_wr_4 <= output_fifo_rd_en[4];
         out_wr_5 <= output_fifo_rd_en[5];
         out_wr_6 <= output_fifo_rd_en[6];
         out_wr_7 <= output_fifo_rd_en[7];
      end
   end // always @ (posedge clk)
   
/*   reg output_state;
   always @(posedge clk)begin
      if(reset) begin 
         input_fifo_out_vld <= 0;
         output_fifo_wr_en <= 0;
         input_fifo_data_out_d <= 64'b0;
         input_fifo_ctrl_out_d <= 8'b0;
         output_state <= 0;
      end
      else begin
         //stage 1
         input_fifo_data_out_d <= input_fifo_data_out;
         input_fifo_ctrl_out_d <= input_fifo_ctrl_out;

         input_fifo_out_vld <= input_fifo_rd_en;
         //stage 2
         case(output_state)
         0: begin
            if(input_fifo_out_vld && input_fifo_ctrl_out==`IO_QUEUE_STAGE_NUM)
               output_fifo_wr_en <= input_fifo_data_out[`IOQ_DST_PORT_POS + NUM_OUTPUT_QUEUES - 1:`IOQ_DST_PORT_POS];
            else if(input_fifo_out_vld && (input_fifo_ctrl_out !=0)) output_state <= 1;
         end
         1: begin
            output_fifo_wr_en <= 0;
            output_state <= 0;
         end 
         endcase         
      end
   end*/
    always@(posedge clk or negedge reset)
        if(reset)    input_fifo_out_vld <= 0;
        else        input_fifo_out_vld <= input_fifo_rd_en;
   
    always@(posedge clk or negedge reset)
        if(reset)
            begin
                input_fifo_data_out_d1 <= 0;
                input_fifo_ctrl_out_d1 <= 0;  
            end
        else
            begin
                input_fifo_data_out_d1 <= input_fifo_data_out;
                input_fifo_ctrl_out_d1 <= input_fifo_ctrl_out;
            end
            
     always@(posedge clk or negedge reset)
         if(reset)
             begin
                 input_fifo_data_out_d2 <= 0;
                 input_fifo_ctrl_out_d2 <= 0;  
             end
         else
             begin
                 input_fifo_data_out_d2 <= input_fifo_data_out_d1;
                 input_fifo_ctrl_out_d2 <= input_fifo_ctrl_out_d1;
             end
                                
   localparam IDLE=0;
   localparam WRITE=1;
   localparam DONE=2;
   
   
    reg [2:0]cur_st,nxt_st;
    always@(posedge clk or negedge reset)
        if(reset)
            cur_st<=0;
        else
            cur_st<=nxt_st;
    
    always@(*)
        begin
            nxt_st=0;
            case(cur_st)
                IDLE:
                    if(input_fifo_out_vld && input_fifo_ctrl_out==`IO_QUEUE_STAGE_NUM)
                            nxt_st=WRITE;
                    else
                        nxt_st=IDLE;
                WRITE:
                    if(input_fifo_out_vld && (input_fifo_ctrl_out !=0)) nxt_st <= DONE;
                    else  nxt_st=WRITE;
                DONE:
                        nxt_st=IDLE;
                default:
                    nxt_st=IDLE;
            endcase    
        end
   
    always@(posedge clk or negedge reset)
        if(reset)
            output_fifo_wr_en<=0;
        else if(cur_st==IDLE && input_fifo_out_vld && input_fifo_ctrl_out==`IO_QUEUE_STAGE_NUM)   
            output_fifo_wr_en <= input_fifo_data_out[`IOQ_DST_PORT_POS + NUM_OUTPUT_QUEUES - 1:`IOQ_DST_PORT_POS] & (~output_fifo_nearly_full);
        else if(cur_st==DONE)
            output_fifo_wr_en <=0;
        
   /* registers unused */
   always @(posedge clk) begin
      reg_req_out        <= reg_req_in;
      reg_ack_out        <= reg_ack_in;
      reg_rd_wr_L_out    <= reg_rd_wr_L_in;
      reg_addr_out       <= reg_addr_in;
      reg_data_out       <= reg_data_in;
      reg_src_out        <= reg_src_in;
   end
endmodule // output_queues




