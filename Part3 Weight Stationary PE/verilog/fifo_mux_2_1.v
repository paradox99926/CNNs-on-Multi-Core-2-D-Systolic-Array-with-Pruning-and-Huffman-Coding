// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module fifo_mux_2_1(in0, in1, sel, out);

  parameter bw = 8;

  input [bw-1:0] in0;
  input [bw-1:0] in1; 
  input sel;
  output [bw-1:0] out;
  wire sbar; 
  wire [bw-1:0] w1, w2, out;

  genvar i;

  not G01 (sbar, sel);

  for (i=0; i < bw ; i=i+1) begin : gen
     and G0  (w1[i], in0[i], sbar);
     and G1  (w2[i], in1[i], sel);
     or  G2  (out[i], w1[i], w2[i]);
  end

 endmodule
