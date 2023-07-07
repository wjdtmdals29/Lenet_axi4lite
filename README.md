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


# Simulation Result
Check the results of entering one data in order from the numbers 0 to 9.

1. AXI4 lite Interface(Write and Read data)

   ![image](https://github.com/wjdtmdals29/Lenet_axi4lite/assets/109125304/6c00d81f-7f96-4ad3-9db9-d0b21f0741d1)

    ****If want to see more detail, try simulation and check 'WRITE address & data', 'READ address & data(inference result)'.
2. TCL console

   ![image](https://github.com/wjdtmdals29/Lenet_axi4lite/assets/109125304/464ada41-7193-41ff-8960-54e712a83ebe)

#Lenet in SW(C language)
Test 1000 images.
Accuracy = 97.7%

![image](https://github.com/wjdtmdals29/Lenet_axi4lite/assets/109125304/0b220949-d6a9-4c6e-ac50-0458c80e7993)
