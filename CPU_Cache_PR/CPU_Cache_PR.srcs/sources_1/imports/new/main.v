`timescale 1ns/1ps
`define HIT (1)
`define MISS (0)
`define NULL (8'b00000000)
//------------------------------------
module cache_handler(
input clk,
input [31:0] address,
input rst,
input write_enable,
input [31:0] write_data,
output reg [31:0] read_data,
output reg result, //Hit or Miss
output reg [31:0] total_accesses,
output reg [31:0] total_misses);
//Constant Paramters
parameter NUM_LINES = 16;
parameter WORD_PER_LINE = 4;
parameter MEM_SIZE = 1024;
//Registers definition
reg [7:0] cache_memory[0:NUM_LINES - 1][0:WORD_PER_LINE - 1];
reg [17:0] cache_tag[0:NUM_LINES - 1];
reg valid_bit[0:NUM_LINES - 1];
reg [7:0] memory [0:MEM_SIZE - 1];
integer i;
initial $readmemb("C:\Users\Farbo\Desktop\Uni_Stuff\Term 2\Logic Circuits\Project\LogicCircuits_Project_CPU_Cache\LogicCircuits_Project_CPU_Cache.sim\sim_1\behav\xsim\memory.list", memory); //Initialize Memory Values from Randomly Generated Values in memory.list (ASCII characters)
function check_memory(input [31:0] address);
    begin
        if (cache_tag[address[5:2]] == address[24:6])
            check_memory = 1;
        else
            check_memory = 0;
    end
endfunction
function [7:0]read_cache(input [3:0]row, input [1:0]column);
begin
    if (valid_bit[row])
        read_cache = cache_memory[row][column];
    else
        read_cache = `NULL;
end
endfunction
function [7:0]load_to_cache(input address);
begin
    valid_bit[address[6:2]] = 1;
    cache_tag[address[6:2]] = address[25:7];
    for (i = 0; i < WORD_PER_LINE; i = i + 1)
        // cache_memory[address[6:2]] = memory

end
endfunction
always @(posedge clk) begin
//Reset Pin
if (rst)
begin
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
if (~write_enable)
begin
    if (check_memory(address))
        begin
            result <= `HIT;
            read_data <= read_cache(address[6:2], address[1:0]);
        end
    else
        begin
            total_misses <= total_misses + 1;
            result <= `MISS;
            read_data <= load_to_cache(address);
        end

end
//----------------------------------
//Write
else
begin
$display("Kir");
end
end
endmodule


