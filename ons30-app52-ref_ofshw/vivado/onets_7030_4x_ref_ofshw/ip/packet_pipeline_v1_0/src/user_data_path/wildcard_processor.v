`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/27/2015 03:47:45 PM
// Design Name: 
// Module Name: wildcard_processer
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
// 
//////////////////////////////////////////////////////////////////////////////////


module wildcard_processor
#(parameter NUM_OUTPUT_QUEUES = 8,
    parameter DATA_WIDTH = 64,
    parameter CTRL_WIDTH = DATA_WIDTH/8,
    parameter RESULT_WIDTH = `OPENFLOW_ACTION_WIDTH,
    parameter CURRENT_TABLE_ID = 0,
    parameter TABLE_NUM=2
  )
(

    input      [RESULT_WIDTH-1:0]           result_fifo_dout,
    output reg                              result_fifo_rd_en,
    input                                   result_fifo_empty,

    input [CTRL_WIDTH-1:0]                  in_fifo_ctrl,
    input [DATA_WIDTH-1:0]                  in_fifo_data,
    output reg                              in_fifo_rd_en,
    input                                   in_fifo_empty,
    
    output reg [DATA_WIDTH-1:0]             out_data,
    output reg [CTRL_WIDTH-1:0]             out_ctrl,
    output reg                              out_wr,
    input                                   out_rdy,
    
    input                                    wildcard_hit_dout,
    output reg                              actions_en,
    output reg                              actions_hit,
    output reg  [`OPENFLOW_ACTION_WIDTH-1:0]         actions,

    input                                   clk,
    input                                   reset,
    
    output reg [3:0]                        src_port,
    input                                    skip_lookup
    );
    
    reg [DATA_WIDTH-1:0]             out_data_d1;
    reg [CTRL_WIDTH-1:0]             out_ctrl_d1;
    reg [DATA_WIDTH-1:0]             out_data_d2;
    reg [CTRL_WIDTH-1:0]             out_ctrl_d2;
    reg                               out_wr_d1;
    reg                               out_wr_d2;
    reg                               out_wr_d3;

   // assign out_data_d1=in_fifo_data;
   // assign out_ctrl_d1=in_fifo_ctrl;
    
   always@(posedge clk)
      actions_hit<=wildcard_hit_dout;
    
    always@(posedge clk)
        begin
            out_data_d1<=in_fifo_data;
            out_ctrl_d1<=in_fifo_ctrl;
            out_data_d2<=out_data_d1;
            out_ctrl_d2<=out_ctrl_d1;
            out_data<=out_data_d2;
            out_ctrl<=out_ctrl_d2;
            out_wr_d1<=in_fifo_rd_en;
            out_wr_d2<=out_wr_d1;
            out_wr_d3<=out_wr_d2;
            out_wr<=out_wr_d3;
        end
        
        
        
    reg [`OPENFLOW_NEXT_TABLE_ID_WIDTH-1:0]    pkt_dst_table_id;
    
    
    reg [5:0]cur_st,nxt_st;
    
    always@(posedge clk)
        if(reset)
            cur_st<=0;
        else
            cur_st<=nxt_st;
            
    localparam IDLE=0,
               WAIT_FOR_ACTION=1,
               READ_ACTION=2,
               READ_HEAD=3,
               READ_DATA=4,
               WAIT_EOP=5;
               
               
    always@(*)
        begin
            nxt_st=cur_st;
            case(cur_st)
                IDLE:
                    nxt_st=WAIT_FOR_ACTION;
                WAIT_FOR_ACTION:
                    if(!result_fifo_empty)  nxt_st=READ_ACTION;
                READ_ACTION:
                    nxt_st=READ_HEAD;
                READ_HEAD:
                    if(out_rdy) nxt_st=READ_DATA;
                READ_DATA:
                    if(in_fifo_ctrl==0 && out_rdy) nxt_st=WAIT_EOP;
                WAIT_EOP:
                    if(in_fifo_ctrl!=0 && out_rdy) nxt_st=IDLE;
                default:nxt_st=IDLE;
            endcase
        end
    
    always@(*)
        begin
            result_fifo_rd_en=0;
            in_fifo_rd_en=0;
            if(cur_st==READ_ACTION)
                result_fifo_rd_en=out_rdy;
            else if(cur_st==READ_HEAD)
                in_fifo_rd_en=out_rdy;
            else if(cur_st==READ_DATA)
                    in_fifo_rd_en=out_rdy;
            else if(cur_st==WAIT_EOP)
                begin
                    if(in_fifo_ctrl!=0)
                        in_fifo_rd_en=0;
                    else in_fifo_rd_en=out_rdy;
                end
        end
    
    always@(posedge clk)
        if(reset)
            src_port<=0;
        else// if(cur_st==READ_HEAD)
            if(in_fifo_ctrl==`IO_QUEUE_STAGE_NUM)
                src_port<=in_fifo_data[`IOQ_SRC_PORT_POS + `OPENFLOW_ENTRY_SRC_PORT_WIDTH - 1 : `IOQ_SRC_PORT_POS] ;      
    
    always@(posedge clk)
        if(reset)
            actions<=0;
        else if(cur_st==READ_DATA)
            actions<= result_fifo_dout;
                   
    always@(posedge clk)
        if(reset)
            actions_en<=0;
        else if(in_fifo_ctrl==`IO_QUEUE_STAGE_NUM)
            begin
                if(in_fifo_data[`IOQ_DST_TABLE_ID_POS+8-1:`IOQ_DST_TABLE_ID_POS]==CURRENT_TABLE_ID)
                    actions_en<=1;
                else actions_en<=0;
            end
        else if(cur_st==IDLE)
            actions_en<=0;

    
endmodule
