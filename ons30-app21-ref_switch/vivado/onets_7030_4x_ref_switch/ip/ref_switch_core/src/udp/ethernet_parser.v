///////////////////////////////////////////////////////////////////////////////
// $Id: ethernet_parser.v 1976 2007-07-20 00:59:57Z grg $
//
// Module: ethernet_parser.v
// Project: NF2.1
// Description: parses the Ethernet header for a 32 or 64 bit datapath
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
  module ethernet_parser
    #(parameter DATA_WIDTH = 64,
      parameter CTRL_WIDTH=DATA_WIDTH/8,
      parameter NUM_IQ_BITS = 3,
      parameter INPUT_ARBITER_STAGE_NUM = 2
      )
   (// --- Interface to the previous stage
    input  [DATA_WIDTH-1:0]            in_data,
    input  [CTRL_WIDTH-1:0]            in_ctrl,
    input                              in_wr,

    // --- Interface to output_port_lookup
    output [47:0]                      dst_mac,
    output [47:0]                      src_mac,
    output [15:0]                      ethertype,
    output                             eth_done,
    output [NUM_IQ_BITS-1:0]           src_port,

    // --- Misc

    input                              reset,
    input                              clk
   );

   generate
   genvar i;
   if(DATA_WIDTH==64) begin: eth_parser_64bit
      ethernet_parser_64bit
	#(
	  .NUM_IQ_BITS(NUM_IQ_BITS),
	  .INPUT_ARBITER_STAGE_NUM(INPUT_ARBITER_STAGE_NUM))
         eth_parser
	   (.in_data(in_data),
	    .in_ctrl(in_ctrl),
	    .in_wr(in_wr),
	    .dst_mac (dst_mac),
	    .src_mac(src_mac),
	    .ethertype (ethertype),
	    .eth_done (eth_done),
	    .src_port(src_port),
	    .reset(reset),
	    .clk(clk));
   end // block: eth_parser_64bit
   else if(DATA_WIDTH==32) begin: eth_parser_32bit
      ethernet_parser_32bit
	#(
	  .NUM_IQ_BITS(NUM_IQ_BITS),
	  .INPUT_ARBITER_STAGE_NUM(INPUT_ARBITER_STAGE_NUM))
         eth_parser
	   (.in_data(in_data),
	    .in_ctrl(in_ctrl),
	    .in_wr(in_wr),
	    .dst_mac (dst_mac),
	    .src_mac(src_mac),
	    .ethertype (ethertype),
	    .eth_done (eth_done),
	    .src_port(src_port),
	    .reset(reset),
	    .clk(clk));
   end // block: eth_parser_32bit
   endgenerate



endmodule // ethernet_parser_64bit
