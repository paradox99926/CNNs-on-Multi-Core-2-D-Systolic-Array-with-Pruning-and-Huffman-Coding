
module pruning(clk,
               reset,
               pruning_in,
               pruning_out,
               pruning_begin);
    
    parameter col             = 8;   // Number of columns in the MAC array and OFIFO
    parameter bw              = 4;   // Bit-width of input weights and activations
    parameter pruning_version = 0;
    parameter pruning_num     = 4;
    parameter unit_thres      = 1;
    
    input clk;
    input reset;
    input [bw*col-1:0] pruning_in;
    input pruning_begin;
    output [bw*col-1:0] pruning_out;
    
    reg [bw*col-1:0] pruning_in_temp;
    reg [bw*col-1:0] norm;
    reg [bw*col-1:0] norm1;
    reg [bw*col-1:0] norm2;
    wire [bw-1:0] abs_0;
    wire [bw-1:0] abs_1;
    wire [bw-1:0] abs_2;
    wire [bw-1:0] abs_3;
    wire [bw-1:0] abs_4;
    wire [bw-1:0] abs_5;
    wire [bw-1:0] abs_6;
    wire [bw-1:0] abs_7;
    
    
    assign abs_0 = ((pruning_in[bw*1-1] == 1)?(~pruning_in[bw*1-1:bw*0] + 1'b1):pruning_in[bw*1-1:bw*0]);
    assign abs_1 = ((pruning_in[bw*2-1] == 1)?(~pruning_in[bw*2-1:bw*1] + 1'b1):pruning_in[bw*2-1:bw*1]);
    assign abs_2 = ((pruning_in[bw*3-1] == 1)?(~pruning_in[bw*3-1:bw*2] + 1'b1):pruning_in[bw*3-1:bw*2]);
    assign abs_3 = ((pruning_in[bw*4-1] == 1)?(~pruning_in[bw*4-1:bw*3] + 1'b1):pruning_in[bw*4-1:bw*3]);
    assign abs_4 = ((pruning_in[bw*5-1] == 1)?(~pruning_in[bw*5-1:bw*4] + 1'b1):pruning_in[bw*5-1:bw*4]);
    assign abs_5 = ((pruning_in[bw*6-1] == 1)?(~pruning_in[bw*6-1:bw*5] + 1'b1):pruning_in[bw*6-1:bw*5]);
    assign abs_6 = ((pruning_in[bw*7-1] == 1)?(~pruning_in[bw*7-1:bw*6] + 1'b1):pruning_in[bw*7-1:bw*6]);
    assign abs_7 = ((pruning_in[bw*8-1] == 1)?(~pruning_in[bw*8-1:bw*7] + 1'b1):pruning_in[bw*8-1:bw*7]);
    
    assign pruning_out = pruning_in_temp;
    
    always @(posedge clk) begin
        if (reset||(~pruning_begin))begin
            pruning_in_temp <= 0;
        end
        else begin
            case (pruning_version)
                0:begin
                    pruning_in_temp[bw*1-1:bw*0] <= (abs_0>unit_thres)?pruning_in[bw*1-1:bw*0]:0;
                    pruning_in_temp[bw*2-1:bw*1] <= (abs_1>unit_thres)?pruning_in[bw*2-1:bw*1]:0;
                    pruning_in_temp[bw*3-1:bw*2] <= (abs_2>unit_thres)?pruning_in[bw*3-1:bw*2]:0;
                    pruning_in_temp[bw*4-1:bw*3] <= (abs_3>unit_thres)?pruning_in[bw*4-1:bw*3]:0;
                    pruning_in_temp[bw*5-1:bw*4] <= (abs_4>unit_thres)?pruning_in[bw*5-1:bw*4]:0;
                    pruning_in_temp[bw*6-1:bw*5] <= (abs_5>unit_thres)?pruning_in[bw*6-1:bw*5]:0;
                    pruning_in_temp[bw*7-1:bw*6] <= (abs_6>unit_thres)?pruning_in[bw*7-1:bw*6]:0;
                    pruning_in_temp[bw*8-1:bw*7] <= (abs_7>unit_thres)?pruning_in[bw*8-1:bw*7]:0;
                end
                
                1:begin
                    norm1                                    <= abs_0+abs_1+abs_2+abs_3;
                    norm2                                    <= abs_4+abs_5+abs_6+abs_7;
                    pruning_in_temp[bw*pruning_num-1:bw*0]   <= (norm1>unit_thres*pruning_num)?pruning_in[bw*pruning_num-1:bw*0]:0;
                    pruning_in_temp[bw*col-1:bw*pruning_num] <= (norm2>unit_thres*pruning_num)?pruning_in[bw*col-1:bw*pruning_num]:0;
                end
                
                2: begin
                    norm <= abs_0+abs_1+abs_2+abs_3+abs_4+abs_5+abs_6+abs_7;
                    if (norm >unit_thres*col)
                        pruning_in_temp <= pruning_in;
                    else
                        pruning_in_temp <= 0;
                end
                
                default: begin
                    pruning_in_temp <= pruning_in;
                end
                
            endcase
        end
    end
    
endmodule
