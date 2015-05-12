`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/03/12 11:16:23
// Design Name: 
// Module Name: output_port_lookup_reg_master
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
/*
lut_actions_tmp[31:0]      = reg_data; 
lut_actions_tmp[63:32]     = reg_data; 
lut_actions_tmp[95:64]     = reg_data; 
lut_actions_tmp[127:96]    = reg_data; 
lut_actions_tmp[159:128]   = reg_data; 
lut_actions_tmp[191:160]   = reg_data; 
lut_actions_tmp[223:192]   = reg_data; 
lut_actions_tmp[255:224]   = reg_data; 
lut_actions_tmp[287:256]   = reg_data; 
lut_actions_tmp[319:288]   = reg_data; 
cam_data[prio][31:0]       = reg_data; 
cam_data[prio][63:32]      = reg_data; 
cam_data[prio][95:64]      = reg_data; 
cam_data_mask[prio][31:0]  = reg_data; 
cam_data_mask[prio][63:32] = reg_data; 
cam_data_mask[prio][95:64] = reg_data; 
cam_data_mask[prio][95:64] = reg_data;*/
//////////////////////////////////////////////////////////////////////////////////


module output_port_lookup_reg_master#
(
   parameter LUT_DEPTH=16,
   parameter LUT_DEPTH_BITS=log2(LUT_DEPTH),
   parameter TABLE_NUM=2
)
(
   input [31:0] data_output_port_lookup_i,
   input [31:0] addr_output_port_lookup_i,
   input req_output_port_lookup_i,
   input rw_output_port_lookup_i,
   output reg ack_output_port_lookup_o,
   output reg[31:0] data_output_port_lookup_o,
   
   output reg bram_cs,
   output reg bram_we,
   output reg [`PRIO_WIDTH-1:0]bram_addr,
   output reg [319:0]lut_actions_in,  
   input [319:0]lut_actions_out,
      
   output reg[`PRIO_WIDTH+`ACTION_WIDTH-1:0] tcam_addr_out,
   output reg [31:0] tcam_data_out,
   output reg tcam_we,
   input [31:0] tcam_data_in,
   
   output reg [3:0] counter_addr_out,
   output reg counter_addr_rd,
   input [31:0]pkt_counter_in,
   input [31:0]byte_counter_in,
   
   output reg[7:0]   head_combine,
      
   input clk,
   input reset
   

   
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
    reg [`OPENFLOW_ACTION_WIDTH-1:0]    lut_actions_tmp;
    reg [95:0] tcam_tmp;    
    reg [LUT_DEPTH_BITS-1:0]clear_count;
    
    
    
    reg [3:0]deconcentrator_flag;
    reg [4:0]cur_st,nxt_st;
    localparam IDLE=0,
               DECON=1,
               LUT=2,
               TCAM=3,
               HEAD=4,
               COUNTER=5,
               COUNTER_ACK=6,
               LUT_READ_RAM=7,
               LUT_MOD_ACTION=8,
               LUT_WRITE_RAM=9,
               LUT_READ=10,
               TCAM_MOD_DATA=11,
               TCAM_WRITE_RAM=12,
               TCAM_READ=13,
               ACK_BLANK=14,
               REG_DONE=15,
               CLEAR=16;
               
    always@(posedge clk)
      if(reset) cur_st<=CLEAR;
      else cur_st<=nxt_st;
    
    always@(*)
    begin
      nxt_st=cur_st;
      case(cur_st)
         CLEAR:if(clear_count==LUT_DEPTH-1) nxt_st=IDLE;
         IDLE:if(req_output_port_lookup_i) nxt_st=DECON;
         DECON:
            if(addr_output_port_lookup_i[`TABLE_ID_POS+`TABLE_ID_WIDTH-1:`TABLE_ID_POS]<=TABLE_NUM && addr_output_port_lookup_i[`PRIO_POS+`PRIO_WIDTH-1:`PRIO_POS]<LUT_DEPTH)
            begin
               if(deconcentrator_flag==`LUT_ACTION_TAG)        nxt_st=LUT;
               else if(deconcentrator_flag==`TCAM_TAG)         nxt_st=TCAM;
               else if(deconcentrator_flag==`HEAD_PARSER_TAG)  nxt_st=HEAD;
               else if(deconcentrator_flag==`FLOW_COUNTER)     nxt_st=COUNTER;
               else nxt_st=ACK_BLANK;
            end
            else nxt_st=ACK_BLANK;
         LUT:if(rw_output_port_lookup_i==0) 
                 nxt_st=LUT_MOD_ACTION;
             else if(rw_output_port_lookup_i==1) 
                 nxt_st=LUT_READ;               
         LUT_MOD_ACTION:nxt_st=LUT_WRITE_RAM;
         LUT_WRITE_RAM:nxt_st=REG_DONE;
         LUT_READ:nxt_st=REG_DONE;    
         TCAM:
            if(rw_output_port_lookup_i==0) 
               nxt_st=TCAM_WRITE_RAM;
            else if(rw_output_port_lookup_i==1) 
               nxt_st=TCAM_READ;        
         TCAM_WRITE_RAM:nxt_st=REG_DONE;
         TCAM_READ:nxt_st=REG_DONE;
         COUNTER:nxt_st=COUNTER_ACK;
         COUNTER_ACK:nxt_st=REG_DONE;
         HEAD:nxt_st=REG_DONE;
         ACK_BLANK:nxt_st=REG_DONE;
         REG_DONE:nxt_st=IDLE;     
         default:nxt_st=IDLE;
         endcase
      end
    
    always@(posedge clk)
    if(reset)
      clear_count<=0;
    else if(cur_st==CLEAR)
      clear_count<=clear_count+1;
    
    always@(posedge clk)
    if(cur_st==IDLE && req_output_port_lookup_i)
    case(addr_output_port_lookup_i[`ACTION_POS+`ACTION_WIDTH-1:`ACTION_POS])
    `OPENFLOW_WILDCARD_LOOKUP_ACTION_0_REG:     deconcentrator_flag  <=  `LUT_ACTION_TAG;   
    `OPENFLOW_WILDCARD_LOOKUP_ACTION_1_REG:     deconcentrator_flag  <=  `LUT_ACTION_TAG;   
    `OPENFLOW_WILDCARD_LOOKUP_ACTION_2_REG:     deconcentrator_flag  <=  `LUT_ACTION_TAG;   
    `OPENFLOW_WILDCARD_LOOKUP_ACTION_3_REG:     deconcentrator_flag  <=  `LUT_ACTION_TAG;   
    `OPENFLOW_WILDCARD_LOOKUP_ACTION_4_REG:     deconcentrator_flag  <=  `LUT_ACTION_TAG;   
    `OPENFLOW_WILDCARD_LOOKUP_ACTION_5_REG:     deconcentrator_flag  <=  `LUT_ACTION_TAG;   
    `OPENFLOW_WILDCARD_LOOKUP_ACTION_6_REG:     deconcentrator_flag  <=  `LUT_ACTION_TAG;   
    `OPENFLOW_WILDCARD_LOOKUP_ACTION_7_REG:     deconcentrator_flag  <=  `LUT_ACTION_TAG;   
    `OPENFLOW_WILDCARD_LOOKUP_ACTION_8_REG:     deconcentrator_flag  <=  `LUT_ACTION_TAG;   
    `OPENFLOW_WILDCARD_LOOKUP_ACTION_9_REG:     deconcentrator_flag  <=  `LUT_ACTION_TAG;   
    `OPENFLOW_WILDCARD_LOOKUP_CMP_0_REG:        deconcentrator_flag  <=  `TCAM_TAG;         
    `OPENFLOW_WILDCARD_LOOKUP_CMP_1_REG:        deconcentrator_flag  <=  `TCAM_TAG;         
    `OPENFLOW_WILDCARD_LOOKUP_CMP_2_REG:        deconcentrator_flag  <=  `TCAM_TAG;         
    `OPENFLOW_WILDCARD_LOOKUP_CMP_MASK_0_REG:   deconcentrator_flag  <=  `TCAM_TAG;
    `OPENFLOW_WILDCARD_LOOKUP_CMP_MASK_1_REG:   deconcentrator_flag  <=  `TCAM_TAG;         
    `OPENFLOW_WILDCARD_LOOKUP_CMP_MASK_2_REG:   deconcentrator_flag  <=  `TCAM_TAG;         
    `OPENFLOW_WILDCARD_LOOKUP_HEAD_PARSER_REG:  deconcentrator_flag  <=  `HEAD_PARSER_TAG;
    `OPENFLOW_WILDCARD_LOOKUP_BYTE_COUNTER:     deconcentrator_flag  <=  `FLOW_COUNTER;        
    `OPENFLOW_WILDCARD_LOOKUP_PKT_COUNTER:      deconcentrator_flag  <=  `FLOW_COUNTER;     
    default:deconcentrator_flag<=4'hf;
    endcase
    else deconcentrator_flag <= 4'hf ;
    
    always@(*)
      if(reset)
         lut_actions_tmp=0;   
       else if(cur_st==LUT_MOD_ACTION)
       begin
         lut_actions_tmp=lut_actions_out;
           case(addr_output_port_lookup_i[`ACTION_POS+`ACTION_WIDTH-1:`ACTION_POS])
               `OPENFLOW_WILDCARD_LOOKUP_ACTION_0_REG: lut_actions_tmp[31:0]     =data_output_port_lookup_i;
               `OPENFLOW_WILDCARD_LOOKUP_ACTION_1_REG: lut_actions_tmp[63:32]    =data_output_port_lookup_i;
               `OPENFLOW_WILDCARD_LOOKUP_ACTION_2_REG: lut_actions_tmp[95:64]    =data_output_port_lookup_i;
               `OPENFLOW_WILDCARD_LOOKUP_ACTION_3_REG: lut_actions_tmp[127:96]   =data_output_port_lookup_i;
               `OPENFLOW_WILDCARD_LOOKUP_ACTION_4_REG: lut_actions_tmp[159:128]  =data_output_port_lookup_i;
               `OPENFLOW_WILDCARD_LOOKUP_ACTION_5_REG: lut_actions_tmp[191:160]  =data_output_port_lookup_i;
               `OPENFLOW_WILDCARD_LOOKUP_ACTION_6_REG: lut_actions_tmp[223:192]  =data_output_port_lookup_i;
               `OPENFLOW_WILDCARD_LOOKUP_ACTION_7_REG: lut_actions_tmp[255:224]  =data_output_port_lookup_i;
               `OPENFLOW_WILDCARD_LOOKUP_ACTION_8_REG: lut_actions_tmp[287:256]  =data_output_port_lookup_i;
               `OPENFLOW_WILDCARD_LOOKUP_ACTION_9_REG: lut_actions_tmp[319:288]  =data_output_port_lookup_i;
               default:lut_actions_tmp=lut_actions_out;
           endcase
       end

    always@(*)
      if(reset)   bram_cs=0;
      else if(cur_st==CLEAR | cur_st==LUT | cur_st==LUT_WRITE_RAM) bram_cs=1;
      else bram_cs=0;

    always@(*)
        if(reset) bram_we=0;
        else if(cur_st==CLEAR | cur_st==LUT_WRITE_RAM) bram_we=1;
        else bram_we=0;      
    
    always@(*)
      if(reset)   bram_addr=0;
      else if(cur_st==CLEAR) bram_addr=clear_count;
      else if(cur_st==LUT | cur_st==LUT_WRITE_RAM) bram_addr=addr_output_port_lookup_i[15:8];
      else bram_addr=0;
    
    always@(posedge clk)
      lut_actions_in<=lut_actions_tmp;
      
    always@(posedge clk)
      if(reset)
         ack_output_port_lookup_o<=0;
      else if(cur_st==REG_DONE)
         ack_output_port_lookup_o<=1;
      else ack_output_port_lookup_o<=0;
    
    always@(*)
      if(reset)
         tcam_addr_out=0;
      else if(cur_st==CLEAR)
         tcam_addr_out=clear_count;
      else if(cur_st==TCAM)
         tcam_addr_out=addr_output_port_lookup_i[`PRIO_WIDTH+`ACTION_WIDTH+`ACTION_POS-1:`ACTION_POS];
    
    always@(*)
      if(reset)
         tcam_data_out=0;
      else if(cur_st==TCAM_WRITE_RAM)
         tcam_data_out=data_output_port_lookup_i;
      else tcam_data_out=0;
    
    always@(*)
      if(reset)
         tcam_we=0;
      else if(cur_st==TCAM_WRITE_RAM)
         tcam_we=1;
      else tcam_we=0;      
      
      always@(posedge clk)
         if(reset)
            tcam_tmp<=0;
         else if(cur_st==TCAM_MOD_DATA)
            tcam_tmp<=tcam_data_in;
         else if(cur_st==TCAM_WRITE_RAM)
            case(addr_output_port_lookup_i[`ACTION_POS+`ACTION_WIDTH-1:`ACTION_POS])
               `OPENFLOW_WILDCARD_LOOKUP_CMP_MASK_0_REG:tcam_tmp[31:0]<=data_output_port_lookup_i;
               `OPENFLOW_WILDCARD_LOOKUP_CMP_MASK_1_REG:tcam_tmp[63:32]<=data_output_port_lookup_i;
               `OPENFLOW_WILDCARD_LOOKUP_CMP_MASK_2_REG:tcam_tmp[95:64]<=data_output_port_lookup_i;
               `OPENFLOW_WILDCARD_LOOKUP_CMP_0_REG:tcam_tmp[31:0]<=data_output_port_lookup_i;
               `OPENFLOW_WILDCARD_LOOKUP_CMP_1_REG:tcam_tmp[63:32]<=data_output_port_lookup_i;
               `OPENFLOW_WILDCARD_LOOKUP_CMP_2_REG:tcam_tmp[95:64]<=data_output_port_lookup_i;
               default: tcam_tmp<=tcam_data_in;
            endcase
            
