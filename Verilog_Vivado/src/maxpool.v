/*******************************************************************************
#Author: Seungmin.Jeong(Graduated from Kwangwoon University, Seoul, Korea 2023.02)
#Purpose: verilog code / maxpooler
#Revision History: 2023.03.03
*******************************************************************************/
`timescale 1ns / 1ps
module maxpool #(parameter BW = 20, I_SIZE = 24, O_SIZE = 12, P_SIZE = 2, CO = 4)
(
  clk, global_rst_n, ce, user_reset, rst,
  i_data, o_data, o_valid, o_end
);
`include "clog2_function.vh"
localparam MSB = I_SIZE + P_SIZE;
localparam BW_P_SIZE = clog2(P_SIZE)+1; //+1 : prevent overflow
localparam BW_I_SIZE = clog2(I_SIZE)+1; //+1 : prevent overflow
localparam BW_O_SIZE = clog2(O_SIZE)+1; //+1 : prevent overflow

input clk, global_rst_n, ce, user_reset, rst;
input  [BW-1:0] i_data;
output [BW-1:0] o_data;
output o_valid, o_end;

reg [BW-1:0]        r_strdata [0:MSB-1];
wire [BW-1:0]        w_max1;
wire [BW-1:0]        w_max2;
reg [BW_P_SIZE-1:0] r_cnt_psize;
reg [BW_I_SIZE-1:0] r_cnt_row;
reg                 r_cnt_en;
reg [BW_O_SIZE-1:0] r_cnt_end;
reg r_valid;
reg r_end;
reg r_end_d;
integer i;
always @(posedge clk or negedge global_rst_n) begin
  if(!global_rst_n) begin
    r_valid <= 1'b0;
    r_end <= 1'b0;
    r_cnt_psize <= {(BW_P_SIZE){1'b0}};
    r_cnt_row <= {(BW_I_SIZE){1'b0}};
    r_cnt_en <= 1'b0;
    r_cnt_end <= {(BW_O_SIZE){1'b0}};
    for(i=0;i<MSB;i=i+1) begin
      r_strdata[i] <= {(BW){1'b0}};
    end
  end
  else if(rst||user_reset) begin
    r_valid <= 1'b0;
    r_end <= 1'b0;
    r_cnt_psize <= {(BW_P_SIZE){1'b0}};
    r_cnt_row <= {(BW_I_SIZE){1'b0}};
    r_cnt_en <= 1'b0;
    r_cnt_end <= {(BW_O_SIZE){1'b0}};
    for(i=0;i<MSB;i=i+1) begin
      r_strdata[i] <= {(BW){1'b0}};
    end
  end
  else if(ce) begin
    r_cnt_row <= r_cnt_row + 1;
    r_strdata[0] <= i_data;
    r_valid <= (r_cnt_en == 1)&&(r_cnt_psize == P_SIZE-1);
    r_end <= (r_cnt_end == O_SIZE);
    for(i=0;i<MSB-1;i=i+1) begin
      r_strdata[i+1] <= r_strdata[i];
    end
    if(r_cnt_row == I_SIZE-1) begin
      r_cnt_en <= 1'b1;
    end
    else if(r_cnt_row == (2*I_SIZE)-1) begin
      r_cnt_en <= 1'b0;
      r_cnt_row <= {(BW_I_SIZE){1'b0}};
      if(r_cnt_end == O_SIZE) begin
        r_cnt_end <= 0;
      end
      else begin
        r_cnt_end <= r_cnt_end + 1;
        r_cnt_psize <= {(BW_P_SIZE){1'b0}};
      end
    end
    else begin
      if(r_cnt_en) begin
        if(r_cnt_psize == P_SIZE-1) begin
          r_cnt_psize <= {(BW_P_SIZE){1'b0}};
        end
        else begin
          r_cnt_psize <= r_cnt_psize + 1;
        end
      end
    end
  end
  else begin
    r_valid <= (r_cnt_en == 1)&&(r_cnt_psize == P_SIZE-1);
    r_end <= (r_cnt_end == O_SIZE);
    
  end
end
always@ (posedge clk or negedge global_rst_n) begin
  if(!global_rst_n) begin
    r_end_d <= 1'b0;
  end
  else begin
    r_end_d <= r_end;
  end
end

assign w_max1 = (r_strdata[MSB-2] > r_strdata[MSB-1]) ? r_strdata[MSB-2] : r_strdata[MSB-1];
assign w_max2 = (r_strdata[0] > r_strdata[1]) ? r_strdata[0] : r_strdata[1];


assign o_data = (w_max1 > w_max2) ? w_max1 : w_max2;
assign o_valid = r_valid;
assign o_end = r_end_d;



endmodule
