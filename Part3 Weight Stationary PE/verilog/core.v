// Created by 284 little group @UCSD
// Please do not spread this code without permission
module core (clk,
             reset,
             inst,
             D_xmem,
             l0_ofifo_valid,
             sfp_out,
             rd_version);
    
    parameter bw      = 4;
    parameter psum_bw = 16;
    parameter col     = 8;
    parameter row     = 8;
    
    input clk;
    input reset;
    input [33:0] inst;
    input [31:0] D_xmem;
    input rd_version;
    output [4:0] l0_ofifo_valid;//4:ofifi o_valid; 3:ofifi o_ready; 2:ofifi o_full; 1:l0 o_full; 0:l0 o_ready;
    output [127:0] sfp_out;
    
    
    wire [127:0] sfp_in;
    wire [31:0] sram2l0_in;
    wire [127:0] ofifo2sram_out;
    
    // //////////////////////////////////////////////////////////
    // inst[33]    = acc_q;        // Accumulation control signal
    // inst[32]    = CEN_pmem_q;   // PMEM read enable signal, active low
    // inst[31]    = WEN_pmem_q;   // PMEM write enable signal, active low
    // inst[30:20] = A_pmem_q;     // PMEM address
    // inst[19]    = CEN_xmem_q;   // XMEM read enable signal, active low
    // inst[18]    = WEN_xmem_q;   // XMEM write enable signal, active low
    // inst[17:7]  = A_xmem_q;     // XMEM address
    // inst[6]     = ofifo_rd_q;   // OFIFO read enable signal
    // inst[5]     = ififo_wr_q;   // IFIFO write enable signal
    // inst[4]     = ififo_rd_q;   // IFIFO read enable signal
    // inst[3]     = l0_rd_q;      // L0 read enable signal
    // inst[2]     = l0_wr_q;      // L0 write enable signal
    // inst[1]     = execute_q;    // Execution enable signal
    // inst[0]     = load_q;       // Kernel loading enable signal
    // //////////////////////////////////////////////////////////
    
    
    corelet #(.row(row), .col(col), .bw(bw), .psum_bw(psum_bw)) corelet_instance(
    .clk(clk),
    .reset(reset),
    .ofifo_valid(l0_ofifo_valid[4]),
    .sfp_in(sfp_in),
    .sfp_out(sfp_out),
    .inst(inst),
    .l0_in(sram2l0_in),
    .l0_o_full(l0_ofifo_valid[1]),
    .l0_o_ready(l0_ofifo_valid[0]),
    .ofifo_out(ofifo2sram_out),
    .ofifo_o_full(l0_ofifo_valid[2]),
    .ofifo_o_ready(l0_ofifo_valid[3]),
    .rd_version(rd_version));
    
    sram_32b_w2048 input_sram(
    .CLK(clk),
    .D(D_xmem),
    .Q(sram2l0_in),
    .CEN(inst[19]),
    .WEN(inst[18]),
    .A(inst[17:7]));
    
    sram_128b_w2048 psum_sram(
    .CLK(clk),
    .D(ofifo2sram_out),
    .Q(sfp_in),
    .CEN(inst[32]),
    .WEN(inst[31]),
    .A(inst[30:20]));
    
    
endmodule
