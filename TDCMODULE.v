`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.01.2018 11:30:30
// Design Name: 
// Module Name: TDCMODULE
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

module TDCMODULE(
    input iCLK0,
    input iCLK1,
    input iCLK2,
    input iRST,
    input iHIT,
    output oVALUEREADY,
    //DEBUG OUTPUTS
    //output [`NUM_STAGES-1:0] oTHERMOMETERSTART,
    //output [`NUM_STAGES-1:0] oTHERMOMETERSTOP,
    //END OF DEBUG OUTPUTS
    //output [`COARSE_BITS-1:0] oCOARSEARBITERVALUE,
    output [`NUM_OUTPUT_BITS-1:0] oTDCVALUE
);


//TDC SIGNAL

(* dont_touch = "TRUE" *) wire [`NUM_STAGES-1:0] wTHERMOMETERSTART;
(* dont_touch = "TRUE" *) wire [`NUM_STAGES-1:0] wTHERMOMETERSTOP;
wire [`NUM_BITS-1:0] wBINSTART;
wire [`NUM_BITS-1:0] wBINSTOP;
wire [`COARSE_BITS-1:0] wCOARSEVALUE;
wire [`COARSE_BITS-1:0] wCOARSEARBITERVALUE;
wire [`COARSE_BITS-1:0] wCOARSEARBITER2VALUE;

wire [`NUM_OUTPUT_BITS-1:0] wTDCVALUE;
reg [`NUM_OUTPUT_BITS-1:0] rTDCVALUE;
wire rVALUEREADY;
wire rVALUEREADYOUT;

//reg [2:0] rDELAYCNT;
reg rDELAYCNT;
wire wENABLEDELAY;
wire wENDOFCONVERTION;


//PREVENT MULTIPLE HITS
reg rREADY;
reg rREADYOUTSTORED;

always @(posedge iCLK0 or negedge iHIT or posedge rVALUEREADYOUT)
begin
    if(iRST)
    begin
        rREADY <= 1'b1;
    end
    else if(rVALUEREADYOUT & !rREADYOUTSTORED)
    begin
        rREADYOUTSTORED <= 1'b1;
    end
    else if(rREADYOUTSTORED & !iHIT)
    begin
        rREADY <= 1'b1;
        //rREADYOUTSTORED <= 1'b0;
    end
    else if(iHIT)
    begin
        rREADY <= 1'b0;
		rREADYOUTSTORED <= 1'b0; //alterado a 22-05-2018 RMAC
    end
end 
//wire wREADY;
wire wAUXHIT;
//wire wPRESET;

assign wAUXHIT = iHIT & rREADY;

//(* dont_touch = "TRUE" *) FDPE_1 #(.INIT(1'b1)) READYDFF(
//    .Q(wREADY),
//    .C(iHIT),
//    .CE(1'b1),
//    .PRE(wPRESET),
//    .D(1'b0)
//);
//BUFFER FOR HIT SIGNAL TO IMPROVE TIMING

wire wHIT;

(* dont_touch = "TRUE" *) BUFG hit_buffer_inst(
    .O(wHIT),
    .I(wAUXHIT)
);




//HIT RISE AND FALL EDGE DETECTION

wire [1:0] wEDGE;
wire wRISEEDGE;
wire wFALLEDGE;

(* dont_touch = "TRUE" *) FDCE #(.INIT(1'b0)) edge_detector_ffd0(
    .Q(wEDGE[0]),
    .C(iCLK0),
    .CE(1'b1),
    .CLR(iRST),
    .D(wHIT)
);

(* dont_touch = "TRUE" *) FDCE #(.INIT(1'b0)) edge_detector_ffd1(
    .Q(wEDGE[1]),
    .C(iCLK0),
    .CE(1'b1),
    .CLR(iRST),
    .D(wEDGE[0])
);


assign wRISEEDGE = wEDGE[0] & ~wEDGE[1];
assign wFALLEDGE = wEDGE[1] & ~wEDGE[0];

//FINE TDC

FINETDC start_tdc_inst(
    .iCLK(iCLK0),
    .iRST(rVALUEREADYOUT),
    .iHIT(wHIT),
    .iSTORESTART(wRISEEDGE),
    .iSTORESTOP(wFALLEDGE),
    .oTHERMOMETERSTARTVALUE(wTHERMOMETERSTART),
    .oTHERMOMETERSTOPVALUE(wTHERMOMETERSTOP)
);

