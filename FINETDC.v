`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.01.2018 11:38:01
// Design Name: 
// Module Name: FINETDC
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

(* keep_hierarchy = "TRUE" *) module FINETDC(
    input iCLK,
    input iRST,
    input iHIT,
    input iSTORESTART,
    input iSTORESTOP,
    output [`NUM_STAGES-1:0] oTHERMOMETERSTARTVALUE,
    output [`NUM_STAGES-1:0] oTHERMOMETERSTOPVALUE
);

wire [`NUM_STAGES-1:0] wFINEVALUE;
wire [`NUM_STAGES-1:0] wTDCVALUE; 
wire [`NUM_STAGES-1:0] wTHERMOMETERSTARTVALUE;
wire [`NUM_STAGES-1:0] wTHERMOMETERSTOPVALUE; 

//FINE TDC DELAY CHAIN
genvar i;
generate
    for(i=0; i <= `NUM_STAGES/4-1; i=i+1) 
    begin : generate_block
        if(i==0)
        begin
        (* dont_touch = "TRUE" *) CARRY4 carry4_1(
            .CO(wFINEVALUE[3:0]),
            .CI(1'b0),
            .CYINIT(iHIT),
            .DI(4'b0000),
            .S(4'b1111),
            .O()
        );
        end
        else
        begin
        (* dont_touch = "TRUE" *) CARRY4 carry4_1(
            .CO(wFINEVALUE[4*(i+1)-1:4*i]),
            .CI(wFINEVALUE[4*i-1]),
            .CYINIT(1'b00),
            .DI(4'b0000),
            .S(4'b1111),
            .O()
        );
        end         
    end
endgenerate

//FIRST STAGE D FLIP FLOPS TO SAMPLE DELAY CHAIN
genvar j;
generate
    for(j=0;j<=`NUM_STAGES-1;j=j+1)
    begin
       (* dont_touch = "TRUE" *) FDCE #(.INIT(1'b0)) rTDCVALUE(
        .Q(wTDCVALUE[j]),
        .C(iCLK),
        .CE(1'b1),
        .CLR(1'b0),
        .D(wFINEVALUE[j])
       );
    end
endgenerate

//STORE STAGE D FLIP FLOPS TO SAVE FINE DELAY CHAIN VALUE
genvar k;
generate
    for(k=0;k<=`NUM_STAGES-1;k=k+1)
    begin
       (* dont_touch = "TRUE" *) FDCE #(.INIT(1'b0)) rTHERMOMETERSTARTVALUE(
        .Q(wTHERMOMETERSTARTVALUE[k]),
        .C(iCLK),
        .CE(iSTORESTART),
        .CLR(iRST),
        .D(wTDCVALUE[k])
       );
    end
endgenerate

genvar l;
generate
    for(l=0;l<=`NUM_STAGES-1;l=l+1)
    begin
       (* dont_touch = "TRUE" *) FDCE #(.INIT(1'b0)) rTHERMOMETERSTOPVALUE(
        .Q(wTHERMOMETERSTOPVALUE[l]),
        .C(iCLK),
        .CE(iSTORESTOP),
        .CLR(iRST),
        .D(wTDCVALUE[l])
       );
    end
endgenerate

assign oTHERMOMETERSTARTVALUE = wTHERMOMETERSTARTVALUE;
assign oTHERMOMETERSTOPVALUE = wTHERMOMETERSTOPVALUE;

endmodule
