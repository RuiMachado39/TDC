`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.01.2018 11:38:34
// Design Name: 
// Module Name: COARSECOUNTER
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

(* keep_hierarchy = "TRUE" *) module COARSECOUNTER(
    input iCLK,
    input iRST,
    input iHIT,
    input iSTORE,
    output [`COARSE_BITS-1:0] oCOARSEVALUE
);

(* dont_touch = "TRUE" *) reg [`COARSE_BITS-1:0] rCOARSEVALUE;
(* dont_touch = "TRUE" *) reg [`COARSE_BITS-1:0] rCOARSEVALUESTORED;

always @(posedge iCLK)
begin
    if(iRST)
    begin
        rCOARSEVALUE <= 0;     
    end
    else if(iHIT)
    begin
        rCOARSEVALUE <= rCOARSEVALUE + 1'b1;
    end
    /*else if(iSTORE)
    begin
        rCOARSEVALUESTORED <= rCOARSEVALUE;
    end*/
end

always @(posedge iCLK)
begin
    if(iSTORE)
    begin
        rCOARSEVALUESTORED <= rCOARSEVALUE;
    end
end

assign oCOARSEVALUE = rCOARSEVALUESTORED;

endmodule
