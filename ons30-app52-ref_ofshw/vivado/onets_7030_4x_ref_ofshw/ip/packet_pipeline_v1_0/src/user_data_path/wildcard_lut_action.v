///////////////////////////////////////////////////////////////////////////////
// $Id: unencoded_cam_lut_sm.v 5697 2009-06-17 22:32:11Z tyabe $
//
// Module: unencoded_cam_lut_sm.v
// Project: NF2.1
// Author: Jad Naous <jnaous@stanford.edu>
// Description: controls an unencoded muli-match cam and provides a LUT.
//  Matches data and provides reg access
//
//  The sizes of the compare input and the data to store in the LUT can be
//  specified either by number of words or by exact size. The benefit of the
//  first is that you don't have to calculate the exact number of words used
//  in the parent module, but then the granularity of your matches will be
//  in increments of `CPCI_NF2_DATA_WIDTH bits, which might or might not matter
///////////////////////////////////////////////////////////////////////////////

  module wildcard_lut_action
    #(
      parameter DATA_WIDTH = 32,
      parameter CMP_WIDTH = 64,
      parameter LUT_DEPTH  = 16,
      parameter LUT_DEPTH_BITS = 4,
      parameter CURRENT_TABLE_ID=0
      )
   (// --- Interface for lookups
    input                              lookup_req,
    input      [CMP_WIDTH-1:0]         lookup_cmp_data,
    output reg                         lookup_ack,
    output reg                         lookup_hit,
    output reg    [DATA_WIDTH-1:0]     lookup_data,
    output reg [LUT_DEPTH_BITS-1:0]    lookup_address,

    // --- CAM interface

    input                              cam_busy,
    input                              cam_match,
    input      [LUT_DEPTH_BITS-1:0]         cam_match_addr,
     output     [CMP_WIDTH-1:0]         cam_cmp_din,


    // --- Watchdog Timer Interface
    input                              table_flush,

    // --- Misc
    input                              reset,
    input                              clk,
    
    input                             skip_lookup,
    
    input bram_cs,
    input bram_we,
    input [`PRIO_WIDTH-1:0]bram_addr,
    input [319:0]lut_actions_in,  
    output [319:0]lut_actions_out
    
    
   );
    assign cam_cmp_din       = skip_lookup?0:lookup_cmp_data;
    reg [LUT_DEPTH_BITS-1:0] prio;
    //assign prio=reg_addr_prio[LUT_DEPTH_BITS-1:0];
   
    reg [`OPENFLOW_ACTION_WIDTH-1:0]    lut_actions[LUT_DEPTH-1:0];
    reg [`OPENFLOW_ACTION_WIDTH-1:0]    lut_actions_tmp;

    reg wea;
    reg ena;
    reg [3:0]addra;
   
   reg bram_cs_en;
   reg bram_we_en;
   reg [LUT_DEPTH_BITS-1:0]bram_addr_en;
   
    /*BRam 
    #(
       .width(`OPENFLOW_ACTION_WIDTH),
       .depth(LUT_DEPTH_BITS)
    )lut_action_bram
    (  .clk(clk),
       .cs(bram_cs_en),
       .we(bram_we_en),
       .addr(bram_addr_en),
       .din(lut_actions_in),
       .dout(lut_actions_out)
    );*/
        lut_action_bram lut_action_bram
        (  .clka(clk),
           .ena(bram_cs_en),
           .wea(bram_we_en),
           .addra(bram_addr_en),
           .dina(lut_actions_in),
           .douta(lut_actions_out)
        );
   
    reg [LUT_DEPTH_BITS-1:0]clear_counter;
 


   function integer log2;
      input integer number;
      begin
         log2=0;
         while(2**log2<number) begin
            log2=log2+1;
         end
      end
   endfunction // log2

   function integer ceildiv;
      input integer num;
      input integer divisor;
      begin
         if (num <= divisor)
            ceildiv = 1;
         else begin
            ceildiv = num / divisor;
            if (ceildiv * divisor < num)
               ceildiv = ceildiv + 1;
         end
      end
   endfunction 

   //-------------------- Internal Parameters ------------------------
   localparam NUM_DATA_WORDS_USED = ceildiv(DATA_WIDTH,`CPCI_NF2_DATA_WIDTH);
   localparam NUM_CMP_WORDS_USED  = ceildiv(CMP_WIDTH, `CPCI_NF2_DATA_WIDTH);
   localparam NUM_REGS_USED = (2 // for the read and write address registers
                               + NUM_DATA_WORDS_USED // for data associated with an entry
                               + NUM_CMP_WORDS_USED  // for the data to match on
                               + NUM_CMP_WORDS_USED);  // for the don't cares

   localparam READ_ADDR  = NUM_REGS_USED-2;
   
   localparam  WAIT=0,
               MATCH_BUSY=1,
               MATCH=2,
               MATCH_WAIT=3,
               DONE=4;


   reg [3:0]cur_st,nxt_st;   
   
   always@(posedge clk)
      if(reset)
         cur_st<=0;
      else cur_st<=nxt_st;
   always@(*)
   begin
      nxt_st=cur_st;
      case(cur_st)
            WAIT:   if(!cam_busy & lookup_req & !skip_lookup)
                        begin 
                            //if(cur_st==READY)  nxt_st=MATCH;
                            //else nxt_st=MATCH_BUSY;
                             nxt_st=MATCH;
                        end
                     else if(!cam_busy & lookup_req & skip_lookup)
                        nxt_st=DONE;
            MATCH_BUSY:nxt_st=WAIT;
            MATCH:  nxt_st=MATCH_WAIT;
            MATCH_WAIT:nxt_st=DONE;
            DONE:   nxt_st=WAIT;
            default:nxt_st=WAIT;    
        endcase
     end

     always@(posedge clk)
        if(reset)
            lookup_ack<=0;
        else if(cur_st==DONE)   
            lookup_ack<=1;
        else if(cur_st==MATCH_BUSY)
            lookup_ack<=1;
        else
            lookup_ack<=0;

     always@(posedge clk)
        if(reset)
            lookup_hit<=0;
        else if(cur_st==DONE)   
            lookup_hit<=cam_match;
        else if(MATCH_BUSY)
            lookup_hit<=0;
        else
            lookup_hit<=0;
            
      always@(posedge clk)
      if(reset)
         bram_cs_en<=0;
      //else if(bram_cs) bram_cs_en=1;
      else if(cur_st==MATCH)
         bram_cs_en<=1;
      else bram_cs_en<=bram_cs;
      
      always@(posedge clk)
      if(reset)
         bram_we_en<=0;
      //else if(bram_cs) bram_we_en=bram_we;
      else if(cur_st==MATCH)
         bram_we_en<=0;
      else bram_we_en<=bram_we;
      
      always@(posedge clk)
      if(reset)
         bram_addr_en<=0;
      //else if(bram_cs) bram_addr_en=bram_addr;
      else if(cur_st==MATCH)
         bram_addr_en<=cam_match_addr;
      else bram_addr_en<=bram_addr;

     always@(posedge clk)
        if(reset)
            lookup_data<=0;
        else
            lookup_data<=cam_match?lut_actions_out:0;
            
     always@(posedge clk)
        if(reset)
            lookup_address<=0;
        else if(cur_st==MATCH_BUSY)
            lookup_address<=0;
        else if(cur_st==DONE)   
            lookup_address<=cam_match?cam_match_addr:0;
        else lookup_address<=0;
            


