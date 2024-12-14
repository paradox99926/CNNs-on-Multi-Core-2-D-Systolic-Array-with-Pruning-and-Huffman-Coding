// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission
module ofifo (clk,
              in,
              out,
              rd,
              wr,
              o_full,
              reset,
              o_ready,
              o_valid);

    // Receives the data at each column at different timing
    // Read out all columns at a time

    parameter col = 8;
    parameter bw  = 16;

    input  clk;
    input  [col-1:0] wr;
    input  [bw*col-1:0] in;
    input  rd;
    input  reset;
    output o_full;
    output o_ready;
    output o_valid;
    output [bw*col-1:0] out;

    wire [col-1:0] empty;
    wire [col-1:0] full;
    reg  rd_en;

    genvar i;

    assign o_ready = ~(|full);    // high if all col_fifo are not full
    assign o_full  = |full;       // high if any col_fifo is full
    assign o_valid = &(~empty);   // high if all col_fifo is not empty,
                                  // so that all columns can be read out at same time

    generate
    for (i = 0; i<col ; i = i+1) begin : col_num
    fifo_depth64 #(.bw(bw)) fifo_instance (
    .rd_clk(clk),
    .wr_clk(clk),
    .rd(rd_en),
    .wr(wr[i]),
    .o_empty(empty[i]),
    .o_full(full[i]),
    .in(in[bw*(i+1)-1:bw*i]),
    .out(out[bw*(i+1)-1:bw*i]),
    .reset(reset));
    end
    endgenerate

    always @ (posedge clk) begin
        if (reset) begin
            rd_en <= 0;
        end
        else begin
            rd_en <= rd;    //read out at the same time
        end

    end


endmodule
