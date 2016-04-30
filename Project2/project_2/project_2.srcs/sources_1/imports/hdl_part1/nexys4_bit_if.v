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
module nexys4_bot_if#(
    /*==============================================================*/
    //                 PARAMTER DECLARATION                         //
    /*==============================================================*/
    parameter integer RESET_POLARITY_LOW = 1,
    
    //Parameters PORT Constants
    parameter   PA_PBTNS                 = 8'h00,
    parameter   PA_SLSWTCH               = 8'h01,
    parameter   PA_LEDS                  = 8'h02,
    parameter   PA_DIG3                  = 8'h03,
    parameter   PA_DIG2                  = 8'h04,
    parameter   PA_DIG1                  = 8'h05,
    parameter   PA_DIG0                  = 8'h06,
    parameter   PA_DP                    = 8'h07,
    parameter   PA_MOTCTL_IN             = 8'h09,   
    
    parameter   PA_LOCX             	 = 8'h0A,
    parameter   PA_LOCY		             = 8'h0B,
    parameter   PA_BOTINFO		         = 8'h0C,    
    parameter   PA_SENSORS      		 = 8'h0D,
    parameter   PA_LMDIST            	 = 8'h0E,
    parameter   PA_RMDIST   		     = 8'h0F,
    parameter   PA_SLSWTCH1508           = 8'h11,
    
    parameter   PA_LEDS1508         	 = 8'h12,
    parameter   PA_DIG7 		         = 8'h13,
    parameter   PA_DIG6         		 = 8'h14,
    parameter   PA_DIG5     		     = 8'h15,
    parameter   PA_DIG4     		     = 8'h16,
    parameter   PA_DP0704		         = 8'h17
    
    
    
)    
(
  //IO definition for BOT interface
  input        [7:0] LocX_reg,                   // X-coordinate of rojobot's location
                     LocY_reg,                   // Y-coordinate of rojobot's location
                     BotInfo_reg,                // Information about rojobot's activity
                     Sensors_reg,                // Sensor readings
                     LMDist_reg,                 // left motor distance register
                     RMDist_reg,                 // right motor distance register

  input              upd_sysregs,                // flag from PicoBlaze to indicate that the system registers

  output  reg  [7:0] MotCtl,                     // Motor control output

  //IO definition for picoblaze (Names with respct to picoblaze)
  input        [7:0] port_id,                    // I/O port address
  input        [7:0] io_dataIn,                  // Data from the picoblaze to be written to I/O register
  output  reg  [7:0] io_dataOut,                 // Data from the I/O register to the Picoblaze
  input              write_strobe,               // Asserted to write the data register
  input              read_strobe,                // Asserted to read the data register
  output  reg        interrupt,                  // Interrupt request to Picoblaze
  input              interrupt_ack,              // Interrupt acknowledge from Picoblaze

  //IO definition with debounce module
  input      [15:0]  db_sw,                     // slider switches
  input       [7:0]  db_btns,                   // pushbutton inputs - including CPU RESET button

  //IO definition with 7-segment display
  output  reg  [4:0] dig7,dig6,
                     dig5,dig4,
                     dig3,dig2,
                     dig1,dig0,

  output  reg  [7:0] dp,
  output  reg [15:0] led,

  //Global System interface
  input sysclk,
  input sysrst
  );

  //System Asserted RESET
  wire reset_in = RESET_POLARITY_LOW ? ~sysrst : sysrst;

  /*================================================================*/
  //                    General Input port mapping                  //
  /*================================================================*/

  always @(posedge sysclk) begin
    if(reset_in)
            io_dataOut<=8'h0;
    else begin
            case (port_id)
                //Read the input ports
                PA_LOCX:
                    io_dataOut<=LocX_reg;
                PA_LOCY:
                    io_dataOut<=LocY_reg;
                PA_BOTINFO:
                    io_dataOut<=BotInfo_reg;
                PA_SENSORS:
                    io_dataOut<=Sensors_reg;
                PA_LMDIST:
                    io_dataOut<=LMDist_reg;
                PA_RMDIST:
                    io_dataOut<=RMDist_reg;

                //Read the higher switch status
                PA_SLSWTCH1508:
                    io_dataOut<=db_sw[15:8];
                //Read the lower switch status
                PA_SLSWTCH:
                    io_dataOut<=db_sw[7:0];
                // Read the status of debounce buttons
                PA_PBTNS:
                    io_dataOut <= db_btns;
                default:
                    io_dataOut<=8'bxxxxxxxx;
            endcase
        end
  end
  
  /*===================================================================*/
  //                       General Output port Mapping                 //
  /*===================================================================*/
  always @(posedge sysclk) begin
    if(reset_in) begin
        //Resetting all the inputs to IO
        led <= 16'b0;
        dig0 <= 5'b0;
        dig1 <= 5'b0;
        dig2 <= 5'b0;
        dig3 <= 5'b0;
        dig4 <= 5'b0;
        dig5 <= 5'b0;
        dig6 <= 5'b0;
        dig7 <= 5'b0;
        MotCtl <= MotCtl;
    end            
    else begin
        if(write_strobe == 1'b1) begin      //Validating the write signal
            case (port_id)
                PA_LEDS:
                    led[7:0] <= io_dataIn;
                PA_LEDS1508:
                    led[15:8] <= io_dataIn;
                PA_DIG7:
                    dig7 <= io_dataIn;
                PA_DIG6:
                    dig6 <= io_dataIn;
                PA_DIG5:
                    dig5 <= io_dataIn;
                PA_DIG4:
                    dig4 <= io_dataIn;
                PA_DP0704:
                    dp[7:4] <= io_dataIn[7:4];
                PA_DIG3:
                    dig3 <= io_dataIn;
                PA_DIG2:
                    dig2 <= io_dataIn;
                PA_DIG1:
                    dig1 <= io_dataIn;
                PA_DIG0:
                    dig0 <= io_dataIn;
                PA_DP:
                    dp[3:0] <= io_dataIn[3:0];
                PA_MOTCTL_IN:
                    MotCtl <= io_dataIn;
                default:
                    begin
                        led <= led;
                        dig0 <= dig0;
                        dig1 <= dig1;
                        dig2 <= dig2;
                        dig3 <= dig3;
                        dig4 <= dig4;
                        dig5 <= dig5;
                        dig6 <= dig6;
                        dig7 <= dig7;
                        MotCtl <= MotCtl;
                    end
            endcase
        end
    end
 end
  /*=========================================================================*/
  //                    Interrupt Logic for Interface                        //
  /*=========================================================================*/
  always @(posedge sysclk) begin
    if(reset_in)
        interrupt<=1'b0;            //Interrupt Disabled for reset condition
    else if(interrupt_ack ==1'b1) 
        interrupt <= 1'b0;          //Interrupt Disabled, once it is acknowledged
    else if(upd_sysregs)
        interrupt <= 1'b1;          //Interrupt enabled due to request from botsim
    else
        interrupt <= interrupt;     //default 
  end
 endmodule