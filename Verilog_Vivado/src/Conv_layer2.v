/*******************************************************************************
#Author: Seungmin.Jeong(Graduated from Kwangwoon University, Seoul, Korea 2023.02)
#Purpose: verilog code / Convolution layer2 
#Revision History: 2023.07.03
*******************************************************************************/
`timescale 1ns / 1ps
module Conv_layer2 #(parameter
mem_ifmap_addr_width = 8, mem_ifmap_bit_width = 16, mem_ifmap_depth = 144, I_SIZE = 12, O_SIZE = 8,
I_BW = 16, W_BW = 8, O_BW = 16, O_CONV_BW = 28, O_CONVSUM_BW = 32, CI = 4, CO = 12, K_SIZE = 5, P_SIZE = 2)
(
  clk, ce, global_rst_n, user_reset,
  i_fmap, i_weight, i_convlayer1_ch_end,
  o_conv2_result, o_convlayer2_en, o_convlayer2_ch_end, o_convlayer2_allch_end
);
`include "clog2_function.vh"
localparam I_SIZE_max = I_SIZE - K_SIZE + 1;
localparam O_SIZE_max = (I_SIZE - K_SIZE + 1)/2;
localparam CI_cnt_BW = clog2(CI);

input clk, ce, global_rst_n, user_reset;
input signed [I_BW-1:0] i_fmap;
input signed [CI*CO*K_SIZE*K_SIZE*W_BW-1:0] i_weight;
input            i_convlayer1_ch_end;
output signed [O_BW-1:0] o_conv2_result;
output o_convlayer2_en, o_convlayer2_ch_end, o_convlayer2_allch_end;

