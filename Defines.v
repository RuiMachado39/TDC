//Defines for the TDC
`ifndef _DEFINES_V_
`define _DEFINES_V_

//number or Bits
`define NUM_OUTPUT_BITS 32 //number or output bits range of the TDC
`define NUM_STAGES 300 //number of delay cells to ensure one clock cycle coverage
`define NUM_BITS 10 //number of output bits from the decoder
`define COARSE_BITS `NUM_OUTPUT_BITS - (2* `NUM_BITS)//number of bits from the coarse counter total number or output bits minus 2 time the number or bits of the decoder

//state machine stages
//`define READY 3'b000
//`define WAIT 3'b001
//`define STORE 3'b010
//`define DECODE 3'b011
//`define MERGE 3'b100
//`define FINISH 3'b101

//FIFO DEFINES
`define FIFO_DEPTH 256
`define FIFO_ADDR_BITS 8

//FIFO DEFINES
`define MEMDEPTHPOS 512 //512 MEMORY POSITIONS
`define MEMDEPTH 9 //NUMBER OF BITS NEEDED TO ADDRESS 512 MEMORY POSITIONS
`define MEMLENGTH 32 //32 BIT MEMORY POSITIONS
`define PTRLENGTH (`MEMDEPTH + 1) //ONE EXTRA BIT TO RESOLVE FIFO FULL/EMPTY CONDITIONS

`endif