`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/29/2016 06:31:33 PM
// Design Name: 
// Module Name: ICON
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


module ICON(
    input   [7:0]       LocX_reg,               //Location X of bot
                        LocY_reg,               //Location Y of bot
                        BotInfo_reg,            //Information about bot's activity
                        
    input   [9:0]       pixel_row,              //current pixel row address
                        pixel_column,           //current pixel column address
                    
    output  reg [1:0]   icon                    //ICON positon change
    );
    
    
endmodule
