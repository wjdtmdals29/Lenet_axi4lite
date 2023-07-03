/*******************************************************************************
#Author: Seungmin.Jeong(Graduated from Kwangwoon University, Seoul, Korea 2023.02)
#Purpose: verilog code / buffer to store Convlayer weights
#Revision History: 2023.03.03
*******************************************************************************/
`timescale 1ns / 1ps
module buffer_Weight #(parameter BW = 8, SIZE = 3220) 
(
  clk, ce, global_rst_n, user_reset , we,
  i_data,
  o_weight1, o_weight2, o_weight_fc, o_empty, o_full
);
`include "param_clog2.vh"
localparam cnt_size = clog2(SIZE);
localparam SIZE1 = K_SIZE*K_SIZE*CI1*CO1;
localparam SIZE2 = K_SIZE*K_SIZE*CI2*CO2;
localparam SIZE3 = I_SIZE3*I_SIZE3*CI3*CO3;

input signed [BW-1:0] i_data;
input  clk, ce, we, global_rst_n, user_reset;
output signed [(BW*SIZE1)-1:0] o_weight1;
output signed [(BW*SIZE2)-1:0] o_weight2;
output signed [(BW*SIZE3)-1:0] o_weight_fc;
output o_empty, o_full;

reg signed [BW-1:0]       r_buffer [0:(SIZE)-1];
reg [cnt_size-1:0] r_cnt;
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
  for(k=0; k<SIZE1; k=k+1) begin
    assign o_weight1[k*BW +: BW] = r_buffer[k][BW-1:0];
  end
  for(k=0; k<SIZE2; k=k+1) begin
    assign o_weight2[k*BW +: BW] = r_buffer[k+SIZE1][BW-1:0];
  end
  for(k=0; k<SIZE3; k=k+1) begin
    assign o_weight_fc[k*BW +: BW] = r_buffer[k+SIZE1+SIZE2][BW-1:0];
  end
endgenerate
assign o_empty = (r_cnt != SIZE);
assign o_full  = (r_cnt == SIZE);

endmodule