/*
   //---------------------- Wires and regs----------------------------

   always @(*) begin
      cam_match_encoded_addr = LUT_DEPTH[LUT_DEPTH_BITS-1:0] - 1'b1;
      for (i = LUT_DEPTH-2; i >= 0; i = i-1) begin
         if (cam_match_unencoded_addr[i]) begin
            cam_match_encoded_addr = i[LUT_DEPTH_BITS-1:0];
         end
      end
   end

   always @(posedge clk) begin

      if(reset || table_flush) begin
         lookup_latched              <= 0;
         cam_match_found             <= 0;
         cam_lookup_done             <= 0;
         rd_req_latched              <= 0;
         lookup_ack                  <= 0;
         lookup_hit                  <= 0;
         cam_we                      <= 0;
         cam_wr_addr                 <= 0;
         cam_din                     <= 0;
         cam_data_mask               <= 0;
         wr_ack                      <= 0;
         rd_ack                      <= 0;
         state                       <= RESET;
         lookup_address              <= 0;
         reset_count                 <= 0;
         cam_match_unencoded_addr    <= 0;
         cam_match_encoded           <= 0;
         cam_match_found_d1          <= 0;
      end // if (reset)
      else begin

         // defaults
         lookup_latched     <= 0;
         cam_match_found    <= 0;
         cam_lookup_done    <= 0;
         rd_req_latched     <= 0;
         lookup_ack         <= 0;
         lookup_hit         <= 0;
         cam_we             <= 0;
         cam_din            <= 0;
         cam_data_mask      <= 0;
         wr_ack             <= 0;
         rd_ack             <= 0;

         if (state == RESET && !cam_busy) begin
            if(reset_count == LUT_DEPTH) begin
               state  <= READY;
               cam_we <= 1'b0;
            end
            else begin
               reset_count      <= reset_count + 1'b1;
               cam_we           <= 1'b1;
               cam_wr_addr      <= reset_count[LUT_DEPTH_BITS-1:0];
               cam_din          <= RESET_CMP_DATA;
               cam_data_mask    <= RESET_CMP_DMASK;
               lut_wr_data      <= RESET_DATA;
            end
         end

         else if (state == READY) begin

            lookup_latched              <= lookup_req;


            cam_match_found             <= lookup_latched & cam_match;
            cam_lookup_done             <= lookup_latched;
            cam_match_unencoded_addr    <= cam_match_addr;


            cam_match_encoded           <= cam_lookup_done;
            cam_match_found_d1          <= cam_match_found;
            lut_rd_addr                 <= (!cam_match_found && rd_req) ? rd_addr : cam_match_encoded_addr;
            rd_req_latched              <= (!cam_match_found && rd_req);


            lookup_ack                  <= cam_match_encoded;
            lookup_hit                  <= cam_match_found_d1;
            lut_rd_data                 <= lut[lut_rd_addr];
            lookup_address              <= lut_rd_addr;
            rd_ack                      <= rd_req_latched;


            if(wr_req & !cam_busy & !lookup_latched & !cam_match_found & !cam_match_found_d1) begin
               cam_we           <= 1;
               cam_wr_addr      <= wr_addr;
               cam_din          <= wr_cmp_data ;
               cam_data_mask    <= wr_cmp_dmask;
               wr_ack           <= 1;
               lut_wr_data      <= wr_data;
            end
            else begin
               cam_we <= 0;
               wr_ack <= 0;
            end // else: !if(wr_req & !cam_busy & !lookup_latched & !cam_match_found & !cam_match_found_d1)
         end // else: !if(state == RESET)

      end // else: !if(reset)

      // separate this out to allow implementation as BRAM

   end // always @ (posedge clk)*/

endmodule // cam_lut_sm