//COARSE COUNTER

COARSECOUNTER coarse_cnt_inst(
    .iCLK(iCLK0),
    .iRST(wENDOFCONVERTION),
    .iHIT(wHIT),
    .iSTORE(wFALLEDGE),
    .oCOARSEVALUE(wCOARSEVALUE)
);

//COARSE COUNTER ARBITER
wire [1:0] wAEDGE;
wire wARISEEDGE;
wire wAFALLEDGE;

(* dont_touch = "TRUE" *) FDCE #(.INIT(1'b0)) arbiter_edge_detector_ffd0(
    .Q(wAEDGE[0]),
    .C(iCLK1),
    .CE(1'b1),
    .CLR(iRST),
    .D(wHIT)
);

(* dont_touch = "TRUE" *) FDCE #(.INIT(1'b0)) arbiter_edge_detector_ffd1(
    .Q(wAEDGE[1]),
    .C(iCLK1),
    .CE(1'b1),
    .CLR(iRST),
    .D(wAEDGE[0])
);


assign wARISEEDGE = wAEDGE[0] & ~wAEDGE[1];
assign wAFALLEDGE = wAEDGE[1] & ~wAEDGE[0];

COARSECOUNTER coarse_cnt_arbiter_inst(
    .iCLK(iCLK1),
    .iRST(wENDOFCONVERTION),
    .iHIT(wHIT),
    .iSTORE(wAFALLEDGE),
    .oCOARSEVALUE(wCOARSEARBITERVALUE)
);

//SECOND COARSE COUNTER ARBITER
wire [1:0] wA2EDGE;
wire wA2RISEEDGE;
wire wA2FALLEDGE;

(* dont_touch = "TRUE" *) FDCE #(.INIT(1'b0)) arbiter2_edge_detector_ffd0(
    .Q(wA2EDGE[0]),
    .C(iCLK2),
    .CE(1'b1),
    .CLR(iRST),
    .D(wHIT)
);

(* dont_touch = "TRUE" *) FDCE #(.INIT(1'b0)) arbiter2_edge_detector_ffd1(
    .Q(wA2EDGE[1]),
    .C(iCLK2),
    .CE(1'b1),
    .CLR(iRST),
    .D(wA2EDGE[0])
);


assign wA2RISEEDGE = wA2EDGE[0] & ~wA2EDGE[1];
assign wA2FALLEDGE = wA2EDGE[1] & ~wA2EDGE[0];

COARSECOUNTER coarse_cnt_arbiter2_inst(
    .iCLK(iCLK2),
    .iRST(wENDOFCONVERTION),
    .iHIT(wHIT),
    .iSTORE(wA2FALLEDGE),
    .oCOARSEVALUE(wCOARSEARBITER2VALUE)
);

//DECODE START THERMOMETER

DECODESTART decode_start_inst(
    .iTHERMOMETERSTART(wTHERMOMETERSTART),
    .oBINSTART(wBINSTART)
);

//DECODE STOP THERMOMETER

DECODESTOP decode_stop_inst(
    .iTHERMOMETERSTOP(wTHERMOMETERSTOP),
    .oBINSTOP(wBINSTOP)
);

//END OF CONVERTION CIRCUIT

