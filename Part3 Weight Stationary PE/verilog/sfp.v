// Created by 284 little group @UCSD
// Please do not spread this code without permission
module sfp (clk,
            reset,
            acc_q,
            sfp_in,
            sfp_out);
    
    parameter psum_bw      = 16;  // Bit-width of partial sum
    parameter col          = 8;   // Number of columns
    parameter signed thres = 8'b00000000;   // Number of columns
    parameter relu         = 1'b1;
    
    input  clk;
    input  reset;
    input  acc_q;                               // Accumulation enable signal
    input  signed [psum_bw*col-1:0] sfp_in;    // Input data
    output reg signed [psum_bw*col-1:0] sfp_out; // Output result
    
    // Logic block: Clock synchronization
    always @ (posedge clk) begin
        if (reset) begin
            sfp_out <= 0;   // Clear output
        end
        else begin
            if (acc_q) begin
                sfp_out[psum_bw*1-1:psum_bw*0] <= $signed(sfp_out[psum_bw*1-1:psum_bw*0]) + $signed(sfp_in[psum_bw*1-1:psum_bw*0]);
                sfp_out[psum_bw*2-1:psum_bw*1] <= $signed(sfp_out[psum_bw*2-1:psum_bw*1]) + $signed(sfp_in[psum_bw*2-1:psum_bw*1]);
                sfp_out[psum_bw*3-1:psum_bw*2] <= $signed(sfp_out[psum_bw*3-1:psum_bw*2]) + $signed(sfp_in[psum_bw*3-1:psum_bw*2]);
                sfp_out[psum_bw*4-1:psum_bw*3] <= $signed(sfp_out[psum_bw*4-1:psum_bw*3]) + $signed(sfp_in[psum_bw*4-1:psum_bw*3]);
                sfp_out[psum_bw*5-1:psum_bw*4] <= $signed(sfp_out[psum_bw*5-1:psum_bw*4]) + $signed(sfp_in[psum_bw*5-1:psum_bw*4]);
                sfp_out[psum_bw*6-1:psum_bw*5] <= $signed(sfp_out[psum_bw*6-1:psum_bw*5]) + $signed(sfp_in[psum_bw*6-1:psum_bw*5]);
                sfp_out[psum_bw*7-1:psum_bw*6] <= $signed(sfp_out[psum_bw*7-1:psum_bw*6]) + $signed(sfp_in[psum_bw*7-1:psum_bw*6]);
                sfp_out[psum_bw*8-1:psum_bw*7] <= $signed(sfp_out[psum_bw*8-1:psum_bw*7]) + $signed(sfp_in[psum_bw*8-1:psum_bw*7]);
            end
            else if (relu) begin
                sfp_out[psum_bw*1-1:psum_bw*0] <= ($signed(sfp_out[psum_bw*1-1:psum_bw*0]) > thres) ? sfp_out[psum_bw*1-1:psum_bw*0]: 0;
                sfp_out[psum_bw*2-1:psum_bw*1] <= ($signed(sfp_out[psum_bw*2-1:psum_bw*1]) > thres) ? sfp_out[psum_bw*2-1:psum_bw*1]: 0;
                sfp_out[psum_bw*3-1:psum_bw*2] <= ($signed(sfp_out[psum_bw*3-1:psum_bw*2]) > thres) ? sfp_out[psum_bw*3-1:psum_bw*2]: 0;
                sfp_out[psum_bw*4-1:psum_bw*3] <= ($signed(sfp_out[psum_bw*4-1:psum_bw*3]) > thres) ? sfp_out[psum_bw*4-1:psum_bw*3]: 0;
                sfp_out[psum_bw*5-1:psum_bw*4] <= ($signed(sfp_out[psum_bw*5-1:psum_bw*4]) > thres) ? sfp_out[psum_bw*5-1:psum_bw*4]: 0;
                sfp_out[psum_bw*6-1:psum_bw*5] <= ($signed(sfp_out[psum_bw*6-1:psum_bw*5]) > thres) ? sfp_out[psum_bw*6-1:psum_bw*5]: 0;
                sfp_out[psum_bw*7-1:psum_bw*6] <= ($signed(sfp_out[psum_bw*7-1:psum_bw*6]) > thres) ? sfp_out[psum_bw*7-1:psum_bw*6]: 0;
                sfp_out[psum_bw*8-1:psum_bw*7] <= ($signed(sfp_out[psum_bw*8-1:psum_bw*7]) > thres) ? sfp_out[psum_bw*8-1:psum_bw*7]: 0;
            end
                end
                end
                endmodule
