/*
///////////////////////////////////////////////////////////////////
//	nexys4fpga.v 
//	Created By:			ROY Kravitz
//	Last Modified:		23-April-2016 
//	
//	Revision History:
//	-----------------
//	April		YS,LS		Modified this module
//	
//	Description
//	-----------
//  The Top Module for RojoBot
///////////////////////////////////////////////////////////////////
*/
module Nexys4fpga ( 
 
    input                   clk,                        // 100MHz clock from on-board oscillator  


    input                   btnL, btnR,                     // pushbutton inputs - left (db_btns[4])and right (db_btns[2])  
    input                   btnU, btnD,                     // pushbutton inputs - up (db_btns[3]) and down (db_btns[1])           
    input                   btnC,                           // pushbutton inputs - center button ->  db_btns[5]          
    input                   btnCpuReset,                    // red pushbutton input -> db_btns[0] 

    input       [15:0]      sw,                             // switch inputs

    input 	    [9:0]       vid_row,                        // video logic row address
                            vid_col,                        // video logic column address

    output      [1:0]       vid_pixel_out,                  // pixel (location) value    
    output      [15:0]      led,                            // LED outputs   
    output      [6:0]       seg,                            // Seven segment display cathode pins  
    output                  dp,  
    output      [7:0]       an,                             // Seven segment display anode pins     
    output      [7:0]       JA,                              // JA Header 

//OUTPUT for VGA
	output 			    	vga_hsync,				        // horizontal sync pulse from DTG
	output 		    		vga_vsync,				        // vertical sync pulse from DTG
	output 	    [3:0]		vga_red,				        // red pixel data --> send to screen
	output 	    [3:0]		vga_green,				        // green pixel data --> send to screen
	output 	    [3:0]		vga_blue				        // blue pixel data --> send to screen

);




// parameter  
parameter SIMULATE = 0;  

// internal variables  
wire  [15:0]     db_sw;                         // debounced switches 
wire  [5:0]      db_btns;                       // debounced buttons
wire             sysclk;                        // 100MHz clock from on-board 

//Clock Wizard variables
wire             VGAclk;                        // VGAclk is 25MHz
wire             Clk_75MHz;                     // Clk generated for 75MHz
wire             Clk_100MHz;                    // Clk generated for 100MHz

// oscillator   
wire             sysreset;                      // system reset signal – asserted 

 // high to force reset    
wire  [4:0]      dig7, dig6, dig5, dig4,        // display digits 7-4
                 dig3, dig2, dig1, dig0;        // display digits 3-0  
                
wire  [7:0]      decpts;                        // decimal points  
wire  [7:0]      segs_int;                      // segment outputs (internal)  
wire  [63:0]     digits_out;                    // digits_out (only for simulation)  
wire  [17:0]     instruction; 

 
 // PicoBlaze interface  
wire [11:0] address;  
wire        bram_enable;  
wire [7:0]  port_id; 
wire [7:0]  out_port;  
wire [7:0]  in_port;  
wire        write_strobe;  
wire        k_write_strobe;  
wire        read_strobe; 
wire        interrupt;  
wire        interrupt_ack;  
wire        sleep;                  //kcpsm6_sleep;  
wire        kcpsm6_reset;  
wire        cpu_reset;  
wire        rdl;  
wire        int_request;

//VGA interface (Colorizer, ICON, DTG)
wire        video_on;
wire [1:0]  world_pixel;
wire [11:0] Screen_Color;
wire [9:0]  pixel_row;
wire [9:0]  pixel_column;


// new block (only for reference remove later )
wire [7:0]  motctl;
wire [7:0]  locX, locY;
wire [7:0]  botinfo;
wire [7:0]  sensors;
wire [7:0]  lmdist;
wire [7:0]  rmdist;
wire        upd_sysregs;

/*
// set up the display by blanking all but Digit[0] 
assign  dig7 = {5'b00011};  
assign  dig6 = {5'b11111};  
assign  dig5 = {5'b11111};  
assign  dig4 = {5'b11111};  
assign  dig3 = {5'b11111};  
assign  dig2 = {5'b11111};  
assign  dig1 = {5'b11111}; 
*/

/*
 // The debounced switches, 7-segment Digit[0] and the 7-segment decimal   
 // points are writable by the Picoblaze  assign    
 dig0 = digit0_int[4:0];    
*/

 // global assigns  
assign  sysclk          =   clk;  
assign  sysreset        =   ~db_btns[0]; // btnCpuReset is asserted low so invert it  
assign  sw_high         =   db_sw[15:8];  
assign  sw_low          =   db_sw[7:0]; 


