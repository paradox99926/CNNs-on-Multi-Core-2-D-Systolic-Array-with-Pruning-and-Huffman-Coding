 // Created by 284 Little Group @UCSD
// Please do not spread this code without permission

module corelet (clk,
                reset,
                ofifo_valid,
                ofifo_valid2,
                sfp_in,
                final_out,
                final_out2,
                inst,
                l0_in,
                l1_in,
                l0_o_full,
                l0_o_ready,
                l1_o_full,
                l1_o_ready,
                ofifo_out,
                ofifo2_rd,
                ofifo_o_full,
                ofifo_o_ready,
                ofifo_o_full2,
                ofifo_o_ready2,
                ififo_in,
                ififo_o_full,
                ififo_o_ready,
                ififo_valid,
                rd_version,
                l1_wr,
                l1_rd,
                WeightOrOutput);

    // Parameters for corelet configuration
    parameter row     = 8;   // Number of rows in the L0 buffer and MAC array
    parameter col     = 8;   // Number of columns in the MAC array and OFIFO
    parameter bw      = 4;   // Bit-width of input weights and activations
    parameter psum_bw = 16;  // Bit-width of partial sums

    // Inputs
    input ofifo2_rd;                   // Read enable signal for OFIFO2
    input clk;                         // Clock signal
    input reset;                       // Reset signal (active high)
    input [33:0] inst;                 // Control instructions for corelet operation
    input [row*bw-1:0] l0_in;          // Input data for the L0 buffer
    input [row*bw-1:0] l1_in;          // Input data for the L0 buffer
    input rd_version;                  // Read version signal for L0 buffer
    input [psum_bw*col-1:0] sfp_in;    // Input data for the SFP module
    input [col*bw-1:0] ififo_in;       // Input weight data for the IFIFO module
    input WeightOrOutput;              // 0: weight stationary; 1: output stationsary
    input l1_wr;                       // Write enable signal for L1 buffer
    input l1_rd;                       // Read enable signal for L1 buffer
    // Outputs
    output l0_o_full;                  // Full signal from L0 buffer
    output l0_o_ready;                 // Ready signal from L0 buffer
    output l1_o_full;                  // Full signal from L1 buffer
    output l1_o_ready;                 // Ready signal from L1 buffer
    output ofifo_o_full;               // Full signal from OFIFO
    output ofifo_o_ready;              // Ready signal from OFIFO
    output ofifo_valid;                // Valid signal indicating OFIFO has valid data
    output ofifo_o_full2;               // Full signal from OFIFO
    output ofifo_o_ready2;              // Ready signal from OFIFO
    output ofifo_valid2;                // Valid signal indicating OFIFO has valid data
    output [col*psum_bw-1:0] ofifo_out;// Output data from OFIFO
    output [psum_bw*col-1:0] final_out;  // Final Output data
    output [psum_bw*col-1:0] final_out2;  // Final Output data
    output ififo_o_full;               // Full signal from IFIFO
    output ififo_o_ready;              // Ready signal from IFIFO
    output ififo_valid;                // Valid signal indicating IFIFO has valid data
    // Internal wires
    wire [psum_bw*col-1:0] Array2ofifo_out; // Data from MAC array to OFIFO
    wire [psum_bw*col-1:0] Array2ofifo_out2; // Data from MAC array to OFIFO
    wire [psum_bw*col-1:0] Array2ofifo_out_WS_1; // Data from MAC array to OFIFO in Weight Stationary mode
    wire [psum_bw*col-1:0] Array2ofifo_out_OS_1; // Data from MAC array to OFIFO in Output Stationary mode
    wire [psum_bw*col-1:0] Array2ofifo_out_WS_2; // Data from MAC array to OFIFO in Weight Stationary mode
    wire [psum_bw*col-1:0] Array2ofifo_out_OS_2; // Data from MAC array to OFIFO in Output Stationary mode
    wire [psum_bw*col-1:0] sfp_out;  // Output data from SFP
    wire [col*psum_bw-1:0] ofifo_out2;// Output data from OFIFO
    assign final_out = WeightOrOutput ? ofifo_out : sfp_out;
    assign final_out2 = WeightOrOutput ? ofifo_out2 : sfp_out;
    assign Array2ofifo_out = WeightOrOutput ? Array2ofifo_out_OS_1 : Array2ofifo_out_WS_1;
    assign Array2ofifo_out2 = WeightOrOutput ? Array2ofifo_out_OS_2 : Array2ofifo_out_WS_2;

    wire [row*bw-1:0] l02Array_in_w;        // Data from L0 buffer to MAC array's in_w
    wire [row*bw-1:0] l12Array_in_w;        // Data from L1 buffer to MAC array's in_w
    wire [col-1:0] Array2ofifo_valid;       // Valid signal from MAC array to OFIFO
    wire [col-1:0] Array2ofifo_valid2;       // Valid signal from MAC array to OFIFO
    wire [col*bw-1:0] l02Array_in_n;                  // Weight Data from XMEM to ififo in_n
    wire [col*bw-1:0] ififo2Array_in_n;               // Weight Data from ififo to MAC array, 4bit weight
    wire [col*psum_bw-1:0] ififo2Array_in_n_padded;   // Weight Data from ififo to MAC array, 16bit weight
    wire [col*psum_bw-1:0] Array_in_n;                     // north input data for MAC array
    
    // generate
    // genvar i;
    // for (i = 1; i < col+1; i = i + 1) begin : weight_padding_loop
    //     assign ififo2Array_in_n_padded[i*psum_bw-1: psum_bw*(i-1)] = {12'b0, ififo2Array_in_n[i*bw-1:bw*(i-1)]};
    // end
    // endgenerate
    assign ififo2Array_in_n_padded = 
    {
        12'b000000000000, ififo2Array_in_n[31:28],
        12'b000000000000, ififo2Array_in_n[27:24],
        12'b000000000000, ififo2Array_in_n[23:20],
        12'b000000000000, ififo2Array_in_n[19:16],
        12'b000000000000, ififo2Array_in_n[15:12],
        12'b000000000000, ififo2Array_in_n[11:8],
        12'b000000000000, ififo2Array_in_n[7:4],
        12'b000000000000, ififo2Array_in_n[3:0]
    };
    assign Array_in_n = WeightOrOutput ? ififo2Array_in_n_padded : 0;

    wire [col-1:0] IFIFO_loop;                      // Valid signal from first row in Output Stationary mode

    // L0 Buffer Instance
    // This module serves as a local buffer to provide input data to the MAC array.
    l0 #(
    .row(row),
    .bw(bw)
    ) l0_instance (
    .clk(clk),
    .wr(inst[2]),             // Write enable for L0 buffer
    .rd(inst[3]),             // Read enable for L0 buffer
    .reset(reset),            // Reset signal
    .in(l0_in),               // Input data to the L0 buffer
    .out(l02Array_in_w),      // Output data from L0 buffer to MAC array
    .o_full(l0_o_full),       // Full signal from L0 buffer
    .o_ready(l0_o_ready),     // Ready signal from L0 buffer
    .rd_version(rd_version)  // Read version signal
    //.WeightOrOutput(WeightOrOutput)
    );

    l0 #(
    .row(row),
    .bw(bw)
    ) l1_instance (
    .clk(clk),
    .wr(l1_wr),             // Write enable for L0 buffer
    .rd(l1_rd),             // Read enable for L0 buffer
    .reset(reset),            // Reset signal
    .in(l1_in),               // Input data to the L0 buffer
    .out(l12Array_in_w),      // Output data from L0 buffer to MAC array
    .o_full(l1_o_full),       // Full signal from L0 buffer
    .o_ready(l1_o_ready),     // Ready signal from L0 buffer
    .rd_version(rd_version)  // Read version signal
    //.WeightOrOutput(WeightOrOutput)
    );

    // MAC Array Instance
    // This module performs matrix multiplication and generates partial sums.
    mac_array #(
    .bw(bw),
    .psum_bw(psum_bw),
    .col(col),
    .row(row)
    ) mac_array_instance1 (
    .clk(clk),
    .reset(reset),
    .out_s(Array2ofifo_out_WS_1),       // Output partial sums to OFIFO
    .in_w(l02Array_in_w),             // Input weights/activations from L0
    .inst_w(inst[1:0]),               // Instructions for MAC operation
    .in_n(Array_in_n),          // north input is weight data from ififo
    .WeightOrOutput(WeightOrOutput),  // 0: weight stationary; 1: output stationsary
    .OS_out(Array2ofifo_out_OS_1),       // Output data for Output Stationary mode
    .IFIFO_loop(IFIFO_loop),       // Valid signal from first row in Output Stationary mode
    .valid(Array2ofifo_valid)        // Valid signal for output data, WS -- last row of MAC array, OS -- 
    );

    mac_array #(
    .bw(bw),
    .psum_bw(psum_bw),
    .col(col),
    .row(row)
    ) mac_array_instance2 (
    .clk(clk),
    .reset(reset),
    .out_s(Array2ofifo_out_WS_2),       // Output partial sums to OFIFO
    .in_w(l12Array_in_w),             // Input weights/activations from L0
    .inst_w(inst[1:0]),               // Instructions for MAC operation
    .in_n(Array_in_n),          // north input is weight data from ififo
    .WeightOrOutput(WeightOrOutput),  // 0: weight stationary; 1: output stationsary
    .OS_out(Array2ofifo_out_OS_2),       // Output data for Output Stationary mode
    .IFIFO_loop(IFIFO_loop),       // Valid signal from first row in Output Stationary mode
    .valid(Array2ofifo_valid2)        // Valid signal for output data, WS -- last row of MAC array, OS -- 
    );


    // OFIFO (Output FIFO) Instance
    // Buffers the output of the MAC array for further processing.
    ofifo #(
    .col(col),
    .bw(psum_bw)
    ) ofifo_instance1 (
    .clk(clk),
    .wr(Array2ofifo_valid),           // Write enable from MAC array
    .rd(inst[6]),                     // Read enable signal
    .reset(reset),                    // Reset signal
    .in(Array2ofifo_out),             // Input data from MAC array
    .out(ofifo_out),                  // Output data from OFIFO
    .o_full(ofifo_o_full),            // Full signal from OFIFO
    .o_ready(ofifo_o_ready),          // Ready signal from OFIFO
    .o_valid(ofifo_valid)            // Valid signal from OFIFO
    );

    ofifo #(
    .col(col),
    .bw(psum_bw)
    ) ofifo_instance2 (
    .clk(clk),
    .wr(Array2ofifo_valid2),           // Write enable from MAC array
    .rd(ofifo2_rd),                     // Read enable signal
    .reset(reset),                    // Reset signal
    .in(Array2ofifo_out2),             // Input data from MAC array
    .out(ofifo_out2),                  // Output data from OFIFO
    .o_full(ofifo_o_full2),            // Full signal from OFIFO
    .o_ready(ofifo_o_ready2),          // Ready signal from OFIFO
    .o_valid(ofifo_valid2)            // Valid signal from OFIFO
    );

    // IFIFO (Iuput FIFO) Instance
    // Local buffer for the input weights.
    ififo #(
    .col(col),
    .bw(bw)
    ) ififo_instance (
    .clk(clk),
    .wr(inst[5]),                     // Write enable signal for ififo
    .rd(inst[4]),                     // Read enable signal for ififo
    .reset(reset),                    // Reset signal
    .in(ififo_in),             // Weight input data from SRAM to ififo
    .out(ififo2Array_in_n),                  // Output data from OFIFO
    .o_full(ififo_o_full),            // Full signal from IFIFO
    .o_ready(ififo_o_ready),          // Ready signal from IFIFO
    .loop_flag(IFIFO_loop),
    .o_valid(ififo_valid)            // Valid signal from IFIFO
    );


    // SFP (Sum Function Processor) Instance
    // Accumulates partial sums and applies ReLU or other operations.
    sfp #(
    .psum_bw(psum_bw),
    .col(col)
    ) sfp_instance (
    .clk(clk),
    .reset(reset),
    .acc_q(inst[33]),                  // Accumulation enable signal
    .sfp_in(sfp_in),                   // Input data for accumulation
    .sfp_out(sfp_out)                 // Final accumulated output
    //.WeightOrOutput(WeightOrOutput)
    );


endmodule
