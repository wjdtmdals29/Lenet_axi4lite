/*******************************************************************************
#Author: Seungmin.Jeong(Graduated from Kwangwoon University, Seoul, Korea 2023.02)
#Purpose: verilog code / counter
#Revision History: 2023.07.03
*******************************************************************************/
`timescale 1ns / 1ps
module counter1 #(parameter BW = 8, CNT_WIDTH = 4, CNT_DEPTH = 16)
(
  clk, global_rst_n, rst, ce, we, user_reset,
  o_count, o_done
);
input clk, global_rst_n, rst, ce, user_reset, we;
output    [CNT_WIDTH-1:0] o_count;
output                    o_done;

reg [CNT_WIDTH-1:0] r_count;
reg                 r_done_wr;

always @(posedge clk or negedge global_rst_n)begin
  if(!global_rst_n)begin
    r_count <= {(CNT_WIDTH){1'b0}};
    r_done_wr  <= 1'b0;
  end
  else if(rst) begin
    r_count <= {(CNT_WIDTH){1'b0}};
  end
  else if(user_reset) begin
    r_done_wr <= 1'b0;
  end
  else if(ce) begin
    if(r_done_wr == 1'b0) begin
      if(we) begin
        if(r_count != CNT_DEPTH-1) begin
          r_count <= r_count+1;
        end
        else if (r_count == CNT_DEPTH-1) begin
          r_count <= {(CNT_WIDTH){1'b0}};
          r_done_wr <= 1'b1;
        end
      end
      else begin
        r_count <= r_count;
      end
    end
    else if (r_done_wr == 1'b1) begin
      if(r_count != CNT_DEPTH-1) begin
        r_count <= r_count+1;
      end
      else if(r_count == CNT_DEPTH-1) begin
        r_count <= {(CNT_WIDTH){1'b0}};
      end
    end
  end
end
assign o_count = r_count;
assign o_done  = r_done_wr;
endmodule