module Cache_tb;
    // Clock and I/O signals
    reg         clk;
    reg         reset;
    reg         access;
    reg  [31:0] Address;
    reg  [31:0] Write_Data;
    reg         Write_Enable;
    wire [31:0] Data_Out;
    wire        Hit_Miss;
    wire [31:0] total_accesses;
    wire [31:0] total_misses;

    // Instantiate the Cache UUT
    cache_handler uut (
        .clk(clk),
        .rst(reset),
        .access(access),
        .address(Address),
        .write_data(Write_Data),
        .write_enable(Write_Enable),
        .read_data(Data_Out),
        .result(Hit_Miss),
        .total_accesses(total_accesses),
        .total_misses(total_misses)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    // Task 
    task do_access;
        input [31:0] addr;
        input        we;
        input [31:0] wdata;
        begin
            Address      = addr;
            Write_Enable = we;
            Write_Data   = wdata;
            access       = 1;
            @(posedge clk);
            access       = 0;
        end
    endtask

    // Test sequence
    initial begin
        // Initialize signals
        reset        = 1;
        access       = 0;
        Address      = 0;
        Write_Enable = 0;
        Write_Data   = 0;
        // Hold reset for two cycles
        repeat (2) @(posedge clk);
        reset = 0;

        // 1) Read Addr=0 (miss)
        do_access(32'd0, 1'b0, 32'd0);
        $display("Read Addr=0: Data_Out=0x%h, Hit_Miss=%s, Acc=%0d, Miss=%0d", 
                Data_Out, Hit_Miss ? "HIT" : "MISS", total_accesses, total_misses);

        // 2) Read Addr=0 (hit)
        do_access(32'd0, 1'b0, 32'd0);
        $display("Read Addr=0 again: Data_Out=0x%h, Hit_Miss=%s, Acc=%0d, Miss=%0d", 
                Data_Out, Hit_Miss ? "HIT" : "MISS", total_accesses, total_misses);

        // 3) Write Addr=4
        do_access(32'd4, 1'b1, 32'hA5A5A5A5);
        $display("Write Addr=4: Hit_Miss=%s, Acc=%0d, Miss=%0d", 
                Hit_Miss ? "HIT" : "MISS", total_accesses, total_misses);

        // 4) Read Addr=4 (hit)
        do_access(32'd4, 1'b0, 32'd0);
        $display("Read Addr=4: Data_Out=0x%h, Hit_Miss=%s, Acc=%0d, Miss=%0d", 
                Data_Out, Hit_Miss ? "HIT" : "MISS", total_accesses, total_misses);

        // 5) Read Addr=32 (new block)
        do_access(32'd32, 1'b0, 32'd0);
        $display("Read Addr=32: Data_Out=0x%h, Hit_Miss=%s, Acc=%0d, Miss=%0d", 
                Data_Out, Hit_Miss ? "HIT" : "MISS", total_accesses, total_misses);

        // Final stats
        $display("Final: Accesses=%0d, Misses=%0d, HitRate=%.2f%%", 
                total_accesses, total_misses, ((total_accesses - total_misses) * 100.0) / total_accesses);
        $finish;

    end
endmodule
