
module udp_reg_path_decode (
   input                reg_req,
   input                reg_rd_wr_L,
   input [31:0]         reg_addr,
   input [31:0]         reg_wr_data,
   
   output reg           reg_ack,
   output reg [31:0]    reg_rd_data,

   // interface to core registers
   output reg           core_reg_req,
   output reg           core_reg_rd_wr_L,
   output reg [31:0]    core_reg_addr,
   output reg [31:0]    core_reg_wr_data,

   input                core_reg_ack,
   input [31:0]         core_reg_rd_data,

   // interface to user data path
   output reg           udp_reg_req,
   output reg           udp_reg_rd_wr_L,
   output reg [31:0]    udp_reg_addr,
   output reg [31:0]    udp_reg_wr_data,

   input                udp_reg_ack,
   input [31:0]         udp_reg_rd_data,


   input                clk,
   input                reset
);
   always @(posedge clk) begin

      if(reset) begin
         reg_ack <= 1'b0;
         reg_rd_data <= 32'h0;

         core_reg_req <= 1'b0;
         core_reg_rd_wr_L <= 1'b1;
         core_reg_addr <= 31'h0;
         core_reg_wr_data <= 31'h0;

         udp_reg_req <= 1'b0;
         udp_reg_rd_wr_L <= 1'b1;
         udp_reg_addr <= 31'h0;
         udp_reg_wr_data <= 31'h0;
      end
      else begin
         casez (reg_addr[26:24])
           3'b000: begin
              reg_ack <= core_reg_ack;
              reg_rd_data <= core_reg_rd_data;

              core_reg_req <= reg_req;
              core_reg_rd_wr_L <= reg_rd_wr_L;
              core_reg_addr <= reg_addr[31:2];
              core_reg_wr_data <= reg_wr_data;
           end

           3'b01?: begin
              reg_ack <= udp_reg_ack;
              reg_rd_data <= udp_reg_rd_data;

              udp_reg_req <= reg_req;
              udp_reg_rd_wr_L <= reg_rd_wr_L;
              udp_reg_addr <= reg_addr[31:2];
              udp_reg_wr_data <= reg_wr_data;
           end
           
           default: begin
              reg_ack <= reg_req;
              reg_rd_data <= 32'h DEAD_BEEF;
           end 
         endcase
      end

   end

endmodule 
