`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.01.2018 11:38:34
// Design Name: 
// Module Name: TDC_TOP
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

module TDC_TOP(
    input iCLK,
    input iRST,
    input iHIT,
    //DEBUG OUTPUTS
    //output [`NUM_STAGES-1:0] oTHERMOMETERSTART,
    //output [`NUM_STAGES-1:0] oTHERMOMETERSTOP,
    //END OF DEBUG OUTPUTS
    output oVALUEREADY,
    //output [`COARSE_BITS-1:0] oCOARSEARBITERVALUE,
    output [`NUM_OUTPUT_BITS-1:0] oTDCVALUE
);

//PLL TO SHIFT SYSTEM CLOCK FOR TDC SAMPLING AND COARSE COUNTING
//wire wCLK0;
wire wCLK1;
wire wCLK2;

PHASEPLL pll_inst(
    .iCLK(iCLK),
    .reset(iRST),
    .oCLK(wCLK1),
    .oCLK2(wCLK2)
);


//TDC BLOCK
TDCMODULE tdc_module_inst(
    .iCLK0(iCLK),
    .iCLK1(wCLK1),
    .iCLK2(wCLK2),
    .iRST(iRST),
    .iHIT(iHIT),
    //DEBUG OUTPUTS
    //.oTHERMOMETERSTART(oTHERMOMETERSTART),
    //.oTHERMOMETERSTOP(oTHERMOMETERSTOP),
    //END OF DEBUG OUTPUTS
    //.oCOARSEARBITERVALUE(oCOARSEARBITERVALUE),
    .oVALUEREADY(oVALUEREADY),
    .oTDCVALUE(oTDCVALUE)
);

endmodule