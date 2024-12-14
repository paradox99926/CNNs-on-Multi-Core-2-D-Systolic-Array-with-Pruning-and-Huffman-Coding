// Created by 284 little group @UCSD
// Please do not spread this code without permission

`timescale 1ns/1ps

module core_tb();
    
    parameter bw       = 4;  // Bit-width for input weights or activations
    parameter psum_bw  = 16; // Bit-width for partial sum
    parameter len_kij  = 9;  // Kernel loop iteration length
    parameter len_onij = 16; // Output activation length
    parameter col      = 8;  // Number of columns in the core
    parameter row      = 8;  // Number of rows in the core
    parameter len_nij  = 36; // Number of input activations
    parameter a_pad_ni_dim = 6; //input activations length root
    parameter o_ni_dim     = 4; //output activations length root
    parameter ki_dim       = 3; //Kernel loop iteration length root
    
    reg clk   = 0;
    reg reset = 1;
    
    // Core control and data signals
    wire [33:0] inst_q;   // Instruction bus for core configuration
    reg [1:0]  inst_w_q = 0; // Write instructions
    
    // Data memory (XMEM) control signals
    reg [bw*row-1:0] D_xmem_q = 0; // Data to be written into XMEM
    reg CEN_xmem              = 0;             // Chip Enable for XMEM, active low
    reg WEN_xmem              = 0;             // Write Enable for XMEM, active low
    reg [10:0] A_xmem         = 0;        // Address signal for XMEM
    
    // Data memory (XMEM) pipeline control signals
    reg CEN_xmem_q      = 0;           // Pipeline register for XMEM chip enable
    reg WEN_xmem_q      = 0;           // Pipeline register for XMEM write enable
    reg [10:0] A_xmem_q = 0;      // Pipeline register for XMEM address
    
    // Program memory (PMEM) control signals
    reg CEN_pmem      = 0;             // Chip Enable for PMEM, active low
    reg WEN_pmem      = 0;             // Write Enable for PMEM, active low
    reg [10:0] A_pmem = 0;        // Address signal for PMEM
    
    // Program memory (PMEM) pipeline control signals
    reg CEN_pmem_q      = 0;           // Pipeline register for PMEM chip enable
    reg WEN_pmem_q      = 0;           // Pipeline register for PMEM write enable
    reg [10:0] A_pmem_q = 0;      // Pipeline register for PMEM address
    
    // FIFOs and L0 control signals
    reg ofifo_rd_q = 0;           // Read enable signal for output FIFO (OFIFO)
    reg ififo_wr_q = 0;           // Write enable signal for input FIFO (IFIFO)
    reg ififo_rd_q = 0;           // Read enable signal for input FIFO (IFIFO)
    reg l0_rd_q    = 0;              // Read enable signal for L0 buffer
    reg l0_wr_q    = 0;              // Write enable signal for L0 buffer
    
    // Execution control signals
    reg execute_q = 0;            // Execution enable signal for the core
    reg load_q    = 0;               // Kernel loading enable signal
    reg acc_q     = 0;                // Accumulation enable signal for partial sums
    
    reg acc = 0;                  // Accumulation signal
    
    // Data for simulation
    reg [1:0]  inst_w;
    reg [bw*row-1:0] D_xmem;
    reg [psum_bw*col-1:0] answer;
    
    reg ofifo_rd;
    reg ififo_wr;
    reg ififo_rd;
    reg l0_rd;
    reg l0_wr;
    reg execute;
    reg load;
    // reg [8*30:1] stringvar;
    reg [8*30:1] w_file_name;
    
    reg [col*psum_bw-1:0] final_out;
    reg rd_version_q;
    reg rd_version;
    reg WeightOrOutput;

    wire ofifo_valid;
    wire [col*psum_bw-1:0] sfp_out;
    wire [4:0] l0_ofifo_valid;      //4:ofifi o_valid; 3:ofifi o_ready; 2:ofifi o_full; 1:l0 o_full; 0:l0 o_ready;
    wire OFIFO_o_valid;
    wire OFIFO_o_ready;
    wire OFIFO_o_full;
    wire l0_o_full;
    wire l0_o_ready;
    
    // File handlers for I/O operations
    integer x_file, x_scan_file;  // Handles for input activation files
    integer w_file, w_scan_file;  // Handles for kernel weight files
    integer out_file, out_scan_file; // Handles for output files
    // integer acc_file, acc_scan_file; // Handles for accumulation files
    // integer captured_data;        // Temporary variable for captured file data
    
    // Loop variables
    integer t, i, j, kij;      // Loop iterators
    integer error;                // Error counter for result verification
    
    assign inst_q[33]    = acc_q;        // Accumulation control signal
    assign inst_q[32]    = CEN_pmem_q;   // PMEM read enable signal, active low
    assign inst_q[31]    = WEN_pmem_q;   // PMEM write enable signal, active low
    assign inst_q[30:20] = A_pmem_q;     // PMEM address
    assign inst_q[19]    = CEN_xmem_q;   // XMEM read enable signal, active low
    assign inst_q[18]    = WEN_xmem_q;   // XMEM write enable signal, active low
    assign inst_q[17:7]  = A_xmem_q;     // XMEM address
    assign inst_q[6]     = ofifo_rd_q;   // OFIFO read enable signal
    assign inst_q[5]     = ififo_wr_q;   // IFIFO write enable signal
    assign inst_q[4]     = ififo_rd_q;   // IFIFO read enable signal
    assign inst_q[3]     = l0_rd_q;      // L0 read enable signal
    assign inst_q[2]     = l0_wr_q;      // L0 write enable signal
    assign inst_q[1]     = execute_q;    // Execution enable signal
    assign inst_q[0]     = load_q;       // Kernel loading enable signal
    
    //l0 and ofifo valid output signal assign
    assign  OFIFO_o_valid = l0_ofifo_valid[4];
    assign  OFIFO_o_ready = l0_ofifo_valid[3];
    assign  OFIFO_o_full  = l0_ofifo_valid[2];
    assign  l0_o_full     = l0_ofifo_valid[1];
    assign  l0_o_ready    = l0_ofifo_valid[0];
    
    // x  |input_CH7|input_CH6|...|input_CH0|
    // n11|
    // n12|
    // ...
    // nij|               36*8
    // ...
    // n66|
    
    //     w     |input_CH7|input_CH6|...|input_CH0|
    // output_CH0|
    // output_CH1|
    // ...                      8*8
    // output_CH7|
    
    // out  |output_CH7|output_CH6|...|output_CH0|
    // o_n11|
    // o_n12|
    // ...
    // o_nij|                 16*8
    // ...
    // o_n44|
    
    
    core  #(.bw(bw), .col(col), .row(row)) core_instance (
    .clk(clk),
    .inst(inst_q),
    .l0_ofifo_valid(l0_ofifo_valid),
    .D_xmem(D_xmem_q),
    .sfp_out(sfp_out),
    .reset(reset),
    .WeightOrOutput(WeightOrOutput),
    .rd_version(rd_version_q));
    
    
    initial begin
        inst_w     = 0;
        D_xmem     = 0;
        CEN_xmem   = 1;
        WEN_xmem   = 1;
        A_xmem     = 0;
        ofifo_rd   = 0;
        ififo_wr   = 0;
        ififo_rd   = 0;
        l0_rd      = 0;
        l0_wr      = 0;
        execute    = 0;
        load       = 0;
        rd_version = 1;
        WeightOrOutput = 0; // 0: weight stationary; 1: output stationsary
        $dumpfile("core_tb.vcd");
        $dumpvars(0,core_tb);
        
        x_file = $fopen("activation_tile0.txt", "r");
        //Following three lines are to remove the first three comment lines of the file
        // x_scan_file = $fscanf(x_file,"%s", captured_data);
        // x_scan_file = $fscanf(x_file,"%s", captured_data);
        // x_scan_file = $fscanf(x_file,"%s", captured_data);
        
        //////// Reset /////////
        #0.5 clk = 1'b0;   reset = 1;
        #0.5 clk = 1'b1;
        
        for (i = 0; i<10 ; i = i+1) begin
            #0.5 clk = 1'b0;
            #0.5 clk = 1'b1;
        end
        
        #0.5 clk = 1'b0;   reset = 0;
        #0.5 clk = 1'b1;
        
        #0.5 clk = 1'b0;
        #0.5 clk = 1'b1;
        /////////////////////////
        
        /////// Activation data writing to memory ///////
        for (t = 0; t<len_nij; t = t+1) begin
            #0.5 clk        = 1'b0;
            x_scan_file     = $fscanf(x_file,"%32b", D_xmem);
            WEN_xmem        = 0;
            CEN_xmem        = 0;
            if (t>0) A_xmem = A_xmem + 1;
            #0.5 clk        = 1'b1;
        end
        
        #0.5 clk = 1'b0;
        WEN_xmem = 1;
        CEN_xmem = 1;
        A_xmem   = 0;
        #0.5 clk = 1'b1;
        
        $fclose(x_file);
        /////////////////////////////////////////////////
        
        
        for (kij = 0; kij<9; kij = kij+1) begin  // kij loop
            
            case(kij)
                0: w_file_name = "weight_itile0_otile0_kij0.txt";
                1: w_file_name = "weight_itile0_otile0_kij1.txt";
                2: w_file_name = "weight_itile0_otile0_kij2.txt";
                3: w_file_name = "weight_itile0_otile0_kij3.txt";
                4: w_file_name = "weight_itile0_otile0_kij4.txt";
                5: w_file_name = "weight_itile0_otile0_kij5.txt";
                6: w_file_name = "weight_itile0_otile0_kij6.txt";
                7: w_file_name = "weight_itile0_otile0_kij7.txt";
                8: w_file_name = "weight_itile0_otile0_kij8.txt";
            endcase
            
            w_file = $fopen(w_file_name, "r");
            // // Following three lines are to remove the first three comment lines of the file
            // w_scan_file = $fscanf(w_file,"%s", captured_data);
            // w_scan_file = $fscanf(w_file,"%s", captured_data);
            // w_scan_file = $fscanf(w_file,"%s", captured_data);
            
            #0.5 clk = 1'b0;
            reset    = 1;
            #0.5 clk = 1'b1;
            
            for (i = 0; i<10 ; i = i+1) begin
                #0.5 clk = 1'b0;
                #0.5 clk = 1'b1;
            end
            
            #0.5 clk = 1'b0;
            reset    = 0;
            #0.5 clk = 1'b1;
            
            #0.5 clk = 1'b0;
            #0.5 clk = 1'b1;
            
            /////// Kernel data writing to memory ///////
            
            A_xmem = 11'b10000000000;
            
            for (t = 0; t<col; t = t+1) begin   // load into xmem
                #0.5 clk        = 1'b0;
                w_scan_file     = $fscanf(w_file,"%32b", D_xmem);
                WEN_xmem        = 0;
                CEN_xmem        = 0;
                if (t>0) A_xmem = A_xmem + 1;
                #0.5 clk        = 1'b1;
            end
            
            #0.5 clk = 1'b0;
            WEN_xmem = 1;
            CEN_xmem = 1;
            A_xmem   = 0;
            #0.5 clk = 1'b1;
            /////////////////////////////////////
            for (i = 0; i<10 ; i = i+1) begin
                #0.5 clk = 1'b0;
                #0.5 clk = 1'b1;
            end
            
            /////// Kernel data writing to L0 ///////
            A_xmem = 11'b10000000000;
            
            #0.5 clk = 1'b0;
            WEN_xmem = 1;
            CEN_xmem = 0; // xmem read operation
            #0.5 clk = 1'b1;
            
            for (t = 0; t<col; t = t+1) begin
                #0.5 clk        = 1'b0;
                l0_wr           = 1;
                if (t>0) A_xmem = A_xmem + 1;
                #0.5 clk        = 1'b1;
            end
            
            #0.5 clk = 1'b0;
            WEN_xmem = 1;
            CEN_xmem = 1;
            A_xmem   = 0;
            #0.5 clk = 1'b1;
            #0.5 clk = 1'b0;
            l0_wr    = 0;
            #0.5 clk = 1'b1;
            
            for (i = 0; ~l0_o_full&&i<10; i = i+1) begin
                #0.5 clk = 1'b0;
                #0.5 clk = 1'b1;
            end
            
            /////////////////////////////////////
            
            
            
            /////// Kernel loading to PEs ///////
            #0.5 clk = 1'b0;
            l0_rd    = 1;
            #0.5 clk = 1'b1;
            
            for (t = 0; t<col; t = t+1) begin
                #0.5 clk = 1'b0;
                load     = 1;  // load weight into mac_array
                #0.5 clk = 1'b1;
            end
            /////////////////////////////////////
            
            
            
            ////// provide some intermission to clear up the kernel loading ///
            #0.5 clk = 1'b0;
            load     = 0;
            l0_rd    = 0;
            #0.5 clk = 1'b1;
            
            
            for (i = 0; i<10 ; i = i+1) begin
                #0.5 clk = 1'b0;
                #0.5 clk = 1'b1;
            end
            /////////////////////////////////////
            
            
            
            /////// Activation data writing to L0 ///////
            A_xmem   = 0;
            #0.5 clk = 1'b0;
            WEN_xmem = 1;
            CEN_xmem = 0; // xmem read operation
            #0.5 clk = 1'b1;
            
            for (t = 0; t<len_nij; t = t+1) begin
                #0.5 clk        = 1'b0;
                l0_wr           = 1;
                if (t>0) A_xmem = A_xmem + 1;
                #0.5 clk        = 1'b1;
            end
            
            #0.5 clk = 1'b0;
            WEN_xmem = 1;
            CEN_xmem = 1;
            A_xmem   = 0;
            #0.5 clk = 1'b1;
            #0.5 clk = 1'b0;
            l0_wr    = 0;
            #0.5 clk = 1'b1;
            /////////////////////////////////////
            
            
            
            /////// Execution ///////
            #0.5 clk = 1'b0;
            l0_rd    = 1;
            #0.5 clk = 1'b1;
            
            
            for (t = 0; t<len_nij; t = t+1) begin
                #0.5 clk = 1'b0;
                execute  = 1;
                #0.5 clk = 1'b1;
            end
            
            for (t = 0; t<row+col; t = t+1) begin  //  drain cycles to let the final computations complete
                #0.5 clk = 1'b0;
                #0.5 clk = 1'b1;
            end
            
            #0.5 clk = 1'b0;
            l0_rd    = 0;
            execute  = 0;
            #0.5 clk = 1'b1;

            //////// READ OUT psum from OFIFO to PMEM  ////////
            // Ideally, OFIFO should be read while execution, but we have enough ofifo
            // depth so we can fetch out after execution.
            #0.5 clk = 1'b0;
            ofifo_rd = 1;
            #0.5 clk = 1'b1;

            for (t = 0; t<len_nij; t = t+1) begin   // Store to pmem
                #0.5 clk                   = 1'b0;
                WEN_pmem                   = 0;
                CEN_pmem                   = 0; //PMEM read enable
                if (t>0 | A_pmem>0) A_pmem = A_pmem + 1;
                #0.5 clk                   = 1'b1;
            end

            #0.5 clk = 1'b0;
            ofifo_rd = 0;
            WEN_pmem = 1;
            CEN_pmem = 1;
            #0.5 clk = 1'b1;
            /////////////////////////////////////
            
            
            $display("kij = %d is completed", kij);
            
        end  // end of kij loop
        
        #0.5 clk = 1'b0;
        #0.5 clk = 1'b1;
        
        ////////// Accumulation /////////
        out_file = $fopen("out.txt", "r");   // need to modify file path
        // Following three lines are to remove the first three comment lines of the file
        // out_scan_file = $fscanf(out_file,"%s", answer);
        // out_scan_file = $fscanf(out_file,"%s", answer);
        // out_scan_file = $fscanf(out_file,"%s", answer);
        
        error = 0;
        
        
        $display("############ Verification Start during accumulation #############");
        
        for (i = 0; i<len_onij+1; i = i+1) begin
            
            #0.5 clk = 1'b0;
            #0.5 clk = 1'b1;
            
            if (i>0) begin
                final_out     = sfp_out;
                out_scan_file = $fscanf(out_file,"%128b", answer);
                if (final_out == answer)
                    $display("%2d-th output featuremap Data matched! :D", i);
                
                else begin
                $display("%2d-th output featuremap Data ERROR!!", i);
                $display("final out: %128b", final_out);
                $display("answer: %128b", answer);
                error = 1;
            end
        end
        
        
        #0.5 clk = 1'b0; reset = 1;
        #0.5 clk = 1'b1;
        #0.5 clk = 1'b0; reset = 0;
        #0.5 clk = 1'b1;
        
        for (j = 0; j<len_kij+1; j = j+1) begin
            
            #0.5 clk = 1'b0;
            if (j<len_kij) begin
                CEN_pmem = 0;   // PMEM read enable, psum move from PMEM to SFP
                WEN_pmem = 1;
                //calculate the address of data that conv needs
                A_pmem = (i / o_ni_dim) * a_pad_ni_dim + (i % o_ni_dim) + (j / ki_dim) * a_pad_ni_dim + (j % ki_dim) + (j * len_nij);

            end
            else  begin
                CEN_pmem = 1;
                WEN_pmem = 1;
            end

            if (j>0)  acc = 1;
            #0.5 clk      = 1'b1;
        end

        #0.5 clk = 1'b0;
        acc      = 0;
        #0.5 clk = 1'b1;

        #0.5 clk = 1'b0;
        #0.5 clk = 1'b1;

    end


    if (error == 0) begin
        $display("############ No error detected ##############");
        $display("########### Project Completed !! ############");
        
    end
    
    // $fclose(acc_file);
    //////////////////////////////////
    
    for (t = 0; t<10; t = t+1) begin
        #0.5 clk = 1'b0;
        #0.5 clk = 1'b1;
    end
    
    #10 $finish;
    
    end
    
    always @ (posedge clk) begin
        inst_w_q     <= inst_w;
        D_xmem_q     <= D_xmem;
        CEN_xmem_q   <= CEN_xmem;
        WEN_xmem_q   <= WEN_xmem;
        A_pmem_q     <= A_pmem;
        CEN_pmem_q   <= CEN_pmem;
        WEN_pmem_q   <= WEN_pmem;
        A_xmem_q     <= A_xmem;
        ofifo_rd_q   <= ofifo_rd;
        acc_q        <= acc;
        ififo_wr_q   <= ififo_wr;
        ififo_rd_q   <= ififo_rd;
        l0_rd_q      <= l0_rd;
        l0_wr_q      <= l0_wr ;
        execute_q    <= execute;
        load_q       <= load;
        rd_version_q <= rd_version;
    end
    
    
endmodule
    
    
    
    
