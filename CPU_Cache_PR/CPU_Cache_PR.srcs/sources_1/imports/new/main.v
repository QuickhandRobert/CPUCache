`timescale 1ns/1ps
`define HIT (1)
`define MISS (0)
`define NULL (8'b00000000)
//CPU Cache Simulator, Written by QuickhandRobert
//August, 2025
//Note:
////Since our memory is byte addressable, but we're storing words (4bytes), we're gonna ignore the first two bits
//------------------------------------
module cache_handler(
        input clk,
        input [31:0] address,
        input rst,
        input access,
        input write_enable,
        input [31:0] write_data,
        output reg [31:0] read_data,
        output reg result, //Hit or Miss
        output reg [31:0] total_accesses,
        output reg [31:0] total_misses);
    //Constant Paramters
    parameter NUM_LINES = 16;
    parameter NUM_LINES_BITS = 4; // (2 ^ 4)
    parameter WORD_PER_LINE = 4;
    parameter WORD_PER_LINE_BITS = 2; // (2 ^ 2)
    parameter MEM_SIZE = 1024;
    //Registers definition
    reg [31:0] cache_memory[0:NUM_LINES - 1][0:WORD_PER_LINE - 1];
    reg [17:0] cache_tag[0:NUM_LINES - 1];
    reg valid_bit[0:NUM_LINES - 1];
    reg [7:0] memory [0:MEM_SIZE - 1];
    integer i;
    integer memory_address_temp;
    initial
        $readmemb("C:/Users/Farbo/Desktop/Uni_Stuff/Term_2/Logic_Circuits/Project/CPU_Cache_PR/memory.list", memory); //Initialize Memory Values from Randomly Generated Values in memory.list (ASCII characters)
    function check_memory(input [31:0] address);
        begin
            if (cache_tag[address[9:5]] == address[24:6])
                check_memory = 1;
            else
                check_memory = 0;
        end
    endfunction
    function [31:0]read_cache(input [3:0]row, input [1:0]column);
        begin
            if (valid_bit[row])
                read_cache = cache_memory[row][column];
            else
                read_cache = `NULL;
        end
    endfunction
    function [31:0]create_memory_address (input [WORD_PER_LINE_BITS - 1:0]n, input [NUM_LINES_BITS - 1:0]row);
        begin
            create_memory_address = cache_tag[row];
            create_memory_address = create_memory_address << 17 | row;
            create_memory_address = create_memory_address << NUM_LINES_BITS | n;
            create_memory_address = create_memory_address << 2;
        end
    endfunction
    function [31:0]load_to_cache(input [31:0] address);
        begin
            valid_bit[address[9:5]] = 1;
            cache_tag[address[9:5]] = address[27:10];
            for (i = 0; i < WORD_PER_LINE; i = i + 1) begin
                memory_address_temp = create_memory_address(i, address[6:2]);
                cache_memory[address[9:5]][i] =
                            {memory[memory_address_temp + 3], memory[memory_address_temp + 2], memory[memory_address_temp + 1], memory[memory_address_temp]}; //32 / 8 (Memory is Byte Addressable)
            end
            load_to_cache = read_cache(address[9:5], address[4:2]);
        end
    endfunction
    always @(posedge clk) begin
        //Reset Pin
        if (rst) begin
            total_accesses <= 0;
            total_misses <= 0;
            //Reset valid bits
            for (i = 0; i < NUM_LINES; i = i + 1)
                valid_bit[i] = 0;
        end
        else
            total_accesses <= total_accesses + 1;
        //----------------------------------
        //Read
        if (access) begin
            if (~write_enable) begin
                if (check_memory(address)) begin
                    result <= `HIT;
                    read_data <= read_cache(address[9:5], address[4:2]);
                end
                else begin
                    total_misses <= total_misses + 1;
                    result <= `MISS;
                    read_data <= load_to_cache(address);
                end

            end
            //----------------------------------
            //Write
            //  Let's Cook !!
            else begin
                $display("There's no Kir anymore :(");
                if (check_memory(address)) begin
                    // Write Hit - Write-through policy
                    result <= `HIT;

                    // Write to cache
                    cache_memory[address[9:5]][address[4:2]] <= write_data;

                    // Write to main memory (write-through)
                    memory_address_temp = create_memory_address(address[4:2], address[9:5]);
                    memory[memory_address_temp] <= write_data[7:0];
                    memory[memory_address_temp + 1] <= write_data[15:8];
                    memory[memory_address_temp + 2] <= write_data[23:16];
                    memory[memory_address_temp + 3] <= write_data[31:24];
                end
                else begin
                    // Write Miss - Write-allocate policy
                    total_misses <= total_misses + 1;
                    result <= `MISS;

                    // Load the cache line from memory (write-allocate)
                    valid_bit[address[9:5]] <= 1;
                    cache_tag[address[9:5]] <= address[27:10];

                    for (i = 0; i < WORD_PER_LINE; i = i + 1) begin
                        memory_address_temp = create_memory_address(i, address[6:2]);
                        cache_memory[address[9:5]][i] <=
                                    {memory[memory_address_temp + 3], memory[memory_address_temp + 2],
                                     memory[memory_address_temp + 1], memory[memory_address_temp]};
                    end

                    // Now write to the cache (and memory - write-through)
                    cache_memory[address[9:5]][address[4:2]] <= write_data;

                    memory_address_temp = create_memory_address(address[4:2], address[9:5]);
                    memory[memory_address_temp] <= write_data[7:0];
                    memory[memory_address_temp + 1] <= write_data[15:8];
                    memory[memory_address_temp + 2] <= write_data[23:16];
                    memory[memory_address_temp + 3] <= write_data[31:24];
                end
            end
        end
    end
endmodule


