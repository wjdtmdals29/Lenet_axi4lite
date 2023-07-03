# Lenet_axi4lite
# Lenet & AXI4-lite I/F IP block simulation method
1. Generate ip (File location : Verilog_Vivado\src)
2. Create new project -> Tools -> Create and package new ip -> Create AXI4 Peripheral -> Select 'Verify Peripheral IP using AXI4 VIP' in 'Create Peripheral' step -> Finish
3. Delete basic IP and replace myip (1. Generate ip (File location : Verilog_Vivado\src)). And connect (M_AXI - s00_axi), (aclk - s00_axi_aclk), (aresetn - s00_axi_aresetn)

    ![image](https://github.com/wjdtmdals29/Lenet_axi4lite/assets/109125304/306e23d2-8691-4175-996c-e2f512cf906d)
   
4. Open 'XX_v1_0_tb.sv'
5. Delete the existing code and copy and paste the code from Verilog_Vivado\tb\ip_tb.sv
6. Run Simulation

# AXI4 Lite I/F Address mapping
0x00 : write clock enable
0x04 : write data(weight)
0x08 : write data(bias)
0x0C : write data(feature map)
0x10 : read 'en' signal(inference processing en)
0x14 : read 'end' signal(inference processing en)
0x18 : read data(inference result)
0x1C : User reset_pos(0 to 1 : reset)

# Process
1. User reset
2. Clock enable
3. Write weight data(buffer_Weight)
4. Write bias data(buffer_Bias)
5. Write feature map data(SPBram)
6. Start inference
7. Read classification en, end, result
8. DONE
***More detail in Simulation***

