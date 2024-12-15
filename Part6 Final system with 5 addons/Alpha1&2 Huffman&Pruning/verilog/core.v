// Created by 284 little group @UCSD
// Please do not spread this code without permission

module core (clk,
             reset,
             inst,
             D_xmem,
             l0_ofifo_valid,
             ififo_valid,
             sfp_out,
             WeightOrOutput);
    
    parameter bw              = 4;
    parameter psum_bw         = 16;
    parameter col             = 8;
    parameter row             = 8;
    parameter pruning_version = 0;
    parameter pruning_num     = 4;
    parameter unit_thres      = 1;
    
    input clk;
    input reset;
    input [37:0] inst;
    input [31:0] D_xmem;
    input WeightOrOutput;       // 0: weight stationary; 1: output stationsary
    output [4:0] l0_ofifo_valid; //4:ofifi o_valid; 3:ofifi o_ready; 2:ofifi o_full; 1:l0 o_full; 0:l0 o_ready;
    output [127:0] sfp_out;
    output [2:0] ififo_valid;    //2:ififo o_valid; 1:ififo o_ready; 0:ififo o_full;
    
    wire [127:0] sfp_in;
    wire [31:0] sram2l0_in;
    wire [127:0] ofifo2sram_out;
    wire [31:0] sram2ififo_in;
    wire [bw*row-1:0]prun2sram_in;
    wire [bw*row-1:0]encoder_in;
    wire [bw*row-1:0]decoded_out;
    wire [bw*row-1:0]pruning_in;
    
    // //////////////////////////////////////////////////////////
    //inst_q[37]    = pruning_begin_q;// pruning begin signal
    //inst_q[36:35] = huf_inst_q;     // [1] pass signal; [0] Heffman begin signal
    //inst_q[34]    = rd_version_q;   // l0 read version
    //inst_q[33]    = acc_q;          // Accumulation control signal
    //inst_q[32]    = CEN_pmem_q;     // PMEM read enable signal, active low
    //inst_q[31]    = WEN_pmem_q;     // PMEM write enable signal, active low
    //inst_q[30:20] = A_pmem_q;       // PMEM address
    //inst_q[19]    = CEN_xmem_q;     // XMEM read enable signal, active low
    //inst_q[18]    = WEN_xmem_q;     // XMEM write enable signal, active low
    //inst_q[17:7]  = A_xmem_q;       // XMEM address
    //inst_q[6]     = ofifo_rd_q;     // OFIFO read enable signal
    //inst_q[5]     = ififo_wr_q;     // IFIFO write enable signal
    //inst_q[4]     = ififo_rd_q;     // IFIFO read enable signal
    //inst_q[3]     = l0_rd_q;        // L0 read enable signal
    //inst_q[2]     = l0_wr_q;        // L0 write enable signal
    //inst_q[1]     = execute_q;      // Execution enable signal
    //inst_q[0]     = load_q;         // Kernel loading enable signal
    // //////////////////////////////////////////////////////////
    assign encoder_in = WeightOrOutput? 0 : D_xmem;
    assign pruning_in = WeightOrOutput? D_xmem : decoded_out;
    
    corelet #(.row(row),
    .col(col),
    .bw(bw),
    .psum_bw(psum_bw),
    .pruning_version(pruning_version),
    .pruning_num(pruning_num),
    .unit_thres(unit_thres)
    ) corelet_instance(
    .clk(clk),
    .reset(reset),
    .ofifo_valid(l0_ofifo_valid[4]),
    .sfp_in(sfp_in),
    .final_out(sfp_out),
    .inst(inst),
    .l0_in(sram2l0_in),
    .l0_o_full(l0_ofifo_valid[1]),
    .l0_o_ready(l0_ofifo_valid[0]),
    .ofifo_out(ofifo2sram_out),
    .ofifo_o_full(l0_ofifo_valid[2]),
    .ofifo_o_ready(l0_ofifo_valid[3]),
    .WeightOrOutput(WeightOrOutput),
    .ififo_in(sram2l0_in),
    .ififo_o_full(ififo_valid[0]),
    .ififo_o_ready(ififo_valid[1]),
    .ififo_valid(ififo_valid[2]),
    .encoded_data(encoder_in),
    .decoded_out(decoded_out),
    .pruning_in(pruning_in),
    .pruning_out(prun2sram_in)
    );
    
    sram_32b_w2048 input_sram(
    .CLK(clk),
    .D(prun2sram_in),
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
