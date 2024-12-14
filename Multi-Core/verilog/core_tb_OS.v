// Created by 284 little group @UCSD
// Please do not spread this code without permission
// Output Stationary testbench

`timescale 1ns/1ps

module core_tb_OS();

    parameter bw       = 4;  // Bit-width for input weights or activations
    parameter psum_bw  = 16; // Bit-width for partial sum
    parameter len_kij  = 9;  // Kernel loop iteration length
    parameter len_onij = 8; // Output activation length
    parameter col      = 8;  // Number of columns in the core
    parameter row      = 8;  // Number of rows in the core
    parameter len_nij  = 36; // Number of input activations
    parameter ic_dim   = 3;  // Number of input channels
    parameter a_pad_ni_dim = 6; //input activations length root
    parameter o_ni_dim     = 4; //output activations length root
    parameter ki_dim       = 8; //Kernel loop iteration length root
    parameter act_tile = 2;  // tiles of input activations per input channel = o_ni_dim*o_ni_dim / row
    parameter o_feature_num = 8; // number of output featuremaps

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

    // // Weight memory (WMEM) control signals
    // reg [bw*row-1:0] D_wmem_q = 0; // Data to be written into WMEM
    // reg CEN_wmem              = 0;             // Chip Enable for WMEM, active low
    // reg WEN_wmem              = 0;             // Write Enable for WMEM, active low
    // reg [10:0] A_wmem         = 0;        // Address signal for WMEM

    // // Weight memory (WMEM) pipeline control signals
    // reg CEN_wmem_q      = 0;           // Pipeline register for WMEM chip enable
    // reg WEN_wmem_q      = 0;           // Pipeline register for WMEM write enable
    // reg [10:0] A_wmem_q = 0;      // Pipeline register for WMEM address

    // FIFOs and L0 control signals
    reg ofifo_rd_q = 0;           // Read enable signal for output FIFO (OFIFO)
    reg ififo_wr_q = 0;           // Write enable signal for input FIFO (IFIFO)
    reg ififo_rd_q = 0;           // Read enable signal for input FIFO (IFIFO)
    reg l0_rd_q    = 0;              // Read enable signal for L0 buffer
    reg l0_wr_q    = 0;              // Write enable signal for L0 buffer
    reg l1_rd_q    = 0;              // Read enable signal for L1 buffer
    reg l1_wr_q    = 0;              // Write enable signal for L1 buffer
    reg ofifo2_rd_q = 0;           // Read enable signal for output FIFO (OFIFO)
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
    reg ofifo2_rd;
    reg ififo_wr;
    reg ififo_rd;
    reg l0_rd;
    reg l0_wr;
    reg l1_rd;
    reg l1_wr;
    reg execute;
    reg load;
    // reg [8*30:1] stringvar;
    reg [8*30:1] w_file_name;
    reg [8*32:1] x_file_name;
    reg [col*psum_bw-1:0] final_out;
    reg rd_version_q;
    reg rd_version;
    reg WeightOrOutput_q;
    reg WeightOrOutput;

    wire ofifo_valid;
    wire [col*psum_bw-1:0] sfp_out;
    wire [col*psum_bw-1:0] sfp_out2;
    wire [4:0] l0_ofifo_valid;      //4:ofifo o_valid; 3:ofifo o_ready; 2:ofifo o_full; 1:l0 o_full; 0:l0 o_ready;
    wire [2:0] ififo_valid;         //2:ififo o_valid; 1:ififo o_ready; 0:ififo o_full;
    wire OFIFO_o_valid; // High if all col_fifo is not empty, all col_fifo can be read out at same time
    wire OFIFO_o_ready; // High if all col_fifo are not full
    wire OFIFO_o_full;  // High if any col_fifo is full
    wire IFIFO_o_valid; // High if all col_fifo are not empty
    wire IFIFO_o_ready; // High if all col_fifo are empty (ready for new writes)
    wire IFIFO_o_full;  // High if any col_fifo is full
    wire l0_o_full;     // High if any row_fifo is full
    wire l0_o_ready;    // High if all row_fifo are empty (ready for new writes)

    // File handlers for I/O operations
    integer x_file, x_scan_file;  // Handles for input activation files
    integer w_file, w_scan_file;  // Handles for kernel weight files
    integer out_file, out_scan_file; // Handles for output files
    // integer acc_file, acc_scan_file; // Handles for accumulation files
    // integer captured_data;        // Temporary variable for captured file data

    // Loop variables
    integer t, i, j, kij, ic, tile;      // Loop iterators
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
    assign  IFIFO_o_valid = ififo_valid[2];
    assign  IFIFO_o_ready = ififo_valid[1];
    assign  IFIFO_o_full  = ififo_valid[0];
    assign  l0_o_full     = l0_ofifo_valid[1];
    assign  l0_o_ready    = l0_ofifo_valid[0];


    core  #(.bw(bw), .col(col), .row(row)) core_instance (
    .clk(clk),
    .inst(inst_q),
    .l0_ofifo_valid(l0_ofifo_valid),
    .D_xmem(D_xmem_q),
    .sfp_out(sfp_out),
    .sfp_out2(sfp_out2),
    .l1_rd(l1_rd),
    .l1_wr(l1_wr),
    .ofifo2_rd(ofifo2_rd),
    .reset(reset),
    .rd_version(rd_version_q),
    .ififo_valid(ififo_valid),
    .WeightOrOutput(WeightOrOutput));   // 0: weight stationary; 1: output stationsary


///////////////////////////////////////////////// Output Stationary /////////////////////////////////////////////////
    initial begin
        inst_w     = 0;
        D_xmem     = 0;
        CEN_xmem   = 1;
        WEN_xmem   = 1;
        A_xmem     = 0;
        ofifo_rd   = 0;
        ofifo2_rd  = 0;
        ififo_wr   = 0;
        ififo_rd   = 0;
        l0_rd      = 0;
        l0_wr      = 0;
        l1_rd      = 0;
        l1_wr      = 0;
        execute    = 0;
        load       = 0;
        rd_version = 1;
        WeightOrOutput = 1;

        $dumpfile("core_tb_OS.vcd");
        $dumpvars(0,core_tb_OS);


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



        w_file_name = "weight_os_3ic.txt";

        w_file = $fopen(w_file_name, "r");

        /////// Weight data writing to high address XMEM ///////

        A_xmem = 11'b10000000000;

        for (t = 0; t<len_kij*3; t = t+1) begin   // load into xmem
            #0.5 clk        = 1'b0;
            w_scan_file     = $fscanf(w_file,"%32b", D_xmem);   // read out 8*4bit weight once
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

        /////// Weight data writing to ififo ///////
        A_xmem = 11'b10000000000;

        #0.5 clk = 1'b0;
        WEN_xmem = 1;
        CEN_xmem = 0; // xmem read operation
        #0.5 clk = 1'b1;


        for (t = 0; t<len_kij*3; t = t+1) begin
            #0.5 clk        = 1'b0;
            ififo_wr           = 1;
            A_xmem = A_xmem + 1;
            #0.5 clk        = 1'b1;
        end

        #0.5 clk = 1'b0;
        WEN_xmem = 1;
        CEN_xmem = 1;
        A_xmem   = 0;
        #0.5 clk = 1'b1;
        #0.5 clk = 1'b0;
        ififo_wr    = 0;
        #0.5 clk = 1'b1;

        for (i = 0; ~IFIFO_o_full && i < 10; i = i+1) begin
            #0.5 clk = 1'b0;
            #0.5 clk = 1'b1;
        end

        /////////////////////////////////////




        /////// Activation tile0 data writing to low address XMEM ///////
        x_file_name = "activation_os_3ic_tile0.txt";
        x_file = $fopen(x_file_name, "r");
        A_xmem = 0;

        for (t = 0; t<len_kij*3; t = t+1) begin
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


        /////// Activation tile0 data writing to L0 ///////
        A_xmem   = 0;
        #0.5 clk = 1'b0;
        WEN_xmem = 1;
        CEN_xmem = 0; // xmem read operation
        #0.5 clk = 1'b1;

        for (t = 0; t<len_kij*3; t = t+1) begin
            #0.5 clk        = 1'b0;
            l0_wr           = 1;
            A_xmem = A_xmem + 1;
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

        for (i = 0; i<10 ; i = i+1) begin   // provide some intermission
            #0.5 clk = 1'b0;
            #0.5 clk = 1'b1;
        end
        /////////////////////////////////////


        /////// Activation tile1 data writing to low address XMEM ///////
        x_file_name = "activation_os_3ic_tile1.txt";
        x_file = $fopen(x_file_name, "r");
        A_xmem = 27;

        for (t = 0; t<len_kij*3; t = t+1) begin
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


        /////// Activation tile1 data writing to L1 ///////
        A_xmem   = 27;
        #0.5 clk = 1'b0;
        WEN_xmem = 1;
        CEN_xmem = 0; // xmem read operation
        #0.5 clk = 1'b1;

        for (t = 0; t<len_kij*3; t = t+1) begin
            #0.5 clk        = 1'b0;
            l1_wr           = 1;
            A_xmem = A_xmem + 1;
            #0.5 clk        = 1'b1;
        end

        #0.5 clk = 1'b0;
        WEN_xmem = 1;
        CEN_xmem = 1;
        A_xmem   = 0;
        #0.5 clk = 1'b1;
        #0.5 clk = 1'b0;
        l1_wr    = 0;
        #0.5 clk = 1'b1;

        for (i = 0; i<10 ; i = i+1) begin   // provide some intermission
            #0.5 clk = 1'b0;
            #0.5 clk = 1'b1;
        end
        /////////////////////////////////////

        /////// Execution, read data from L0 and L1, and IFIFO start to array at same time ///////
        #0.5 clk = 1'b0;
        l0_rd    = 1;
        l1_rd    = 1;
        ififo_rd = 1;
        #0.5 clk = 1'b1;




        for (t = 0; t<len_kij*3+row+col; t = t+1) begin   // drain cycles to let the final computations complete
            
            execute  = 1;
            #0.5 clk = 1'b0;
            #0.5 clk = 1'b1;
        end

        #0.5 clk = 1'b0;
        l0_rd    = 0;
        l1_rd    = 0;
        ififo_rd = 0;
        execute  = 0;
        #0.5 clk = 1'b1;            
        /////////////////////////////////////



        /////////////////////////////////////////////////

        #0.5 clk = 1'b0; reset = 0;
        #0.5 clk = 1'b1;
        #0.5 clk = 1'b0; reset = 0;
        #0.5 clk = 1'b1;

    

        //////// Accumulation has been done while Execution /////////
        #0.5 clk = 1'b0;
        #0.5 clk = 1'b1;

        out_file = $fopen("out.txt", "r");   // need to modify file path

        error = 0;

        $display("############ Verification Start during accumulation #############");
        for (i = 0; i<2; i = i+1) begin

            #0.5 clk = 1'b0;
            #0.5 clk = 1'b1;

            ofifo_rd = 1;
        end

        for (i = 0; i<o_feature_num; i = i+1) begin

            #0.5 clk = 1'b0;
            #0.5 clk = 1'b1;

            ofifo_rd = 1;
        
            final_out     = sfp_out;
            out_scan_file = $fscanf(out_file,"%128b", answer);
            if (final_out == answer)
                $display("%2d-th output featuremap Data matched! :D", i);

            else begin
                $display("%2d-th output featuremap Data ERROR!!", i);
                $display("output: %128b", final_out);
                $display("answer: %128b", answer);
                error = 1;
            end
            
        end

        ofifo_rd = 0;

        for (i = 0; i<1; i = i+1) begin

            #0.5 clk = 1'b0;
            #0.5 clk = 1'b1;

            ofifo2_rd = 1;
        end

        for (i = 0; i<o_feature_num; i = i+1) begin

            #0.5 clk = 1'b0;
            #0.5 clk = 1'b1;

            ofifo2_rd = 1;
        
            final_out     = sfp_out2;
            out_scan_file = $fscanf(out_file,"%128b", answer);
            if (final_out == answer)
                $display("%2d-th output featuremap Data matched! :D", i+8);

            else begin
                $display("%2d-th output featuremap Data ERROR!!", i+8);
                $display("output: %128b", final_out);
                $display("answer: %128b", answer);
                error = 1;
            end
            
        end
        ofifo2_rd = 0;

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

    end // end of initial block

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
        ofifo2_rd_q  <= ofifo2_rd;
        acc_q        <= acc;
        ififo_wr_q   <= ififo_wr;
        ififo_rd_q   <= ififo_rd;
        l0_rd_q      <= l0_rd;
        l0_wr_q      <= l0_wr;
        l1_rd_q      <= l1_rd;
        l1_wr_q      <= l1_wr;
        execute_q    <= execute;
        load_q       <= load;
        rd_version_q <= rd_version;
    end


endmodule
