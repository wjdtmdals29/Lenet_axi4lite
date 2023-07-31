/*******************************************************************************
#Author: Seungmin.Jeong(Graduated from Kwangwoon University, Seoul, Korea 2023.02)
#Purpose: systemVerilog code for testbench
#Revision History: 2023.07.03
#Customizing code
#Based on AXI VIP IP
*******************************************************************************/


`timescale 1ns / 1ps
`include "myip_v1_0_tb_include.svh"

import axi_vip_pkg::*;
import myip_v1_0_bfm_1_master_0_0_pkg::*;

module myip_v1_0_tb();


xil_axi_uint                            error_cnt = 0;
xil_axi_uint                            comparison_cnt = 0;
axi_transaction                         wr_transaction;   
axi_transaction                         rd_transaction;   
axi_monitor_transaction                 mst_monitor_transaction;  
axi_monitor_transaction                 master_moniter_transaction_queue[$];  
xil_axi_uint                            master_moniter_transaction_queue_size =0;  
axi_monitor_transaction                 mst_scb_transaction;  
axi_monitor_transaction                 passthrough_monitor_transaction;  
axi_monitor_transaction                 passthrough_master_moniter_transaction_queue[$];  
xil_axi_uint                            passthrough_master_moniter_transaction_queue_size =0;  
axi_monitor_transaction                 passthrough_mst_scb_transaction;  
axi_monitor_transaction                 passthrough_slave_moniter_transaction_queue[$];  
xil_axi_uint                            passthrough_slave_moniter_transaction_queue_size =0;  
axi_monitor_transaction                 passthrough_slv_scb_transaction;  
axi_monitor_transaction                 slv_monitor_transaction;  
axi_monitor_transaction                 slave_moniter_transaction_queue[$];  
xil_axi_uint                            slave_moniter_transaction_queue_size =0;  
axi_monitor_transaction                 slv_scb_transaction;  
xil_axi_uint                           mst_agent_verbosity = 0;  
xil_axi_uint                           slv_agent_verbosity = 0;  
xil_axi_uint                           passthrough_agent_verbosity = 0;  
bit                                     clock;
bit                                     reset;
integer result_slave;  
bit [31:0] S00_AXI_test_data[3:0]; 
 localparam LC_AXI_BURST_LENGTH = 8; 
 localparam LC_AXI_DATA_WIDTH = 32; 
task automatic COMPARE_DATA; 
  input [(LC_AXI_BURST_LENGTH * LC_AXI_DATA_WIDTH)-1:0]expected; 
  input [(LC_AXI_BURST_LENGTH * LC_AXI_DATA_WIDTH)-1:0]actual; 
  begin 
    if (expected === 'hx || actual === 'hx) begin 
      $display("TESTBENCH ERROR! COMPARE_DATA cannot be performed with an expected or actual vector that is all 'x'!"); 
 result_slave = 0;    $stop; 
  end 
  if (actual != expected) begin 
    $display("TESTBENCH ERROR! Data expected is not equal to actual.",     " expected = 0x%h",expected,     " actual   = 0x%h",actual); 
    result_slave = 0; 
    $stop; 
  end 
  else  
    begin 
     $display("TESTBENCH Passed! Data expected is equal to actual.", 
              " expected = 0x%h",expected,               " actual   = 0x%h",actual); 
    end 
  end 
