/*******************************************************************************
#Author: Seungmin.Jeong(Graduated from Kwangwoon University, Seoul, Korea 2023.02)
#Purpose: verilog code / log2 function & global parameter
#Revision History: 2023.03.03
*******************************************************************************/
function [31:0] clog2;
   input [31:0] value;
   integer i;
   reg [31:0] j;
   begin
      j = value - 1;
      clog2 = 0;
      for (i = 0; i < 31; i = i + 1)
        if (j[i]) clog2 = i+1;
   end
endfunction


parameter W_BW = 8;
parameter B_BW = 16;
parameter K_SIZE = 5;
parameter P_SIZE = 2;
parameter Num_of_TestImage = 100;
//Convlayer1 param
parameter I_SIZE1 = 28;
parameter O_SIZE1 = I_SIZE1 - K_SIZE + 1;
parameter I_SIZE1_max = I_SIZE1 - K_SIZE + 1;
parameter O_SIZE1_max = (I_SIZE1 - K_SIZE + 1)/2 ;
parameter I_BW1 = 8;
parameter O_BW1 = 16;
parameter CI1   = 1;
parameter Kernel_ch_depth1 = CI1;
parameter CO1   = 4;
parameter O_CONV_BW1 = (I_BW1 + W_BW) + clog2(K_SIZE*K_SIZE) - 1; // 16 + 5 - 1 = 20
parameter O_CONVSUM_BW1 = O_CONV_BW1 + clog2(CI1) - 1; // 20 + 1 - 1 = 20
parameter mem_ifmap1_bit_width = I_BW1;
parameter mem_ifmap1_addr_width = clog2(I_SIZE1*I_SIZE1);
parameter mem_ifmap1_depth = I_SIZE1*I_SIZE1;

//Convlayer2 param

parameter I_SIZE2 = O_SIZE1_max;
parameter O_SIZE2 = I_SIZE2 - K_SIZE + 1;
parameter I_SIZE2_max = I_SIZE2 - K_SIZE + 1;
parameter O_SIZE2_max = (I_SIZE2 - K_SIZE + 1)/2 ;
parameter I_BW2 = 16;
parameter O_BW2 = 16;
parameter CI2   = 4;
parameter Kernel_ch_depth2 = CI2;
parameter CO2   = 12;
parameter O_CONV_BW2 = (I_BW2 + W_BW) + clog2(K_SIZE*K_SIZE) - 2;//16 + 8 + 5 - 2 = 27
parameter O_CONVSUM_BW2 = O_CONV_BW2;// 27 //clog2(CI2);
parameter mem_ifmap2_bit_width = I_BW2;
parameter mem_ifmap2_addr_width = clog2(I_SIZE2*I_SIZE2);
parameter mem_ifmap2_depth = I_SIZE2*I_SIZE2;

//FC layer param
parameter I_SIZE3 = O_SIZE2_max; //4
parameter I_BW3 = 16;
parameter O_BW3 = 16;
parameter CI3   = 12;
parameter CO3   = 10;
parameter O_FC_BW3 = (I_BW3 + W_BW);//16 + 8 = 24
parameter O_FCSUM_BW3 = O_FC_BW3 + clog2(CI3*I_SIZE3*I_SIZE3)-2;//30

//Define clock cycle for simulation
parameter clkp = 10;


