
module tcam_parallel_matcher
#(
   parameter CMP_WIDTH = 32,
   parameter DEPTH = 32,
   parameter DEPTH_BITS = 5,
   parameter ENCODE = 0
)(
   input                            clk,
   input [2*DEPTH*CMP_WIDTH - 1 : 0]  lut_linear,
   input [CMP_WIDTH - 1 : 0]        cmp_din,
	input [CMP_WIDTH - 1 : 0]        cmp_data_mask,
   output                           busy,
   output                           match,
   output reg[DEPTH - 1 : 0]        match_addr,

   input                            we,
   input [DEPTH_BITS - 1 : 0]	      wr_addr,
   input [CMP_WIDTH - 1 : 0]        din,
	input [CMP_WIDTH - 1 : 0]        data_mask
);

   wire [DEPTH - 1 : 0]             match_addr_unencoded;
   reg [DEPTH - 1 : 0]              match_addr_unencoded_reg;
   wire [CMP_WIDTH - 1 : 0]         stage1[DEPTH - 1 : 0];
   wire [CMP_WIDTH - 1 : 0]         stage2[DEPTH - 1 : 0];
   wire [CMP_WIDTH - 1 : 0]         cam_data[DEPTH - 1 : 0];
   wire [CMP_WIDTH - 1 : 0]         cam_data_mask[DEPTH - 1 : 0];

   genvar n;
   generate 
      for(n = 0; n < DEPTH; n = n + 1) begin: lut_table
         assign cam_data[n] = lut_linear[n*2*CMP_WIDTH +:CMP_WIDTH];
         assign cam_data_mask[n] = lut_linear[n*2*CMP_WIDTH+CMP_WIDTH +:CMP_WIDTH];
      end
   endgenerate
   generate 
      for(n = 0; n < DEPTH; n = n + 1) begin : gen_cmp
         assign stage1[n] = cmp_din ^~ cam_data[n];
         assign stage2[n] = stage1[n] | cam_data_mask[n];
         assign match_addr_unencoded[n]= &stage2[n];
      end
   endgenerate
   
   always @(posedge clk)begin
      match_addr_unencoded_reg <= match_addr_unencoded;
   end
   
   generate 
      if(ENCODE == 1) begin
         /*encode the match address*/
         integer i;
         always @(*)begin
            match_addr = DEPTH[DEPTH_BITS - 1 : 0] - 1'b1;
            for(i = DEPTH - 2; i >= 0; i = i - 1)begin
               if(match_addr_unencoded_reg[i])begin
                  match_addr = i[DEPTH_BITS - 1 : 0];
               end
            end
         end  
      end
      else if(ENCODE == 0) begin
         always @(*)begin
            match_addr = match_addr_unencoded_reg;
         end
      end
   endgenerate

   assign busy = 0;
   assign match = | match_addr_unencoded_reg;
   
endmodule
