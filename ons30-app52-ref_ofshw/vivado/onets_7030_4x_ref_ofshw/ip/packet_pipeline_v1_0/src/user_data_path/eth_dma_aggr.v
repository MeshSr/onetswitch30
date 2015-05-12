`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2014 05:55:17 PM
// Design Name: 
// Module Name: eth_dma_aggr
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


module eth_dma_aggr
#(
      parameter DATA_WIDTH = 64,
      parameter CTRL_WIDTH = DATA_WIDTH/8,
      parameter ENABLE_HEADER = 1,
      parameter STAGE_NUMBER = 'hff,
      parameter AXI_DATA_WIDTH  = 32,
      parameter AXI_KEEP_WIDTH  = AXI_DATA_WIDTH/8
   )

   (input  [DATA_WIDTH-1:0]              eth_in_data,
    input  [CTRL_WIDTH-1:0]              eth_in_ctrl,
    input                                eth_in_wr,
    output                               eth_in_rdy,
    input  [DATA_WIDTH-1:0]              dma_in_data,
    input  [CTRL_WIDTH-1:0]              dma_in_ctrl,
    input                                dma_in_wr,
    output                               dma_in_rdy,
    output reg [DATA_WIDTH-1:0]          out_data,
    output reg [CTRL_WIDTH-1:0]          out_ctrl,
    output                               out_wr,
    input                                out_rdy,
    
    input                                clk,
    input                                reset
    
    );

    assign dma_in_rdy=1;
    reg eth_fifo_rd,dma_fifo_rd;
    wire [7:0]eth_ctrl_dout,dma_ctrl_dout;
    wire [63:0]eth_data_dout,dma_data_dout;
    wire eth_fifo_almost_full,dma_fifo_almost_full;
    wire eth_fifo_empty,dma_fifo_empty;
    assign eth_in_rdy=!eth_fifo_almost_full;
    
    
    reg [7:0]eth_in_ctrl_d1,eth_in_crtl_d2,dma_in_ctrl_d1,dma_in_ctrl_d2;
    reg [63:0]eth_in_data_d1,eth_in_data_d2,dma_in_data_d1,dma_in_data_d2;
    reg dma_fifo_wr;
    data_fifo eth_in_fifo
        (  .din ({eth_in_ctrl, eth_in_data}),  // Data in
           .wr_en         (eth_in_wr),             // Write enable
           .rd_en         (eth_fifo_rd),    // Read the next word
           .dout          ({eth_ctrl_dout,eth_data_dout}),
           .data_count    (),
           .nearly_full   (),
           .full          (),
           .prog_full     (eth_fifo_almost_full),
           .empty         (eth_fifo_empty),
           .reset         (reset),
           .clk           (clk)
        );
     
     data_fifo dma_in_fifo
      (  .din ({dma_in_ctrl_d2, dma_in_data_d2}),  // Data in
         .wr_en         (dma_fifo_wr),             // Write enable
         .rd_en         (dma_fifo_rd),    // Read the next word
         .dout          ({dma_ctrl_dout,dma_data_dout}),
         .data_count    (),
         .nearly_full   (),
         .full          (),
         .prog_full     (dma_fifo_almost_full),
         .empty         (dma_fifo_empty),
         .reset         (reset),
         .clk           (clk)
      );
     
     
          localparam IDLE=0;
          localparam WAIT_QOS=1;
          localparam LUT_READ=2;
          localparam WRITE=3;
          localparam NO_WRITE=4;
          localparam WAIT_EOP=5;
          localparam WAIT_NO_WRITE_EOP=6;
          localparam EOP=7;
          localparam EOP2=8;
                 
     reg [4:0]cur_st,nxt_st;         
     always@(posedge clk)
         if(reset)  cur_st<=0;
         else       cur_st<=nxt_st;
         
     always@(*)
         begin
             nxt_st=0;
             case(cur_st)
                 IDLE:
                     nxt_st=WAIT_QOS;
                 WAIT_QOS:
                     if(dma_in_wr & dma_fifo_almost_full) nxt_st=NO_WRITE;
                     else if(dma_in_wr)nxt_st=WRITE;
                     else nxt_st=WAIT_QOS;
                 NO_WRITE:
                     if(dma_in_ctrl==0) nxt_st=WAIT_NO_WRITE_EOP;
                     else nxt_st=NO_WRITE;
                 WRITE:
                     if(dma_in_ctrl==0) nxt_st=WAIT_EOP;
                     else nxt_st=WRITE;
                 WAIT_NO_WRITE_EOP:
                     if(dma_in_ctrl!=0) nxt_st=EOP;
                     else nxt_st=WAIT_NO_WRITE_EOP;
                 WAIT_EOP:
                     if(dma_in_ctrl!=0) nxt_st=EOP;
                     else nxt_st=WAIT_EOP;
                 EOP:nxt_st=EOP2;
                 EOP2:nxt_st=IDLE;
                 default:nxt_st=IDLE;
             endcase
         end
     
     always@(posedge clk)
        if(reset)   dma_fifo_wr<=0;
        else if(cur_st==WRITE) dma_fifo_wr<=1;
        else if(cur_st==EOP2) dma_fifo_wr<=0;
        
     always@(posedge clk)
        if(reset)
            begin
                dma_in_ctrl_d1<=0;
                dma_in_ctrl_d2<=0;
                dma_in_data_d1<=0;
                dma_in_data_d2<=0;
            end
        else begin
            dma_in_ctrl_d1<=dma_in_ctrl;
            dma_in_ctrl_d2<=dma_in_ctrl_d1;
            dma_in_data_d1<=dma_in_data;
            dma_in_data_d2<=dma_in_data_d1;
        end
        
    reg [2:0]state,state_nxt;
    localparam select=0;
    localparam read_dma=1;
    localparam read_eth=2;
    localparam wait_eth_end=3;
    localparam wait_dma_end=4;
    
        
    always@(posedge clk)
        if(reset) state<=0;
        else state<=state_nxt;
    
    always@(*)
        begin
            state_nxt=0;
            case(state)
                select:
                    if(~eth_fifo_empty) state_nxt=read_eth;
                    else if(~dma_fifo_empty) state_nxt=read_dma;
                    else state_nxt=select;
                read_eth:
                    if(eth_ctrl_dout==0) state_nxt=wait_eth_end;
                    else state_nxt=read_eth;
                read_dma:
                    if(dma_ctrl_dout==0) state_nxt=wait_dma_end;
                    else state_nxt=read_dma;
                wait_eth_end:
                    if(eth_ctrl_dout!=0) state_nxt=select;
                    else state_nxt=wait_eth_end;
                wait_dma_end:
                    if(dma_ctrl_dout!=0) state_nxt=select;
                    else state_nxt=wait_dma_end;
                default:state_nxt=select;
            endcase
        end
    
    always@(*)
        if(state==wait_eth_end && eth_ctrl_dout!=0)
            eth_fifo_rd=0;
        else if(state==read_eth | state==wait_eth_end)
            eth_fifo_rd=out_rdy;
        else eth_fifo_rd=0;
        
    always@(*)
        if(state==wait_dma_end && dma_ctrl_dout!=0)
            dma_fifo_rd=0;
        else if(state==read_dma | state==wait_dma_end)
            dma_fifo_rd=out_rdy;
        else dma_fifo_rd=0;
        
    reg eth_wr,dma_wr;
    always@(posedge clk)
        begin
            eth_wr<=eth_fifo_rd;
            dma_wr<=dma_fifo_rd;
        end 
    assign out_wr=eth_wr | dma_wr;
        
    always@(*)
        if(eth_wr)
            begin
                out_ctrl=eth_ctrl_dout;
                out_data=eth_data_dout;
            end
        else if(dma_wr)
            begin
                out_ctrl=dma_ctrl_dout;
                out_data=dma_data_dout;
            end
        else 
            begin
                out_ctrl=0;
                out_data=0;
            end
    
endmodule
