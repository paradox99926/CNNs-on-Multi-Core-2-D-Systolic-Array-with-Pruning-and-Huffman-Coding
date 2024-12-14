// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module fifo_mux_16_1 (out, sel, in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15 );

  parameter bw = 4;
  parameter simd = 1;

  input  [3:0 ] sel ;
  input  [simd*bw-1:0] in0;
  input  [simd*bw-1:0] in1;
  input  [simd*bw-1:0] in2;
  input  [simd*bw-1:0] in3;
  input  [simd*bw-1:0] in4;
  input  [simd*bw-1:0] in5;
  input  [simd*bw-1:0] in6;
  input  [simd*bw-1:0] in7;
  input  [simd*bw-1:0] in8;
  input  [simd*bw-1:0] in9;
  input  [simd*bw-1:0] in10;
  input  [simd*bw-1:0] in11;
  input  [simd*bw-1:0] in12;
  input  [simd*bw-1:0] in13;
  input  [simd*bw-1:0] in14;
  input  [simd*bw-1:0] in15;
  output [simd*bw-1:0] out;

  wire   [simd*bw-1:0] out_sub0, out_sub1 ;


 fifo_mux_8_1  #(.bw(bw)) mux_8_1a (.in0(in0), .in1(in1), .in2(in2), .in3(in3), .in4(in4), .in5(in5), .in6(in6), .in7(in7),       .sel(sel[2:0]), .out(out_sub0));
 fifo_mux_8_1  #(.bw(bw)) mux_8_1b (.in0(in8), .in1(in9), .in2(in10), .in3(in11), .in4(in12), .in5(in13), .in6(in14), .in7(in15), .sel(sel[2:0]), .out(out_sub1));

 fifo_mux_2_1  #(.bw(bw)) mux_2_1a (.in0(out_sub0), .in1(out_sub1), .sel(sel[3]), .out(out));


endmodule
