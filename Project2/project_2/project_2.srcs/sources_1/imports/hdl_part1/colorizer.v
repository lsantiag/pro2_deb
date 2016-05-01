/*
///////////////////////////////////////////////////////////////////
//	nexys4_bit_if.v 
//	Created By:			Yadnesh Samant & Luis Santiago
//	Last Modified:		23-April-2016 
//	
//	Revision History:
//	-----------------
//	April		YS,LS		Created this module
//	
//	Description
//	-----------
//
///////////////////////////////////////////////////////////////////
*/

module colorizer#(

    /*==============================================================*/
    //                 PARAMTER DECLARATION                         //
    /*==============================================================*/
    
    // World Map pixel encoding
        parameter       WORLD_BACKGROUND    = 2'b00,
        parameter       WORLD_BLACKLINE     = 2'b01,
        parameter       WORLD_OBSTRUCTION   = 2'b10,
        parameter       WORLD_RESERVED      = 2'b11,
        
    // ICON pixel encoding
        parameter       ICON_TRANSPARENT    = 2'b00,          
    
    //Color Encoding
        parameter       RGB_BLACK           = 12'h000,
        parameter       RGB_WHITE           = 12'hFFF,
        parameter       RGB_RED             = 12'hF00, 
        parameter       RGB_BLUE            = 12'h00F,
        parameter       RGB_LIGHTBLUE       = 12'h0FF
)(
        //Declaring the Inputs
        input                    sysclk, sysreset,       //VGA Clock and Reset 
            
        input                    video_on,               //Video ON signal from the DTG Module
        
        input           [1:0]    world_pixel,            //World pixel from BOT world
        //                         icon_pixel,                   //ICON pixel from the ICON module
        
        //Declaring the Output
        output    reg   [11:0]   Screen_Color            //Output from Colorizer
);
    
    always @( posedge sysclk) begin
        if(sysreset | ~video_on)                           //Validating for synchronous reset or video_on signal OFF
                Screen_Color <= RGB_RED;
        /*else if (icon_pixel != ICON_TRANSPARENT) 
           Screen_Color <= RGB_YELLOW;*/
        else
            case(world_pixel)                          
                WORLD_BACKGROUND  : Screen_Color  =    RGB_LIGHTBLUE;
                WORLD_BLACKLINE   : Screen_Color  =    RGB_BLACK;
                WORLD_OBSTRUCTION : Screen_Color  =    RGB_BLUE;
                WORLD_RESERVED    : Screen_Color  =    RGB_BLACK;
                default           : Screen_Color  =    RGB_RED;
            endcase        
    end //always
endmodule

