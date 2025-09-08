# Simple Verilog Cache Implemention
## Specifications
- Memory: 1024 Bytes (Byte Addressable)
- Cache: 16 Lines, 4 Words per Line
- Cache Tag: 18 Bits
- Cache Type: Direct, Write-Through
## Usage
Example usage syntax is available in cache_tb.v
```v
do_access(ADDRESS, WRITE_ENABLE(1, 9), WRITE_DATA);
do_access(32'd0, 1'b0, 32'd0);
```
#