`ifdef ONETS45
begin      
      always@(posedge clk)
         if(reset)
            data_output_port_lookup_o<=0;
         else if(cur_st==LUT_READ)
            case(addr_output_port_lookup_i[`ACTION_POS+`ACTION_WIDTH-1:`ACTION_POS])
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_0_REG: data_output_port_lookup_o<=lut_actions_out[31:0]    ;    
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_1_REG: data_output_port_lookup_o<=lut_actions_out[63:32]  ;
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_2_REG: data_output_port_lookup_o<=lut_actions_out[95:64]  ;
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_3_REG: data_output_port_lookup_o<=lut_actions_out[127:96] ;
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_4_REG: data_output_port_lookup_o<=lut_actions_out[159:128];
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_5_REG: data_output_port_lookup_o<=lut_actions_out[191:160];
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_6_REG: data_output_port_lookup_o<=lut_actions_out[223:192];
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_7_REG: data_output_port_lookup_o<=lut_actions_out[255:224];
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_8_REG: data_output_port_lookup_o<=lut_actions_out[287:256];
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_9_REG: data_output_port_lookup_o<=lut_actions_out[319:288];
                default:data_output_port_lookup_o<=32'hdeadbeef;
            endcase
         else if(cur_st==TCAM_READ)
            case(addr_output_port_lookup_i[`ACTION_POS+`ACTION_WIDTH-1:`ACTION_POS])
               `OPENFLOW_WILDCARD_LOOKUP_CMP_MASK_0_REG:data_output_port_lookup_o<=tcam_data_in;
               `OPENFLOW_WILDCARD_LOOKUP_CMP_MASK_1_REG:data_output_port_lookup_o<=tcam_data_in;
               `OPENFLOW_WILDCARD_LOOKUP_CMP_MASK_2_REG:data_output_port_lookup_o<=tcam_data_in;
               `OPENFLOW_WILDCARD_LOOKUP_CMP_0_REG:data_output_port_lookup_o<=tcam_data_in;
               `OPENFLOW_WILDCARD_LOOKUP_CMP_1_REG:data_output_port_lookup_o<=tcam_data_in;
               `OPENFLOW_WILDCARD_LOOKUP_CMP_2_REG:data_output_port_lookup_o<=tcam_data_in;
               default: data_output_port_lookup_o<=32'hdeadbeef;
            endcase
         else if(cur_st==COUNTER_ACK)
            case(addr_output_port_lookup_i[`ACTION_POS+`ACTION_WIDTH-1:`ACTION_POS])
               `OPENFLOW_WILDCARD_LOOKUP_BYTE_COUNTER:   data_output_port_lookup_o<=byte_counter_in;
               `OPENFLOW_WILDCARD_LOOKUP_PKT_COUNTER:    data_output_port_lookup_o<=pkt_counter_in;
               default:data_output_port_lookup_o<=32'hdeadbeef;
            endcase
         else if(cur_st==HEAD)
            data_output_port_lookup_o<=head_combine;
         else if(cur_st==ACK_BLANK)
            data_output_port_lookup_o<=32'hdeadbeef;
