/*******************************************************************************
#Author: Seungmin.Jeong(Graduated from Kwangwoon University, Seoul, Korea 2023.02)
#Purpose: verilog code / fc layer
#Revision History: 2023.03.03
*******************************************************************************/
`timescale 1ns / 1ps
module fc_layer #(parameter I_BW = 16, W_BW = 8, B_BW = 16, O_BW = 16, O_FCSUM_BW = 32, I_SIZE = 4, CI = 12, CO = 10)
(
  clk, ce, global_rst_n, user_reset,
  i_data, i_weight, i_bias, o_data, o_en, o_end
);
`include "clog2_function.vh"
localparam size_weight_each = I_SIZE*I_SIZE*CI;
localparam cnt_weight = clog2(I_SIZE*I_SIZE*CI)+1;
localparam class_BW = clog2(CO);

input clk, ce, global_rst_n, user_reset;
input signed [I_BW-1:0] i_data;
input signed [size_weight_each*CO*W_BW-1:0] i_weight;
input signed [CO*B_BW-1:0] i_bias;
output [3:0] o_data;
output o_en, o_end;

wire signed [W_BW-1:0] w_weight [0:size_weight_each*CO-1];
wire signed [O_FCSUM_BW-1:0] w_exp_bias [0:CO-1];
wire signed [B_BW-1:0] w_bias   [0:CO-1];
reg [cnt_weight-1:0] r_cnt_weight;
reg signed [O_FCSUM_BW-1:0] r_o_data_acc [0:CO-1];
reg signed [O_BW-1:0]       r_o_data_trun [0:CO-1];
reg signed [O_FCSUM_BW-1:0] r_add_bias [0:CO-1];
reg signed [O_BW-1:0]       r_max0 [0:4];
reg signed [O_BW-1:0]       r_max1 [0:1];
reg signed [O_BW-1:0]       r_max2;
reg signed [O_BW-1:0]       r_max_final;
reg [class_BW-1:0] r_o_result;
reg r_en_relu;
reg r_en_add_bias;
reg r_en_classfication;
reg [class_BW-1:0] r_cnt_clssification;
reg r_en, r_en_d;
reg r_end, r_end_d;
integer i;
integer m;
genvar k;
generate
  for(k=0;k<size_weight_each*CO;k=k+1) begin
    assign w_weight[k][W_BW-1:0] = i_weight[k*W_BW +: W_BW];
  end
  for(k=0;k<CO;k=k+1) begin
    assign w_bias[k][B_BW-1:0] = i_bias[k*B_BW +: B_BW];
    assign w_exp_bias[k][O_FCSUM_BW-1:0] = (w_bias[k][B_BW-1]==1) ? {14'b11111111111111111111, w_bias[k]} : {14'd0, w_bias[k]};
  end
endgenerate

