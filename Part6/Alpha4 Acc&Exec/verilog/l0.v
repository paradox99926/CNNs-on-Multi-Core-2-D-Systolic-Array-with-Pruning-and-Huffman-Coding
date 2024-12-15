// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission

module l0 (clk,
           in,
           out,
           rd,
           wr,
           o_full,
           reset,
           o_ready,
           rd_version);

    parameter row = 8;
    parameter bw  = 4;

    input  clk;                     // Clock signal
    input  wr;                      // Write enable signal
    input  rd;                      // Read enable signal
    input  reset;                   // Reset signal (active low)
    input  [row*bw-1:0] in;         // Input data (row*bw bits wide)
    input  rd_version;
    output [row*bw-1:0] out;        // Output data (row*bw bits wide)
    output o_full;                  // High if any row_fifo is full
    output o_ready;                 // High if all row_fifo are empty (ready for new writes)

    wire [row-1:0] empty;           // Empty flags for each row
    wire [row-1:0] full;            // Full flags for each row
    reg [row-1:0] rd_en;            // Read enable signals for each row

    genvar i;
    assign o_ready = &empty;
    assign o_full = |full;

    generate
    for (i = 0; i<row ; i = i+1) begin : row_num
    fifo_depth64 #(.bw(bw)) fifo_instance (
    .rd_clk(clk),
    .wr_clk(clk),
    .rd(rd_en[i]),
    .wr(wr),
    .o_empty(empty[i]),
    .o_full(full[i]),
    .in(in[bw*(i+1)-1:bw*i]),
    .out(out[bw*(i+1)-1:bw*i]),
    .reset(reset));
    end
    endgenerate


    always @ (posedge clk) begin
        if (reset) begin
            rd_en <= 8'b00000000;
        end
        else begin
            case(rd_version)
                /////////////// version1: read all row at a time ////////////////
                0:
                begin
                    if (rd)
                    begin
                        rd_en <= 8'b11111111;
                    end
                    else begin
                        rd_en <= 8'b00000000;
                    end
                end
                //////////////// version2: read 1 row at a time /////////////////
                1:
                begin
                    rd_en[0] <= rd;
                    rd_en[1] <= rd_en[0];
                    rd_en[2] <= rd_en[1];
                    rd_en[3] <= rd_en[2];
                    rd_en[4] <= rd_en[3];
                    rd_en[5] <= rd_en[4];
                    rd_en[6] <= rd_en[5];
                    rd_en[7] <= rd_en[6];
                end
                ///////////////////////////////////////////////////////
            endcase
        end
    end
endmodule