end
`elsif ONETS30
begin      
      always@(posedge clk)
         if(reset)
            data_output_port_lookup_o<=0;
         else if(cur_st==LUT_READ)
            case(addr_output_port_lookup_i[`ACTION_POS+`ACTION_WIDTH-1:`ACTION_POS])
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_0_REG: data_output_port_lookup_o<=lut_actions_out[31:0]    ;    
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_1_REG: data_output_port_lookup_o<=lut_actions_out[63:32]  ;
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_2_REG: data_output_port_lookup_o<=lut_actions_out[95:64]  ;
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_3_REG: data_output_port_lookup_o<=lut_actions_out[127:96] ;
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_4_REG: data_output_port_lookup_o<=lut_actions_out[159:128];
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_5_REG: data_output_port_lookup_o<=lut_actions_out[191:160];
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_6_REG: data_output_port_lookup_o<=lut_actions_out[223:192];
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_7_REG: data_output_port_lookup_o<=lut_actions_out[255:224];
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_8_REG: data_output_port_lookup_o<=lut_actions_out[287:256];
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_9_REG: data_output_port_lookup_o<=lut_actions_out[319:288];
                default:data_output_port_lookup_o<=32'hdeadbeef;
            endcase
         else if(cur_st==TCAM_READ)
            case(addr_output_port_lookup_i[`ACTION_POS+`ACTION_WIDTH-1:`ACTION_POS])
               `OPENFLOW_WILDCARD_LOOKUP_CMP_MASK_0_REG:data_output_port_lookup_o<=tcam_data_in;
               `OPENFLOW_WILDCARD_LOOKUP_CMP_MASK_1_REG:data_output_port_lookup_o<=tcam_data_in;
               `OPENFLOW_WILDCARD_LOOKUP_CMP_MASK_2_REG:data_output_port_lookup_o<=tcam_data_in;
               `OPENFLOW_WILDCARD_LOOKUP_CMP_0_REG:data_output_port_lookup_o<=tcam_data_in;
               `OPENFLOW_WILDCARD_LOOKUP_CMP_1_REG:data_output_port_lookup_o<=tcam_data_in;
               `OPENFLOW_WILDCARD_LOOKUP_CMP_2_REG:data_output_port_lookup_o<=tcam_data_in;
               default: data_output_port_lookup_o<=32'hdeadbeef;
            endcase
         else if(cur_st==COUNTER_ACK)
            case(addr_output_port_lookup_i[`ACTION_POS+`ACTION_WIDTH-1:`ACTION_POS])
               `OPENFLOW_WILDCARD_LOOKUP_BYTE_COUNTER:   data_output_port_lookup_o<=byte_counter_in;
               `OPENFLOW_WILDCARD_LOOKUP_PKT_COUNTER:    data_output_port_lookup_o<=pkt_counter_in;
               default:data_output_port_lookup_o<=32'hdeadbeef;
            endcase
         else if(cur_st==HEAD)
            data_output_port_lookup_o<=head_combine;
         else if(cur_st==ACK_BLANK)
            data_output_port_lookup_o<=32'hdeadbeef;
