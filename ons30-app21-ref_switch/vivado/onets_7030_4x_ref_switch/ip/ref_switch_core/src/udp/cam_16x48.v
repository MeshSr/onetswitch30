
module cam_16x48
(
    input           clk,
    input [47:0]    cmp_din,
    input [47:0]    din,
    input           we,
    input [3:0]	    wr_addr,
    output          busy,
    output          match,
    output [3:0]    match_addr
);
endmodule
