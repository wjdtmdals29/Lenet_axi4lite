//global param
`include "clog2_function.vh"
parameter W_BW = 8;
parameter B_BW = 16;
parameter K_SIZE = 5;
parameter P_SIZE = 2;

//channel1 param
parameter I_SIZE1 = 6;
parameter O_SIZE1 = 2;
parameter I_BW1 = 8;
parameter O_BW1 = 16;
parameter O_CONV_BW1 = 20;
parameter CI1   = 1;
parameter CO1   = 4;
parameter mem_ifmap1_bit_width = 8;
parameter mem_ifmap1_addr_width = clog2(I_SIZE1*I_SIZE1);
parameter mem_ifmap1_depth = I_SIZE1*I_SIZE1;

//channel2 param
parameter I_SIZE2 = 5;
parameter O_SIZE2 = 3;
parameter I_BW2 = 16;
parameter O_BW2 = 16;
parameter O_CONV_BW2 = 20;
parameter CI2   = 3;
parameter CO2   = 3;
parameter mem_ifmap2_bit_width = 16;
parameter mem_ifmap2_addr_width = 4;
parameter mem_ifmap2_depth = 16;

//channel3 param
parameter I_SIZE3 = 5;
parameter O_SIZE3 = 3;
parameter I_BW3 = 16;
parameter O_BW3 = 16;
parameter O_FC_BW3 = 20;
parameter FI1   = 48;
parameter FO1   = 10;
parameter mem_ifmap3_bit_width = 16;
parameter mem_ifmap3_addr_width = 4;
parameter mem_ifmap3_depth = 16;

//Define clock cycle for simulation
parameter clkp = 4;


