`timescale 1ns/1ps;
//------------------------------------
module cache_handler(
input clk,
input [31:0] address,
input rst,
input write_enable,
input [31:0] read_data,
output [31:0] wrote_data,
output result, //Hit or Miss
output reg total_accesses,
output reg total_misses);
//Constant Paramters
parameter NUM_LINES = 16;
parameter WORD_PER_LINE = 4;
parameter MEM_SIZE = 1024;
//Registers definition
reg [31:0] cache_memory[0:NUM_LINES - 1][0:WORD_PER_LINE - 1];
reg [17:0] cache_tag[0:NUM_LINES - 1];
reg valid_bit[0:NUM_LINES - 1];
reg [7:0] memory [0:MEM_SIZE - 1];
initial $readmemb("memory.list", memory);
function check_memory(input [31:0] address, input [17:0] cache_tag[0:NUM_LINES - 1], output x);
    begin
        if (cache_tag[address[5:2]] == address[31:6])
            x <= 1;
        else
            x <= 0;
    end
endfunction
always @(posedge clk) begin
//Reset Pin
if (rst)
begin
  total_accesses <= 0;
  total_misses <= 0;
end
else
    total_accesses <= total_accesses + 1;
//----------------------------------
//Read
if (~write_enable)
begin
    if(check_memory())
end
end
endmodule


