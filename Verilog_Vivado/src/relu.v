`timescale 1ns / 1ps
module relu #(parameter BW = 32)
(
  input [BW-1:0] i_data,
  output [BW-1:0] o_data
);
assign o_data = (i_data[BW-1] == 1) ? 0 : i_data;
endmodule