(* dont_touch = "TRUE" *)FDCE #(.INIT(1'b0)) enable_delay_dff(
    .Q(wENABLEDELAY),
    .C(wFALLEDGE),
    .CE(1'b1),
    .CLR(wENDOFCONVERTION),
    .D(1'b1)
);

always @(posedge iCLK0)
begin
    if(wENDOFCONVERTION)
    begin
        rDELAYCNT <= 0;
    end
    else if(wENABLEDELAY)
    begin
        rDELAYCNT <= rDELAYCNT + 1'b1;
    end    
end

assign wENDOFCONVERTION = rDELAYCNT;

//MERGE CIRCUIT

//assign wTDCVALUE = {wCOARSEVALUE, wBINSTART, wBINSTOP};

/*assign wTDCVALUE =  (wBINSTART == 0 & wCOARSEVALUE < wCOARSEARBITERVALUE)    ?   {wCOARSEARBITERVALUE, wBINSTART, wBINSTOP}    :
                    (wBINSTOP == 0 & wCOARSEVALUE > wCOARSEARBITERVALUE)     ?   {wCOARSEARBITERVALUE, wBINSTART, wBINSTOP}    :   {wCOARSEVALUE, wBINSTART, wBINSTOP};*/

wire wSTARTPHASEDECIDER; //DETERMINES THE POSITION IN WHICH THE START SIGNAL WAS CAPTURED - LOGIC 1 IF START > 4NS
wire wSTOPPHASEDECIDER; //DETERMINES THE POSITION IN WHICH THE STOP SIGNAL WAS CAPTURED - LOGIC 1 IF STOP > 4NS

assign wSTARTPHASEDECIDER = (wBINSTART > 210) ? 1 : 0;
assign wSTOPPHASEDECIDER = (wBINSTOP > 210) ? 1 : 0;

assign wTDCVALUE =  (wBINSTART == 0 & wCOARSEVALUE <= wCOARSEARBITERVALUE & wCOARSEARBITERVALUE > wCOARSEARBITER2VALUE)                             ?   {wCOARSEARBITERVALUE, wBINSTART, wBINSTOP}          :
                    (wBINSTART == 0 & wCOARSEVALUE <= wCOARSEARBITERVALUE & wCOARSEARBITERVALUE == wCOARSEARBITER2VALUE  & ~wSTOPPHASEDECIDER)      ?   {wCOARSEARBITERVALUE, wBINSTART, wBINSTOP}          :
                    (wBINSTART == 0 & wCOARSEVALUE <= wCOARSEARBITERVALUE & wCOARSEARBITERVALUE == wCOARSEARBITER2VALUE  & wSTOPPHASEDECIDER)       ?   {wCOARSEARBITERVALUE + 1'b1, wBINSTART, wBINSTOP}   :
                    (wBINSTOP == 0 & wCOARSEVALUE >= wCOARSEARBITERVALUE & wCOARSEARBITERVALUE < wCOARSEARBITER2VALUE)                              ?   {wCOARSEARBITERVALUE, wBINSTART, wBINSTOP}          :
                    (wBINSTOP == 0 & wCOARSEVALUE >= wCOARSEARBITERVALUE & wCOARSEARBITERVALUE == wCOARSEARBITER2VALUE & ~wSTARTPHASEDECIDER)       ?   {wCOARSEARBITERVALUE, wBINSTART, wBINSTOP}          :
                    (wBINSTOP == 0 & wCOARSEVALUE >= wCOARSEARBITERVALUE & wCOARSEARBITERVALUE == wCOARSEARBITER2VALUE & wSTARTPHASEDECIDER)        ?   {wCOARSEARBITERVALUE - 1'b1, wBINSTART, wBINSTOP}   :   {wCOARSEVALUE, wBINSTART, wBINSTOP}; 


(* dont_touch = "TRUE" *)FDRE #(.INIT(1'b0)) value_ready_dff(
    .Q(rVALUEREADY),
    .C(iCLK0),
    .CE(1'b1),
    .R(~wENDOFCONVERTION),
    .D(1'b1)
);

(* dont_touch = "TRUE" *)FDRE #(.INIT(1'b0)) value_ready_out_dff(
    .Q(rVALUEREADYOUT),
    .C(iCLK0),
    .CE(1'b1),
    .R(rVALUEREADYOUT),
    .D(rVALUEREADY)
);

always @(posedge iCLK0)
begin
    if(iRST)
    begin
        rTDCVALUE <= 0;
    end
    else if(wENDOFCONVERTION)
    begin
        rTDCVALUE <= wTDCVALUE;     
    end
end

assign oTDCVALUE = rTDCVALUE;
assign oVALUEREADY = rVALUEREADYOUT;

//assign oCOARSEARBITERVALUE = wCOARSEARBITERVALUE;

//DEBUG SECTION
//assign oTHERMOMETERSTART = wTHERMOMETERSTART;
//assign oTHERMOMETERSTOP = wTHERMOMETERSTOP;
//END OF DEBUG SECTION


endmodule
