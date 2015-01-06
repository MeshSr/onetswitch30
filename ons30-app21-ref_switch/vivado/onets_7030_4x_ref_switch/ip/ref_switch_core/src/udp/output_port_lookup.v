///////////////////////////////////////////////////////////////////////////////
// vim:set shiftwidth=3 softtabstop=3 expandtab:
// $Id: output_port_lookup.v 5240 2009-03-14 01:50:42Z grg $
//
// Module: switch_output_port.v
// Project: NF2.1
// Description: reads incoming packets parses them and decides on the output port
//  and adds it as a header. The design of this module assumes that only one eop
//  will be in the pipeline of this module at any given time.
//  i.e. we assume pkt length incl pkt and module headers >= 8*DATA_WIDTH bits
//  for a 64 bit datapath, this is 64 bytes.
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
  module output_port_lookup
    #(parameter DATA_WIDTH = 64,
      parameter CTRL_WIDTH=DATA_WIDTH/8,
      parameter UDP_REG_SRC_WIDTH = 2,
      parameter INPUT_ARBITER_STAGE_NUM = 2,
      parameter NUM_OUTPUT_QUEUES = 8,
      parameter STAGE_NUM = 4,
      parameter NUM_IQ_BITS = 3)

   (// --- data path interface
    output reg [DATA_WIDTH-1:0]        out_data,
    output reg [CTRL_WIDTH-1:0]        out_ctrl,
    output reg                         out_wr,
    input                              out_rdy,

    input  [DATA_WIDTH-1:0]            in_data,
    input  [CTRL_WIDTH-1:0]            in_ctrl,
    input                              in_wr,
    output                             in_rdy,

    // --- Register interface
    input                              reg_req_in,
    input                              reg_ack_in,
    input                              reg_rd_wr_L_in,
    input  [`UDP_REG_ADDR_WIDTH-1:0]   reg_addr_in,
    input  [`CPCI_NF2_DATA_WIDTH-1:0]  reg_data_in,
    input  [UDP_REG_SRC_WIDTH-1:0]     reg_src_in,

    output                             reg_req_out,
    output                             reg_ack_out,
    output                             reg_rd_wr_L_out,
    output  [`UDP_REG_ADDR_WIDTH-1:0]  reg_addr_out,
    output  [`CPCI_NF2_DATA_WIDTH-1:0] reg_data_out,
    output  [UDP_REG_SRC_WIDTH-1:0]    reg_src_out,


    // --- Misc
    input                              clk,
    input                              reset);

   function integer log2;
      input integer number;
      begin
         log2=0;
         while(2**log2<number) begin
            log2=log2+1;
         end
      end
   endfunction // log2

   //--------------------- Internal Parameter-------------------------
   parameter LUT_DEPTH_BITS = 4;
   parameter DEFAULT_MISS_OUTPUT_PORTS = 8'b01010101; // exclude the CPU queues

   parameter NUM_STATES = 4;
   parameter WAIT_TILL_DONE_DECODE = 1;
   parameter WRITE_HDR             = 2;
   parameter SKIP_HDRS             = 4;
   parameter WAIT_EOP              = 8;

   //---------------------- Wires and regs----------------------------

   wire                         lookup_ack;
   wire [47:0]                  dst_mac;
   wire [47:0]                  src_mac;
   wire [15:0]                  ethertype;
   wire [NUM_IQ_BITS-1:0]       src_port;
   wire                         eth_done;
   wire [NUM_OUTPUT_QUEUES-1:0] dst_ports;
   wire [NUM_OUTPUT_QUEUES-1:0] dst_ports_latched;

   wire [LUT_DEPTH_BITS-1:0]    rd_addr;          // address in table to read
   wire                         rd_req;           // request a read
   wire [NUM_OUTPUT_QUEUES-1:0] rd_oq;            // data read from the LUT at rd_addr
   wire                         rd_wr_protect;    // wr_protect bit read
   wire [47:0]                  rd_mac;           // data to match in the CAM
   wire                         rd_ack;           // pulses high when data is rdy

   wire [LUT_DEPTH_BITS-1:0]    wr_addr;
   wire                         wr_req;
   wire [NUM_OUTPUT_QUEUES-1:0] wr_oq;
   wire                         wr_protect;       // wr_protect bit to write
   wire [47:0]                  wr_mac;           // data to match in the CAM
   wire                         wr_ack;           // pulses high when wr is done

   wire                         lut_hit;          // pulses high on a hit
   wire                         lut_miss;         // pulses high on a miss

   reg                          in_fifo_rd_en;
   wire [CTRL_WIDTH-1:0]        in_fifo_ctrl_dout;
   wire [DATA_WIDTH-1:0]        in_fifo_data_dout;
   wire                         in_fifo_nearly_full;
   wire                         in_fifo_empty;

   reg                          dst_port_rd;
   wire                         dst_port_fifo_nearly_full;
   wire                         dst_port_fifo_empty;

   reg [NUM_STATES-1:0]         state, state_next;

   //------------------------- Modules-------------------------------
   ethernet_parser
     #(.DATA_WIDTH (DATA_WIDTH),
       .CTRL_WIDTH (CTRL_WIDTH),
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

   mac_cam_lut
     #(.NUM_OUTPUT_QUEUES(NUM_OUTPUT_QUEUES),
       .LUT_DEPTH_BITS(LUT_DEPTH_BITS),
       .NUM_IQ_BITS(NUM_IQ_BITS),
       .DEFAULT_MISS_OUTPUT_PORTS(DEFAULT_MISS_OUTPUT_PORTS))
   mac_cam_lut
     // --- lookup and learn port
     (.dst_mac (dst_mac),
      .src_mac (src_mac),
      .src_port (src_port),
      .lookup_req (eth_done),
      .dst_ports (dst_ports),
      .lookup_ack (lookup_ack),

      // --- direct access ports
      // --- Read port
      .rd_addr (rd_addr),          // address in table to read
      .rd_req (rd_req),           // request a read
      .rd_oq (rd_oq),            // data read from the LUT at rd_addr
      .rd_wr_protect (rd_wr_protect),    // wr_protect bit read
      .rd_mac (rd_mac),    // data to match in the CAM
      .rd_ack (rd_ack),           // stays high when data is rdy until req goes low

      // --- Write port
      .wr_addr (wr_addr),
      .wr_req (wr_req),
      .wr_oq (wr_oq),
      .wr_protect (wr_protect),       // wr_protect bit to write
      .wr_mac (wr_mac),    // data to match in the CAM
      .wr_ack (wr_ack),

      // --- Register signals
      .lut_hit (lut_hit),          // pulses high on a hit
      .lut_miss (lut_miss),         // pulses high on a miss

      // --- Misc
      .clk (clk),
      .reset (reset));

   /* The size of this fifo has to be large enough to fit the previous modules' headers
    * and the ethernet header */
   small_fifo #(.WIDTH(DATA_WIDTH+CTRL_WIDTH), .MAX_DEPTH_BITS(4))
      input_fifo
        (.din ({in_ctrl,in_data}),     // Data in
         .wr_en (in_wr),               // Write enable
         .rd_en (in_fifo_rd_en),       // Read the next word
         .dout ({in_fifo_ctrl_dout, in_fifo_data_dout}),
         .full (),
         .prog_full (),
         .nearly_full (in_fifo_nearly_full),
         .empty (in_fifo_empty),
         .reset (reset),
         .clk (clk)
         );

   small_fifo #(.WIDTH(NUM_OUTPUT_QUEUES), .MAX_DEPTH_BITS(2))
      dst_port_fifo
        (.din (dst_ports),     // Data in
         .wr_en (lut_hit|lut_miss),             // Write enable
         .rd_en (dst_port_rd),       // Read the next word
         .dout (dst_ports_latched),
         .full (),
         .prog_full (),
         .nearly_full (dst_port_fifo_nearly_full),
         .empty (dst_port_fifo_empty),
         .reset (reset),
         .clk (clk)
         );


   op_lut_regs
     #( .NUM_OUTPUT_QUEUES(NUM_OUTPUT_QUEUES),
        .LUT_DEPTH_BITS(LUT_DEPTH_BITS),
        .UDP_REG_SRC_WIDTH(UDP_REG_SRC_WIDTH))
     op_lut_regs
     (
      // Registers
      .reg_req_in       (reg_req_in),
      .reg_ack_in       (reg_ack_in),
      .reg_rd_wr_L_in   (reg_rd_wr_L_in),
      .reg_addr_in      (reg_addr_in),
      .reg_data_in      (reg_data_in),
      .reg_src_in       (reg_src_in),

      .reg_req_out      (reg_req_out),
      .reg_ack_out      (reg_ack_out),
      .reg_rd_wr_L_out  (reg_rd_wr_L_out),
      .reg_addr_out     (reg_addr_out),
      .reg_data_out     (reg_data_out),
      .reg_src_out      (reg_src_out),

      // Outputs
      .rd_addr                          (rd_addr),
      .rd_req                           (rd_req),
      .wr_addr                          (wr_addr),
      .wr_req                           (wr_req),
      .wr_oq                            (wr_oq),
      .wr_protect                       (wr_protect),
      .wr_mac                           (wr_mac),
      // Inputs
      .rd_oq                            (rd_oq),
      .rd_wr_protect                    (rd_wr_protect),
      .rd_mac                           (rd_mac),
      .rd_ack                           (rd_ack),
      .wr_ack                           (wr_ack),
      .lut_hit                          (lut_hit),
      .lut_miss                         (lut_miss),
      .clk                              (clk),
      .reset                            (reset));

   //----------------------- Logic -----------------------------

   assign    in_rdy = !in_fifo_nearly_full && !dst_port_fifo_nearly_full;

   /*********************************************************************
    * Wait until the ethernet header has been decoded and the output
    * port is found, then write the module header and move the packet
    * to the output
    **********************************************************************/
   always @(*) begin
      out_ctrl = in_fifo_ctrl_dout;
      out_data = in_fifo_data_dout;
      state_next = state;
      out_wr = 0;
      in_fifo_rd_en = 0;
      dst_port_rd = 0;

      case(state)
        WAIT_TILL_DONE_DECODE: begin
           if(!dst_port_fifo_empty) begin
              dst_port_rd     = 1;
              state_next      = WRITE_HDR;
              in_fifo_rd_en   = 1;
           end
        end

        /* write Destionation output ports */
        WRITE_HDR: begin
           if(out_rdy) begin
              if(in_fifo_ctrl_dout==`IO_QUEUE_STAGE_NUM) begin
                 out_data[`IOQ_DST_PORT_POS + NUM_OUTPUT_QUEUES - 1:`IOQ_DST_PORT_POS] = dst_ports_latched;
              end
              out_wr          = 1;
              in_fifo_rd_en   = 1;
              state_next      = SKIP_HDRS;
           end
        end

        /* Skip the rest of the headers */
        SKIP_HDRS: begin
           if(in_fifo_ctrl_dout==0) begin
              state_next = WAIT_EOP;
           end
           if(!in_fifo_empty & out_rdy) begin
              in_fifo_rd_en   = 1;
              out_wr          = 1;
           end
        end

        /* write all data */
        WAIT_EOP: begin
           if(in_fifo_ctrl_dout!=0)begin
              if(out_rdy) begin
                 state_next   = WAIT_TILL_DONE_DECODE;
                 out_wr       = 1;
              end
           end
           else if(!in_fifo_empty & out_rdy) begin
              in_fifo_rd_en   = 1;
              out_wr          = 1;
           end
        end // case: WAIT_EOP

      endcase // case(state)
   end // always @ (*)

   always @(posedge clk) begin
      if(reset) begin
         state <= WAIT_TILL_DONE_DECODE;
      end
      else begin
         state <= state_next;
      end
   end
endmodule // switch_output_port

