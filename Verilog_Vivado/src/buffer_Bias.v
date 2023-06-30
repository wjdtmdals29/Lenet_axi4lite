/*******************************************************************************
#Author: Seungmin.Jeong(Graduated from Kwangwoon University, Seoul, Korea 2023.02)
#Purpose: verilog code / buffer to store Convlayer weights
#Revision History: 2023.03.03
*******************************************************************************/
`timescale 1ns / 1ps
module buffer_Bias #(parameter BW = 16, SIZE = 10)
(
  clk, ce, we, global_rst_n, user_reset,
  i_data,
  o_bias, o_empty, o_full
);
`include "param_clog2.vh"
localparam cnt_size = clog2(SIZE);

input signed [BW-1:0] i_data;
input clk, ce, global_rst_n, user_reset, we;
output signed [(BW*SIZE)-1:0] o_bias;
output o_empty, o_full;

reg signed [BW-1:0] r_buffer [0:(SIZE)-1];
reg [cnt_size-1:0]  r_cnt;
integer i;

always @(posedge clk or negedge global_rst_n) begin
  if(!global_rst_n) begin
    r_cnt <= {(cnt_size){1'b0}};
    for(i=0;i<SIZE;i=i+1) begin
      r_buffer[i] <= {(BW){1'b0}};
    end
  end
  else if(user_reset) begin
    r_cnt <= {(cnt_size){1'b0}};
    for(i=0;i<SIZE;i=i+1) begin
      r_buffer[i] <= {(BW){1'b0}};
    end
  end
  
  else if(ce) begin
    if(we) begin
      if(r_cnt != SIZE) begin
        r_buffer[r_cnt] <= i_data;
        r_cnt <= r_cnt + 1;
      end
      else if(r_cnt == SIZE) begin
        r_cnt <= r_cnt;
      end
    end
    else begin
      for(i=0;i<SIZE;i=i+1) begin
        r_buffer[i] <= r_buffer[i];
      end
      r_cnt <= r_cnt;
    end
  end
end

generate
  genvar k;
  for(k=0; k<SIZE; k=k+1) begin
    assign o_bias[k*BW +: BW] = r_buffer[k][BW-1:0];
  end
endgenerate
assign o_empty = (r_cnt != SIZE);
assign o_full  = (r_cnt == SIZE);

endmodule