endtask 
integer                                 i; 
integer                                 j;  
xil_axi_uint                            trans_cnt_before_switch = 48;  
xil_axi_uint                            passthrough_cmd_switch_cnt = 0;  
event                                   passthrough_mastermode_start_event;  
event                                   passthrough_mastermode_end_event;  
event                                   passthrough_slavemode_end_event;  
xil_axi_uint                            mtestID;  
xil_axi_ulong                           mtestADDR;  
xil_axi_len_t                           mtestBurstLength;  
xil_axi_size_t                          mtestDataSize;   
xil_axi_burst_t                         mtestBurstType;   
xil_axi_lock_t                          mtestLOCK;  
xil_axi_cache_t                         mtestCacheType = 0;  
xil_axi_prot_t                          mtestProtectionType = 3'b000;  
xil_axi_region_t                        mtestRegion = 4'b000;  
xil_axi_qos_t                           mtestQOS = 4'b000;  
xil_axi_data_beat                       dbeat;  
xil_axi_data_beat [255:0]               mtestWUSER;   
xil_axi_data_beat                       mtestAWUSER = 'h0;  
xil_axi_data_beat                       mtestARUSER = 0;  
xil_axi_data_beat [255:0]               mtestRUSER;      
xil_axi_uint                            mtestBUSER = 0;  
xil_axi_resp_t                          mtestBresp;  
xil_axi_resp_t[255:0]                   mtestRresp;  
bit [63:0]                              mtestWDataL; 
bit [63:0]                              mtestRDataL; 
bit [63:0]                              mtestRDataResult;
axi_transaction                         pss_wr_transaction;   
axi_transaction                         pss_rd_transaction;   
axi_transaction                         reactive_transaction;   
axi_transaction                         rd_payload_transaction;  
axi_transaction                         wr_rand;  
axi_transaction                         rd_rand;  
axi_transaction                         wr_reactive;  
axi_transaction                         rd_reactive;  
axi_transaction                         wr_reactive2;   
axi_transaction                         rd_reactive2;  
axi_ready_gen                           bready_gen;  
axi_ready_gen                           rready_gen;  
axi_ready_gen                           awready_gen;  
axi_ready_gen                           wready_gen;  
axi_ready_gen                           arready_gen;  
axi_ready_gen                           bready_gen2;  
axi_ready_gen                           rready_gen2;  
axi_ready_gen                           awready_gen2;  
axi_ready_gen                           wready_gen2;  
axi_ready_gen                           arready_gen2;  
xil_axi_payload_byte                    data_mem[xil_axi_ulong];  
myip_v1_0_bfm_1_master_0_0_mst_t          mst_agent_0;

  `BD_WRAPPER DUT(
      .ARESETN(reset), 
      .ACLK(clock) 
    ); 
  
initial begin
     mst_agent_0 = new("master vip agent",DUT.`BD_INST_NAME.master_0.inst.IF);//ms  
   mst_agent_0.vif_proxy.set_dummy_drive_type(XIL_AXI_VIF_DRIVE_NONE); 
   mst_agent_0.set_agent_tag("Master VIP"); 
   mst_agent_0.set_verbosity(mst_agent_verbosity); 
   mst_agent_0.start_master(); 
     $timeformat (-12, 1, " ps", 1);
  end
  initial begin
    reset <= 1'b0;
    #200ns;
    reset <= 1'b1;
    repeat (5) @(negedge clock); 
  end
  
  always #5 clock <= ~clock;
  initial begin
      S_AXI_TEST ( );

      #1ns;
      $finish;
  end
  localparam test_image = 10;
  int n_test_image = 10;
  reg signed [31:0] weight [0:3219];
  reg [16:0] cnt_weight = 0;
  reg signed [31:0] bias [0:9];
  reg [16:0] cnt_bias = 0;
  reg signed [31:0] fmap [0:783*test_image];
  reg [31:0] cnt_fmap = 0;
  reg [31:0] cnt_image = 0;
  int n_cnt_image = 0;
  integer file1;
  integer file2;
  integer file3;
  integer file4;
  integer file5;
  integer file6;
  initial begin
    file1=$fopen("HW_Weight.mem","r");
    while (cnt_weight<3200) begin
    file2=$fscanf(file1,"%h",weight[cnt_weight]);
    cnt_weight = cnt_weight + 1;
    end
    $fclose(file1);
    file3=$fopen("HW_Bias.mem","r");
    while (cnt_bias<10) begin
    file4=$fscanf(file3,"%h",bias[cnt_bias]);
    cnt_bias = cnt_bias + 1;
    end
    $fclose(file3);
    file5=$fopen("test_num_0to9.mem","r");
    while (cnt_fmap<784*test_image) begin
    file6=$fscanf(file5,"%h",fmap[cnt_fmap]);
    cnt_fmap = cnt_fmap + 1;
    end
    $fclose(file5);
end
    
