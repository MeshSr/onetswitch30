///////////////////////////////////////////////////////////////////////////////
// Module: queue_splitter.v
// Description: dispatch incoming packets to different packet queues.
//
///////////////////////////////////////////////////////////////////////////////

module queue_splitter #(
   parameter DATA_WIDTH = 64,
   parameter CTRL_WIDTH=DATA_WIDTH/8,
   parameter UDP_REG_SRC_WIDTH = 2,
   parameter NUM_QUEUES = 4,
   parameter MAX_NUM_QUEUES = 8
)(// --- data path interface
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

    /*output  [DATA_WIDTH-1:0]           out_data_5,
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
    input                              out_rdy_7,*/

    // --- Interface to the previous module
    input  [DATA_WIDTH-1:0]            in_data,
    input  [CTRL_WIDTH-1:0]            in_ctrl,
    output                             in_rdy,
    input                              in_wr,

    // --- Misc
    input                              clk,
    input                              reset,
          
    output reg[31:0]                      pass_pkt_counter_0,
    output reg[31:0]                      pass_pkt_counter_1,
    output reg[31:0]                      pass_pkt_counter_2,
    output reg[31:0]                      pass_pkt_counter_3,
    output reg[31:0]                      pass_pkt_counter_4,
    
    output reg[31:0]                      pass_byte_counter_0,
    output reg[31:0]                      pass_byte_counter_1,
    output reg[31:0]                      pass_byte_counter_2,
    output reg[31:0]                      pass_byte_counter_3,
    output reg[31:0]                      pass_byte_counter_4,
    
    output reg[31:0]                      drop_pkt_counter_0,
    output reg[31:0]                      drop_pkt_counter_1,
    output reg[31:0]                      drop_pkt_counter_2,
    output reg[31:0]                      drop_pkt_counter_3,
    output reg[31:0]                      drop_pkt_counter_4,
    
    output reg[31:0]                      drop_byte_counter_0,
    output reg[31:0]                      drop_byte_counter_1,
    output reg[31:0]                      drop_byte_counter_2,
    output reg[31:0]                      drop_byte_counter_3,
    output reg[31:0]                      drop_byte_counter_4
    
    );


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
   localparam NUM_OQ_WIDTH       = log2(NUM_QUEUES);
   localparam PKT_LEN_WIDTH      = 11;
   localparam PKT_WORDS_WIDTH    = PKT_LEN_WIDTH-log2(CTRL_WIDTH);
   localparam MAX_PKT            = 2048;   // allow for 2K bytes
   localparam PKT_BYTE_CNT_WIDTH = log2(MAX_PKT);
   localparam PKT_WORD_CNT_WIDTH = log2(MAX_PKT/CTRL_WIDTH);

   //--------------- Regs/Wires ----------------------


   wire                       input_fifo_rd_en;
   wire                       input_fifo_empty;
   wire [DATA_WIDTH-1:0]      input_fifo_data_out;
   wire [CTRL_WIDTH-1:0]      input_fifo_ctrl_out;
   reg [DATA_WIDTH-1:0]       input_fifo_data_out_d;
   reg [CTRL_WIDTH-1:0]       input_fifo_ctrl_out_d;
   wire                       input_fifo_nearly_full;
   wire [DATA_WIDTH+CTRL_WIDTH-1:0] output_fifo_dout[NUM_QUEUES-1 : 0];
   reg                        input_fifo_out_vld;
   
   reg [NUM_QUEUES-1:0]  output_fifo_wr_en;
   wire [NUM_QUEUES-1:0] output_fifo_rd_en;
   wire [NUM_QUEUES-1:0] output_fifo_empty;
   wire [NUM_QUEUES-1:0] output_fifo_almost_full;
   
   reg [NUM_QUEUES-1:0] output_fifo_wr_en_calc;
   reg [NUM_QUEUES-1:0] output_fifo_wr_en_reg;
   //---------------- Modules ------------------------

  
   generate genvar i;
      for(i=0; i<NUM_QUEUES; i=i+1) begin: output_fifos
         data_fifo output_fifo
         (  .din ({input_fifo_ctrl_out, input_fifo_data_out}),  // Data in
            .wr_en         (output_fifo_wr_en[i]),             // Write enable
            .rd_en         (output_fifo_rd_en[i]),    // Read the next word
            .dout          (output_fifo_dout[i]),
            .data_count    (),
            .nearly_full   (),
            .full          (),
            .prog_full     (output_fifo_almost_full[i]),
            .empty         (output_fifo_empty[i]),
            .reset         (reset),
            .clk           (clk)
         );
      end // block: output_fifos
   endgenerate




   //------------------ Logic ------------------------
   
   assign in_rdy = !input_fifo_nearly_full;
   assign input_fifo_rd_en = !input_fifo_empty;
   
   assign output_fifo_rd_en[0] = !output_fifo_empty[0] && out_rdy_0;
   assign output_fifo_rd_en[1] = !output_fifo_empty[1] && out_rdy_1;
   assign output_fifo_rd_en[2] = !output_fifo_empty[2] && out_rdy_2;
   assign output_fifo_rd_en[3] = !output_fifo_empty[3] && out_rdy_3;
   assign output_fifo_rd_en[4] = !output_fifo_empty[4] && out_rdy_4;
   /*assign output_fifo_rd_en[5] = !output_fifo_empty[5] && out_rdy_5;
   assign output_fifo_rd_en[6] = !output_fifo_empty[6] && out_rdy_6;
   assign output_fifo_rd_en[7] = !output_fifo_empty[7] && out_rdy_7;*/
   
   assign {out_ctrl_0,out_data_0} = output_fifo_dout[0];
   assign {out_ctrl_1,out_data_1} = output_fifo_dout[1];
   assign {out_ctrl_2,out_data_2} = output_fifo_dout[2];
   assign {out_ctrl_3,out_data_3} = output_fifo_dout[3];
   assign {out_ctrl_4,out_data_4} = output_fifo_dout[4];
   /*assign {out_ctrl_5,out_data_5} = output_fifo_dout[5];
   assign {out_ctrl_6,out_data_6} = output_fifo_dout[6];
   assign {out_ctrl_7,out_data_7} = output_fifo_dout[7];*/
   
   always @(posedge clk) begin
      if(reset) begin
         out_wr_0 <= 0;
         out_wr_1 <= 0;
         out_wr_2 <= 0;
         out_wr_3 <= 0;
         out_wr_4 <= 0;
         /*out_wr_5 <= 0;
         out_wr_6 <= 0;
         out_wr_7 <= 0;*/
      end
      else begin
         out_wr_0 <= output_fifo_rd_en[0];
         out_wr_1 <= output_fifo_rd_en[1];
         out_wr_2 <= output_fifo_rd_en[2];
         out_wr_3 <= output_fifo_rd_en[3];
         out_wr_4 <= output_fifo_rd_en[4];
         /*out_wr_5 <= output_fifo_rd_en[5];
         out_wr_6 <= output_fifo_rd_en[6];
         out_wr_7 <= output_fifo_rd_en[7];*/
      end
   end // always @ (posedge clk)

    reg  [7:0]in_rd_queue;
    reg in_rd;
    reg [7:0] in_fifo_wr;
    reg [7:0]in_fifo_wr_d1;
    reg [4:0]wr_good;

   always@(posedge clk)
   if(reset)
      in_fifo_wr_d1<=0;
   else in_fifo_wr_d1<=in_fifo_wr;
   
   small_fifo #(.WIDTH(DATA_WIDTH+CTRL_WIDTH),.MAX_DEPTH_BITS(3))
   input_fifo
       (    .din           ({in_ctrl, in_data}),  // Data in
            .wr_en         (in_wr),             // Write enable
            .rd_en         (in_rd),    // Read the next word
            .dout          ({input_fifo_ctrl_out, input_fifo_data_out}),
            .full          (),
            .prog_full     (),
            .nearly_full   (input_fifo_nearly_full),
            .empty         (input_fifo_empty),
            .reset         (reset),
            .clk           (clk)
            );

   localparam READ_HDR=0;
   localparam READY_TO_WRITE=1;
   localparam WAIT_DATA=2;
   localparam WAIT_EOP=3; 
   localparam EOP=4;
   reg [3:0]cur_st,nxt_st;
   always@(posedge clk)
       if(reset) cur_st<=0;
       else cur_st<=nxt_st;
       
   always@(*)
       begin
           nxt_st=0;
           case(cur_st)
               READ_HDR:
                   if(in_wr && (in_ctrl==`IO_QUEUE_STAGE_NUM | in_ctrl==`VLAN_CTRL_WORD)) nxt_st=READY_TO_WRITE;
                   else nxt_st=READ_HDR;
               READY_TO_WRITE:nxt_st=WAIT_DATA;
               WAIT_DATA:
                   if(in_wr && in_ctrl==0) nxt_st=WAIT_EOP;
                   else nxt_st=WAIT_DATA;
               WAIT_EOP:
                   if(in_wr && in_ctrl!=0) nxt_st=EOP;
                   else nxt_st=WAIT_EOP;
               EOP:nxt_st=READ_HDR;                 
               default:nxt_st=READ_HDR;
           endcase
       end
       
   always@(posedge clk)
       if(reset)
           in_fifo_wr<=0;
       else if(in_wr && in_ctrl==`IO_QUEUE_STAGE_NUM)
            begin
                if(in_data[`IOQ_METER_ID_POS + 8 - 1:`IOQ_METER_ID_POS]==0)
                    in_fifo_wr<=5'b10000;
                else if(in_data[`IOQ_METER_ID_POS + 8 - 1:`IOQ_METER_ID_POS]>=5'b10000)
                    in_fifo_wr<=5'b10000;
                else
                    in_fifo_wr<=in_data[`IOQ_METER_ID_POS + 8 - 1:`IOQ_METER_ID_POS];
            end
       else if(cur_st==EOP)
           in_fifo_wr<=0;

   always@(posedge clk)
       if(reset)   in_rd<=0;
       else        in_rd<=in_wr;
   
   
       reg [3:0]splitter_cur_st,splitter_nxt_st;
       localparam SPLITTER_IDLE=0;
       localparam SPLITTER_WAIT_QOS=1;
       localparam SPLITTER_READ=2;
       localparam SPLITTER_WRITE=3;
       localparam SPLITTER_NO_WRITE=4;
       localparam SPLITTER_WAIT_EOP=5;
       localparam SPLITTER_WAIT_NO_WRITE_EOP=6;
       localparam SPLITTER_EOP=7;
       
       always@(posedge clk or negedge reset)
           if(reset)  splitter_cur_st<=0;
           else       splitter_cur_st<=splitter_nxt_st;
           
       always@(*)
           begin
               splitter_nxt_st=0;
               case(splitter_cur_st)
                   SPLITTER_IDLE:
                       if(in_rd && |(in_fifo_wr & (~output_fifo_almost_full[4:0]))) splitter_nxt_st=SPLITTER_WRITE;
                       else if(in_rd) splitter_nxt_st=SPLITTER_NO_WRITE;
                   SPLITTER_WRITE:
                       if(input_fifo_ctrl_out==0) splitter_nxt_st=SPLITTER_WAIT_EOP;
                       else splitter_nxt_st=SPLITTER_WRITE;
                   SPLITTER_NO_WRITE:
                       if(input_fifo_ctrl_out==0) splitter_nxt_st=SPLITTER_WAIT_NO_WRITE_EOP;
                       else splitter_nxt_st=SPLITTER_NO_WRITE;
                   SPLITTER_WAIT_NO_WRITE_EOP:
                       if(input_fifo_ctrl_out!=0) splitter_nxt_st=SPLITTER_EOP;
                       else splitter_nxt_st=SPLITTER_WAIT_NO_WRITE_EOP;
                   SPLITTER_WAIT_EOP:
                       if(input_fifo_ctrl_out!=0) splitter_nxt_st=SPLITTER_EOP;
                       else splitter_nxt_st=SPLITTER_WAIT_EOP;
                   SPLITTER_EOP:splitter_nxt_st=SPLITTER_IDLE;
                   default:splitter_nxt_st=SPLITTER_IDLE;
               endcase
           end

   
   always@(*)
       if(reset)   output_fifo_wr_en=0;
       else if(splitter_cur_st==SPLITTER_WRITE | splitter_cur_st==SPLITTER_WAIT_EOP)output_fifo_wr_en= in_fifo_wr_d1;
       else output_fifo_wr_en=0;

`ifdef ONETS45
begin
   always@(posedge clk)
      if(reset)
      begin
         pass_pkt_counter_0<=0;
         pass_pkt_counter_1<=0;
         pass_pkt_counter_2<=0;
         pass_pkt_counter_3<=0;
         pass_pkt_counter_4<=0;
      end
      else if(splitter_cur_st==SPLITTER_IDLE && in_rd && |(in_fifo_wr & (~output_fifo_almost_full[4:0])))
      case(in_fifo_wr)
      1: pass_pkt_counter_0<=pass_pkt_counter_0+1;
      2: pass_pkt_counter_1<=pass_pkt_counter_1+1;
      4: pass_pkt_counter_2<=pass_pkt_counter_2+1;
      8: pass_pkt_counter_3<=pass_pkt_counter_3+1;
      16:pass_pkt_counter_4<=pass_pkt_counter_4+1;
      endcase
      
   always@(posedge clk)
      if(reset)
      begin
         drop_pkt_counter_0<=0;
         drop_pkt_counter_1<=0;
         drop_pkt_counter_2<=0;
         drop_pkt_counter_3<=0;
         drop_pkt_counter_4<=0;
      end
      else if(splitter_cur_st==SPLITTER_IDLE && in_rd && (!(|(in_fifo_wr & (~output_fifo_almost_full[4:0])))))
      case(in_fifo_wr)
      1: drop_pkt_counter_0<=drop_pkt_counter_0+1;
      2: drop_pkt_counter_1<=drop_pkt_counter_1+1;
      4: drop_pkt_counter_2<=drop_pkt_counter_2+1;
      8: drop_pkt_counter_3<=drop_pkt_counter_3+1;
      16:drop_pkt_counter_4<=drop_pkt_counter_4+1;
      endcase 
      
   always@(posedge clk)
      if(reset)
      begin
         pass_byte_counter_0<=0;
         pass_byte_counter_1<=0;
         pass_byte_counter_2<=0;
         pass_byte_counter_3<=0;
         pass_byte_counter_4<=0;
      end
      else if(splitter_cur_st==SPLITTER_WAIT_EOP | (splitter_cur_st==SPLITTER_WRITE && input_fifo_ctrl_out==0))
      case(in_fifo_wr)
      1: pass_byte_counter_0<=pass_byte_counter_0+1;
      2: pass_byte_counter_1<=pass_byte_counter_1+1;
      4: pass_byte_counter_2<=pass_byte_counter_2+1;
      8: pass_byte_counter_3<=pass_byte_counter_3+1;
      16:pass_byte_counter_4<=pass_byte_counter_4+1;
      endcase     
      
      always@(posedge clk)
         if(reset)
         begin
            drop_byte_counter_0<=0;
            drop_byte_counter_1<=0;
            drop_byte_counter_2<=0;
            drop_byte_counter_3<=0;
            drop_byte_counter_4<=0;
         end
         else if(splitter_cur_st==SPLITTER_WAIT_NO_WRITE_EOP | (splitter_cur_st==SPLITTER_NO_WRITE && input_fifo_ctrl_out==0))
         case(in_fifo_wr)
         1: drop_byte_counter_0<=drop_byte_counter_0+1;
         2: drop_byte_counter_1<=drop_byte_counter_1+1;
         4: drop_byte_counter_2<=drop_byte_counter_2+1;
         8: drop_byte_counter_3<=drop_byte_counter_3+1;
         16:drop_byte_counter_4<=drop_byte_counter_4+1;
         endcase   
end   
`elsif ONETS30
begin
   always@(posedge clk)
      if(reset)
      begin
         pass_pkt_counter_0<=0;
         pass_pkt_counter_1<=0;
         pass_pkt_counter_2<=0;
         pass_pkt_counter_3<=0;
         pass_pkt_counter_4<=0;
      end
      else if(splitter_cur_st==SPLITTER_IDLE && in_rd && |(in_fifo_wr & (~output_fifo_almost_full[4:0])))
      case(in_fifo_wr)
      1: pass_pkt_counter_0<=pass_pkt_counter_0+1;
      2: pass_pkt_counter_1<=pass_pkt_counter_1+1;
      4: pass_pkt_counter_2<=pass_pkt_counter_2+1;
      8: pass_pkt_counter_3<=pass_pkt_counter_3+1;
      16:pass_pkt_counter_4<=pass_pkt_counter_4+1;
      endcase
      
   always@(posedge clk)
      if(reset)
      begin
         drop_pkt_counter_0<=0;
         drop_pkt_counter_1<=0;
         drop_pkt_counter_2<=0;
         drop_pkt_counter_3<=0;
         drop_pkt_counter_4<=0;
      end
      else if(splitter_cur_st==SPLITTER_IDLE && in_rd && (!(|(in_fifo_wr & (~output_fifo_almost_full[4:0])))))
      case(in_fifo_wr)
      1: drop_pkt_counter_0<=drop_pkt_counter_0+1;
      2: drop_pkt_counter_1<=drop_pkt_counter_1+1;
      4: drop_pkt_counter_2<=drop_pkt_counter_2+1;
      8: drop_pkt_counter_3<=drop_pkt_counter_3+1;
      16:drop_pkt_counter_4<=drop_pkt_counter_4+1;
      endcase 
      
   always@(posedge clk)
      if(reset)
      begin
         pass_byte_counter_0<=0;
         pass_byte_counter_1<=0;
         pass_byte_counter_2<=0;
         pass_byte_counter_3<=0;
         pass_byte_counter_4<=0;
      end
      else if(splitter_cur_st==SPLITTER_WAIT_EOP | (splitter_cur_st==SPLITTER_WRITE && input_fifo_ctrl_out==0))
      case(in_fifo_wr)
      1: pass_byte_counter_0<=pass_byte_counter_0+1;
      2: pass_byte_counter_1<=pass_byte_counter_1+1;
      4: pass_byte_counter_2<=pass_byte_counter_2+1;
      8: pass_byte_counter_3<=pass_byte_counter_3+1;
      16:pass_byte_counter_4<=pass_byte_counter_4+1;
      endcase     
      
      always@(posedge clk)
         if(reset)
         begin
            drop_byte_counter_0<=0;
            drop_byte_counter_1<=0;
            drop_byte_counter_2<=0;
            drop_byte_counter_3<=0;
            drop_byte_counter_4<=0;
         end
         else if(splitter_cur_st==SPLITTER_WAIT_NO_WRITE_EOP | (splitter_cur_st==SPLITTER_NO_WRITE && input_fifo_ctrl_out==0))
         case(in_fifo_wr)
         1: drop_byte_counter_0<=drop_byte_counter_0+1;
         2: drop_byte_counter_1<=drop_byte_counter_1+1;
         4: drop_byte_counter_2<=drop_byte_counter_2+1;
         8: drop_byte_counter_3<=drop_byte_counter_3+1;
         16:drop_byte_counter_4<=drop_byte_counter_4+1;
         endcase   
end   
`endif
         
endmodule // queue_splitter




