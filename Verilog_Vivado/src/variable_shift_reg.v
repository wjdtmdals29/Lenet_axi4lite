`timescale 1ns / 1ps

module variable_shift_reg #(parameter WIDTH = 8, parameter SIZE = 3) (
input clk,
input ce,
input global_rst_n,
input rst,
input signed [WIDTH-1:0] i_data,
output signed [WIDTH-1:0] o_data
);
reg signed [WIDTH-1:0] r_ShiftReg [SIZE-1:0];

genvar i;
generate
for(i=0;i<SIZE;i=i+1)begin
  always@(posedge clk or negedge global_rst_n) begin
    if(!global_rst_n) begin
      r_ShiftReg[i] <= {(WIDTH){1'b0}};
    end
    else if(rst) begin
      r_ShiftReg[i] <= {(WIDTH){1'b0}};
    end

    else if (ce) begin
      if(i == 0) begin
        r_ShiftReg[i] <= i_data;
      end
      else begin
        r_ShiftReg[i] <= r_ShiftReg[i-1];
      end
    end
    else begin
      r_ShiftReg[i] <= r_ShiftReg[i];
    end
  end
end
endgenerate
assign o_data = r_ShiftReg[SIZE-1];
endmodule