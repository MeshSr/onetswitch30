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
    output                        out_wr_0,

    output     [DATA_WIDTH-1:0]        out_data_1,
    output     [CTRL_WIDTH-1:0]        out_ctrl_1,
    input                              out_rdy_1,
    output                         out_wr_1,

    output     [DATA_WIDTH-1:0]        out_data_2,
    output     [CTRL_WIDTH-1:0]        out_ctrl_2,
    input                              out_rdy_2,
    output                          out_wr_2,

    output     [DATA_WIDTH-1:0]        out_data_3,
    output     [CTRL_WIDTH-1:0]        out_ctrl_3,
    input                              out_rdy_3,
    output                          out_wr_3,

    output     [DATA_WIDTH-1:0]        out_data_4,
    output     [CTRL_WIDTH-1:0]        out_ctrl_4,
    input                              out_rdy_4,
    output                          out_wr_4,

    output  [DATA_WIDTH-1:0]           out_data_5,
    output  [CTRL_WIDTH-1:0]           out_ctrl_5,
    output                          out_wr_5,
    input                              out_rdy_5,

    output  [DATA_WIDTH-1:0]           out_data_6,
    output  [CTRL_WIDTH-1:0]           out_ctrl_6,
    output                          out_wr_6,
    input                              out_rdy_6,

    output  [DATA_WIDTH-1:0]           out_data_7,
    output  [CTRL_WIDTH-1:0]           out_ctrl_7,
    output                         out_wr_7,
    input                              out_rdy_7,

    // --- Interface to the previous module
    input  [DATA_WIDTH-1:0]            in_data,
    input  [CTRL_WIDTH-1:0]            in_ctrl,
    output                             in_rdy,
    input                              in_wr,

    // --- Register interface
    input [31:0]   data_output_queues_i ,
    input [31:0]   addr_output_queues_i ,
    input          req_output_queues_i  ,
    input          rw_output_queues_i   ,
    output         ack_output_queues_o  ,
    output [31:0]  data_output_queues_o ,
    
    // --- Misc
    input                              clk,
    input                              reset);
    
    
    wire input_fifo_nearly_full;
    assign in_rdy=!input_fifo_nearly_full;
    wire [DATA_WIDTH-1:0]input_fifo_data_out;
    wire [CTRL_WIDTH-1:0]input_fifo_ctrl_out;
    
    wire [7:0]in_rdy_queue;
    wire [DATA_WIDTH-1:0]out_data[7:0];
    wire [CTRL_WIDTH-1:0]out_ctrl[7:0];
    wire [7:0]out_rdy;
    wire [7:0]out_wr;
    reg [7:0]in_wr_qos;
    
    assign out_data_7=out_data[7];
    assign out_data_6=out_data[6];
    assign out_data_5=out_data[5];
    assign out_data_4=out_data[4];
    assign out_data_3=out_data[3];
    assign out_data_2=out_data[2];
    assign out_data_1=out_data[1];
    assign out_data_0=out_data[0];
    
    assign out_ctrl_7=out_ctrl[7];
    assign out_ctrl_6=out_ctrl[6];
    assign out_ctrl_5=out_ctrl[5];
    assign out_ctrl_4=out_ctrl[4];
    assign out_ctrl_3=out_ctrl[3];
    assign out_ctrl_2=out_ctrl[2];
    assign out_ctrl_1=out_ctrl[1];
    assign out_ctrl_0=out_ctrl[0];
    
    assign out_wr_7=out_wr[7];
    assign out_wr_6=out_wr[6];
    assign out_wr_5=out_wr[5];
    assign out_wr_4=out_wr[4];
    assign out_wr_3=out_wr[3];
    assign out_wr_2=out_wr[2];
    assign out_wr_1=out_wr[1];
    assign out_wr_0=out_wr[0];
    
    assign out_rdy[7]=out_rdy_7;
    assign out_rdy[6]=out_rdy_6;
    assign out_rdy[5]=out_rdy_5;
    assign out_rdy[4]=out_rdy_4;
    assign out_rdy[3]=out_rdy_3;
    assign out_rdy[2]=out_rdy_2;
    assign out_rdy[1]=out_rdy_1;
    assign out_rdy[0]=out_rdy_0;
    

    
    wire [5:0]queue_weight_0;
    wire [5:0]queue_weight_1;
    wire [5:0]queue_weight_2;
    wire [5:0]queue_weight_3;
    wire [5:0]queue_weight_4;
    wire [5:0]queue_weight_5;
    
    wire [5:0]transmit_vld[7:0];
    wire [31:0]transmit_byte[7:0];
    wire [5:0]drop_vld[7:0];
    
    wire [5:0]transmit_vld_0=transmit_vld[0]    ;
    wire [5:0]transmit_vld_1=transmit_vld[1]    ;
    wire [5:0]transmit_vld_2=transmit_vld[2]    ;
    wire [5:0]transmit_vld_3=transmit_vld[3]    ;
    wire [5:0]transmit_vld_4=transmit_vld[4]    ;
    wire [5:0]transmit_vld_5=transmit_vld[5]    ;
    wire [5:0]transmit_vld_6=transmit_vld[6]    ;
    wire [5:0]transmit_vld_7=transmit_vld[7]    ;
        
    wire [31:0]transmit_byte_0=transmit_byte[0]   ;
    wire [31:0]transmit_byte_1=transmit_byte[1]   ;
    wire [31:0]transmit_byte_2=transmit_byte[2]   ;
    wire [31:0]transmit_byte_3=transmit_byte[3]   ;
    wire [31:0]transmit_byte_4=transmit_byte[4]   ;
    wire [31:0]transmit_byte_5=transmit_byte[5]   ;
    wire [31:0]transmit_byte_6=transmit_byte[6]   ;
    wire [31:0]transmit_byte_7=transmit_byte[7]   ;
    
    wire [5:0]drop_vld_0=drop_vld[0]        ;
    wire [5:0]drop_vld_1=drop_vld[1]        ;
    wire [5:0]drop_vld_2=drop_vld[2]        ;
    wire [5:0]drop_vld_3=drop_vld[3]        ;
    wire [5:0]drop_vld_4=drop_vld[4]        ;
    wire [5:0]drop_vld_5=drop_vld[5]        ;
    wire [5:0]drop_vld_6=drop_vld[6]        ;
    wire [5:0]drop_vld_7=drop_vld[7]        ;
    
    
    output_queue_reg_master output_queue_reg_master
    (
      .data_output_queues_i  (data_output_queues_i),
      .addr_output_queues_i  (addr_output_queues_i),
      .req_output_queues_i   (req_output_queues_i),
      .rw_output_queues_i    (rw_output_queues_i),
      .ack_output_queues_o   (ack_output_queues_o),
      .data_output_queues_o  (data_output_queues_o),
      
      .queue_weight_0(queue_weight_0),
      .queue_weight_1(queue_weight_1),
      .queue_weight_2(queue_weight_2),
      .queue_weight_3(queue_weight_3),
      .queue_weight_4(queue_weight_4),
      .queue_weight_5(queue_weight_5),
      
      .clk(clk),
      .reset(reset),
      
      .transmit_vld_0   (transmit_vld_0),   
      .transmit_vld_1   (transmit_vld_1),   
      .transmit_vld_2   (transmit_vld_2),   
      .transmit_vld_3   (transmit_vld_3),   
      .transmit_vld_4   (transmit_vld_4),   
      .transmit_vld_5   (transmit_vld_5),   
      .transmit_vld_6   (transmit_vld_6),
      .transmit_vld_7   (transmit_vld_7),
      
      .qos_byte_0  (transmit_byte_0),
      .qos_byte_1  (transmit_byte_1),
      .qos_byte_2  (transmit_byte_2),
      .qos_byte_3  (transmit_byte_3),
      .qos_byte_4  (transmit_byte_4),
      .qos_byte_5  (transmit_byte_5),
      .qos_byte_6  (transmit_byte_6),
      .qos_byte_7  (transmit_byte_7),
      
      .drop_vld_0 (drop_vld_0), 
      .drop_vld_1 (drop_vld_1), 
      .drop_vld_2 (drop_vld_2),   
      .drop_vld_3 (drop_vld_3),
      .drop_vld_4 (drop_vld_4),
      .drop_vld_5 (drop_vld_5),
      .drop_vld_6 (drop_vld_6),
      .drop_vld_7 (drop_vld_7)
     

    );
    
    generate 
        genvar i;
        for(i=0; i<8; i=i+1) begin:qos_queue
            qos_wrr
            #(
                .DATA_WIDTH(DATA_WIDTH),
                .CTRL_WIDTH(CTRL_WIDTH),
                .QUEUE(i),
                .QUEUE_NUM(`QUEUE_NUM)
            )queues_qos
            (
                .clk             (clk     ), 
                .reset           (reset   ),  
                .in_data         (input_fifo_data_out ),
                .in_ctrl         (input_fifo_ctrl_out ), 
                .in_rdy          (in_rdy_queue[i]  ),  
                .in_wr           (in_wr_qos[i]   ),          
                .out_data        (out_data[i]),
                .out_ctrl        (out_ctrl[i]), 
                .out_rdy         (out_rdy[i] ),
                .out_wr          (out_wr[i]  ),
                
                .queue_weight_0(queue_weight_0),
                .queue_weight_1(queue_weight_1),
                .queue_weight_2(queue_weight_2),
                .queue_weight_3(queue_weight_3),
                .queue_weight_4(queue_weight_4),
                .queue_weight_5(queue_weight_5),
                
                .transmit_vld    (transmit_vld[i]   ),
                .transmit_byte   (transmit_byte[i]  ),
                .drop_vld        (drop_vld[i]       )
                  
            );
        end
    endgenerate
 
    reg  [7:0]in_rd_queue;
    reg in_rd;
    reg [7:0] in_fifo_wr;
    reg [7:0]in_fifo_wr_d1;

    small_fifo #(.WIDTH(DATA_WIDTH+CTRL_WIDTH),.MAX_DEPTH_BITS(4))
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
 
    localparam READ_HDR=1;
    localparam WAIT_DATA=2;
    localparam WAIT_EOP=3; 
    localparam EOP=4;
    reg [2:0]cur_st,nxt_st;
    always@(posedge clk)
        if(reset) cur_st<=0;
        else cur_st<=nxt_st;
        
    always@(*)
        begin
            nxt_st=0;
            case(cur_st)
                READ_HDR:
                    if(in_wr && in_ctrl==`IO_QUEUE_STAGE_NUM) nxt_st=WAIT_DATA;
                    else nxt_st=READ_HDR;
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
        else if(cur_st==READ_HDR && in_wr && in_ctrl==`IO_QUEUE_STAGE_NUM)
            in_fifo_wr<=in_data[`IOQ_DST_PORT_POS + 8 - 1:`IOQ_DST_PORT_POS];
        else if(cur_st==EOP)
            in_fifo_wr<=0;

    always@(posedge clk)
        if(reset)   in_rd<=0;
        else        in_rd<=in_wr;
    
    always@(posedge clk)
        if(reset)   in_wr_qos<=0;
        else if(in_rd) in_wr_qos<= in_fifo_wr;
        else in_wr_qos<=0;

 
endmodule // output_queues




