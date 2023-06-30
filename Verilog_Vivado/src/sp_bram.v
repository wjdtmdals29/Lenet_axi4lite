/*******************************************************************************
#Author: Seungmin.Jeong(Graduated from Kwangwoon University, Seoul, Korea 2023.02)
#Purpose: verilog code / single port bram
#Revision History: 2023.03.03
*******************************************************************************/
`timescale 1 ns / 1 ps
module sp_bram #(parameter mem_data_width = 32, mem_address_width = 10, mem_mem_depth = 1024)
(
	clk, 
	addr0, ce0, we0, o_data0, i_data0
);

input clk;

input     [mem_address_width-1:0] addr0;
input     ce0;
input     we0;
input     [mem_data_width-1:0] i_data0;
output reg[mem_data_width-1:0] o_data0;

(* ram_style = "block" *)reg [mem_data_width-1:0] ram[0:mem_mem_depth-1];

always @(posedge clk) begin 
    if (ce0) begin
        if (we0) 
          ram[addr0] <= i_data0;
		    else
        	o_data0 <= ram[addr0];
    end
end


endmodule