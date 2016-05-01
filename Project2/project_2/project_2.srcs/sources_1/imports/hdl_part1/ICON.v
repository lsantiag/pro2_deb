/*
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


module ICON#(
    //Encoding for No ICON
        parameter ICON_TRANSPARENT = 2'b00,
        parameter ICON_BLACK = 2'b00,
        parameter ICON_WHITE = 2'b11,

    //Encoding the BOTsim Orientation
        parameter NORTH         = 3'h0,
        parameter NORTHEAST     = 3'h1,
        parameter EAST          = 3'h2,
        parameter SOUTHEAST     = 3'h3,
        parameter SOUTH         = 3'h4,
        parameter SOUTHWEST     = 3'h5,
        parameter WEST          = 3'h6,
        parameter NORTHWEST     = 3'h7
)

(
    input       [7:0]       LocX_reg,               //Location X of bot
                            LocY_reg,               //Location Y of bot
                            BotInfo_reg,            //Information about bot's activity
                        
    input       [9:0]       pixel_row,              //current pixel row address
                            pixel_column,           //current pixel column address
    
    input                   clock,                  //VGA Clock
    input                   reset,                  //VGA Reset
    
    output  reg [1:0]       icon_pixel              //ICON positon change
    );

    //Local Parameters
    wire    LocX_map = 4*LocX_reg;                     //Scaling the X location of BOT world to VGA scale
    wire    LocY_map = 4*LocY_reg;                     //Scaling the Y location of BOT world to VGA scale
    wire    [2:0]   orient;
    
    //Setting the ICON Boundary
    wire X_boundary = (pixel_column >= LocX_map-8) && (pixel_column <= LocX_map+8);
    wire Y_boundary = (pixel_row >= LocY_map-8) && (pixel_row <= LocX_map+8);
    
    //Getting the ICON Offset Pixel
    //X_Icon_offset =
    //ROM Address and OUTPUT
    wire [8:0]  ROM1_Address;
    wire [8:0]  ROM2_Address;
    wire [1:0]  ROM1_out;
    wire [1:0]  ROM2_out;
    
    //Assigning the orientation
    assign orient = BotInfo_reg[2:0];
    
    //Determining the Orientation
    always @(posedge clock) begin
            case(orient)
                NORTH:      ROM1_Address <=;
                SOUTH:      ROM1_Address <=;
                EAST:       ROM1_Address <=;
                WEST:       ROM1_Address <=;
                NORTHEAST:  ROM2_Address <=;
                NORTHWEST:  ROM2_Address <=;
                SOUTHEAST:  ROM2_Address <=;
                SOUTHWEST:  ROM2_Address <=;              
            endcase
    end
    
    //Determining the ICON Pixel value
    always @(posedge clock) begin
            if(reset)
                icon_pixel <= ICON_TRANSPARENT;
            else if(X_boundary && Y_boundary) begin
                    case(orient)
                        NORTH,EAST,SOUTH,WEST: icon_pixel <= ROM1_out;
                        NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST <= ROM2_out;
                    endcase
                end
            else    
                icon_pixel <= ICON_TRANSPARENT;
    end
//Instantiate the ICON_0 ROM module
    ICON_0(
    .clka(clock), 
    .addra(ROM1_Address), 
    .douta(ROM1_out[0]), 
    .clkb(clock), 
    .addrb(ROM1_Address), 
    .doutb(ROM1_out[1]));

//Instantiate the ICON_1 ROM module
   
endmodule
*/