always @(posedge clk or negedge global_rst_n) begin
  r_end_d <= r_end;
  r_en_d <= r_en;
  if(!global_rst_n) begin
    r_en_relu <= 1'b0;
    r_en_add_bias <= 1'b0;
    r_en_classfication <= 1'b0;
    r_en <= 1'b0;
    r_end <= 1'b0;
    r_en_d <= 1'b0;
    r_end_d <= 1'b0;
    r_max0[0] <= {(O_BW){1'b0}};
    r_max0[1] <= {(O_BW){1'b0}};
    r_max0[2] <= {(O_BW){1'b0}};
    r_max0[3] <= {(O_BW){1'b0}};
    r_max0[4] <= {(O_BW){1'b0}};
    r_max1[0] <= {(O_BW){1'b0}};
    r_max1[1] <= {(O_BW){1'b0}};
    r_max2    <= {(O_BW){1'b0}};
    r_max_final <= {(O_BW){1'b0}};
    r_cnt_weight <= {(cnt_weight){1'b0}};
    r_cnt_clssification <= {(class_BW){1'b0}};
    r_o_result <= {(class_BW){1'b0}};
    for(i=0;i<CO;i=i+1) begin
      r_o_data_acc[i] <= {(O_FCSUM_BW){1'b0}};
      r_o_data_trun[i] <= {(O_BW){1'b0}};
      r_add_bias[i] <= {(O_FCSUM_BW){1'b0}};
    end
  end
  else if(user_reset) begin
    r_en_relu <= 1'b0;
    r_en_add_bias <= 1'b0;
    r_en_classfication <= 1'b0;
    r_en <= 1'b0;
    r_en_d <= 1'b0;
    r_end <= 1'b0;
    r_end_d <= 1'b0;
    r_max0[0] <= {(O_BW){1'b0}};
    r_max0[1] <= {(O_BW){1'b0}};
    r_max0[2] <= {(O_BW){1'b0}};
    r_max0[3] <= {(O_BW){1'b0}};
    r_max0[4] <= {(O_BW){1'b0}};
    r_max1[0] <= {(O_BW){1'b0}};
    r_max1[1] <= {(O_BW){1'b0}};
    r_max2    <= {(O_BW){1'b0}};
    r_max_final <= {(O_BW){1'b0}};
    r_cnt_weight <= {(cnt_weight){1'b0}};
    r_cnt_clssification <= {(class_BW){1'b0}};
    r_o_result <= {(class_BW){1'b0}};
    for(i=0;i<CO;i=i+1) begin
      r_o_data_acc[i] <= {(O_FCSUM_BW){1'b0}};
      r_o_data_trun[i] <= {(O_BW){1'b0}};
      r_add_bias[i] <= {(O_FCSUM_BW){1'b0}};
    end
  end
  else if(ce) begin
    if(r_cnt_weight != size_weight_each) begin
      r_cnt_weight <= r_cnt_weight + 1;
      r_o_data_acc[0] <= r_o_data_acc[0] + (i_data * w_weight[r_cnt_weight]);
      r_o_data_acc[1] <= r_o_data_acc[1] + (i_data * w_weight[r_cnt_weight+(size_weight_each*1)]);
      r_o_data_acc[2] <= r_o_data_acc[2] + (i_data * w_weight[r_cnt_weight+(size_weight_each*2)]);
      r_o_data_acc[3] <= r_o_data_acc[3] + (i_data * w_weight[r_cnt_weight+(size_weight_each*3)]);
      r_o_data_acc[4] <= r_o_data_acc[4] + (i_data * w_weight[r_cnt_weight+(size_weight_each*4)]);
      r_o_data_acc[5] <= r_o_data_acc[5] + (i_data * w_weight[r_cnt_weight+(size_weight_each*5)]);
      r_o_data_acc[6] <= r_o_data_acc[6] + (i_data * w_weight[r_cnt_weight+(size_weight_each*6)]);
      r_o_data_acc[7] <= r_o_data_acc[7] + (i_data * w_weight[r_cnt_weight+(size_weight_each*7)]);
      r_o_data_acc[8] <= r_o_data_acc[8] + (i_data * w_weight[r_cnt_weight+(size_weight_each*8)]);
      r_o_data_acc[9] <= r_o_data_acc[9] + (i_data * w_weight[r_cnt_weight+(size_weight_each*9)]);
    end
  end
  else if(r_cnt_weight == size_weight_each) begin
    r_cnt_weight <= 0;
    r_en_add_bias <= 1'b1;
  end
  else if(r_en_add_bias == 1'b1) begin
    r_en_add_bias <= 1'b0;
    r_en_relu <= 1'b1;
    for(i=0;i<CO;i=i+1) begin
      r_add_bias[i] <= r_o_data_acc[i] + w_exp_bias[i];
    end
  end
  else if(r_en_relu == 1'b1) begin
    r_en_relu <= 1'b0;
    r_en_classfication <= 1'b1;
    for(i=0;i<CO;i=i+1) begin
      r_o_data_trun[i] <= (r_add_bias[i] > 0) ? r_add_bias[i][O_FCSUM_BW-1:O_FCSUM_BW-O_BW] : {(O_BW){1'b0}};
    end
  end
  
  else if(r_en_classfication == 1'b1) begin
    if(r_cnt_clssification != 4) begin
      r_cnt_clssification <= r_cnt_clssification + 1;
      for(i=0;i<5;i=i+1) begin
        r_max0[i] <= (r_o_data_trun[2*i] > r_o_data_trun[(2*i)+1]) ? r_o_data_trun[2*i] : r_o_data_trun[(2*i)+1];
      end
      r_max1[0] <= (r_max0[0] > r_max0[1]) ? r_max0[0] : r_max0[1];
      r_max1[1] <= (r_max0[2] > r_max0[3]) ? r_max0[2] : r_max0[3];
      r_max2    <= (r_max1[0] > r_max1[1]) ? r_max1[0] : r_max1[1];
      r_max_final <= (r_max2 > r_max0[4]) ? r_max2 : r_max0[4];
    end
    else if(r_cnt_clssification == 4) begin
      r_en <= 1'b1;
      r_en_classfication <= 1'b0;
    end
  end
  else if(r_en == 1'b1) begin
    r_end <= 1'b1;
    if(r_max_final==r_o_data_trun[0])
      r_o_result <= 4'b0000;
    else if(r_max_final==r_o_data_trun[1])
      r_o_result <= 4'b0001;
    else if(r_max_final==r_o_data_trun[2])
      r_o_result <= 4'b0010;
    else if(r_max_final==r_o_data_trun[3])
      r_o_result <= 4'b0011;
    else if(r_max_final==r_o_data_trun[4])
      r_o_result <= 4'b0100;
    else if(r_max_final==r_o_data_trun[5])
      r_o_result <= 4'b0101;
    else if(r_max_final==r_o_data_trun[6])
      r_o_result <= 4'b0110;
    else if(r_max_final==r_o_data_trun[7])
      r_o_result <= 4'b0111;
    else if(r_max_final==r_o_data_trun[8])
      r_o_result <= 4'b1000;
    else if(r_max_final==r_o_data_trun[9])
      r_o_result <= 4'b1001;
    else
      r_o_result <= r_o_result;
    end
end
//assign output ports
assign o_en = r_en_d&&(~r_end_d);
assign o_end = r_end_d;
assign o_data = r_o_result;
endmodule