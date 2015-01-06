 
`define IOQ_BYTE_LEN_POS      0
`define IOQ_SRC_PORT_POS      16
`define IOQ_WORD_LEN_POS      32
`define IOQ_DST_PORT_POS      48

`define IO_QUEUE_STAGE_NUM    8'hff

//Register address space decode
`define CORE_REG_ADDR_WIDTH   22
`define UDP_REG_ADDR_WIDTH    23



`define MAC_QUEUE_0_BLOCK_ADDR  4'h8
`define MAC_QUEUE_1_BLOCK_ADDR  4'h9
`define MAC_QUEUE_2_BLOCK_ADDR  4'ha
`define MAC_QUEUE_3_BLOCK_ADDR  4'hb
`define CPU_QUEUE_0_BLOCK_ADDR  4'hc
`define CPU_QUEUE_1_BLOCK_ADDR  4'hd
`define CPU_QUEUE_2_BLOCK_ADDR  4'he
`define CPU_QUEUE_3_BLOCK_ADDR  4'hf

`define CPCI_NF2_DATA_WIDTH                 32
// --- Define address ranges
// 4 bits to identify blocks of size 64k words
`define BLOCK_SIZE_64k_BLOCK_ADDR_WIDTH   4
`define BLOCK_SIZE_64k_REG_ADDR_WIDTH     16

// 2 bits to identify blocks of size 1M words
`define BLOCK_SIZE_1M_BLOCK_ADDR_WIDTH  2
`define BLOCK_SIZE_1M_REG_ADDR_WIDTH    20

// 1 bit to identify blocks of size 4M words
`define BLOCK_SIZE_4M_BLOCK_ADDR_WIDTH  1
`define BLOCK_SIZE_4M_REG_ADDR_WIDTH    22

// 1 bit to identify blocks of size 8M words
`define BLOCK_SIZE_8M_BLOCK_ADDR_WIDTH  1
`define BLOCK_SIZE_8M_REG_ADDR_WIDTH    23

// 1 bit to identify blocks of size 16M words
`define BLOCK_SIZE_16M_BLOCK_ADDR_WIDTH  1
`define BLOCK_SIZE_16M_REG_ADDR_WIDTH    24

// Extract a word of width "width" from a flat bus
`define WORD(word, width)    (word) * (width) +: (width)
//
`define REG_END(addr_num)   `CPCI_NF2_DATA_WIDTH*((addr_num)+1)-1
`define REG_START(addr_num) `CPCI_NF2_DATA_WIDTH*(addr_num)
//------------------------------------------------
//Registers defination
//------------------------------------------------
// ethernet control register defination
// TX queue disable bit
`define MAC_GRP_TX_QUEUE_DISABLE_BIT_NUM    0
// RX queue disable bit
`define MAC_GRP_RX_QUEUE_DISABLE_BIT_NUM    1
// Reset MAC bit
`define MAC_GRP_RESET_MAC_BIT_NUM           2
// MAC TX queue disable bit
`define MAC_GRP_MAC_DISABLE_TX_BIT_NUM      3
// MAC RX queue disable bit
`define MAC_GRP_MAC_DISABLE_RX_BIT_NUM      4
// MAC disable jumbo TX bit
`define MAC_GRP_MAC_DIS_JUMBO_TX_BIT_NUM    5
// MAC disable jumbo RX bit
`define MAC_GRP_MAC_DIS_JUMBO_RX_BIT_NUM    6
// MAC disable crc check disable bit
`define MAC_GRP_MAC_DIS_CRC_CHECK_BIT_NUM   7
// MAC disable crc generate bit
`define MAC_GRP_MAC_DIS_CRC_GEN_BIT_NUM     8
//------------------------------------------------
//eth_queue
//------------------------------------------------
`define MAC_GRP_REG_ADDR_WIDTH      16
`define MAC_GRP_CONTROL                         16'h0
`define MAC_GRP_RX_QUEUE_NUM_PKTS_IN_QUEUE      16'h1
`define MAC_GRP_RX_QUEUE_NUM_PKTS_STORED        16'h2
`define MAC_GRP_RX_QUEUE_NUM_PKTS_DROPPED_FULL  16'h3
`define MAC_GRP_RX_QUEUE_NUM_PKTS_DROPPED_BAD   16'h4
`define MAC_GRP_RX_QUEUE_NUM_PKTS_DEQUEUED      16'h5
`define MAC_GRP_RX_QUEUE_NUM_WORDS_PUSHED       16'h6
`define MAC_GRP_RX_QUEUE_NUM_BYTES_PUSHED       16'h7
`define MAC_GRP_TX_QUEUE_NUM_PKTS_IN_QUEUE      16'h8
`define MAC_GRP_TX_QUEUE_NUM_PKTS_ENQUEUED      16'h9
`define MAC_GRP_TX_QUEUE_NUM_PKTS_SENT          16'ha
`define MAC_GRP_TX_QUEUE_NUM_WORDS_PUSHED       16'hb
`define MAC_GRP_TX_QUEUE_NUM_BYTES_PUSHED       16'hc

//------------------------------------------------
//input arbiter
//------------------------------------------------
`define IN_ARB_BLOCK_ADDR_WIDTH                    17
`define IN_ARB_REG_ADDR_WIDTH                      6
`define IN_ARB_BLOCK_ADDR                          17'h00000
`define IN_ARB_NUM_PKTS_SENT       6'h0
`define IN_ARB_LAST_PKT_WORD_0_HI  6'h1
`define IN_ARB_LAST_PKT_WORD_0_LO  6'h2
`define IN_ARB_LAST_PKT_CTRL_0     6'h3
`define IN_ARB_LAST_PKT_WORD_1_HI  6'h4
`define IN_ARB_LAST_PKT_WORD_1_LO  6'h5
`define IN_ARB_LAST_PKT_CTRL_1     6'h6
`define IN_ARB_STATE               6'h7

//-------------------------------------------------
//reference_switch
//-------------------------------------------------
`define SWITCH_OP_LUT_BLOCK_ADDR_WIDTH  17
`define SWITCH_OP_LUT_REG_ADDR_WIDTH    6
`define SWITCH_OP_LUT_BLOCK_ADDR  17'h00001

`define SWITCH_OP_LUT_PORTS_MAC_HI     6'h0

`define SWITCH_OP_LUT_MAC_LO           6'h1
`define SWITCH_OP_LUT_NUM_HITS         6'h2
`define SWITCH_OP_LUT_NUM_MISSES       6'h3
`define SWITCH_OP_LUT_MAC_LUT_RD_ADDR  6'h4
`define SWITCH_OP_LUT_MAC_LUT_WR_ADDR  6'h5

 /* Common Functions */
`define LOG2_FUNC \
function integer log2; \
      input integer number; \
      begin \
         log2=0; \
         while(2**log2<number) begin \
            log2=log2+1; \
         end \
      end \
endfunction

`define CEILDIV_FUNC \
function integer ceildiv; \
      input integer num; \
      input integer divisor; \
      begin \
         if (num <= divisor) \
           ceildiv = 1; \
         else begin \
            ceildiv = num / divisor; \
            if (ceildiv * divisor < num) \
              ceildiv = ceildiv + 1; \
         end \
      end \
endfunction

// Clock period of 125 MHz clock in ns
`define FAST_CLOCK_PERIOD                         8