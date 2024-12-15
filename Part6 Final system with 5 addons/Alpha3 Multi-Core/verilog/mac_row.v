// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission
module mac_row (clk, out_s, in_w, in_n, valid, inst_w, reset, WeightOrOutput, OS_out, IFIFO_loop, OS_out_valid);

parameter bw = 4;
parameter psum_bw = 16;
parameter col = 8;

input  clk, reset;
input  [bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
input  [1:0] inst_w;
input  [psum_bw*col-1:0] in_n;
input  WeightOrOutput;

output [psum_bw*col-1:0] out_s;
output [col-1:0] valid;
output [col-1:0] IFIFO_loop;
output [psum_bw*col-1:0] OS_out;
output [col-1:0] OS_out_valid;

wire  [(col+1)*bw-1:0] temp;
wire  [(col+1)*2-1:0]  temp_inst;

assign temp[bw-1:0]   = in_w;
assign temp_inst[1:0] = inst_w;


generate
genvar i;
for (i=1; i < col+1 ; i=i+1) begin : col_num
  mac_tile #(.bw(bw), .psum_bw(psum_bw)) mac_tile_instance (
    .clk(clk),
    .reset(reset),
    .in_w( temp[bw*i-1:bw*(i-1)]),
    .out_e(temp[bw*(i+1)-1:bw*i]),
    .inst_w(temp_inst[2*i-1:2*(i-1)]),
    .inst_e(temp_inst[2*i+1:2*i]),
    .in_n(in_n[psum_bw*i-1:psum_bw*(i-1)]),
    .out_s(out_s[psum_bw*i-1:psum_bw*(i-1)]),
    .WeightOrOutput(WeightOrOutput),
    .IFIFO_loop(IFIFO_loop[i-1]),
    .OS_out_valid(OS_out_valid[i-1]),
    .OS_out(OS_out[psum_bw*i-1:psum_bw*(i-1)])
    );
  assign valid[i-1] = temp_inst[2*(i+1)-1];
end
endgenerate


endmodule
