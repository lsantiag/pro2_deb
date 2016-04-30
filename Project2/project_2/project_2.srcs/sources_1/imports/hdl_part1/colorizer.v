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
        parameter       WORLD_BACKGROUND    = 2'B00,
        parameter       WORLD_BLACKLINE     = 2'B01,
        parameter       WORLD_OBSTRUCTION   = 2'B10,
        parameter       WORLD_RESERVED      = 2'B11,
        
    // ICON pixel encoding
        parameter       ICON_TRANSPARENT    = 12'h000,
        parameter       RGB_BLACK           = 12'h000,
        parameter       RGB_WHITE           = 12'hFFF,
        parameter       RGB_RED             = 12'hF00, 
        parameter       RGB_BLUE            = 12'h00F       
)(
        //Declaring the Inputs
        input                    sysclk, sysreset,       //System Clock and System Reset 
            
        input                    video_on,               //Video ON signal from the DTG Module
        
        input           [1:0]    world_pixel,            //World pixel from BOT world
                                 //icon,                   //ICON pixel from the ICON module
        
        //Declaring the Output
        output          [11:0]   Screen_Color            //Output from Colorizer
);
    
    always @( posedge clk) begin
        if(reset | ~video_on)                           //Validating for synchronous reset or video_on signal OFF
                Screen_Color <=     RGB_BLACK;
        else 
            case(world_pixel)                          
                WORLD_BACKGROUND  : Screen_Color  =    RGB_WHITE;
                WORLD_BLACKLINE   : Screen_Color  =    RGB_BLACK;
                WORLD_OBSTRUCTION : Screen_Color  =    RGB_BLUE;
                WORLD_RESERVED    : Screen_Color  =    RGB_BLACK;
                default           : Screen_Color  =    RGB_RED;
            endcase        
    end //always
endmodule