integer i;
reg [CI_cnt_BW:0] r_bram_cnt;
always @(posedge clk or negedge global_rst_n) begin
  if(!global_rst_n) begin
    r_bram_cnt <= {(CI_cnt_BW+1){1'b0}};
  end
  else if(user_reset) begin
    r_bram_cnt <= {(CI_cnt_BW+1){1'b0}};
  end
  else if(i_convlayer1_ch_end) begin
    r_bram_cnt <= r_bram_cnt + 1;
  end
end
reg r_ce_sel_bram [0:CI-1];


always @(*) begin
  for(i=0;i<CI;i=i+1) begin
    r_ce_sel_bram[i] = (r_bram_cnt == i) ? 1'b1 : 1'b0;
  end
end

wire [mem_ifmap_addr_width-1:0] w_addr_ifmap[0:CI-1];
reg  [mem_ifmap_addr_width-1:0] r_addr_ifmap_d[0:CI-1];

always@(posedge clk or negedge global_rst_n) begin
  if(!global_rst_n) begin
    for(i=0;i<CI;i=i+1) begin
      r_addr_ifmap_d[i] <= 0;
    end
  end
  else if(user_reset) begin
    for(i=0;i<CI;i=i+1) begin
      r_addr_ifmap_d[i] <= 0;
    end
  end
  else begin
    for(i=0;i<CI;i=i+1) begin
      r_addr_ifmap_d[i] <= w_addr_ifmap[i];
    end
  end
end 

wire signed [I_BW-1:0] w_o_fmap [0:CI-1];
wire w_done_ifmap_bram_write [0:CI-1];
wire w_conv_rst [0:CI-1];
wire signed [O_CONV_BW-1:0] w_conv_result [0:CI-1];
wire w_conv_valid [0:CI-1];
wire w_conv_end [0:CI-1];
wire w_conv_all_end [0:CI-1];
reg bram_read_en;
reg bram_read_en_d;
reg bram_read_en_dd;

always@(posedge clk or negedge global_rst_n) begin
  if(!global_rst_n) begin
    bram_read_en <= 1'b0;
    bram_read_en_d <= 1'b0;
    bram_read_en_dd <= 1'b0;
  end
  else if(user_reset) begin
    bram_read_en <= 1'b0;
    bram_read_en_d <= 1'b0;
    bram_read_en_dd <= 1'b0;
  end
  else begin
    bram_read_en <= w_done_ifmap_bram_write[CI-1];
    bram_read_en_d <= bram_read_en;
    bram_read_en_dd <= bram_read_en_d;
  end
end
reg r_conv_end_d [0:CI-1];

always@(posedge clk) begin
  for(i=0;i<CI;i=i+1) begin
    r_conv_end_d[i] <= w_conv_end[i];
  end
end
genvar k;
wire signed [CO*K_SIZE*K_SIZE*W_BW-1:0] w_weight[0:CI-1];
wire w_ce_conv[0:CI-1];
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////Instiation Address counter, SPBRAM, Convolution layer////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
generate
  for(k=0;k<CI;k=k+1) begin
    assign w_weight[k][CO*K_SIZE*K_SIZE*W_BW-1:0] = i_weight[k*CO*K_SIZE*K_SIZE*W_BW +: CO*K_SIZE*K_SIZE*W_BW];
  counter2 #(.BW(mem_ifmap_bit_width),.CNT_WIDTH(mem_ifmap_addr_width),.CNT_DEPTH(mem_ifmap_depth)) u_ifmap_bram_address_counter
  (
    .clk(clk), .global_rst_n(global_rst_n), .rst(w_conv_end[k]), .user_reset(user_reset), .ce(((ce&&r_ce_sel_bram[k])||bram_read_en_d)&&(~w_conv_end[k])&&(~w_conv_all_end[k])),
    .o_count(w_addr_ifmap[k]), .o_done(w_done_ifmap_bram_write[k])
  );
  sp_bram #(.mem_data_width(mem_ifmap_bit_width),.mem_address_width(mem_ifmap_addr_width),.mem_mem_depth(mem_ifmap_depth))
  u_sp_bram_StoreInFmap
  (
    .clk(clk), 
	  .addr0(r_addr_ifmap_d[k]), .ce0(((ce&&r_ce_sel_bram[k])||bram_read_en_dd)&&(~w_conv_end[k])&&(~w_conv_all_end[k])), .we0(ce&&r_ce_sel_bram[k]), .o_data0(w_o_fmap[k]), .i_data0(i_fmap)
  );
  assign w_ce_conv[k] = ((bram_read_en_dd)&&(~w_conv_end[k]))&&(~w_conv_all_end[k])&&(~w_conv_all_end[k]);
  assign w_conv_rst[k] = w_conv_end[k]||r_conv_end_d[k];
  convolution_55_layer2 #(.I_BW(I_BW),.O_CONV_BW(O_CONV_BW),.O_BW(O_BW),.I_SIZE(I_SIZE),.K_SIZE(K_SIZE),.W_BW(W_BW),.CO(CO)) 
    u_convolution_55
    (
      .clk(clk), .ce(w_ce_conv[k]), .global_rst_n(global_rst_n), .rst(w_conv_rst[k]), .self_rst(w_conv_end[k]), .user_reset(user_reset),
      .i_fmap(w_o_fmap[k]), .i_weight(w_weight[k]),
      .o_conv_result(w_conv_result[k]),
      .o_conv_valid(w_conv_valid[k]),.o_conv_end(w_conv_end[k]),.o_conv_all_end(w_conv_all_end[k])
    );
  end
endgenerate
////////////////////////////////Add outputs of 4 channels////////////////////////////////
reg signed [O_CONVSUM_BW-1:0] r_add_conv_result;
always @(*) begin
  r_add_conv_result = {(O_CONVSUM_BW){1'b0}};
  for(i=0;i<CI;i=i+1) begin
    r_add_conv_result = r_add_conv_result + w_conv_result[i];
  end
end
////////////////////////////////Instiation relu function////////////////////////////////
wire signed [O_CONVSUM_BW-1:0] w_o_relu;
relu #(.BW(O_CONVSUM_BW)) u_relu
(
  .i_data(r_add_conv_result),.o_data(w_o_relu)
);
////////////////////////////////Instiation maxpooler////////////////////////////////
wire signed [O_CONVSUM_BW-1:0] w_o_max;
wire w_o_max_valid;
wire w_o_max_end;
wire w_max_rst;
assign w_max_rst = w_conv_end[0]&&w_conv_end[1]&&w_conv_end[2]&&w_conv_end[3];
wire w_max_ce;
assign w_max_ce = w_conv_valid[0]&&w_conv_valid[1]&&w_conv_valid[2]&&w_conv_valid[3];

maxpool #(.BW(O_CONVSUM_BW),.I_SIZE(I_SIZE_max),.O_SIZE(O_SIZE_max),.P_SIZE(P_SIZE),.CO(CO)) u_maxpool
(
  .clk(clk),.global_rst_n(global_rst_n),.user_reset(user_reset),.rst(w_max_rst),.ce(w_max_ce),
  .i_data(w_o_relu), 
  .o_data(w_o_max),
  .o_valid(w_o_max_valid), .o_end(w_o_max_end)
);

//truncate output bits
wire signed [O_BW-1:0] w_convlayer2_trunc;
assign w_convlayer2_trunc = w_o_max[O_CONVSUM_BW-1:O_CONVSUM_BW-O_BW];

//assign output ports
assign o_conv2_result = w_convlayer2_trunc;
assign o_convlayer2_en = w_o_max_valid;
assign o_convlayer2_ch_end = w_o_max_end;
assign o_convlayer2_allch_end = w_conv_all_end[0]&&w_conv_all_end[1]&&w_conv_all_end[2]&&w_conv_all_end[3];
endmodule