reg [31:0] real_number;
reg [10:0] error_count;
task automatic S_AXI_TEST;  
begin   
#1; 
   //$display("Sequential write transfers example similar to  AXI BFM WRITE_BURST method starts"); 
   mtestID = 0; 
   mtestADDR = 64'h00000000; 
   mtestBurstLength = 0; 
   mtestDataSize = xil_axi_size_t'(xil_clog2(32/8)); 
   mtestBurstType = XIL_AXI_BURST_TYPE_INCR;  
   mtestLOCK = XIL_AXI_ALOCK_NOLOCK;  
   mtestCacheType = 0;  
   mtestProtectionType = 0;  
   mtestRegion = 0; 
   mtestQOS = 0; 
   result_slave = 1; 
  mtestWDataL[31:0] = 32'h00000001; 
  
  for(n_cnt_image = 0; n_cnt_image < n_test_image; n_cnt_image = n_cnt_image+1) begin
  if(n_cnt_image == 0)
    real_number = 32'h0;
  else if(n_cnt_image==1)
    real_number = 32'h1;
  else if(n_cnt_image==2)
    real_number = 32'h2;
  else if(n_cnt_image==3)
    real_number = 32'h3;
  else if(n_cnt_image==4)
    real_number = 32'h4;
  else if(n_cnt_image==5)
    real_number = 32'h5;
  else if(n_cnt_image==6)
    real_number = 32'h6;
  else if(n_cnt_image==7)
    real_number = 32'h7;
  else if(n_cnt_image==8)
    real_number = 32'h8;
  else if(n_cnt_image==9)
    real_number = 32'h9;
    
  mst_agent_0.AXI4LITE_WRITE_BURST(32'h1c, mtestProtectionType, 32'b0, mtestBresp); 
  mst_agent_0.AXI4LITE_WRITE_BURST(32'h1c, mtestProtectionType, 32'b1, mtestBresp); 
  mst_agent_0.AXI4LITE_WRITE_BURST(32'h1c, mtestProtectionType, 32'b0, mtestBresp); 
  mst_agent_0.AXI4LITE_WRITE_BURST(32'h0, mtestProtectionType, 32'b1, mtestBresp); 
  for(int i = 0; i < 3220;i++) begin 
  	mst_agent_0.AXI4LITE_WRITE_BURST(32'h4, mtestProtectionType, weight[i], mtestBresp);
  end
  for(int i = 0; i < 10;i++) begin 
  	mst_agent_0.AXI4LITE_WRITE_BURST(32'h8, mtestProtectionType, bias[i], mtestBresp);
  end
  for(int i = (784*n_cnt_image); i < 784*(1+n_cnt_image);i++) begin 
  	mst_agent_0.AXI4LITE_WRITE_BURST(32'hc, mtestProtectionType, fmap[i], mtestBresp);
  end
  while(1) begin
  mst_agent_0.AXI4LITE_READ_BURST(32'h14, mtestProtectionType, mtestRDataL, mtestBresp);
  if(mtestRDataL==1) begin
    mst_agent_0.AXI4LITE_READ_BURST(32'h18, mtestProtectionType, mtestRDataResult, mtestBresp);
    cnt_image <= cnt_image + 1;
    if(real_number != mtestRDataResult) begin
    error_count <= error_count+1;
    $display("[%d]Mismatch !! Expected result = %d, actual result = %d",n_cnt_image,real_number[3:0], mtestRDataResult[3:0]);
    end
    else if (real_number == mtestRDataResult) begin
    $display("[%d]Match !! Expected result = %d, actual result =  %d",n_cnt_image,real_number[3:0], mtestRDataResult[3:0]);
    end
    break;
  end
  end
  mst_agent_0.AXI4LITE_WRITE_BURST(32'h0, mtestProtectionType, 32'b0, mtestBresp);
  end
  $display("DONE!! Accuracy = %d percent",((cnt_image-error_count)/n_test_image)*100);
  $finish;
  
     $display("Sequential read transfers example similar to  AXI BFM READ_BURST method completes"); 
     $display("Sequential read transfers example similar to  AXI VIP READ_BURST method completes"); 
     $display("---------------------------------------------------------"); 
     $display("EXAMPLE TEST S00_AXI: PTGEN_TEST_FINISHED!"); 
     if ( result_slave ) begin                    
       $display("PTGEN_TEST: PASSED!");                  
     end    else begin                                       
       $display("PTGEN_TEST: FAILED!");                  
     end                                
     $display("---------------------------------------------------------"); 
  end 
endtask  

endmodule
