// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_array (clk, reset, out_s, in_w, in_n, inst_w, WeightOrOutput, valid, OS_out, IFIFO_loop);

parameter bw = 4;
parameter psum_bw = 16;
parameter col = 8;
parameter row = 8;

input  clk, reset;
input  [row*bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
input  [1:0] inst_w;
input  WeightOrOutput;
input  [psum_bw*col-1:0] in_n;

output [psum_bw*col-1:0] out_s;
output [col-1:0] valid; // valid signal for OFIFO in WS mode
output [psum_bw*col-1:0] OS_out;
output [col-1:0] IFIFO_loop;

reg [row*2-1:0] inst_w_temp;

wire [psum_bw*col*row-1:0] OS_out_temp;
reg [col-1:0] OS_out_valid;  // valid signal for OFIFO in OS mode
wire [row*col-1:0] valid_temp;
wire [(row+1)*col*psum_bw-1:0] temp;
wire [row*col-1:0] IFIFO_loop_temp;
wire [row*col-1:0] OS_out_valid_temp;

reg [psum_bw-1:0] OS_out_col0;
reg [psum_bw-1:0] OS_out_col1;
reg [psum_bw-1:0] OS_out_col2;
reg [psum_bw-1:0] OS_out_col3;
reg [psum_bw-1:0] OS_out_col4;
reg [psum_bw-1:0] OS_out_col5;
reg [psum_bw-1:0] OS_out_col6;
reg [psum_bw-1:0] OS_out_col7;

assign OS_out = {OS_out_col7, OS_out_col6, OS_out_col5, OS_out_col4, OS_out_col3, OS_out_col2, OS_out_col1, OS_out_col0};

wire [row-1:0] OS_out_valid_col0;
wire [row-1:0] OS_out_valid_col1;
wire [row-1:0] OS_out_valid_col2;
wire [row-1:0] OS_out_valid_col3;
wire [row-1:0] OS_out_valid_col4;
wire [row-1:0] OS_out_valid_col5;
wire [row-1:0] OS_out_valid_col6;
wire [row-1:0] OS_out_valid_col7;

assign OS_out_valid_col0 = {OS_out_valid_temp[56], OS_out_valid_temp[48], OS_out_valid_temp[40], OS_out_valid_temp[32], OS_out_valid_temp[24], OS_out_valid_temp[16], OS_out_valid_temp[8], OS_out_valid_temp[0]};
assign OS_out_valid_col1 = {OS_out_valid_temp[57], OS_out_valid_temp[49], OS_out_valid_temp[41], OS_out_valid_temp[33], OS_out_valid_temp[25], OS_out_valid_temp[17], OS_out_valid_temp[9], OS_out_valid_temp[1]};
assign OS_out_valid_col2 = {OS_out_valid_temp[58], OS_out_valid_temp[50], OS_out_valid_temp[42], OS_out_valid_temp[34], OS_out_valid_temp[26], OS_out_valid_temp[18], OS_out_valid_temp[10], OS_out_valid_temp[2]};
assign OS_out_valid_col3 = {OS_out_valid_temp[59], OS_out_valid_temp[51], OS_out_valid_temp[43], OS_out_valid_temp[35], OS_out_valid_temp[27], OS_out_valid_temp[19], OS_out_valid_temp[11], OS_out_valid_temp[3]};
assign OS_out_valid_col4 = {OS_out_valid_temp[60], OS_out_valid_temp[52], OS_out_valid_temp[44], OS_out_valid_temp[36], OS_out_valid_temp[28], OS_out_valid_temp[20], OS_out_valid_temp[12], OS_out_valid_temp[4]};
assign OS_out_valid_col5 = {OS_out_valid_temp[61], OS_out_valid_temp[53], OS_out_valid_temp[45], OS_out_valid_temp[37], OS_out_valid_temp[29], OS_out_valid_temp[21], OS_out_valid_temp[13], OS_out_valid_temp[5]};
assign OS_out_valid_col6 = {OS_out_valid_temp[62], OS_out_valid_temp[54], OS_out_valid_temp[46], OS_out_valid_temp[38], OS_out_valid_temp[30], OS_out_valid_temp[22], OS_out_valid_temp[14], OS_out_valid_temp[6]};
assign OS_out_valid_col7 = {OS_out_valid_temp[63], OS_out_valid_temp[55], OS_out_valid_temp[47], OS_out_valid_temp[39], OS_out_valid_temp[31], OS_out_valid_temp[23], OS_out_valid_temp[15], OS_out_valid_temp[7]};
// assign OS_out_valid = OS_out_valid_temp[col*1-1:col*0] | OS_out_valid_temp[col*2-1:col*1-1] | OS_out_valid_temp[col*3-1:col*2-1] | OS_out_valid_temp[col*4-1:col*3-1] | OS_out_valid_temp[col*5-1:col*4-1] | OS_out_valid_temp[col*6-1:col*5-1] | OS_out_valid_temp[col*7-1:col*6-1] | OS_out_valid_temp[col*8-1:col*7-1];


assign valid = WeightOrOutput? OS_out_valid : valid_temp[col*row-1:col*row-8];
assign temp[psum_bw*col-1:0] = in_n;
assign out_s = temp[psum_bw*col*9-1:psum_bw*col*8];
assign IFIFO_loop = IFIFO_loop_temp[col-1:0]; // only the first row is pop out to IFIFO as the loop signal


// case(OS_out_valid_col0)
//   8'b00000001: OS_out_col0 = OS_out_temp[15:0];
//   8'b00000010: OS_out_col0 = OS_out_temp[143:128];
//   8'b00000100: OS_out_col0 = OS_out_temp[271:256];
//   8'b00001000: OS_out_col0 = OS_out_temp[399:384];
//   8'b00010000: OS_out_col0 = OS_out_temp[527:512];
//   8'b00100000: OS_out_col0 = OS_out_temp[655:640];
//   8'b01000000: OS_out_col0 = OS_out_temp[783:768];
//   8'b10000000: OS_out_col0 = OS_out_temp[911:896];
// endcase



always @(posedge clk) begin
    OS_out_valid <= {|OS_out_valid_col7, |OS_out_valid_col6, |OS_out_valid_col5, |OS_out_valid_col4, |OS_out_valid_col3, |OS_out_valid_col2, |OS_out_valid_col1, |OS_out_valid_col0};
    case(OS_out_valid_col0)
      8'b00000001: OS_out_col0 = OS_out_temp[15:0];
      8'b00000010: OS_out_col0 = OS_out_temp[143:128];
      8'b00000100: OS_out_col0 = OS_out_temp[271:256];
      8'b00001000: OS_out_col0 = OS_out_temp[399:384];
      8'b00010000: OS_out_col0 = OS_out_temp[527:512];
      8'b00100000: OS_out_col0 = OS_out_temp[655:640];
      8'b01000000: OS_out_col0 = OS_out_temp[783:768];
      8'b10000000: OS_out_col0 = OS_out_temp[911:896];
    endcase

    case(OS_out_valid_col1)
      8'b00000001: OS_out_col1 = OS_out_temp[31:16];
      8'b00000010: OS_out_col1 = OS_out_temp[159:144];
      8'b00000100: OS_out_col1 = OS_out_temp[287:272];
      8'b00001000: OS_out_col1 = OS_out_temp[415:400];
      8'b00010000: OS_out_col1 = OS_out_temp[543:528];
      8'b00100000: OS_out_col1 = OS_out_temp[671:656];
      8'b01000000: OS_out_col1 = OS_out_temp[799:784];
      8'b10000000: OS_out_col1 = OS_out_temp[927:912];
    endcase

    case(OS_out_valid_col2)
      8'b00000001: OS_out_col2 = OS_out_temp[47:32];
      8'b00000010: OS_out_col2 = OS_out_temp[175:160];
      8'b00000100: OS_out_col2 = OS_out_temp[303:288];
      8'b00001000: OS_out_col2 = OS_out_temp[431:416];
      8'b00010000: OS_out_col2 = OS_out_temp[559:544];
      8'b00100000: OS_out_col2 = OS_out_temp[687:672];
      8'b01000000: OS_out_col2 = OS_out_temp[815:800];
      8'b10000000: OS_out_col2 = OS_out_temp[943:928];
    endcase

    case(OS_out_valid_col3)
      8'b00000001: OS_out_col3 = OS_out_temp[63:48];
      8'b00000010: OS_out_col3 = OS_out_temp[191:176];
      8'b00000100: OS_out_col3 = OS_out_temp[319:304];
      8'b00001000: OS_out_col3 = OS_out_temp[447:432];
      8'b00010000: OS_out_col3 = OS_out_temp[575:560];
      8'b00100000: OS_out_col3 = OS_out_temp[703:688];
      8'b01000000: OS_out_col3 = OS_out_temp[831:816];
      8'b10000000: OS_out_col3 = OS_out_temp[959:944];
    endcase

    case(OS_out_valid_col4)
      8'b00000001: OS_out_col4 = OS_out_temp[79:64];
      8'b00000010: OS_out_col4 = OS_out_temp[207:192];
      8'b00000100: OS_out_col4 = OS_out_temp[335:320];
      8'b00001000: OS_out_col4 = OS_out_temp[463:448];
      8'b00010000: OS_out_col4 = OS_out_temp[591:576];
      8'b00100000: OS_out_col4 = OS_out_temp[719:704];
      8'b01000000: OS_out_col4 = OS_out_temp[847:832];
      8'b10000000: OS_out_col4 = OS_out_temp[975:960];
    endcase

    case(OS_out_valid_col5)
      8'b00000001: OS_out_col5 = OS_out_temp[95:80];
      8'b00000010: OS_out_col5 = OS_out_temp[223:208];
      8'b00000100: OS_out_col5 = OS_out_temp[351:336];
      8'b00001000: OS_out_col5 = OS_out_temp[479:464];
      8'b00010000: OS_out_col5 = OS_out_temp[607:592];
      8'b00100000: OS_out_col5 = OS_out_temp[735:720];
      8'b01000000: OS_out_col5 = OS_out_temp[863:848];
      8'b10000000: OS_out_col5 = OS_out_temp[991:976];
    endcase

    case(OS_out_valid_col6)
      8'b00000001: OS_out_col6 = OS_out_temp[111:96];
      8'b00000010: OS_out_col6 = OS_out_temp[239:224];
      8'b00000100: OS_out_col6 = OS_out_temp[367:352];
      8'b00001000: OS_out_col6 = OS_out_temp[495:480];
      8'b00010000: OS_out_col6 = OS_out_temp[623:608];
      8'b00100000: OS_out_col6 = OS_out_temp[751:736];
      8'b01000000: OS_out_col6 = OS_out_temp[879:864];
      8'b10000000: OS_out_col6 = OS_out_temp[1007:992];
    endcase

    case(OS_out_valid_col7)
      8'b00000001: OS_out_col7 = OS_out_temp[127:112];
      8'b00000010: OS_out_col7 = OS_out_temp[255:240];
      8'b00000100: OS_out_col7 = OS_out_temp[383:368];
      8'b00001000: OS_out_col7 = OS_out_temp[511:496];
      8'b00010000: OS_out_col7 = OS_out_temp[639:624];
      8'b00100000: OS_out_col7 = OS_out_temp[767:752];
      8'b01000000: OS_out_col7 = OS_out_temp[895:880];
      8'b10000000: OS_out_col7 = OS_out_temp[1023:1008];
    endcase

end




generate
genvar i;
for (i=1; i < row+1 ; i=i+1) begin : row_num
  mac_row #(.bw(bw), .psum_bw(psum_bw), .col(col)) mac_row_instance (
    .clk(clk),
    .out_s(temp[(i+1)*col*psum_bw-1:i*col*psum_bw]),
    .in_w(in_w[bw*i-1:bw*(i-1)]),
    .in_n(temp[i*psum_bw*col-1:(i-1)*psum_bw*col]),
    .valid(valid_temp[col*i-1:col*(i-1)]),
    .inst_w(inst_w_temp[2*i-1:2*(i-1)]),
    .reset(reset),
    .WeightOrOutput(WeightOrOutput),
    .IFIFO_loop(IFIFO_loop_temp[col*i-1:col*(i-1)]),
    .OS_out_valid(OS_out_valid_temp[col*i-1:col*(i-1)]),
    .OS_out(OS_out_temp[psum_bw*col*i-1:psum_bw*col*(i-1)])
    );
end
endgenerate



always @ (posedge clk) begin
    inst_w_temp[1:0] <= inst_w;
    inst_w_temp[3:2] <= inst_w_temp[1:0];
    inst_w_temp[5:4] <= inst_w_temp[3:2];
    inst_w_temp[7:6] <= inst_w_temp[5:4];
    inst_w_temp[9:8] <= inst_w_temp[7:6];
    inst_w_temp[11:10] <= inst_w_temp[9:8];
    inst_w_temp[13:12] <= inst_w_temp[11:10];
    inst_w_temp[15:14] <= inst_w_temp[13:12];
end

endmodule
