/*******************************************************************************
#Author: Seungmin.Jeong(Graduated from Kwangwoon University, Seoul, Korea 2023.02)
#Purpose: verilog code / mac
#Revision History: 2023.03.03
*******************************************************************************/
`timescale 1ns / 1ps
module mac #(parameter I_BW = 8, W_BW = 8, O_CONV_BW = 20)
    (
    input clk,global_rst_n,rst,ce,
    input signed [I_BW-1:0] i_data1,
    input signed [W_BW-1:0] i_data2,
    input signed [O_CONV_BW-1:0] i_data_before,
    output signed [O_CONV_BW-1:0] o_data
    );

    reg signed [O_CONV_BW-1:0] r_mult;
    reg signed [O_CONV_BW-1:0] r_add;

  always@(posedge clk or negedge global_rst_n) begin
    if(!global_rst_n) begin
      r_mult <= {(O_CONV_BW){1'b0}};
      r_add <= {(O_CONV_BW){1'b0}};
    end
    else if(rst) begin
      r_mult <= {(O_CONV_BW){1'b0}};
      r_add <= {(O_CONV_BW){1'b0}};
    end
    else begin
      if(ce) begin
        r_mult <= i_data1*i_data2;
        r_add <= i_data_before;
      end
      else begin
        r_mult <= 0;
        r_add <= 0;
      end
    end
  end
  assign o_data = r_mult + r_add;
endmodule