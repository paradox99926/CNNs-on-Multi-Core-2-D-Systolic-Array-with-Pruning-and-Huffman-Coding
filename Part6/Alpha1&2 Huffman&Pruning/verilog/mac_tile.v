// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission
module mac_tile (clk, out_s, in_w, out_e, in_n, inst_w, inst_e, reset, WeightOrOutput, OS_out, IFIFO_loop, OS_out_valid);

parameter bw = 4;
parameter psum_bw = 16;
parameter acc_kij = 9;
parameter input_ch = 3;

input  [bw-1:0] in_w;
input  [1:0] inst_w;//[1]:execute,[0]kernel loading
input  [psum_bw-1:0] in_n;
input  clk;
input  reset;
input  WeightOrOutput;


output [1:0] inst_e;
output [bw-1:0] out_e;
output [psum_bw-1:0] out_s;
output IFIFO_loop; // high if psum finish 9 times accumulation, IFIFO need to loop the weight
output [psum_bw-1:0] OS_out; // psum value to be read out to ofifo in Output Stationary mode
output OS_out_valid; // valid signal for OFIFO in OS mode

wire [psum_bw-1:0] mac_out;
reg [bw-1:0] b_q; // buffer for west to east
reg [bw-1:0] a_q; // buffer for north to south
reg [psum_bw-1:0] c_q;
reg [1:0] inst_q; // buffer for west to east instruction
reg load_ready_q; // only active after reset, once receive new weight from west, become 0

reg [4:0] acc_counter;  // counter for accumulation in Output Stationary
reg IFIFO_loop_q;
reg [psum_bw-1:0] OS_tile0; //store the psum of tile0
reg [psum_bw-1:0] OS_tile1; //store the psum of tile1
// reg [3:0] tile0_ic_counter;
// reg [3:0] tile1_ic_counter;
reg choose_tile;
reg tile0_out_valid;  // High if tile0 finished 3 input channels accumulation
reg tile1_out_valid;  // High if tile1 finished 3 input channels accumulation
assign OS_out_valid = tile0_out_valid | tile1_out_valid;

assign out_s = WeightOrOutput ? {12'b000000000000,b_q} : mac_out;
assign out_e = a_q;
assign inst_e = inst_q;
assign IFIFO_loop = IFIFO_loop_q;
assign OS_out = OS_tile0 * tile0_out_valid;


always @(posedge clk) begin

 if (reset) begin
    inst_q[1:0] <= 2'b00;
    load_ready_q <= 1;
    a_q <= 0;
    b_q <= 0;
    c_q <= 0;
    acc_counter <= 0;
    choose_tile <= 0;
    // tile0_ic_counter <= 0;
    // tile1_ic_counter <= 0;
    tile0_out_valid <= 0;
    tile1_out_valid <= 0;
 end


 case(WeightOrOutput)
 0: // Weight Stationary
 begin
    inst_q[1] <= inst_w[1];
    c_q <= in_n;
    if (inst_w[1:0] != 2'b00) begin
      a_q <= in_w;
    end
    if (inst_w[0] && load_ready_q) begin
      b_q <= in_w;
      load_ready_q <= 0;
    end
    if (!load_ready_q) begin
      inst_q[0] <= inst_w[0];
    end
  end

  1:  // Output Stationary
  begin
    inst_q[1] <= inst_w[1];
    if (inst_w[1]) begin
      b_q <= in_n[3:0];  // pass the 4bit weight from north to south
      a_q <= in_w;  // pass the activation from west to east

      if ((acc_counter != 5'b11011)) begin  // execution stage)
        acc_counter <= acc_counter + 1; // increment the accumulation counter
        IFIFO_loop_q <= 0; // disable the output
        c_q <= mac_out;
        tile0_out_valid <= 0;
      end

      // else if ((acc_counter == 5'b01001) || (acc_counter == 5'b10010)) begin
      //   acc_counter <= acc_counter + 1; // increment the accumulation counter
      //   IFIFO_loop_q <= 0; // disable the output
      //   tile0_out_valid <= 0;
      //   c_q <= $signed(mac_out)>0 ? mac_out : 0;
      // end

      else if (acc_counter == 5'b11011) begin
        acc_counter <= 0;
        OS_tile0 <= $signed(mac_out)>0 ? mac_out : 0;
        tile0_out_valid <= 1;
      end
      
    end
  end
 endcase
end




mac #(.bw(bw), .psum_bw(psum_bw)) mac_instance (
    .WeightOrOutput(WeightOrOutput),
    .a(a_q),  // activation
    .b(b_q),  // weight
    .c(c_q),  // psum
    .out(mac_out) // act*weight + psum
    );


endmodule