assign  dp              =   segs_int[7];  
assign  seg             =   segs_int[6:0];
assign  JA              =   {sysclk, sysreset, 6'b000000};
assign  vga_red         =   Screen_Color[11:8];
assign  vga_green       =   Screen_Color[7:4];
assign  vga_blue        =   Screen_Color[3:0];

/*==================================================================================*/
//                       Instantiating the Clock Wizard                             //
/*==================================================================================*/
clk_wiz_0_clk_wiz clock_Wizard(
   // Clock in ports
    .clk_in1(sysclk),                   // 100MHz clock from on-board oscillator 
    // Clock out ports
    .clk_out1(Clk_100MHz),              //sysclk is 100MHz
    .clk_out2(Clk_75MHz),  
    .clk_out3(VGAclk),                  //VGAclk is 25MHz
    
    // Status and control signals
    .reset(1'b0),                       // input reset
    .locked(locked)                     // outut locked
);                   
    
    
/*==================================================================================*/
//                     Instantiating the Debounce Buttons                           //
/*==================================================================================*/  
debounce    #(
                .RESET_POLARITY_LOW(1),
                .SIMULATE(SIMULATE)  )   
        DB  (
                .clk(Clk_100MHz),
                .pbtn_in({btnC,btnL,btnU,btnR,btnD,btnCpuReset}),
                .switch_in(sw),   
                .pbtn_db(db_btns),   
                .swtch_db(db_sw)  
            );
                
/*==================================================================================*/
//                 Instantiating the 7-segment, 8-digit display                     //
/*==================================================================================*/                
sevensegment #(   
                .RESET_POLARITY_LOW(0), 
                .SIMULATE(SIMULATE)) 
         SSB    (   // inputs for control signals   
                 .d0(dig0),   
                 .d1(dig1),    
                 .d2(dig2),   
                 .d3(dig3),   
                 .d4(dig4),   
                 .d5(dig5),   
                 .d6(dig6),   
                 .d7(dig7),   
                 .dp(decpts),      
                 
        // outputs to seven segment display   
        .seg(segs_int),      
        .an(an),      
        // clock and reset signals (100 MHz clock, active high reset)   
        .clk(Clk_100MHz),   
        .reset(sysreset),      
        
        // ouput for simulation only   
        .digits_out(digits_out)  );


/*==================================================================================*/
//                             Instantiating the Colorizer                          //
/*==================================================================================*/        
colorizer colo(
                .sysclk(VGAclk),
                .sysreset(sysreset),
                .video_on(video_on),
                .world_pixel(world_pixel),
                //.icon(),
                .Screen_Color(Screen_Color)
            );

/*==================================================================================*/
//                                 Instantiating the DTG                            //
/*==================================================================================*/ 
dtg generate_dtg(
                .clock(VGAclk), 
                .rst(sysreset),
                .horiz_sync(vga_hsync), 
                .vert_sync(vga_vsync),
                .video_on(video_on),
                .pixel_row(pixel_row),
                .pixel_column(pixel_column)
);




/*==================================================================================*/
//              Instantiating the PicoBlaze and instruction ROM                     //
/*==================================================================================*/         
assign kcpsm6_sleep = 1'b0;  
assign kcpsm6_reset = sysreset | rdl;

kcpsm6  #(   
            .interrupt_vector (12'h3FF),   
            .scratch_pad_memory_size(64),   
            .hwbuild  (8'h00))   
    APPCPU(   
            .address   (address),   
            .instruction  (instruction),   
            .bram_enable  (bram_enable),   
            .port_id   (port_id),   
            .write_strobe  (write_strobe),   
            .k_write_strobe (k_write_strobe),   
            .out_port   (out_port),   
            .read_strobe  (read_strobe),   
            .in_port   (in_port),   
            .interrupt   (interrupt),   
            .interrupt_ack  (interrupt_ack),   
            .reset    (kcpsm6_reset),   
            .sleep   (kcpsm6_sleep),   
            .clk    (Clk_100MHz));  
       
 proj2demo #(  .C_FAMILY     ("7S"),      //Family 'S6' or 'V6' or '7S'   
             .C_RAM_SIZE_KWORDS (2),    //Program size '1', '2' or '4'   
             .C_JTAG_LOADER_ENABLE (1)) //Include JTAG Loader when set to 1'b1   
   PRJ_Demo (                   
            .rdl    (),   
            .enable   (bram_enable),   
            .address   (address),   
            .instruction  (instruction),   
            .clk    (Clk_100MHz));        
          

bot ROJO(
    .clk(Clk_100MHz),
    .reset(sysreset),
    .MotCtl_in(motctl),
    .LocX_reg(locX),		        // X-coordinate of rojobot's location		
    .LocY_reg(locY),                // Y-coordinate of rojobot's location
    .Sensors_reg(sensors),          // Sensor readings
    .BotInfo_reg(botinfo),          // Information about rojobot's activity
    .LMDist_reg(lmdist),            // left motor distance register
    .RMDist_reg(rmdist),
    .upd_sysregs(upd_sysregs),
    .vid_row(pixel_row/4),
    .vid_col(pixel_column/4),
    .vid_pixel_out(world_pixel)
);


/*==================================================================================*/
//             Instantiating the PicoBlaze I/O register interface                   //
/*==================================================================================*/  
nexys4_bot_if #(
                .RESET_POLARITY_LOW(0)
                )  
    N4IF(
            .write_strobe(write_strobe),   
            .read_strobe(read_strobe),   
            .port_id(port_id),   
            .io_dataIn(out_port),      // data from Picoblaze to the I/O register   
            .io_dataOut(in_port),    // data from I/O register to Picoblaze      
            .interrupt_ack(interrupt_ack),   
            .interrupt(interrupt),   
            
            .LocX_reg(locX),
            .LocY_reg(locY),
            .BotInfo_reg(botinfo),
            .Sensors_reg(sensors),
            .LMDist_reg(lmdist),
            .RMDist_reg(rmdist),
            .upd_sysregs(upd_sysregs),
            .MotCtl(motctl),
            
            .db_sw(db_sw),
            .db_btns({3'b000,db_btns[4:1]}),
            .dig7(dig7),
            .dig6(dig6), 
            .dig5(dig5),
            .dig4(dig4),
            .dig3(dig3),
            .dig2(dig2),
            .dig1(dig1),
            .dig0(dig0),
            .dp(decpts),
            .led(led),
            
            .sysclk(Clk_100MHz),   
            .sysrst(sysreset) 
            ); 
            

endmodule 
        
        