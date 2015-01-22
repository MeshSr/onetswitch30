 
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
//eht_queue
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

`define IN_ARB_NUM_PKTS_SENT       6'h0
`define IN_ARB_LAST_PKT_WORD_0_HI  6'h1
`define IN_ARB_LAST_PKT_WORD_0_LO  6'h2
`define IN_ARB_LAST_PKT_CTRL_0     6'h3
`define IN_ARB_LAST_PKT_WORD_1_HI  6'h4
`define IN_ARB_LAST_PKT_WORD_1_LO  6'h5
`define IN_ARB_LAST_PKT_CTRL_1     6'h6
`define IN_ARB_STATE               6'h7

//-------------------------------------------------
//OpenFlow switch
//-------------------------------------------------
`define IOQ_METER_ID_POS      56
`define IOQ_METER_ID_LEN      8
`define IOQ_DST_TABLE_ID_POS  24
`define IOQ_DST_TABLE_ID_LEN  8

//Block addr
`define IN_ARB_BLOCK_ADDR_WIDTH                    17
`define IN_ARB_REG_ADDR_WIDTH                      6
`define IN_ARB_BLOCK_ADDR                          17'h00000

`define RATE_LIMIT_BLOCK_ADDR_WIDTH                17
`define RATE_LIMIT_REG_ADDR_WIDTH                  6
`define RATE_LIMIT_0_BLOCK_ADDR                    17'h00001
`define RATE_LIMIT_1_BLOCK_ADDR                    17'h00002
`define RATE_LIMIT_2_BLOCK_ADDR                    17'h00003
`define RATE_LIMIT_3_BLOCK_ADDR                    17'h00004
`define RATE_LIMIT_4_BLOCK_ADDR                    17'h00005
`define RATE_LIMIT_5_BLOCK_ADDR                    17'h00006
`define RATE_LIMIT_6_BLOCK_ADDR                    17'h00007
`define RATE_LIMIT_7_BLOCK_ADDR                    17'h00008

`define T0_OPENFLOW_LOOKUP_REG_ADDR_WIDTH             6
`define T0_OPENFLOW_LOOKUP_BLOCK_ADDR                 17'h00009
`define T0_OPENFLOW_WILDCARD_LOOKUP_REG_ADDR_WIDTH    10
`define T0_OPENFLOW_WILDCARD_LOOKUP_BLOCK_ADDR        13'h0001

`define T1_OPENFLOW_LOOKUP_REG_ADDR_WIDTH             6
`define T1_OPENFLOW_LOOKUP_BLOCK_ADDR                 17'h0000a
`define T1_OPENFLOW_WILDCARD_LOOKUP_REG_ADDR_WIDTH    10
`define T1_OPENFLOW_WILDCARD_LOOKUP_BLOCK_ADDR        13'h0002
//basic
`define T0_OPENFLOW_WILDCARD_TABLE_SIZE           16 //16
`define T1_OPENFLOW_WILDCARD_TABLE_SIZE           4 //16


//Flow entry
`define OPENFLOW_ENTRY_TRANSP_DST_WIDTH           16
`define OPENFLOW_ENTRY_TRANSP_DST_POS             0

`define OPENFLOW_ENTRY_TRANSP_SRC_WIDTH           16
`define OPENFLOW_ENTRY_TRANSP_SRC_POS             16

`define OPENFLOW_ENTRY_IP_PROTO_WIDTH             8
`define OPENFLOW_ENTRY_IP_PROTO_POS               32

`define OPENFLOW_ENTRY_IP_DST_WIDTH               32
`define OPENFLOW_ENTRY_IP_DST_POS                 40

`define OPENFLOW_ENTRY_IP_SRC_WIDTH               32
`define OPENFLOW_ENTRY_IP_SRC_POS                 72

`define OPENFLOW_ENTRY_ETH_TYPE_WIDTH             16
`define OPENFLOW_ENTRY_ETH_TYPE_POS               104

`define OPENFLOW_ENTRY_ETH_DST_WIDTH              48
`define OPENFLOW_ENTRY_ETH_DST_POS                120

`define OPENFLOW_ENTRY_ETH_SRC_WIDTH              48
`define OPENFLOW_ENTRY_ETH_SRC_POS                168

`define OPENFLOW_ENTRY_SRC_PORT_WIDTH             8
`define OPENFLOW_ENTRY_SRC_PORT_POS               216

`define OPENFLOW_ENTRY_IP_TOS_WIDTH               8
`define OPENFLOW_ENTRY_IP_TOS_POS                 224

`define OPENFLOW_ENTRY_VLAN_ID_WIDTH              16
`define OPENFLOW_ENTRY_VLAN_ID_POS                232

`define OPENFLOW_ENTRY_WIDTH_ALL                  248
`define T0_OPENFLOW_ENTRY_WIDTH                   64
`define T1_OPENFLOW_ENTRY_WIDTH                   64

