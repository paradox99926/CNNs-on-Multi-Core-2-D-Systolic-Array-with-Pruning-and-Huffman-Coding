// Created by 284 Little Group @UCSD
// Please do not spread this code without permission
module corelet (clk,
                reset,
                ofifo_valid,
                sfp_in,
                sfp_out,
                inst,
                l0_in,
                l0_o_full,
                l0_o_ready,
                ofifo_out,
                ofifo_o_full,
                ofifo_o_ready,
                rd_version);
    
    // Parameters for corelet configuration
    parameter row     = 8;   // Number of rows in the L0 buffer and MAC array
    parameter col     = 8;   // Number of columns in the MAC array and OFIFO
    parameter bw      = 4;   // Bit-width of input weights and activations
    parameter psum_bw = 16;  // Bit-width of partial sums
    
    // Inputs
    input clk;                         // Clock signal
    input reset;                       // Reset signal (active high)
    input [33:0] inst;                 // Control instructions for corelet operation
    input [row*bw-1:0] l0_in;          // Input data for the L0 buffer
    input rd_version;                  // Read version signal for L0 buffer
    input [psum_bw*col-1:0] sfp_in;    // Input data for the SFP module
    
    // Outputs
    output l0_o_full;                  // Full signal from L0 buffer
    output l0_o_ready;                 // Ready signal from L0 buffer
    output ofifo_o_full;               // Full signal from OFIFO
    output ofifo_o_ready;              // Ready signal from OFIFO
    output ofifo_valid;                // Valid signal indicating OFIFO has valid data
    output [col*psum_bw-1:0] ofifo_out;// Output data from OFIFO
    output [psum_bw*col-1:0] sfp_out;  // Output data from SFP
    
    // Internal wires
    wire [psum_bw*col-1:0] Array2ofifo_out; // Data from MAC array to OFIFO
    wire [row*bw-1:0] l02Array_in_w;        // Data from L0 buffer to MAC array's in_w
    wire [col-1:0] Array2ofifo_valid;       // Valid signal from MAC array to OFIFO
    
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
    .rd_version(rd_version)   // Read version signal
    );
    
    // MAC Array Instance
    // This module performs matrix multiplication and generates partial sums.
    mac_array #(
    .bw(bw),
    .psum_bw(psum_bw),
    .col(col),
    .row(row)
    ) mac_array_instance (
    .clk(clk),
    .reset(reset),
    .out_s(Array2ofifo_out),          // Output partial sums to OFIFO
    .in_w(l02Array_in_w),             // Input weights/activations from L0
    .inst_w(inst[1:0]),               // Instructions for MAC operation
    .in_n(0),                         // No north input in weight stationary mode
    .valid(Array2ofifo_valid)         // Valid signal for output data
    );
    
    // OFIFO (Output FIFO) Instance
    // Buffers the output of the MAC array for further processing.
    ofifo #(
    .col(col),
    .bw(psum_bw)
    ) ofifo_instance (
    .clk(clk),
    .wr(Array2ofifo_valid),           // Write enable from MAC array
    .rd(inst[6]),                     // Read enable signal
    .reset(reset),                    // Reset signal
    .in(Array2ofifo_out),             // Input data from MAC array
    .out(ofifo_out),                  // Output data from OFIFO
    .o_full(ofifo_o_full),            // Full signal from OFIFO
    .o_ready(ofifo_o_ready),          // Ready signal from OFIFO
    .o_valid(ofifo_valid)             // Valid signal from OFIFO
    );
    
    // SFP (Sum-Final Processing) Instance
    // Accumulates partial sums and applies ReLU or other operations.
    sfp #(
    .psum_bw(psum_bw),
    .col(col)
    ) sfp_instance (
    .clk(clk),
    .reset(reset),
    .acc_q(inst[33]),                  // Accumulation enable signal
    .sfp_in(sfp_in),                   // Input data for accumulation
    .sfp_out(sfp_out)                  // Final accumulated output
    );
    
endmodule
