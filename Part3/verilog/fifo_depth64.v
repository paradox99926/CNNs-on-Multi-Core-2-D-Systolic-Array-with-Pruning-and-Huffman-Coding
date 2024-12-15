// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module fifo_depth64 (rd_clk, wr_clk, in, out, rd, wr, o_full, o_empty, reset);

  parameter bw = 4;
  parameter simd = 1;
  parameter lrf_depth = 1;

  input  rd_clk;
  input  wr_clk;
  input  rd;
  input  wr;
  input  reset;
  output o_full;
  output o_empty;
  input  [simd*bw-1:0] in;
  output [simd*bw-1:0] out;

  wire [simd*bw-1:0] out_sub0_0;
  wire [simd*bw-1:0] out_sub0_1;
  wire [simd*bw-1:0] out_sub0_2;
  wire [simd*bw-1:0] out_sub0_3;
  wire [simd*bw-1:0] out_sub1_0;
  wire [simd*bw-1:0] out_sub1_1;
  wire full, empty;

  reg [6:0] rd_ptr = 7'b0000000;
  reg [6:0] wr_ptr = 7'b0000000;

  reg [simd*bw-1:0] q0;
  reg [simd*bw-1:0] q1;
  reg [simd*bw-1:0] q2;
  reg [simd*bw-1:0] q3;
  reg [simd*bw-1:0] q4;
  reg [simd*bw-1:0] q5;
  reg [simd*bw-1:0] q6;
  reg [simd*bw-1:0] q7;
  reg [simd*bw-1:0] q8;
  reg [simd*bw-1:0] q9;
  reg [simd*bw-1:0] q10;
  reg [simd*bw-1:0] q11;
  reg [simd*bw-1:0] q12;
  reg [simd*bw-1:0] q13;
  reg [simd*bw-1:0] q14;
  reg [simd*bw-1:0] q15;
  reg [simd*bw-1:0] q16;
  reg [simd*bw-1:0] q17;
  reg [simd*bw-1:0] q18;
  reg [simd*bw-1:0] q19;
  reg [simd*bw-1:0] q20;
  reg [simd*bw-1:0] q21;
  reg [simd*bw-1:0] q22;
  reg [simd*bw-1:0] q23;
  reg [simd*bw-1:0] q24;
  reg [simd*bw-1:0] q25;
  reg [simd*bw-1:0] q26;
  reg [simd*bw-1:0] q27;
  reg [simd*bw-1:0] q28;
  reg [simd*bw-1:0] q29;
  reg [simd*bw-1:0] q30;
  reg [simd*bw-1:0] q31;
  reg [simd*bw-1:0] q32;
  reg [simd*bw-1:0] q33;
  reg [simd*bw-1:0] q34;
  reg [simd*bw-1:0] q35;
  reg [simd*bw-1:0] q36;
  reg [simd*bw-1:0] q37;
  reg [simd*bw-1:0] q38;
  reg [simd*bw-1:0] q39;
  reg [simd*bw-1:0] q40;
  reg [simd*bw-1:0] q41;
  reg [simd*bw-1:0] q42;
  reg [simd*bw-1:0] q43;
  reg [simd*bw-1:0] q44;
  reg [simd*bw-1:0] q45;
  reg [simd*bw-1:0] q46;
  reg [simd*bw-1:0] q47;
  reg [simd*bw-1:0] q48;
  reg [simd*bw-1:0] q49;
  reg [simd*bw-1:0] q50;
  reg [simd*bw-1:0] q51;
  reg [simd*bw-1:0] q52;
  reg [simd*bw-1:0] q53;
  reg [simd*bw-1:0] q54;
  reg [simd*bw-1:0] q55;
  reg [simd*bw-1:0] q56;
  reg [simd*bw-1:0] q57;
  reg [simd*bw-1:0] q58;
  reg [simd*bw-1:0] q59;
  reg [simd*bw-1:0] q60;
  reg [simd*bw-1:0] q61;
  reg [simd*bw-1:0] q62;
  reg [simd*bw-1:0] q63;

 assign empty = (wr_ptr == rd_ptr) ? 1'b1 : 1'b0 ;
 assign full  = ((wr_ptr[5:0] == rd_ptr[5:0]) && (wr_ptr[6] != rd_ptr[6])) ? 1'b1 : 1'b0;

 assign o_full  = full;
 assign o_empty = empty;


  fifo_mux_16_1 #(.bw(bw)) fifo_mux_16_1a (.in0(q0), .in1(q1), .in2(q2), .in3(q3), .in4(q4), .in5(q5), .in6(q6), .in7(q7),
                                                        .in8(q8), .in9(q9), .in10(q10), .in11(q11), .in12(q12), .in13(q13), .in14(q14), .in15(q15),
                        	                        .sel(rd_ptr[3:0]), .out(out_sub0_0));

  fifo_mux_16_1 #(.bw(bw)) fifo_mux_16_1b (.in0(q16), .in1(q17), .in2(q18), .in3(q19), .in4(q20), .in5(q21), .in6(q22), .in7(q23),
                                                        .in8(q24), .in9(q25), .in10(q26), .in11(q27), .in12(q28), .in13(q29), .in14(q30), .in15(q31),
                        	                        .sel(rd_ptr[3:0]), .out(out_sub0_1));

  fifo_mux_16_1 #(.bw(bw)) fifo_mux_16_1c (.in0(q32), .in1(q33), .in2(q34), .in3(q35), .in4(q36), .in5(q37), .in6(q38), .in7(q39),
                                                        .in8(q40), .in9(q41), .in10(q42), .in11(q43), .in12(q44), .in13(q45), .in14(q46), .in15(q47),
                        	                        .sel(rd_ptr[3:0]), .out(out_sub0_2));

  fifo_mux_16_1 #(.bw(bw)) fifo_mux_16_1d (.in0(q48), .in1(q49), .in2(q50), .in3(q51), .in4(q52), .in5(q53), .in6(q54), .in7(q55),
                                                        .in8(q56), .in9(q57), .in10(q58), .in11(q59), .in12(q60), .in13(q61), .in14(q62), .in15(q63),
                        	                        .sel(rd_ptr[3:0]), .out(out_sub0_3));


  fifo_mux_2_1 #(.bw(bw)) fifo_mux_2_1a   (.in0(out_sub0_0), .in1(out_sub0_1), .sel(rd_ptr[4]), .out(out_sub1_0));
  fifo_mux_2_1 #(.bw(bw)) fifo_mux_2_1b   (.in0(out_sub0_2), .in1(out_sub0_3), .sel(rd_ptr[4]), .out(out_sub1_1));
  
  fifo_mux_2_1 #(.bw(bw)) fifo_mux_2_1c   (.in0(out_sub1_0), .in1(out_sub1_1), .sel(rd_ptr[5]), .out(out));




 always @ (posedge rd_clk) begin
   if (reset) begin
      rd_ptr <= 7'b0000000;
   end
   else if ((rd == 1) && (empty == 0)) begin
      rd_ptr <= rd_ptr + 1;
   end
 end


 always @ (posedge wr_clk) begin
   if (reset) begin
      wr_ptr <= 7'b0000000;
   end
   else begin 
      if ((wr == 1) && (full == 0)) begin
        wr_ptr <= wr_ptr + 1;
      end

      if (wr == 1) begin
        case (wr_ptr[5:0])
         6'b000000   :    q0  <= in ;
         6'b000001   :    q1  <= in ;
         6'b000010   :    q2  <= in ;
         6'b000011   :    q3  <= in ;
         6'b000100   :    q4  <= in ;
         6'b000101   :    q5  <= in ;
         6'b000110   :    q6  <= in ;
         6'b000111   :    q7  <= in ;
         6'b001000   :    q8  <= in ;
         6'b001001   :    q9  <= in ;
         6'b001010   :    q10 <= in ;
         6'b001011   :    q11 <= in ;
         6'b001100   :    q12 <= in ;
         6'b001101   :    q13 <= in ;
         6'b001110   :    q14 <= in ;
         6'b001111   :    q15 <= in ;

         6'b010000   :    q16  <= in ;
         6'b010001   :    q17  <= in ;
         6'b010010   :    q18  <= in ;
         6'b010011   :    q19  <= in ;
         6'b010100   :    q20  <= in ;
         6'b010101   :    q21  <= in ;
         6'b010110   :    q22  <= in ;
         6'b010111   :    q23  <= in ;
         6'b011000   :    q24  <= in ;
         6'b011001   :    q25  <= in ;
         6'b011010   :    q26 <= in ;
         6'b011011   :    q27 <= in ;
         6'b011100   :    q28 <= in ;
         6'b011101   :    q29 <= in ;
         6'b011110   :    q30 <= in ;
         6'b011111   :    q31 <= in ;

         6'b100000   :    q32  <= in ;
         6'b100001   :    q33  <= in ;
         6'b100010   :    q34  <= in ;
         6'b100011   :    q35  <= in ;
         6'b100100   :    q36  <= in ;
         6'b100101   :    q37  <= in ;
         6'b100110   :    q38  <= in ;
         6'b100111   :    q39  <= in ;
         6'b101000   :    q40  <= in ;
         6'b101001   :    q41  <= in ;
         6'b101010   :    q42 <= in ;
         6'b101011   :    q43 <= in ;
         6'b101100   :    q44 <= in ;
         6'b101101   :    q45 <= in ;
         6'b101110   :    q46 <= in ;
         6'b101111   :    q47 <= in ;

         6'b110000   :    q48  <= in ;
         6'b110001   :    q49  <= in ;
         6'b110010   :    q50  <= in ;
         6'b110011   :    q51  <= in ;
         6'b110100   :    q52  <= in ;
         6'b110101   :    q53  <= in ;
         6'b110110   :    q54  <= in ;
         6'b110111   :    q55  <= in ;
         6'b111000   :    q56  <= in ;
         6'b111001   :    q57  <= in ;
         6'b111010   :    q58 <= in ;
         6'b111011   :    q59 <= in ;
         6'b111100   :    q60 <= in ;
         6'b111101   :    q61 <= in ;
         6'b111110   :    q62 <= in ;
         6'b111111   :    q63 <= in ;

        endcase
      end
   end

 end


endmodule