end
`elsif ONETS20
begin      
      always@(posedge clk)
         if(reset)
            data_output_port_lookup_o<=0;
         else if(cur_st==LUT_READ)
            case(addr_output_port_lookup_i[`ACTION_POS+`ACTION_WIDTH-1:`ACTION_POS])
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_0_REG: data_output_port_lookup_o<=lut_actions_out[31:0]    ;    
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_1_REG: data_output_port_lookup_o<=lut_actions_out[63:32]  ;
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_2_REG: data_output_port_lookup_o<=lut_actions_out[95:64]  ;
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_3_REG: data_output_port_lookup_o<=lut_actions_out[127:96] ;
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_4_REG: data_output_port_lookup_o<=lut_actions_out[159:128];
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_5_REG: data_output_port_lookup_o<=lut_actions_out[191:160];
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_6_REG: data_output_port_lookup_o<=lut_actions_out[223:192];
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_7_REG: data_output_port_lookup_o<=lut_actions_out[255:224];
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_8_REG: data_output_port_lookup_o<=lut_actions_out[287:256];
                `OPENFLOW_WILDCARD_LOOKUP_ACTION_9_REG: data_output_port_lookup_o<=lut_actions_out[319:288];
                default:data_output_port_lookup_o<=32'hdeadbeef;
            endcase
         else if(cur_st==TCAM_READ)
            case(addr_output_port_lookup_i[`ACTION_POS+`ACTION_WIDTH-1:`ACTION_POS])
               `OPENFLOW_WILDCARD_LOOKUP_CMP_MASK_0_REG:data_output_port_lookup_o<=tcam_data_in;
               `OPENFLOW_WILDCARD_LOOKUP_CMP_MASK_1_REG:data_output_port_lookup_o<=tcam_data_in;
               `OPENFLOW_WILDCARD_LOOKUP_CMP_MASK_2_REG:data_output_port_lookup_o<=tcam_data_in;
               `OPENFLOW_WILDCARD_LOOKUP_CMP_0_REG:data_output_port_lookup_o<=tcam_data_in;
               `OPENFLOW_WILDCARD_LOOKUP_CMP_1_REG:data_output_port_lookup_o<=tcam_data_in;
               `OPENFLOW_WILDCARD_LOOKUP_CMP_2_REG:data_output_port_lookup_o<=tcam_data_in;
               default: data_output_port_lookup_o<=32'hdeadbeef;
            endcase
         else if(cur_st==COUNTER_ACK)
            case(addr_output_port_lookup_i[`ACTION_POS+`ACTION_WIDTH-1:`ACTION_POS])
               `OPENFLOW_WILDCARD_LOOKUP_BYTE_COUNTER:   data_output_port_lookup_o<=32'hdeadbeef;
               `OPENFLOW_WILDCARD_LOOKUP_PKT_COUNTER:    data_output_port_lookup_o<=32'hdeadbeef;
               default:data_output_port_lookup_o<=32'hdeadbeef;
            endcase
         else if(cur_st==HEAD)
            data_output_port_lookup_o<=head_combine;
         else if(cur_st==ACK_BLANK)
            data_output_port_lookup_o<=32'hdeadbeef;
end
`endif
         
    
    always@(*)
    if(reset)
        counter_addr_out=0;
    else if(cur_st==COUNTER)
        counter_addr_out=addr_output_port_lookup_i[`PRIO_POS+`PRIO_WIDTH-1:`PRIO_POS];
    else counter_addr_out=0;
    
    always@(*)
    if(reset)
      counter_addr_rd=0;
    else if(cur_st==COUNTER)
      counter_addr_rd=1;
    else counter_addr_rd=0;
    
    always@(posedge clk)
    if(reset)
      head_combine<=0;
    else if(cur_st==HEAD && rw_output_port_lookup_i==0)
      head_combine<=data_output_port_lookup_i[7:0];     
    /*always@(posedge clk)
    if(~rst)
    begin
      data_output_port_lookup_o<=0;
      addr_output_port_lookup_o<=0;
      req_output_port_lookup_o<=0;
      rw_output_port_lookup_0_o<=0;
      ack_output_port_lookup_o<=0;
    end
    else
    begin
      data_output_port_lookup_o<=data_output_port_lookup_i;
      addr_output_port_lookup_o<=addr_output_port_lookup_i;
      req_output_port_lookup_o<=req_output_port_lookup_i;
      rw_output_port_lookup_0_o<=rw_output_port_lookup_0_i;
      ack_output_port_lookup_o<=ack_output_port_lookup_i;   
    end   */
    
    
endmodule
