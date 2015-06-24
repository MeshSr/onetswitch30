
module wildcard_tcam
#(
   parameter CMP_WIDTH = 32,
   parameter DEPTH = 32,
   parameter DEPTH_BITS = 5,
   parameter ENCODE = 0,
   parameter CURRENT_TABLE_ID = 0
)(
   input                            clk,
   input                            reset,

   input [CMP_WIDTH - 1 : 0]        cmp_din,
   output                           busy,
   output                           match,
   output  reg [DEPTH_BITS - 1 : 0]        match_addr,
   input                            cmp_req,
//   output reg[DEPTH - 1 : 0]        match_addr,

   input we,
   input [`PRIO_WIDTH -1:0] tcam_addr,
   output reg [CMP_WIDTH-1:0]tcam_data_out, 
   output reg [CMP_WIDTH-33:0] tcam_data_mask_out,
   input [CMP_WIDTH-1:0]tcam_data_in,
   input [CMP_WIDTH-33:0]tcam_data_mask_in
   /*input [CMP_WIDTH-1:0]tcam_data_in,
   input [CMP_WIDTH-33:0]tcam_data_mask_in*/
);

   wire [DEPTH - 1 : 0]             match_addr_unencoded;
   reg [DEPTH - 1 : 0]              match_addr_unencoded_reg;
   wire [CMP_WIDTH - 1 : 0]         stage1[DEPTH - 1 : 0];
   wire [CMP_WIDTH - 1 : 0]         stage2[DEPTH - 1 : 0];
   reg [CMP_WIDTH - 1 : 0]         cam_data[DEPTH - 1 : 0];
   reg [CMP_WIDTH - 33 : 0]         cam_data_mask[DEPTH - 1 : 0];
    
   reg [DEPTH_BITS-1:0] prio;
   wire [DEPTH - 1 : 0]         match_addr_tmp;
   reg [7:0]                    reg_addr_actions_d;
   reg [7:0]                     clear_count;
   
   always@(*)
   if(tcam_addr < DEPTH)
   begin
         tcam_data_mask_out=cam_data_mask[tcam_addr]   ;
         tcam_data_out=cam_data[tcam_addr]  ;
   end
   else begin
      tcam_data_mask_out=0;
      tcam_data_out=0;
   end

      
      always@(posedge clk)
      if(reset)
         clear_count<=0;
      else if(clear_count==DEPTH)
         clear_count<=clear_count;
      else clear_count<=clear_count+1;
      
      always@(posedge clk)
      if(clear_count<DEPTH)
      begin
         cam_data[clear_count][CMP_WIDTH-1]<=1;
         cam_data[clear_count][CMP_WIDTH-2:0]<=0;
         cam_data_mask[clear_count]<=0;
      end
      else if(we)
            begin
              /*if(CMP_WIDTH<=32)
                       case(tcam_addr[`ACTION_POS+`ACTION_WIDTH-1:`ACTION_POS] )
                          `OPENFLOW_WILDCARD_LOOKUP_CMP_MASK_0_REG:cam_data_mask[tcam_addr[7+DEPTH_BITS:8]][CMP_WIDTH-1:0] <=tcam_data_in;
                          `OPENFLOW_WILDCARD_LOOKUP_CMP_0_REG:cam_data[tcam_addr[7+DEPTH_BITS:8]][CMP_WIDTH-1:0] <=tcam_data_in; 
                       endcase  
              else if(CMP_WIDTH<=64)
                      case(tcam_addr[`ACTION_POS+`ACTION_WIDTH-1:`ACTION_POS] )
                          `OPENFLOW_WILDCARD_LOOKUP_CMP_MASK_0_REG:cam_data_mask[tcam_addr[7+DEPTH_BITS:8]][31:0] <=tcam_data_in;
                          //`OPENFLOW_WILDCARD_LOOKUP_CMP_MASK_1_REG:cam_data_mask[tcam_addr[7+DEPTH_BITS:8]][CMP_WIDTH-1:32]<=tcam_data_in;
                          `OPENFLOW_WILDCARD_LOOKUP_CMP_0_REG:cam_data[tcam_addr[7+DEPTH_BITS:8]][31:0] <=tcam_data_in; 
                          `OPENFLOW_WILDCARD_LOOKUP_CMP_1_REG:cam_data[tcam_addr[7+DEPTH_BITS:8]][CMP_WIDTH-1:32]<=tcam_data_in; 
                       endcase  
              else if(CMP_WIDTH<=96)*/
               /*case(tcam_addr[`ACTION_POS+`ACTION_WIDTH-1:`ACTION_POS] )
                  `OPENFLOW_WILDCARD_LOOKUP_CMP_MASK_0_REG:cam_data_mask[tcam_addr[7+DEPTH_BITS:8]][31:0] <=tcam_data_in;
                  `OPENFLOW_WILDCARD_LOOKUP_CMP_MASK_1_REG:cam_data_mask[tcam_addr[7+DEPTH_BITS:8]][63:32]<=tcam_data_in;
                  //`OPENFLOW_WILDCARD_LOOKUP_CMP_MASK_2_REG:cam_data_mask[tcam_addr[7+DEPTH_BITS:8]][CMP_WIDTH-1:64]<=tcam_data_in;
                  `OPENFLOW_WILDCARD_LOOKUP_CMP_0_REG:cam_data[tcam_addr[7+DEPTH_BITS:8]][31:0] <=tcam_data_in; 
                  `OPENFLOW_WILDCARD_LOOKUP_CMP_1_REG:cam_data[tcam_addr[7+DEPTH_BITS:8]][63:32]<=tcam_data_in; 
                  `OPENFLOW_WILDCARD_LOOKUP_CMP_2_REG:cam_data[tcam_addr[7+DEPTH_BITS:8]][CMP_WIDTH-1:64]<=tcam_data_in; */
                  cam_data_mask[tcam_addr] <= tcam_data_mask_in;
                  cam_data[tcam_addr] <= tcam_data_in;
               //endcase  
            end     
////////////////////////////////////    CMP_DATA    /////////////////////////////////////////

                     
/*    always@(*)
        if(reset) cam_data_tmp[31:0]=0;
        else if(cur_st==WRITE_PRE) cam_data_tmp[31:0]=cam_data[prio][31:0];
        else if(cur_st==WRITE && reg_addr_actions==8'h30) cam_data_tmp[31:0]=reg_data;
        else cam_data_tmp[31:0]=cam_data_tmp[31:0];
    
    always@(*)
        if(reset) cam_data_tmp[63:32]=0;
        else if(cur_st==WRITE_PRE) cam_data_tmp[63:32]=cam_data[prio][63:32];
        else if(cur_st==WRITE && reg_addr_actions==8'h34) cam_data_tmp[63:32]=reg_data;
        else cam_data_tmp[63:32]=cam_data_tmp[63:32];

    always@(*)
        if(reset) cam_data_tmp[95:64]=0;
        else if(cur_st==WRITE_PRE) cam_data_tmp[95:64]=cam_data[prio][95:64];
        else if(cur_st==WRITE && reg_addr_actions==8'h38) cam_data_tmp[95:64]=reg_data;
        else cam_data_tmp[95:64]=cam_data_tmp[95:64];

    always@(*)
        if(reset) cam_data_mask_tmp[31:0]=0;
        else if(cur_st==WRITE_PRE) cam_data_mask_tmp[31:0]=cam_data_mask[prio][31:0];
        else if(cur_st==WRITE && reg_addr_actions==8'h40) cam_data_mask_tmp[31:0]=reg_data;
        else cam_data_mask_tmp[31:0]=cam_data_mask_tmp[31:0];
    
    always@(*)
        if(reset) cam_data_mask_tmp[63:32]=0;
        else if(cur_st==WRITE_PRE) cam_data_mask_tmp[63:32]=cam_data_mask[prio][63:32];
        else if(cur_st==WRITE && reg_addr_actions==8'h44) cam_data_mask_tmp[31:0]=reg_data;
        else cam_data_mask_tmp[63:32]=cam_data_mask_tmp[63:32];

    always@(*)
        if(reset) cam_data_mask_tmp[95:64]=0;
        else if(cur_st==WRITE_PRE) cam_data_mask_tmp[95:64]=cam_data_mask[prio][95:64];
        else if(cur_st==WRITE && reg_addr_actions==8'h48) cam_data_mask_tmp[95:64]=reg_data;
        else cam_data_mask_tmp[95:64]=cam_data_mask_tmp[95:64];*/

////////////////////////////////////////////////////////////////////////////////////////////////
   reg [CMP_WIDTH - 1 : 0]        cmp_din_reg;
   always@(posedge clk)
   if(reset)
      cmp_din_reg<=0;
   else if(cmp_req)
      cmp_din_reg<=cmp_din;
   
      genvar n;
      generate 
         for(n = DEPTH-1; n >= 0; n = n - 1) begin : gen_cmp
            assign stage1[n] = cmp_din_reg ^ ~cam_data[n];
            assign stage2[n] = stage1[n] | cam_data_mask[n];
            assign match_addr_tmp[n]=&stage2[n];
         end
      endgenerate
      
   integer                               i;      
         always @(*) 
         begin match_addr=0;
         if(|match_addr_tmp)
         begin
            for (i = 0; i <= DEPTH-1; i = i+1) begin
               if (match_addr_tmp[i]) 
                  match_addr = i[DEPTH_BITS-1:0];
               /*case(1)
                  match_addr_tmp[i]:match_addr = i[DEPTH_BITS-1:0];
                  //default:match_addr = 0;
               endcase*/
            end
         end     
         end    
  
  reg cmp_req_d1;
  reg cmp_req_d2;
  reg cmp_req_d3;
  
    always@(posedge clk)
    if(reset)
    begin
      cmp_req_d1<=0;
      cmp_req_d2<=0;
      cmp_req_d3<=0;
    end
    else
    begin
        cmp_req_d1<=cmp_req;
        cmp_req_d2<=cmp_req_d1;
        cmp_req_d3<=cmp_req_d2;
    end
              
   assign busy = 0;
   assign match = (| match_addr_tmp) && cmp_req_d3;
   
endmodule

