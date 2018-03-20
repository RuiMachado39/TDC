`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.01.2018 11:39:21
// Design Name: 
// Module Name: DECODESTOP
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

(* keep_hierarchy = "TRUE" *) module DECODESTOP(
    input [`NUM_STAGES-1:0] iTHERMOMETERSTOP,
    output [`NUM_BITS-1:0] oBINSTOP
);

reg [`NUM_BITS-1:0] rBINSTOP;
integer i;

always @(iTHERMOMETERSTOP)
begin
    rBINSTOP = 0;
    for(i=0;i<`NUM_STAGES -20; i = i + 1'b1)
    begin
        if(~iTHERMOMETERSTOP[i] & iTHERMOMETERSTOP[i+1] & iTHERMOMETERSTOP[i+2] & iTHERMOMETERSTOP[i+3] & iTHERMOMETERSTOP[i+4])
        begin
            rBINSTOP = i + 1;
        end
    end
end

assign oBINSTOP = rBINSTOP;

endmodule
