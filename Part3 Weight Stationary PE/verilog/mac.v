// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac 
(out,
 a,
 b,
 c);

parameter bw = 4;
parameter psum_bw = 16;

output signed [psum_bw-1:0] out;
 input  unsigned [bw-1:0] a;
 input signed [bw-1:0]  b;
 input signed[psum_bw-1:0] c;

wire  signed [bw:0] a_unsigned;

assign a_unsigned = ({1'b0,a});
assign out = a_unsigned*b + c;


endmodule
