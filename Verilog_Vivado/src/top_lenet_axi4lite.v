
`timescale 1 ns / 1 ps

	module top_lenet_axi4lite #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 6
	)
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready
	);
	`include "param_clog2.vh"
	wire ce;
	wire [I_BW1-1:0] w_fmap;
	wire [W_BW-1:0] w_weight;
	wire [B_BW-1:0] w_bias_fc;
	wire w_result_en;
	wire w_result_end;
	wire [3:0] w_result;
	wire w_weight_buffer_we;
	wire w_bias_buffer_we;
	wire w_fmap_buffer_we;
// Instantiation of Axi Bus Interface S00_AXI
	axi4_lite # (
		.I_BW(I_BW1),
		.W_BW(W_BW),
		.B_BW(B_BW),
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) u_axi4_lite (
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready),

		// User ports
		.o_data_en		(ce),
		.o_weight		(w_weight),
		.o_weight_buffer_we(w_weight_buffer_we),
		.o_bias_fc		(w_bias_fc),
		.o_bias_buffer_we(w_bias_buffer_we),
		.o_fmap			(w_fmap),
		.o_fmap_buffer_we(w_fmap_buffer_we),
		.o_user_reset	(w_user_reset),
		.i_result_en	(w_result_en),
    	.i_result_end	(w_result_end),
    	.i_result		(w_result)
	);
	// Add user logic here
	wire clk 	 = s00_axi_aclk;
	wire reset_n = s00_axi_aresetn;
	wire w_user_reset;
	
	lenet5 u_lenet5(
    	.clk(clk),
		.ce(ce),
		.global_rst_n(reset_n),
		.user_reset(w_user_reset),
		.i_weight(w_weight),
		.i_weight_buffer_we(w_weight_buffer_we),
		.i_bias_fc(w_bias_fc),
		.i_bias_buffer_we(w_bias_buffer_we),
		.i_fmap(w_fmap),
		.i_fmap_buffer_we(w_fmap_buffer_we),
  		.o_classification_result(w_result),
		.o_classification_en(w_result_en),
		.o_classification_end(w_result_end)    
    );

	// User logic ends

	endmodule
