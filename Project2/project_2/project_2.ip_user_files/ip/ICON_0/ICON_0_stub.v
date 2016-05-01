// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Sat Apr 30 23:09:05 2016
// Host        : LAPTOP-50QHPPJG running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/yadne/Documents/GitHub/pro2_deb/Project2/project_2/project_2.srcs/sources_1/ip/ICON_0/ICON_0_stub.v
// Design      : ICON_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_3_1,Vivado 2015.4" *)
module ICON_0(clka, addra, douta, clkb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,addra[8:0],douta[0:0],clkb,addrb[8:0],doutb[0:0]" */;
  input clka;
  input [8:0]addra;
  output [0:0]douta;
  input clkb;
  input [8:0]addrb;
  output [0:0]doutb;
endmodule
