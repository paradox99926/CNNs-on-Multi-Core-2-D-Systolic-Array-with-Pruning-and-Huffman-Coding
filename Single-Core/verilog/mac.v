// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac 
(out,
 a,
 b,
 c,
 WeightOrOutput);

parameter bw = 4;
parameter psum_bw = 16;

output signed [psum_bw-1:0] out;
input WeightOrOutput;
input [bw-1:0] a;   // activation
input signed [bw-1:0]  b;   // weight
input signed[psum_bw-1:0] c;    // psum

wire signed [bw:0] a_unsigned;
wire [bw-1:0] a_signed;
wire [psum_bw-1:0] out_WS;
wire [psum_bw-1:0] out_OS;

assign a_unsigned = ({1'b0,a});

assign out_WS = a_unsigned*b + c;
assign out_OS = $signed(a)*$signed(b) + $signed(c);
assign out = WeightOrOutput ? out_OS : out_WS;

endmodule
