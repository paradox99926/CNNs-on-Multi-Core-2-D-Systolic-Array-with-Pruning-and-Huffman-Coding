module huffman_decoder (clk,
                        reset,
                        load,
                        encoded_data,
                        decoded_out);
    parameter bw  = 4;
    parameter row = 8;
    
    parameter num_0 = 1'b1;        //1'b1
    
    parameter num_2 = 3'b001;      //3'b100
    
    parameter num_3 = 4'b0100;     //4'b1110
    parameter num_5 = 4'b0110;     //5'b11010
    parameter num_1 = 4'b0111;     //4'b0110
    
    parameter num_10 = 5'b00000;    //5'b11000
    parameter num_11 = 5'b00001;    //6'b000101010
    parameter num_4  = 5'b01010;    //4'b0010
    
    parameter num_7  = 6'b000100;   //5'b01000
    parameter num_9  = 6'b000101;   //10'b1110101010
    parameter num_12 = 6'b000110;   //6'b100101010
    parameter num_15 = 6'b000111;   //6'b001010
    parameter num_8  = 6'b010111;   //10'b0110101010
    
    parameter num_6 = 7'b0101101;  //4'b0000
    
    parameter num_13 = 8'b01011000; //6'b010101010
    parameter num_14 = 8'b01011001; //7'b1101010
    
    input clk;
    input reset;
    input load;
    input [row*bw-1:0] encoded_data;
    output reg [row*bw-1:0] decoded_out;
    
    
    reg [1:0]  ready;
    reg [1:0]  state;
    reg [3:0]  decoded_num;
    reg [row*bw-1:0] temp;
    reg [row*bw-1:0] decoded;
    
    always @ (posedge clk) begin
        if (reset) begin
            decoded_out <= 0;
        end
        else begin
            if (ready[0]) begin
                decoded_out <= decoded;
            end
        end
    end
    
    always @ (posedge clk) begin
        if (reset) begin
            temp        <= 64'd0;
            state       <= 'd0;
            decoded     <= 32'd0;
            decoded_num <= 4'd0;
            ready       <= 2'd0;
        end
        else begin
            case (state)
                
                'd0: begin
                    if (load) begin
                        temp        <= encoded_data;
                        state       <= 'd2;
                        decoded_num <= 4'd0;
                        ready       <= 2'd0;
                    end
                    else begin
                        state <= 'd0;
                    end
                end
                
                'd2: begin
                    // 1st
                    if (decoded_num == 4'd0) begin
                        // 1 bit
                        if (temp[0] == 1'b1) begin
                            decoded[3:0] <= 4'd0;
                            state        <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp         <= {1'bz, temp[31:1]};
                            ready        <= 2'd0;
                        end
                        // 3 bits
                        else if (temp[2:0] == 3'b100) begin
                            decoded[3:0] <= 4'd2;
                            state        <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp         <= {3'bzzz, temp[31:3]};
                            ready        <= 2'd0;
                        end
                        // 4 bits
                        else if (temp[3:0] == 4'b1110) begin
                            decoded[3:0] <= 4'd3;
                            state        <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp         <= {4'bzzzz, temp[31:4]};
                            ready        <= 2'd0;
                        end
                        else if (temp[3:0] == 4'b0110) begin
                            decoded[3:0] <= 4'd1;
                            state        <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp         <= {4'bzzzz, temp[31:4]};
                            ready        <= 2'd0;
                        end
                        else if (temp[3:0] == 4'b0010) begin
                            decoded[3:0] <= 4'd4;
                            state        <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp         <= {4'bzzzz, temp[31:4]};
                            ready        <= 2'd0;
                        end
                        else if (temp[3:0] == 4'b0000) begin
                            decoded[3:0] <= 4'd6;
                            state        <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp         <= {4'bzzzz, temp[31:4]};
                            ready        <= 2'd0;
                        end
                        // 5 bits
                        else if (temp[4:0] == 5'b11010) begin
                            decoded[3:0] <= 4'd5;
                            state        <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp 			     <= {5'bzzzzz, temp[31:5]};
                            ready        <= 2'd0;
                        end
                        else if (temp[4:0] == 5'b11000) begin
                            decoded[3:0] <= 4'd10;
                            state     	  <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp 			     <= {5'bzzzzz, temp[31:5]};
                            ready        <= 2'd0;
                        end
                        else if (temp[4:0] == 5'b01000) begin
                            decoded[3:0] <= 4'd7;
                            state     	  <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp 			     <= {5'bzzzzz, temp[31:5]};
                            ready        <= 2'd0;
                        end
                        // 6 bits
                        else if (temp[5:0] == 6'b001010) begin
                            decoded[3:0] <= 4'd15;
                            state     	  <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp 			     <= {6'bzzzzzz, temp[31:6]};
                            ready        <= 2'd0;
                        end
                        // 7 bits
                        else if (temp[6:0] == 7'b1101010) begin
                            decoded[3:0] <= 4'd14;
                            state     	  <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp 			     <= {7'bzzzzzzz, temp[31:7]};
                            ready        <= 2'd0;
                        end
                        // 9 bits
                        else if (temp[8:0] == 9'b000101010) begin
                            decoded[3:0] <= 4'd11;
                            state     	  <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp 			     <= {9'bzzzzzzzzz, temp[31:9]};
                            ready        <= 2'd0;
                        end
                        else if (temp[8:0] == 9'b100101010) begin
                            decoded[3:0] <= 4'd12;
                            state     	  <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp 			     <= {9'bzzzzzzzzz, temp[31:9]};
                            ready        <= 2'd0;
                        end
                        else if (temp[8:0] == 9'b010101010) begin
                            decoded[3:0] <= 4'd13;
                            state     	  <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp 			     <= {9'bzzzzzzzzz, temp[31:9]};
                            ready        <= 2'd0;
                        end
                        // 10 bits
                        else if (temp[9:0] == 10'b1110101010) begin
                            decoded[3:0] <= 4'd9;
                            state     	  <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp 			     <= {10'bzzzzzzzzzz, temp[31:10]};
                            ready        <= 2'd0;
                        end
                        else if (temp[9:0] == 10'b0110101010) begin
                            decoded[3:0] <= 4'd8;
                            state     	  <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp 			     <= {10'bzzzzzzzzzz, temp[31:10]};
                            ready        <= 2'd0;
                        end
                        else begin
                            state       <= 'd0;
                            decoded_num <= 4'd0;
                            decoded     <= 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
                        end
                    end // end if
                    // 2nd
                    else if (decoded_num == 4'd1) begin
                        // 1 bit
                        if (temp[0] == 1'b1) begin
                            decoded[7:4] <= 4'd0;
                            state        <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp         <= {1'bz, temp[31:1]};
                            ready        <= 2'd0;
                        end
                        // 3 bits
                        else if (temp[2:0] == 3'b100) begin
                            decoded[7:4] <= 4'd2;
                            state        <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp         <= {3'bzzz, temp[31:3]};
                            ready        <= 2'd0;
                        end
                        // 4 bits
                        else if (temp[3:0] == 4'b1110) begin
                            decoded[7:4] <= 4'd3;
                            state        <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp         <= {4'bzzzz, temp[31:4]};
                            ready        <= 2'd0;
                        end
                        else if (temp[3:0] == 4'b0110) begin
                            decoded[7:4] <= 4'd1;
                            state        <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp         <= {4'bzzzz, temp[31:4]};
                            ready        <= 2'd0;
                        end
                        else if (temp[3:0] == 4'b0010) begin
                            decoded[7:4] <= 4'd4;
                            state        <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp         <= {4'bzzzz, temp[31:4]};
                            ready        <= 2'd0;
                        end
                        else if (temp[3:0] == 4'b0000) begin
                            decoded[7:4] <= 4'd6;
                            state        <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp         <= {4'bzzzz, temp[31:4]};
                            ready        <= 2'd0;
                        end
                        // 5 bits
                        else if (temp[4:0] == 5'b11010) begin
                            decoded[7:4] <= 4'd5;
                            state        <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp 			     <= {5'bzzzzz, temp[31:5]};
                            ready        <= 2'd0;
                        end
                        else if (temp[4:0] == 5'b11000) begin
                            decoded[7:4] <= 4'd10;
                            state     	  <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp 			     <= {5'bzzzzz, temp[31:5]};
                            ready        <= 2'd0;
                        end
                        else if (temp[4:0] == 5'b01000) begin
                            decoded[7:4] <= 4'd7;
                            state     	  <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp 			     <= {5'bzzzzz, temp[31:5]};
                            ready        <= 2'd0;
                        end
                        // 6 bits
                        else if (temp[5:0] == 6'b001010) begin
                            decoded[7:4] <= 4'd15;
                            state     	  <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp 			     <= {6'bzzzzzz, temp[31:6]};
                            ready        <= 2'd0;
                        end
                        // 7 bits
                        else if (temp[6:0] == 7'b1101010) begin
                            decoded[7:4] <= 4'd14;
                            state     	  <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp 			     <= {7'bzzzzzzz, temp[31:7]};
                            ready        <= 2'd0;
                        end
                        // 9 bits
                        else if (temp[8:0] == 9'b000101010) begin
                            decoded[7:4] <= 4'd11;
                            state     	  <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp 			     <= {9'bzzzzzzzzz, temp[31:9]};
                            ready        <= 2'd0;
                        end
                        else if (temp[8:0] == 9'b100101010) begin
                            decoded[7:4] <= 4'd12;
                            state     	  <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp 			     <= {9'bzzzzzzzzz, temp[31:9]};
                            ready        <= 2'd0;
                        end
                        else if (temp[8:0] == 9'b010101010) begin
                            decoded[7:4] <= 4'd13;
                            state     	  <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp 			     <= {9'bzzzzzzzzz, temp[31:9]};
                            ready        <= 2'd0;
                        end
                        // 10 bits
                        else if (temp[9:0] == 10'b1110101010) begin
                            decoded[7:4] <= 4'd9;
                            state     	  <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp 			     <= {10'bzzzzzzzzzz, temp[31:10]};
                            ready        <= 2'd0;
                        end
                        else if (temp[9:0] == 10'b0110101010) begin
                            decoded[7:4] <= 4'd8;
                            state     	  <= 'd2;
                            decoded_num  <= decoded_num + 4'd1;
                            temp 			     <= {10'bzzzzzzzzzz, temp[31:10]};
                            ready        <= 2'd0;
                        end
                        else begin
                            state       <= 'd0;
                            decoded_num <= 4'd0;
                            decoded     <= 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
                        end
                    end // end if
                    // 3rd
                    else if (decoded_num == 4'd2) begin
                        // 1 bit
                        if (temp[0] == 1'b1) begin
                            decoded[11:8] <= 4'd0;
                            state         <= 'd2;
                            decoded_num   <= decoded_num + 4'd1;
                            temp          <= {1'bz, temp[31:1]};
                            ready         <= 2'd0;
                        end
                        // 3 bits
                        else if (temp[2:0] == 3'b100) begin
                            decoded[11:8] <= 4'd2;
                            state         <= 'd2;
                            decoded_num   <= decoded_num + 4'd1;
                            temp          <= {3'bzzz, temp[31:3]};
                            ready         <= 2'd0;
                        end
                        // 4 bits
                        else if (temp[3:0] == 4'b1110) begin
                            decoded[11:8] <= 4'd3;
                            state         <= 'd2;
                            decoded_num   <= decoded_num + 4'd1;
                            temp          <= {4'bzzzz, temp[31:4]};
                            ready         <= 2'd0;
                        end
                        else if (temp[3:0] == 4'b0110) begin
                            decoded[11:8] <= 4'd1;
                            state         <= 'd2;
                            decoded_num   <= decoded_num + 4'd1;
                            temp          <= {4'bzzzz, temp[31:4]};
                            ready         <= 2'd0;
                        end
                        else if (temp[3:0] == 4'b0010) begin
                            decoded[11:8] <= 4'd4;
                            state         <= 'd2;
                            decoded_num   <= decoded_num + 4'd1;
                            temp          <= {4'bzzzz, temp[31:4]};
                            ready         <= 2'd0;
                        end
                        else if (temp[3:0] == 4'b0000) begin
                            decoded[11:8] <= 4'd6;
                            state         <= 'd2;
                            decoded_num   <= decoded_num + 4'd1;
                            temp          <= {4'bzzzz, temp[31:4]};
                            ready         <= 2'd0;
                        end
                        // 5 bits
                        else if (temp[4:0] == 5'b11010) begin
                            decoded[11:8] <= 4'd5;
                            state         <= 'd2;
                            decoded_num   <= decoded_num + 4'd1;
                            temp 			      <= {5'bzzzzz, temp[31:5]};
                            ready         <= 2'd0;
                        end
                        else if (temp[4:0] == 5'b11000) begin
                            decoded[11:8] <= 4'd10;
                            state     	   <= 'd2;
                            decoded_num   <= decoded_num + 4'd1;
                            temp 			      <= {5'bzzzzz, temp[31:5]};
                            ready         <= 2'd0;
                        end
                        else if (temp[4:0] == 5'b01000) begin
                            decoded[11:8] <= 4'd7;
                            state     	   <= 'd2;
                            decoded_num   <= decoded_num + 4'd1;
                            temp 			      <= {5'bzzzzz, temp[31:5]};
                            ready         <= 2'd0;
                        end
                        // 6 bits
                        else if (temp[5:0] == 6'b001010) begin
                            decoded[11:8] <= 4'd15;
                            state     	   <= 'd2;
                            decoded_num   <= decoded_num + 4'd1;
                            temp 			      <= {6'bzzzzzz, temp[31:6]};
                            ready         <= 2'd0;
                        end
                        // 7 bits
                        else if (temp[6:0] == 7'b1101010) begin
                            decoded[11:8] <= 4'd14;
                            state     	   <= 'd2;
                            decoded_num   <= decoded_num + 4'd1;
                            temp 			      <= {7'bzzzzzzz, temp[31:7]};
                            ready         <= 2'd0;
                        end
                        // 9 bits
                        else if (temp[8:0] == 9'b000101010) begin
                            decoded[11:8] <= 4'd11;
                            state     	   <= 'd2;
                            decoded_num   <= decoded_num + 4'd1;
                            temp 			      <= {9'bzzzzzzzzz, temp[31:9]};
                            ready         <= 2'd0;
                        end
                        else if (temp[8:0] == 9'b100101010) begin
                            decoded[11:8] <= 4'd12;
                            state     	   <= 'd2;
                            decoded_num   <= decoded_num + 4'd1;
                            temp 			      <= {9'bzzzzzzzzz, temp[31:9]};
                            ready         <= 2'd0;
                        end
                        else if (temp[8:0] == 9'b010101010) begin
                            decoded[11:8] <= 4'd13;
                            state     	   <= 'd2;
                            decoded_num   <= decoded_num + 4'd1;
                            temp 			      <= {9'bzzzzzzzzz, temp[31:9]};
                            ready         <= 2'd0;
                        end
                        // 10 bits
                        else if (temp[9:0] == 10'b1110101010) begin
                            decoded[11:8] <= 4'd9;
                            state     	   <= 'd2;
                            decoded_num   <= decoded_num + 4'd1;
                            temp 			      <= {10'bzzzzzzzzzz, temp[31:10]};
                            ready         <= 2'd0;
                        end
                        else if (temp[9:0] == 10'b0110101010) begin
                            decoded[11:8] <= 4'd8;
                            state     	   <= 'd2;
                            decoded_num   <= decoded_num + 4'd1;
                            temp 			      <= {10'bzzzzzzzzzz, temp[31:10]};
                            ready         <= 2'd0;
                        end
                        else begin
                            state       <= 'd0;
                            decoded_num <= 4'd0;
                            decoded     <= 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
                        end
                    end // end if
                    // 4th
                    else if (decoded_num == 4'd3) begin
                        // 1 bit
                        if (temp[0] == 1'b1) begin
                            decoded[15:12] <= 4'd0;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {1'bz, temp[31:1]};
                            ready          <= 2'd0;
                        end
                        // 3 bits
                        else if (temp[2:0] == 3'b100) begin
                            decoded[15:12] <= 4'd2;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {3'bzzz, temp[31:3]};
                            ready          <= 2'd0;
                        end
                        // 4 bits
                        else if (temp[3:0] == 4'b1110) begin
                            decoded[15:12] <= 4'd3;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {4'bzzzz, temp[31:4]};
                            ready          <= 2'd0;
                        end
                        else if (temp[3:0] == 4'b0110) begin
                            decoded[15:12] <= 4'd1;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {4'bzzzz, temp[31:4]};
                            ready          <= 2'd0;
                        end
                        else if (temp[3:0] == 4'b0010) begin
                            decoded[15:12] <= 4'd4;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {4'bzzzz, temp[31:4]};
                            ready          <= 2'd0;
                        end
                        else if (temp[3:0] == 4'b0000) begin
                            decoded[15:12] <= 4'd6;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {4'bzzzz, temp[31:4]};
                            ready          <= 2'd0;
                        end
                        // 5 bits
                        else if (temp[4:0] == 5'b11010) begin
                            decoded[15:12] <= 4'd5;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp 			       <= {5'bzzzzz, temp[31:5]};
                            ready          <= 2'd0;
                        end
                        else if (temp[4:0] == 5'b11000) begin
                            decoded[15:12] 	 <= 4'd10;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {5'bzzzzz, temp[31:5]};
                            ready            <= 2'd0;
                        end
                        else if (temp[4:0] == 5'b01000) begin
                            decoded[15:12] 	 <= 4'd7;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {5'bzzzzz, temp[31:5]};
                            ready            <= 2'd0;
                        end
                        // 6 bits
                        else if (temp[5:0] == 6'b001010) begin
                            decoded[15:12] 	 <= 4'd15;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {6'bzzzzzz, temp[31:6]};
                            ready            <= 2'd0;
                        end
                        // 7 bits
                        else if (temp[6:0] == 7'b1101010) begin
                            decoded[15:12] 	 <= 4'd14;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {7'bzzzzzzz, temp[31:7]};
                            ready            <= 2'd0;
                        end
                        // 9 bits
                        else if (temp[8:0] == 9'b000101010) begin
                            decoded[15:12] 	 <= 4'd11;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {9'bzzzzzzzzz, temp[31:9]};
                            ready            <= 2'd0;
                        end
                        else if (temp[8:0] == 9'b100101010) begin
                            decoded[15:12] 	 <= 4'd12;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {9'bzzzzzzzzz, temp[31:9]};
                            ready            <= 2'd0;
                        end
                        else if (temp[8:0] == 9'b010101010) begin
                            decoded[15:12] 	 <= 4'd13;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {9'bzzzzzzzzz, temp[31:9]};
                            ready            <= 2'd0;
                        end
                        // 10 bits
                        else if (temp[9:0] == 10'b1110101010) begin
                            decoded[15:12] 	 <= 4'd9;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {10'bzzzzzzzzzz, temp[31:10]};
                            ready            <= 2'd0;
                        end
                        else if (temp[9:0] == 10'b0110101010) begin
                            decoded[15:12] 	 <= 4'd8;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {10'bzzzzzzzzzz, temp[31:10]};
                            ready            <= 2'd0;
                        end
                        else begin
                            state       <= 'd0;
                            decoded_num <= 4'd0;
                            decoded     <= 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
                        end
                    end // end if
                    // 5th
                    else if (decoded_num == 4'd4) begin
                        // 1 bit
                        if (temp[0] == 1'b1) begin
                            decoded[19:16] <= 4'd0;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {1'bz, temp[31:1]};
                            ready          <= 2'd0;
                        end
                        // 3 bits
                        else if (temp[2:0] == 3'b100) begin
                            decoded[19:16] <= 4'd2;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {3'bzzz, temp[31:3]};
                            ready          <= 2'd0;
                        end
                        // 4 bits
                        else if (temp[3:0] == 4'b1110) begin
                            decoded[19:16] <= 4'd3;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {4'bzzzz, temp[31:4]};
                            ready          <= 2'd0;
                        end
                        else if (temp[3:0] == 4'b0110) begin
                            decoded[19:16] <= 4'd1;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {4'bzzzz, temp[31:4]};
                            ready          <= 2'd0;
                        end
                        else if (temp[3:0] == 4'b0010) begin
                            decoded[19:16] <= 4'd4;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {4'bzzzz, temp[31:4]};
                            ready          <= 2'd0;
                        end
                        else if (temp[3:0] == 4'b0000) begin
                            decoded[19:16] <= 4'd6;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {4'bzzzz, temp[31:4]};
                            ready          <= 2'd0;
                        end
                        // 5 bits
                        else if (temp[4:0] == 5'b11010) begin
                            decoded[19:16] <= 4'd5;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp 			       <= {5'bzzzzz, temp[31:5]};
                            ready          <= 2'd0;
                        end
                        else if (temp[4:0] == 5'b11000) begin
                            decoded[19:16] 	 <= 4'd10;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {5'bzzzzz, temp[31:5]};
                            ready            <= 2'd0;
                        end
                        else if (temp[4:0] == 5'b01000) begin
                            decoded[19:16] 	 <= 4'd7;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {5'bzzzzz, temp[31:5]};
                            ready            <= 2'd0;
                        end
                        // 6 bits
                        else if (temp[5:0] == 6'b001010) begin
                            decoded[19:16] 	 <= 4'd15;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {6'bzzzzzz, temp[31:6]};
                            ready            <= 2'd0;
                        end
                        // 7 bits
                        else if (temp[6:0] == 7'b1101010) begin
                            decoded[19:16] 	 <= 4'd14;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {7'bzzzzzzz, temp[31:7]};
                            ready            <= 2'd0;
                        end
                        // 9 bits
                        else if (temp[8:0] == 9'b000101010) begin
                            decoded[19:16] 	 <= 4'd11;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {9'bzzzzzzzzz, temp[31:9]};
                            ready            <= 2'd0;
                        end
                        else if (temp[8:0] == 9'b100101010) begin
                            decoded[19:16] 	 <= 4'd12;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {9'bzzzzzzzzz, temp[31:9]};
                            ready            <= 2'd0;
                        end
                        else if (temp[8:0] == 9'b010101010) begin
                            decoded[19:16] 	 <= 4'd13;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {9'bzzzzzzzzz, temp[31:9]};
                            ready            <= 2'd0;
                        end
                        // 10 bits
                        else if (temp[9:0] == 10'b1110101010) begin
                            decoded[19:16] 	 <= 4'd9;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {10'bzzzzzzzzzz, temp[31:10]};
                            ready            <= 2'd0;
                        end
                        else if (temp[9:0] == 10'b0110101010) begin
                            decoded[19:16] 	 <= 4'd8;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {10'bzzzzzzzzzz, temp[31:10]};
                            ready            <= 2'd0;
                        end
                        else begin
                            state       <= 'd0;
                            decoded_num <= 4'd0;
                            decoded     <= 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
                        end
                    end // end if
                    // 6th
                    else if (decoded_num == 4'd5) begin
                        // 1 bit
                        if (temp[0] == 1'b1) begin
                            decoded[23:20] <= 4'd0;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {1'bz, temp[31:1]};
                            ready          <= 2'd0;
                        end
                        // 3 bits
                        else if (temp[2:0] == 3'b100) begin
                            decoded[23:20] <= 4'd2;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {3'bzzz, temp[31:3]};
                            ready          <= 2'd0;
                        end
                        // 4 bits
                        else if (temp[3:0] == 4'b1110) begin
                            decoded[23:20] <= 4'd3;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {4'bzzzz, temp[31:4]};
                            ready          <= 2'd0;
                        end
                        else if (temp[3:0] == 4'b0110) begin
                            decoded[23:20] <= 4'd1;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {4'bzzzz, temp[31:4]};
                            ready          <= 2'd0;
                        end
                        else if (temp[3:0] == 4'b0010) begin
                            decoded[23:20] <= 4'd4;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {4'bzzzz, temp[31:4]};
                            ready          <= 2'd0;
                        end
                        else if (temp[3:0] == 4'b0000) begin
                            decoded[23:20] <= 4'd6;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {4'bzzzz, temp[31:4]};
                            ready          <= 2'd0;
                        end
                        // 5 bits
                        else if (temp[4:0] == 5'b11010) begin
                            decoded[23:20] <= 4'd5;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp 			       <= {5'bzzzzz, temp[31:5]};
                            ready          <= 2'd0;
                        end
                        else if (temp[4:0] == 5'b11000) begin
                            decoded[23:20] 	 <= 4'd10;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {5'bzzzzz, temp[31:5]};
                            ready            <= 2'd0;
                        end
                        else if (temp[4:0] == 5'b01000) begin
                            decoded[23:20] 	 <= 4'd7;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {5'bzzzzz, temp[31:5]};
                            ready            <= 2'd0;
                        end
                        // 6 bits
                        else if (temp[5:0] == 6'b001010) begin
                            decoded[23:20] 	 <= 4'd15;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {6'bzzzzzz, temp[31:6]};
                            ready            <= 2'd0;
                        end
                        // 7 bits
                        else if (temp[6:0] == 7'b1101010) begin
                            decoded[23:20] 	 <= 4'd14;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {7'bzzzzzzz, temp[31:7]};
                            ready            <= 2'd0;
                        end
                        // 9 bits
                        else if (temp[8:0] == 9'b000101010) begin
                            decoded[23:20] 	 <= 4'd11;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {9'bzzzzzzzzz, temp[31:9]};
                            ready            <= 2'd0;
                        end
                        else if (temp[8:0] == 9'b100101010) begin
                            decoded[23:20] 	 <= 4'd12;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {9'bzzzzzzzzz, temp[31:9]};
                            ready            <= 2'd0;
                        end
                        else if (temp[8:0] == 9'b010101010) begin
                            decoded[23:20] 	 <= 4'd13;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {9'bzzzzzzzzz, temp[31:9]};
                            ready            <= 2'd0;
                        end
                        // 10 bits
                        else if (temp[9:0] == 10'b1110101010) begin
                            decoded[23:20] 	 <= 4'd9;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {10'bzzzzzzzzzz, temp[31:10]};
                            ready            <= 2'd0;
                        end
                        else if (temp[9:0] == 10'b0110101010) begin
                            decoded[23:20] 	 <= 4'd8;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {10'bzzzzzzzzzz, temp[31:10]};
                            ready            <= 2'd0;
                        end
                        else begin
                            state       <= 'd0;
                            decoded_num <= 4'd0;
                            decoded     <= 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
                        end
                    end // end if
                    // 7th
                    else if (decoded_num == 4'd6) begin
                        // 1 bit
                        if (temp[0] == 1'b1) begin
                            decoded[27:24] <= 4'd0;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {1'bz, temp[31:1]};
                            ready          <= 2'd0;
                        end
                        // 3 bits
                        else if (temp[2:0] == 3'b100) begin
                            decoded[27:24] <= 4'd2;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {3'bzzz, temp[31:3]};
                            ready          <= 2'd0;
                        end
                        // 4 bits
                        else if (temp[3:0] == 4'b1110) begin
                            decoded[27:24] <= 4'd3;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {4'bzzzz, temp[31:4]};
                            ready          <= 2'd0;
                        end
                        else if (temp[3:0] == 4'b0110) begin
                            decoded[27:24] <= 4'd1;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {4'bzzzz, temp[31:4]};
                            ready          <= 2'd0;
                        end
                        else if (temp[3:0] == 4'b0010) begin
                            decoded[27:24] <= 4'd4;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {4'bzzzz, temp[31:4]};
                            ready          <= 2'd0;
                        end
                        else if (temp[3:0] == 4'b0000) begin
                            decoded[27:24] <= 4'd6;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {4'bzzzz, temp[31:4]};
                            ready          <= 2'd0;
                        end
                        // 5 bits
                        else if (temp[4:0] == 5'b11010) begin
                            decoded[27:24] <= 4'd5;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp 			       <= {5'bzzzzz, temp[31:5]};
                            ready          <= 2'd0;
                        end
                        else if (temp[4:0] == 5'b11000) begin
                            decoded[27:24] 	 <= 4'd10;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {5'bzzzzz, temp[31:5]};
                            ready            <= 2'd0;
                        end
                        else if (temp[4:0] == 5'b01000) begin
                            decoded[27:24] 	 <= 4'd7;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {5'bzzzzz, temp[31:5]};
                            ready            <= 2'd0;
                        end
                        // 6 bits
                        else if (temp[5:0] == 6'b001010) begin
                            decoded[27:24] 	 <= 4'd15;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {6'bzzzzzz, temp[31:6]};
                            ready            <= 2'd0;
                        end
                        // 7 bits
                        else if (temp[6:0] == 7'b1101010) begin
                            decoded[27:24] 	 <= 4'd14;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {7'bzzzzzzz, temp[31:7]};
                            ready            <= 2'd0;
                        end
                        // 9 bits
                        else if (temp[8:0] == 9'b000101010) begin
                            decoded[27:24] 	 <= 4'd11;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {9'bzzzzzzzzz, temp[31:9]};
                            ready            <= 2'd0;
                        end
                        else if (temp[8:0] == 9'b100101010) begin
                            decoded[27:24] 	 <= 4'd12;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {9'bzzzzzzzzz, temp[31:9]};
                            ready            <= 2'd0;
                        end
                        else if (temp[8:0] == 9'b010101010) begin
                            decoded[27:24] 	 <= 4'd13;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {9'bzzzzzzzzz, temp[31:9]};
                            ready            <= 2'd0;
                        end
                        // 10 bits
                        else if (temp[9:0] == 10'b1110101010) begin
                            decoded[27:24] 	 <= 4'd9;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {10'bzzzzzzzzzz, temp[31:10]};
                            ready            <= 2'd0;
                        end
                        else if (temp[9:0] == 10'b0110101010) begin
                            decoded[27:24] 	 <= 4'd8;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {10'bzzzzzzzzzz, temp[31:10]};
                            ready            <= 2'd0;
                        end
                        else begin
                            state       <= 'd0;
                            decoded_num <= 4'd0;
                            decoded     <= 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
                        end
                    end // end if
                    // 8th
                    else if (decoded_num == 4'd7) begin
                        // 1 bit
                        if (temp[0] == 1'b1) begin
                            decoded[31:28] <= 4'd0;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {1'bz, temp[31:1]};
                            ready          <= 2'd1;
                        end
                        // 3 bits
                        else if (temp[2:0] == 3'b100) begin
                            decoded[31:28] <= 4'd2;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {3'bzzz, temp[31:3]};
                            ready          <= 2'd1;
                        end
                        // 4 bits
                        else if (temp[3:0] == 4'b1110) begin
                            decoded[31:28] <= 4'd3;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {4'bzzzz, temp[31:4]};
                            ready          <= 2'd1;
                        end
                        else if (temp[3:0] == 4'b0110) begin
                            decoded[31:28] <= 4'd1;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {4'bzzzz, temp[31:4]};
                            ready          <= 2'd1;
                        end
                        else if (temp[3:0] == 4'b0010) begin
                            decoded[31:28] <= 4'd4;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {4'bzzzz, temp[31:4]};
                            ready          <= 2'd1;
                        end
                        else if (temp[3:0] == 4'b0000) begin
                            decoded[31:28] <= 4'd6;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp           <= {4'bzzzz, temp[31:4]};
                            ready          <= 2'd1;
                        end
                        // 5 bits
                        else if (temp[4:0] == 5'b11010) begin
                            decoded[31:28] <= 4'd5;
                            state          <= 'd2;
                            decoded_num    <= decoded_num + 4'd1;
                            temp 			       <= {5'bzzzzz, temp[31:5]};
                            ready          <= 2'd1;
                        end
                        else if (temp[4:0] == 5'b11000) begin
                            decoded[31:28] 	 <= 4'd10;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {5'bzzzzz, temp[31:5]};
                            ready            <= 2'd1;
                        end
                        else if (temp[4:0] == 5'b01000) begin
                            decoded[31:28] 	 <= 4'd7;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {5'bzzzzz, temp[31:5]};
                            ready            <= 2'd1;
                        end
                        // 6 bits
                        else if (temp[5:0] == 6'b001010) begin
                            decoded[31:28] 	 <= 4'd15;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {6'bzzzzzz, temp[31:6]};
                            ready            <= 2'd1;
                        end
                        // 7 bits
                        else if (temp[6:0] == 7'b1101010) begin
                            decoded[31:28] 	 <= 4'd14;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {7'bzzzzzzz, temp[31:7]};
                            ready            <= 2'd1;
                        end
                        // 9 bits
                        else if (temp[8:0] == 9'b000101010) begin
                            decoded[31:28] 	 <= 4'd11;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {9'bzzzzzzzzz, temp[31:9]};
                            ready            <= 2'd1;
                        end
                        else if (temp[8:0] == 9'b100101010) begin
                            decoded[31:28] 	 <= 4'd12;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {9'bzzzzzzzzz, temp[31:9]};
                            ready            <= 2'd1;
                        end
                        else if (temp[8:0] == 9'b010101010) begin
                            decoded[31:28] 	 <= 4'd13;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {9'bzzzzzzzzz, temp[31:9]};
                            ready            <= 2'd1;
                        end
                        // 10 bits
                        else if (temp[9:0] == 10'b1110101010) begin
                            decoded[31:28] 	 <= 4'd9;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {10'bzzzzzzzzzz, temp[31:10]};
                            ready            <= 2'd1;
                        end
                        else if (temp[9:0] == 10'b0110101010) begin
                            decoded[31:28] 	 <= 4'd8;
                            state     	      <= 'd2;
                            decoded_num      <= decoded_num + 4'd1;
                            temp 			         <= {10'bzzzzzzzzzz, temp[31:10]};
                            ready            <= 2'd1;
                        end
                        else begin
                            state       <= 'd0;
                            decoded_num <= 4'd0;
                            decoded     <= 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
                        end
                    end // end if
                    else begin
                        ready       <= 2'd0;
                        state       <= 'd0;
                        decoded_num <= 4'd0;
                        decoded     <= 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
                    end
                end // end 'd2
                
            endcase
        end // end else
    end // end always
    
endmodule
