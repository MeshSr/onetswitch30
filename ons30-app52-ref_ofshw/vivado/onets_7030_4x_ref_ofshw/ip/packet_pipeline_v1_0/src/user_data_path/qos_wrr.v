`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2014/09/26 16:10:57
// Design Name: 
// Module Name: queues_qos
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// queue_prio 5>4>3>2>1>0 
// if prio==5
//////////////////////////////////////////////////////////////////////////////////


    module qos_wrr
    #(  parameter QUEUE=0,
        parameter DATA_WIDTH = 64,
        parameter CTRL_WIDTH=DATA_WIDTH/8,
        parameter QUEUE_NUM=2
   )
    (
    input  [DATA_WIDTH-1:0]            in_data,
    input  [CTRL_WIDTH-1:0]            in_ctrl,
    output                             in_rdy,
    input                              in_wr,
    
    input                              clk,
    input                              reset,
    
    output  reg [DATA_WIDTH-1:0]      out_data,
    output  reg [CTRL_WIDTH-1:0]      out_ctrl,
    input                              out_rdy,
    output  reg                       out_wr,
    
    input [5:0]queue_weight_0,
    input [5:0]queue_weight_1,
    input [5:0]queue_weight_2,
    input [5:0]queue_weight_3,
    input [5:0]queue_weight_4,
    input [5:0]queue_weight_5,
    
    output reg [5:0]transmit_vld,
    output reg [31:0]transmit_byte,
    output reg [5:0]drop_vld
    
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
    
    localparam QUEUE_NUM_WIDTH = log2(QUEUE_NUM);
    
    reg [7:0] input_fifo_wr_en;
    wire [DATA_WIDTH-1:0] input_fifo_data_out;
    wire [CTRL_WIDTH-1:0] input_fifo_ctrl_out;
    reg input_fifo_rd_en;
    wire input_fifo_nearly_full;
    
    reg [QUEUE_NUM-1:0]qos_queue_wr;
    reg [QUEUE_NUM-1:0]queue_fifo_wr;
    reg [QUEUE_NUM-1:0]queue_fifo_wr_decoded;
    wire [QUEUE_NUM-1:0]qos_fifo_nearly_full;
    wire [QUEUE_NUM-1:0]qos_fifo_empty;
    reg [QUEUE_NUM-1:0]qos_fifo_rd_en;
    wire [CTRL_WIDTH-1:0] qos_fifo_ctrl_out [QUEUE_NUM-1:0];
    wire [DATA_WIDTH-1:0] qos_fifo_data_out [QUEUE_NUM-1:0];
    
    reg [DATA_WIDTH-1:0] metadata_qos;
    reg metadata_qos_wr;
    reg metadata_qos_rd;
    wire [DATA_WIDTH-1:0] metadata_qos_out;
    wire metadata_qos_empty;
    
    
    
    
    
    reg [5:0] token [QUEUE_NUM-1:0];

    
       
           
    
    
    
   small_fifo #(.WIDTH(DATA_WIDTH+CTRL_WIDTH),.MAX_DEPTH_BITS(4))
   input_fifo
       (    .din           ({in_ctrl, in_data}),  // Data in
            .wr_en         (in_wr),             // Write enable
            .rd_en         (input_fifo_rd_en),    // Read the next word
            .dout          ({input_fifo_ctrl_out, input_fifo_data_out}),
            .full          (),
            .prog_full     (),
            .nearly_full   (input_fifo_nearly_full),
            .empty         (input_fifo_empty),
            .reset         (reset),
            .clk           (clk)
            );
    
    small_fifo #(.WIDTH(DATA_WIDTH),.MAX_DEPTH_BITS(4))
    metadata_qos_fifo
        (    .din           (metadata_qos),  // Data in
             .wr_en         (metadata_qos_wr),             // Write enable
             .rd_en         (metadata_qos_rd),    // Read the next word
             .dout          (metadata_qos_out),
             .full          (),
             .prog_full     (),
             .nearly_full   (),
             .empty         (metadata_qos_empty),
             .reset         (reset),
             .clk           (clk)
             );
             
    assign in_rdy=!input_fifo_nearly_full;
    
    
    reg [3:0]cur_st,nxt_st;
    reg [3:0]cur_st_rd,nxt_st_rd;
    
    localparam IDLE=0;
    localparam WAIT_QOS=1;
    localparam READ=2;
    localparam WAIT_EOP_RD=3;
    localparam EOP_RD=4;
    
    localparam RD_IDLE=0;
    localparam RD_READ=1;
    localparam WRITE=3;
    localparam NO_WRITE=4;
    localparam WAIT_EOP=5;
    localparam WAIT_NO_WRITE_EOP=6;
    localparam RD_EOP=7;
    
    
    always@(posedge clk or negedge reset)
        if(reset)  cur_st<=0;
        else       cur_st<=nxt_st;
        
    always@(*)
        begin
            nxt_st=cur_st;
            case(cur_st)
                IDLE:
                    if(in_wr) nxt_st=WAIT_QOS;
                    else nxt_st=IDLE;
                WAIT_QOS:
                    if(in_ctrl==`METEDATA_NUM) nxt_st=READ;
                    else nxt_st=WAIT_QOS;
                READ:
                    if(in_ctrl==0)nxt_st=WAIT_EOP_RD;
                /*NO_WRITE:
                    if(input_fifo_ctrl_out==0) nxt_st=WAIT_NO_WRITE_EOP;
                    else nxt_st=NO_WRITE;
                WRITE:
                    if(input_fifo_ctrl_out==0) nxt_st=WAIT_EOP;
                    else nxt_st=WRITE;
                WAIT_NO_WRITE_EOP:
                    if(input_fifo_ctrl_out!=0) nxt_st=EOP;
                    else nxt_st=WAIT_NO_WRITE_EOP;
                WAIT_EOP:
                    if(input_fifo_ctrl_out!=0) nxt_st=EOP;
                    else nxt_st=WAIT_EOP;*/
                WAIT_EOP_RD:
                    if(in_ctrl!=0) nxt_st=EOP_RD;
                EOP_RD:nxt_st=IDLE;
                default:nxt_st=IDLE;
            endcase
        end
                
   //transmit_byte_counter
   always@(posedge clk)
   if(reset)
      transmit_vld<=0;
   else if(cur_st_rd==WAIT_EOP && input_fifo_ctrl_out!=0)
      transmit_vld[metadata_qos_out]<=1;
   else transmit_vld<=0;
         
   always@(posedge clk)
   if(reset)
      transmit_byte<=8;
   else if(cur_st_rd==WAIT_NO_WRITE_EOP | cur_st_rd==WAIT_EOP)
      transmit_byte<=transmit_byte+8;
   else transmit_byte<=8;
         
   always@(posedge clk)
   if(reset)
      drop_vld<=0;
   else if(cur_st_rd==WAIT_NO_WRITE_EOP && input_fifo_ctrl_out!=0)
      drop_vld[metadata_qos_out]<=1;
   else drop_vld<=0;         
         
         
         
    
    always@(*)
        if(reset)
            qos_queue_wr=0;
        else case(metadata_qos_out)
            0:qos_queue_wr=5'b00001;
            1:qos_queue_wr=5'b00010;
            2:qos_queue_wr=5'b00100;
            3:qos_queue_wr=5'b01000;
            4:qos_queue_wr=5'b10000;
            default:qos_queue_wr=5'b00001;
            endcase
    
    always@(*)
        if(reset)
            metadata_qos=0;
        else if(cur_st==WAIT_QOS && in_ctrl==`METEDATA_NUM)
            metadata_qos=in_data;//[`METADATA_QOS_QUEUE_POS+`METADATA_QOS_QUEUE_LEN-1:`METADATA_QOS_QUEUE_POS];
        else metadata_qos=0;
            
   always@(*)
       if(reset)
           metadata_qos_wr=0;
       else if(cur_st==WAIT_QOS && in_ctrl==`METEDATA_NUM)
           metadata_qos_wr=1;    
       else metadata_qos_wr=0;         
            


    always@(posedge clk or negedge reset)
        if(reset)  cur_st_rd<=0;
        else       cur_st_rd<=nxt_st_rd;
        
    always@(*)
    begin
      nxt_st_rd=cur_st_rd;
      case(cur_st_rd)
         RD_IDLE:if(!metadata_qos_empty) nxt_st_rd=RD_READ;
         RD_READ:
            if(|(qos_queue_wr & qos_fifo_nearly_full))nxt_st_rd=NO_WRITE;
            else nxt_st_rd=WRITE;
         NO_WRITE:
             if(input_fifo_ctrl_out==0) nxt_st_rd=WAIT_NO_WRITE_EOP;
             else nxt_st_rd=NO_WRITE;
         WRITE:
             if(input_fifo_ctrl_out==0) nxt_st_rd=WAIT_EOP;
             else nxt_st_rd=WRITE;
         WAIT_NO_WRITE_EOP:
             if(input_fifo_ctrl_out!=0) nxt_st_rd=RD_EOP;
             else nxt_st_rd=WAIT_NO_WRITE_EOP;
         WAIT_EOP:
             if(input_fifo_ctrl_out!=0) nxt_st_rd=RD_EOP;
             else nxt_st_rd=WAIT_EOP;
         RD_EOP:nxt_st_rd=RD_IDLE;
         default:nxt_st_rd=RD_IDLE;
      endcase
   end
    
    always@(*)
      if(cur_st_rd==RD_IDLE && (!metadata_qos_empty))metadata_qos_rd=1;
      else metadata_qos_rd=0;
    
    
    always@(*)
        begin
            input_fifo_rd_en=0;
            if(cur_st_rd==RD_READ | cur_st_rd==NO_WRITE | cur_st_rd==WRITE)
                input_fifo_rd_en=~input_fifo_empty;
            else if(cur_st_rd==WAIT_EOP && input_fifo_ctrl_out != 0 )
                input_fifo_rd_en=0;
            else if(cur_st_rd==WAIT_NO_WRITE_EOP && input_fifo_ctrl_out != 0 )
                input_fifo_rd_en=0;
            else if(cur_st_rd==WAIT_EOP | cur_st_rd==WAIT_NO_WRITE_EOP)
                input_fifo_rd_en=~input_fifo_empty;
        end
            
    reg input_fifo_rd_en_d;
    always@(posedge clk)
    if(reset)
      input_fifo_rd_en_d<=0;
    else input_fifo_rd_en_d<=input_fifo_rd_en;
    
    always@(*)
        if(reset)
            queue_fifo_wr=0;
        else if(input_fifo_rd_en_d && (cur_st_rd==WRITE | cur_st_rd==WAIT_EOP))
            queue_fifo_wr=qos_queue_wr;
        else queue_fifo_wr=0;
    /*generate 
        genvar i;
        for(i=0; i<QUEUE_NUM; i=i+1) begin:qos_queue_fifo
            qos_fifo 
            queue_fifo
                (    .din           ({input_fifo_ctrl_out, input_fifo_data_out}),  // Data in
                     .wr_en         (queue_fifo_wr[i]),             // Write enable
                     .rd_en         (qos_fifo_rd_en[i]),    // Read the next word
                     .dout          ({qos_fifo_ctrl_out[i], qos_fifo_data_out[i]}),
                     .full          (),
                     
                     .prog_full     (qos_fifo_nearly_full[i]),
                     //.nearly_full   (),
                     .empty         (qos_fifo_empty[i]),
                     //.reset         (reset),
                     .rst           (reset),
                     .clk           (clk)
                     );
        end
    endgenerate*/
    
        generate 
    genvar i;
    for(i=0; i<QUEUE_NUM; i=i+1) begin:qos_queue_fifo
        qos_fifo_bram 
        queue_fifo
            (    .din           ({input_fifo_ctrl_out, input_fifo_data_out}),  // Data in
                 .wr_en         (queue_fifo_wr[i]),             // Write enable
                 .rd_en         (qos_fifo_rd_en[i]),    // Read the next word
                 .dout          ({qos_fifo_ctrl_out[i], qos_fifo_data_out[i]}),
                 .full          (),
                 
                 .prog_full     (qos_fifo_nearly_full[i]),
                 //.nearly_full   (),
                 .empty         (qos_fifo_empty[i]),
                 //.reset         (reset),
                 .rst           (reset),
                 .clk           (clk)
                 );
    end
endgenerate
        
    reg [31:0]clk_counter;    
    reg [31:0]token_queue[QUEUE_NUM-1:0];    
    reg [QUEUE_NUM-1:0]queue_vld;
    wire [QUEUE_NUM-1:0]weight[QUEUE_NUM-1:0];
    reg [15:0]pkt_byte;
    
    reg [QUEUE_NUM_WIDTH-1:0]          cur_queue;   
    reg [QUEUE_NUM_WIDTH-1:0]          nxt_queue; 
    reg [2:0]                state;
    reg [2:0]                state_nxt; 
    reg                      pkt_ready;
    reg                      pkt_byte_good;
    
    localparam WAIT_NXT_QUEUE=0;
    localparam SETTING_CUR_QUEUE=1;
    localparam READ_HDR=2;
    localparam RATE_QUEUE=3;
    localparam WRITE_QUEUE=4;
    localparam WRITE_QUEUE_EOP=5;
    localparam WRITE_QUEUE_DONE=6; 
   
    always@(posedge clk)
        if(reset) state<=0;
        else state<=state_nxt;
    
    always @(*) 
        begin
            state_nxt=0;
            case(state)
                WAIT_NXT_QUEUE:
                    if(pkt_ready) state_nxt=SETTING_CUR_QUEUE;
                    else state_nxt=WAIT_NXT_QUEUE;
                SETTING_CUR_QUEUE:state_nxt=READ_HDR;
                READ_HDR:
                    if(qos_fifo_ctrl_out[cur_queue]==`IO_QUEUE_STAGE_NUM) state_nxt=WRITE_QUEUE;
                    else state_nxt=READ_HDR;
                WRITE_QUEUE:
                    if(qos_fifo_ctrl_out[cur_queue]==0) state_nxt=WRITE_QUEUE_EOP;
                    else state_nxt=WRITE_QUEUE;
                WRITE_QUEUE_EOP:
                    if(qos_fifo_ctrl_out[cur_queue]!=0) state_nxt=WRITE_QUEUE_DONE;
                    else  state_nxt=   WRITE_QUEUE_EOP;
                WRITE_QUEUE_DONE:state_nxt=WAIT_NXT_QUEUE;
                default:state_nxt=WAIT_NXT_QUEUE;
            endcase
        end
        
    always@(posedge clk)
        if(reset)
            cur_queue<=0;
        else if(state==SETTING_CUR_QUEUE)
            cur_queue<=nxt_queue;

        
    always@(*)
        begin
            qos_fifo_rd_en=0;
            if(state==READ_HDR | state==WRITE_QUEUE)
                qos_fifo_rd_en[cur_queue]=out_rdy && !qos_fifo_empty[cur_queue];              
            else if(state==WRITE_QUEUE_EOP && qos_fifo_ctrl_out[cur_queue]!=0)
                qos_fifo_rd_en[cur_queue]=0;
            else if(state==WRITE_QUEUE_EOP)
                qos_fifo_rd_en[cur_queue]=out_rdy && !qos_fifo_empty[cur_queue];
        end
            
    always@(*)
        if(reset)
            pkt_byte=0;
        else if(state==READ_HDR)
                if(qos_fifo_ctrl_out[cur_queue]==`IO_QUEUE_STAGE_NUM)
                    pkt_byte=qos_fifo_data_out[cur_queue][16+`IOQ_BYTE_LEN_POS-1:`IOQ_BYTE_LEN_POS];

    always@(*)
        if(reset)
            pkt_byte_good=0;
        else if(state==READ_HDR && qos_fifo_ctrl_out[cur_queue]==`IO_QUEUE_STAGE_NUM)
            pkt_byte_good=1;
        else pkt_byte_good=0;
        

    
    always@(posedge clk)
        if(reset) out_wr<=0;
        else if(cur_queue==5) out_wr<=0;
        else out_wr<=qos_fifo_rd_en[cur_queue];
            
    always@(*)
        if(reset)
            begin
                out_data=0;
                out_ctrl=0;
            end
        else if(cur_queue==5) 
            begin
                out_data=0;
                out_ctrl=0;
            end
        else
            begin
                out_data=qos_fifo_data_out[cur_queue];
                out_ctrl=qos_fifo_ctrl_out[cur_queue];     
            end 
 
 //////////////////////////////////////////     nxt_queue   //////////////////////////////////           
    localparam  WAIT_FOR_PKT=0,
                JUDGE=1,
                ADD_QUEUE=2,
                WAIT=3,
                ADD_QUEUE_AFTER=4;
    
    reg [2:0]queue_cur_st,queue_nxt_st;
    always@(posedge clk)
        if(reset) queue_cur_st<=0;
        else queue_cur_st<=queue_nxt_st;
        
    always@(*)
    begin
        queue_nxt_st=queue_cur_st;
        case(queue_cur_st)
            WAIT_FOR_PKT: if(!(&qos_fifo_empty)) queue_nxt_st=JUDGE;
            JUDGE:if(token[nxt_queue]>0 && !qos_fifo_empty[nxt_queue]) queue_nxt_st=WAIT;
                  else queue_nxt_st=ADD_QUEUE;
            ADD_QUEUE: queue_nxt_st=JUDGE;
            WAIT: if(state==SETTING_CUR_QUEUE && token[nxt_queue]==1) queue_nxt_st=ADD_QUEUE_AFTER;
                  else if(state==SETTING_CUR_QUEUE) queue_nxt_st=WAIT_FOR_PKT;
            ADD_QUEUE_AFTER:queue_nxt_st=WAIT_FOR_PKT;
            default:queue_nxt_st=JUDGE;
        endcase
    end
    
    always@(posedge clk)
        if(reset)
            nxt_queue<=1;
        else if(queue_cur_st==ADD_QUEUE | queue_cur_st==ADD_QUEUE_AFTER) 
        begin
            if(nxt_queue==4)
                nxt_queue<=0;
            else nxt_queue<=nxt_queue+1;
        end
    
    always@(*)
        if(reset)
            pkt_ready=0;
        else if(queue_cur_st==WAIT) pkt_ready=1;
        else pkt_ready=0;
              
    always@(posedge clk)
         if(reset)
         begin
            token[0]<=0;
            token[1]<=0;
            token[2]<=0;
            token[3]<=0;
            token[4]<=0;
            token[5]<=0;
         end
         else if(token[cur_queue]==0 )
         begin
            token[0]=token[0]+queue_weight_0;
            token[1]=token[1]+queue_weight_1;
            token[2]=token[2]+queue_weight_2;
            token[3]=token[3]+queue_weight_3;
            token[4]=token[4]+queue_weight_4;
            token[5]=token[5]+queue_weight_5;
         end
         else if(qos_fifo_ctrl_out[0]==8'hff)
            token[0]<=token[0]-1;
         else if(qos_fifo_ctrl_out[1]==8'hff)
            token[1]<=token[1]-1;
         else if(qos_fifo_ctrl_out[2]==8'hff)
            token[2]<=token[2]-1;
         else if(qos_fifo_ctrl_out[3]==8'hff)
            token[3]<=token[3]-1;
         else if(qos_fifo_ctrl_out[4]==8'hff)
            token[4]<=token[4]-1;  
         else if(qos_fifo_ctrl_out[5]==8'hff)
            token[5]<=token[5]-1;             
                            
endmodule