//Actions
`define OPENFLOW_ACTION_WIDTH                     320

`define NF2_OFPAT_OUTPUT                          16'h0001
`define NF2_OFPAT_SET_VLAN_VID                    16'h0002
`define NF2_OFPAT_SET_VLAN_PCP                    16'h0004
`define NF2_OFPAT_STRIP_VLAN                      16'h0008
`define NF2_OFPAT_SET_DL_SRC                      16'h0010
`define NF2_OFPAT_SET_DL_DST                      16'h0020
`define NF2_OFPAT_SET_NW_SRC                      16'h0040
`define NF2_OFPAT_SET_NW_DST                      16'h0080
`define NF2_OFPAT_SET_NW_TOS                      16'h0100
`define NF2_OFPAT_SET_TP_SRC                      16'h0200
`define NF2_OFPAT_SET_TP_DST                      16'h0400
`define NF2_OFPAT_METER                           16'h0800
`define NF2_OFPAT_GOTO_TABLE                      16'h1000

// Ports to forward on
`define OPENFLOW_FORWARD_BITMASK_WIDTH            16
`define OPENFLOW_FORWARD_BITMASK_POS              0

`define OPENFLOW_NF2_ACTION_FLAG_WIDTH            16
`define OPENFLOW_NF2_ACTION_FLAG_POS              16

// Vlan ID to be replaced
`define OPENFLOW_SET_VLAN_VID_WIDTH               16
`define OPENFLOW_SET_VLAN_VID_POS                 32

// Vlan priority to be replaced
`define OPENFLOW_SET_VLAN_PCP_WIDTH               8
`define OPENFLOW_SET_VLAN_PCP_POS                 48

// Source MAC address to be replaced
`define OPENFLOW_SET_DL_SRC_WIDTH                 48
`define OPENFLOW_SET_DL_SRC_POS                   56

// Destination MAC address to be replaced
`define OPENFLOW_SET_DL_DST_WIDTH                 48
`define OPENFLOW_SET_DL_DST_POS                   104

// Source network address to be replaced
`define OPENFLOW_SET_NW_SRC_WIDTH                 32
`define OPENFLOW_SET_NW_SRC_POS                   152

// Destination network address to be replaced
`define OPENFLOW_SET_NW_DST_WIDTH                 32
`define OPENFLOW_SET_NW_DST_POS                   184

// TOS to be replaced
`define OPENFLOW_SET_NW_TOS_WIDTH                 8
`define OPENFLOW_SET_NW_TOS_POS                   216

// Source transport port to be replaced
`define OPENFLOW_SET_TP_SRC_WIDTH                 16
`define OPENFLOW_SET_TP_SRC_POS                   224

// Destination transport port to be replaced
`define OPENFLOW_SET_TP_DST_WIDTH                 16
`define OPENFLOW_SET_TP_DST_POS                   240

`define OPENFLOW_METER_ID_WIDTH                   8
`define OPENFLOW_METER_ID_POS                     256

`define OPENFLOW_NEXT_TABLE_ID_WIDTH              8
`define OPENFLOW_NEXT_TABLE_ID_POS                264
//VLAN REMOVER
`define VLAN_CTRL_WORD                            8'h42
`define VLAN_ETHERTYPE                            16'h8100

//Header parser
`define ETH_TYPE_IP                               16'h0800
`define ETH_TYPE_ARP                              16'h0806
`define IP_PROTO_TCP                              8'h06
`define IP_PROTO_UDP                              8'h11
`define IP_PROTO_ICMP                             8'h01

//----------------------------------
//Rate limmiter
`define RATE_LIMIT_ENABLE_BIT_NUM             0
`define RATE_LIMIT_INCLUDE_OVERHEAD_BIT_NUM   1

`define RATE_LIMIT_CTRL            4'h0
`define RATE_LIMIT_TOKEN_INTERVAL  4'h1
`define RATE_LIMIT_TOKEN_INC       4'h2






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
