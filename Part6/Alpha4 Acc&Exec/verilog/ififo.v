// Created by 284 little group @UCSD
// Please do not spread this code without permission

module ififo (clk,
           in,
           out,
           rd,
           wr,
           o_full,
           reset,
           o_ready,
           loop_flag,
           o_valid);

    // Receive the weight data from SRAM
    // Send the weight data to each column at different timing

    // col0 col1 col2 col3 col4
    // ...
    // k04  k13  k22  k31  k40
    // k03  k12  k21  k30
    // k02  k11  k20
    // k01  k10
    // k00

    parameter col = 8;
    parameter bw  = 4;

    input  clk;                     // Clock signal
    input  wr;                      // Write enable signal
    input  rd;                      // Read enable signal
    input  reset;                   // Reset signal (active low)
    input  [col*bw-1:0] in;         // Input data (col*bw bits wide)
    input  [col-1:0] loop_flag;     // High if the first PE of the col finish the 9times accumulation

    output [col*bw-1:0] out;        // Output data (col*bw bits wide)
    output o_full;                  // High if any col_fifo is full
    output o_ready;                 // High if all col_fifo are empty (ready for new writes)
    output o_valid;                 // High if all col_fifo are not empty, so that all columns can be read out at a time
                                    // really need this signal?

    wire [col-1:0] empty;           // Empty flags for each col
    wire [col-1:0] full;            // Full flags for each col
    reg [col-1:0] rd_en;            // Read enable signals for each col

    genvar i;

    assign o_ready = &empty;
    assign o_full = |full;
    assign o_valid = &(~empty);

    generate
    for (i = 0; i<col ; i = i+1) begin : col_num
    fifo_depth64 #(.bw(bw)) fifo_instance (
    .rd_clk(clk),
    .wr_clk(clk),
    .rd(rd_en[i]),
    .wr(wr),
    .o_empty(empty[i]),
    .o_full(full[i]),
    .in(in[bw*(i+1)-1:bw*i]),
    .out(out[bw*(i+1)-1:bw*i]),
    .rd_ptr_reset(loop_flag[i]),
    .reset(reset));
    end
    endgenerate


    always @ (posedge clk) begin
        if (reset) begin
            rd_en <= 8'b00000000;
        end
        else begin
            rd_en[0] <= rd;
            rd_en[1] <= rd_en[0];
            rd_en[2] <= rd_en[1];
            rd_en[3] <= rd_en[2];
            rd_en[4] <= rd_en[3];
            rd_en[5] <= rd_en[4];
            rd_en[6] <= rd_en[5];
            rd_en[7] <= rd_en[6];
        end
    end

endmodule
