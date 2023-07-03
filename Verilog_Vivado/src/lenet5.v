`timescale 1ns / 1ps
module lenet5
(
  clk, ce, global_rst_n, user_reset, i_fmap, i_weight, i_bias_fc, i_weight_buffer_we, i_bias_buffer_we, i_fmap_buffer_we,
  o_classification_result, o_classification_en, o_classification_end
);
`include "param_clog2.vh"

  input clk, ce, global_rst_n, user_reset;
  input signed [I_BW1-1:0] i_fmap;
  input i_weight_buffer_we;
  input signed [W_BW-1:0]  i_weight;
  input i_bias_buffer_we;
  input signed [B_BW-1:0]  i_bias_fc;
  input i_fmap_buffer_we;
  output [3:0] o_classification_result;
  output o_classification_en, o_classification_end;

  reg r_ce;
  reg signed [I_BW1-1:0] r_fmap;
  always @(posedge clk or negedge global_rst_n) begin
    if(!global_rst_n) begin
      r_ce <= 1'b0;
      r_fmap <= 0;
    end
    else begin
      r_ce <= ce;
      r_fmap <= i_fmap;
    end
  end
  wire [CO1*K_SIZE*K_SIZE*W_BW-1:0] w_weight1;
  wire [CI2*CO2*K_SIZE*K_SIZE*W_BW-1:0] w_weight2;
  wire [CI3*CO3*I_SIZE3*I_SIZE3*W_BW-1:0] w_weight_fc;
  wire [CO3*B_BW-1:0] w_bias_fc;

  wire w_empty_weight;
  wire w_full_weight;
  wire w_empty_fc_bias;
  wire w_full_fc_bias;

  wire w_full_all;

  wire [3:0] w_o_fc_data;
  wire w_fc_end;
  wire w_fc_en;

  wire [O_BW1-1:0] w_conv1_result;
  wire w_conv1_en;
  wire w_convlayer1_ch_end;
  wire w_convlayer1_allch_end;

  wire [O_BW2-1:0] w_conv2_result;
  wire w_conv2_en;
  wire w_convlayer2_ch_end;
  wire w_convlayer2_allch_end;
  //////////instantiation buffer to store weights and biases////////
                                //3220 = (25*CI1*CO1)+(25*CI2*CO2)+(I_SIZE3*I_SIZE3*CI3*CO3)
  buffer_Weight #(.BW(W_BW),.SIZE(3220)) u_buffer_Str_Weight
  (
    .clk(clk),.ce(r_ce),.we(i_weight_buffer_we),.global_rst_n(global_rst_n),.user_reset(user_reset),.i_data(i_weight),.o_weight1(w_weight1),.o_weight2(w_weight2),
    .o_weight_fc(w_weight_fc),.o_empty(w_empty_weight),.o_full(w_full_weight)
  );
                              //10 = (CO3)
  buffer_Bias #(.BW(B_BW),.SIZE(10)) u_buffer_StrBias
  (
    .clk(clk),.ce(r_ce&&w_full_weight),.we(i_bias_buffer_we),.global_rst_n(global_rst_n),.user_reset(user_reset),.i_data(i_bias_fc),
    .o_bias(w_bias_fc),.o_empty(w_empty_fc_bias),.o_full(w_full_fc_bias)
  );
  //////////instantiation Convolution layer 1//////////
  Conv_layer1 #(.mem_ifmap_addr_width(mem_ifmap1_addr_width),.mem_ifmap_bit_width(mem_ifmap1_bit_width),.mem_ifmap_depth(mem_ifmap1_depth),
  .I_SIZE(I_SIZE1),.O_SIZE(O_SIZE1),.I_BW(I_BW1),.W_BW(W_BW),.O_BW(O_BW1),
  .O_CONV_BW(O_CONV_BW1),.CI(CI1),.CO(CO1),.K_SIZE(K_SIZE),.P_SIZE(P_SIZE))
  u_Conv_layer1
  (
    .clk(clk),.ce(ce && w_full_fc_bias),.i_mem_we(i_fmap_buffer_we),.global_rst_n(global_rst_n),.user_reset(user_reset),.i_fmap(r_fmap),.i_weight(w_weight1),
    .o_conv1_result(w_conv1_result),.o_convlayer1_en(w_conv1_en),
    .o_convlayer1_ch_end(w_convlayer1_ch_end),.o_convlayer1_allch_end(w_convlayer1_allch_end)
  );

  //////////instantiation Convolution layer2//////////
  Conv_layer2 #(.mem_ifmap_addr_width(mem_ifmap2_addr_width),.mem_ifmap_bit_width(mem_ifmap2_bit_width),.mem_ifmap_depth(mem_ifmap2_depth),
  .I_SIZE(I_SIZE2),.O_SIZE(O_SIZE2),.I_BW(I_BW2),.W_BW(W_BW),.O_BW(O_BW2),
  .O_CONV_BW(O_CONV_BW2),.O_CONVSUM_BW(O_CONVSUM_BW2),.CI(CI2),.CO(CO2),.K_SIZE(K_SIZE),.P_SIZE(P_SIZE))
  u_Conv_layer2
  (
    .clk(clk),.ce(w_conv1_en),.global_rst_n(global_rst_n),.user_reset(user_reset),
    .i_fmap(w_conv1_result),.i_weight(w_weight2),.i_convlayer1_ch_end(w_convlayer1_ch_end),
    .o_conv2_result(w_conv2_result),.o_convlayer2_en(w_conv2_en),
    .o_convlayer2_ch_end(w_convlayer2_ch_end),.o_convlayer2_allch_end(w_convlayer2_allch_end)
  );

  //////////instantiation FC layer//////////
  fc_layer #(.I_BW(I_BW3),.W_BW(W_BW),.B_BW(B_BW),.O_BW(O_BW3),
  .O_FCSUM_BW(O_FCSUM_BW3),.I_SIZE(I_SIZE3),.CI(CI3),.CO(CO3)) u_fc_layer
  (
    .clk(clk), .ce(w_conv2_en), .global_rst_n(global_rst_n), .user_reset(user_reset),
    .i_data(w_conv2_result), .i_weight(w_weight_fc), .i_bias(w_bias_fc), .o_data(w_o_fc_data), .o_en(w_fc_en), .o_end(w_fc_end)
  );
  
  assign o_classification_result = w_o_fc_data;
  assign o_classification_en = w_fc_en;
  assign o_classification_end = w_fc_end;  
endmodule