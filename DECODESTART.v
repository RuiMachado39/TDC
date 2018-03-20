`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.01.2018 11:39:02
// Design Name: 
// Module Name: DECODESTART
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "Defines.v"

(* keep_hierarchy = "TRUE" *) module DECODESTART(
    input [`NUM_STAGES-1:0] iTHERMOMETERSTART,
    output [`NUM_BITS-1:0] oBINSTART
);

reg [`NUM_BITS-1:0] rBINSTART;
integer i;

wire [`NUM_STAGES-1:0] wTHERMOMETERSTART;

assign wTHERMOMETERSTART = iTHERMOMETERSTART;// << 10;

always @(wTHERMOMETERSTART)
begin
    rBINSTART = 0;
    for(i=0;i<`NUM_STAGES -20; i = i + 1'b1)
    begin
        if(wTHERMOMETERSTART[i] & ~wTHERMOMETERSTART[i+1] & ~wTHERMOMETERSTART[i+2] & ~wTHERMOMETERSTART[i+3] & ~wTHERMOMETERSTART[i+4])
        begin
            rBINSTART = i + 1;
        end
    end
end

assign oBINSTART = rBINSTART;

endmodule
