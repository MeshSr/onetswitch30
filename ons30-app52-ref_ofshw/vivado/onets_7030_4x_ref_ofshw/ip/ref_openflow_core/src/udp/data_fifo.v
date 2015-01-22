///////////////////////////////////////////////////////////////////////////////
// $Id: small_fifo.v 4761 2008-12-27 01:11:00Z jnaous $
//
// Module: small_fifo.v
// Project: UNET
// Description: small fifo with no fallthrough i.e. data valid after rd is high
//
// Change history:
//   7/20/07 -- Set nearly full to 2^MAX_DEPTH_BITS - 1 by default so that it
//              goes high a clock cycle early.
//   11/2/09 -- Modified to have both prog threshold and almost full
///////////////////////////////////////////////////////////////////////////////
//suppose the one packet length smaller than 2048byte,when almost full is asserted,the fifo still can accept a full packet,than depth mast bigger than 256
`timescale 1ns/1ps
//almost full depth 8
  module data_fifo
    #(parameter WIDTH = 72,
      parameter FIFO_DEPTH = 256,
      parameter PROG_FULL_THRESHOLD = 8
      )
    (

     input [WIDTH-1:0] din,     // Data in
     input          wr_en,   // Write enable

     input          rd_en,   // Read the next word

     output reg [WIDTH-1:0]  dout,    // Data out
     output         full,
     output         nearly_full,
     output         prog_full,
     output         empty,
     output [5:0]      data_count,

     input          reset,
     input          clk
     );




reg [WIDTH-1:0] queue [256 : 0];
reg [7 : 0] rd_ptr;
reg [7 : 0] wr_ptr;
reg [7 : 0] depth;

// Sample the data
always @(posedge clk)
begin
   if (wr_en)
      queue[wr_ptr] <= din;
   if (rd_en)
      dout <=
	      // synthesis translate_off
	      #1
	      // synthesis translate_on
	      queue[rd_ptr];
end

always @(posedge clk)
begin
   if (reset) begin
      rd_ptr <= 'h0;
      wr_ptr <= 'h0;
      depth  <= 'h0;
   end
   else begin
      if (wr_en) wr_ptr <= wr_ptr + 'h1;
      if (rd_en) rd_ptr <= rd_ptr + 'h1;
      if (wr_en & ~rd_en) depth <=
				   // synthesis translate_off
				   #1
				   // synthesis translate_on
				   depth + 'h1;
      else if (~wr_en & rd_en) depth <=
				   // synthesis translate_off
				   #1
				   // synthesis translate_on
				   depth - 'h1;
   end
end

//assign dout = queue[rd_ptr];
assign full = depth == 255;
assign prog_full = (depth >= PROG_FULL_THRESHOLD);
assign nearly_full = depth >= 7;
assign empty = depth == 'h0;
assign data_count = depth;

// synthesis translate_off
always @(posedge clk)
begin
   if (wr_en && depth == 255 && !rd_en)
      $display($time, " ERROR: Attempt to write to full FIFO: %m");
   if (rd_en && depth == 'h0)
      $display($time, " ERROR: Attempt to read an empty FIFO: %m");
end
// synthesis translate_on

endmodule // small_fifo


/* vim:set shiftwidth=3 softtabstop=3 expandtab: */
