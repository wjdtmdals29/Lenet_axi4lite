/*******************************************************************************
#Author: Seungmin.Jeong(Graduated from Kwangwoon University, Seoul, Korea 2023.02)
#Purpose: verilog code / Convolution layer1
#Revision History: 2023.07.03
*******************************************************************************/
`timescale 1ns / 1ps
module Conv_layer1 #(parameter
  mem_ifmap_addr_width = 10, mem_ifmap_bit_width = 8, mem_ifmap_depth = 784, I_SIZE = 28, O_SIZE = 24,
  I_BW = 8, W_BW = 8, O_BW = 16, O_CONV_BW = 20, CI = 1, CO = 4, K_SIZE = 5, P_SIZE = 2
  )
(
  clk, ce, global_rst_n, user_reset,
  i_fmap, i_weight, i_mem_we,
  o_conv1_result, o_convlayer1_en, o_convlayer1_ch_end, o_convlayer1_allch_end
);
localparam I_SIZE_max = I_SIZE - K_SIZE + 1;
localparam O_SIZE_max = (I_SIZE - K_SIZE + 1)/2;

input clk, ce, global_rst_n, user_reset, i_mem_we;
input signed [I_BW-1:0] i_fmap;
input signed [CI*CO*K_SIZE*K_SIZE*W_BW-1:0] i_weight;
output signed [O_BW-1:0] o_conv1_result;
output o_convlayer1_en, o_convlayer1_ch_end, o_convlayer1_allch_end;

wire [mem_ifmap_addr_width-1:0] w_addr_ifmap;
//wire [mem_ifmap_addr_width-1:0] w_addr_ofmap;
wire w_done_ifmap_bram_write;
//wire w_done_ofmap_bram_write;
wire signed [I_BW-1:0] w_o_fmap;
wire signed [O_CONV_BW-1:0] w_conv_result;
wire w_conv_valid;
wire w_conv_end;
wire w_conv_all_end;

wire w_ce_cnt1;
wire w_ce_bram1;
wire w_we_bram1;
//wire signed [(CO*K_SIZE*K_SIZE*W_BW)-1:0] w_weight;
//wire w_empty;
//wire w_full;

assign w_ce_cnt1 = (ce&&(~w_conv_end)&&(~w_conv_all_end));
assign w_ce_bram1 = ((ce&&(~(w_conv_end||w_conv_all_end))&&i_mem_we))||(w_done_ifmap_bram_write&&(~(w_conv_end||w_conv_all_end)));
assign w_we_bram1 = (~w_done_ifmap_bram_write)&&i_mem_we;

wire w_conv_ce;
wire w_conv_rst;
reg r_conv_end_d;

always@(posedge clk)begin
  r_conv_end_d <= w_conv_end;
end

reg [mem_ifmap_addr_width-1:0] r_addr_ifmap_d;
reg r_w_ce_bram1_d;
reg r_w_we_bram1_d;
reg r_done_ifmap_bram_write_d;

always@(posedge clk)begin
  r_addr_ifmap_d <= w_addr_ifmap;
  r_w_ce_bram1_d <= w_ce_bram1;
  r_w_we_bram1_d <= w_we_bram1;
  r_done_ifmap_bram_write_d <= w_done_ifmap_bram_write;
end 
assign w_conv_ce = ce&&r_done_ifmap_bram_write_d&&((~w_conv_end&&~r_conv_end_d))&&(~w_conv_all_end);
assign w_conv_rst = w_conv_end||r_conv_end_d;

  ////////////////////////////////Instiation SPBRAM(single port bram) and address counter for bram////////////////////////////////
  //instantiation counter for SPBRAM 1
  counter1 #(.BW(mem_ifmap_bit_width),.CNT_WIDTH(mem_ifmap_addr_width),.CNT_DEPTH(mem_ifmap_depth)) u_ifmap_bram_address_counter
  (
    .clk(clk), .global_rst_n(global_rst_n), .rst(w_conv_end),.user_reset(user_reset), .ce(w_ce_cnt1), .we(i_mem_we),
    .o_count(w_addr_ifmap), .o_done(w_done_ifmap_bram_write)
  );
  //instantiation SPBRAM 1 for store Input feature map // we == 1 : write data of feature map, we == 0 : read data of feature map
  sp_bram #(.mem_data_width(mem_ifmap_bit_width),.mem_address_width(mem_ifmap_addr_width),.mem_mem_depth(mem_ifmap_depth))
  u_sp_bram_StoreInFmap
  (
    .clk(clk), 
	  .addr0(r_addr_ifmap_d), .ce0(r_w_ce_bram1_d), .we0(r_w_we_bram1_d), .o_data0(w_o_fmap), .i_data0(i_fmap)
  );
  
  ////////////////////////////////Instiation convolution 1////////////////////////////////
  //instantiation reuse_convolution filter 1
	convolution_55_layer1 #(.I_BW(I_BW),.O_CONV_BW(O_CONV_BW),.O_BW(O_BW),.I_SIZE(I_SIZE),.K_SIZE(K_SIZE),.W_BW(W_BW),.CO(CO)) 
    u_convolution_55
    (
      .clk(clk), .ce(w_conv_ce), .global_rst_n(global_rst_n), .rst(w_conv_rst), .self_rst(w_conv_end), .user_reset(user_reset),
      .i_fmap(w_o_fmap), .i_weight(i_weight),
      .o_conv_result(w_conv_result),
      .o_conv_valid(w_conv_valid),.o_conv_end(w_conv_end),.o_conv_all_end(w_conv_all_end)
    );
  //instantiaion relu
  wire signed [O_CONV_BW-1:0] w_o_relu;
  relu #(.BW(O_CONV_BW)) u_relu
  (
    .i_data(w_conv_result),.o_data(w_o_relu)
  );
  //instantiaion maxpooler
  wire signed [O_CONV_BW-1:0] w_o_max;
  wire w_o_max_valid;
  wire w_o_max_end;
  maxpool #(.BW(O_CONV_BW),.I_SIZE(I_SIZE_max),.O_SIZE(O_SIZE_max),.P_SIZE(P_SIZE),.CO(CO)) u_maxpool
  (
    .clk(clk),.global_rst_n(global_rst_n),.user_reset(user_reset),.rst(w_conv_end),.ce(w_conv_valid),
    .i_data(w_o_relu), 
    .o_data(w_o_max),
    .o_valid(w_o_max_valid), .o_end(w_o_max_end)
  );
  //truncate output bits
  wire signed [O_BW-1:0] w_convlayer1_trunc;
  assign w_convlayer1_trunc = w_o_max[O_CONV_BW-1:O_CONV_BW-O_BW];
  //assign output ports
  assign o_conv1_result = w_convlayer1_trunc;
  assign o_convlayer1_en = w_o_max_valid;
  assign o_convlayer1_ch_end = w_o_max_end;
  assign o_convlayer1_allch_end = w_conv_all_end;
endmodule