# Lenet_axi4lite
# Lenet & AXI4-lite I/F IP block simulation method
1. Generate ip (File location : Verilog_Vivado\src\)
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

# Lenet in SW(C language)
(File location : SW\)
Test 1000 images.
Accuracy = 97.7%

![image](https://github.com/wjdtmdals29/Lenet_axi4lite/assets/109125304/0b220949-d6a9-4c6e-ac50-0458c80e7993)

So, it may be confirmed that the algorithm of the C code written on the SW is normal.

# Lenet in FPGA
Now check the results in FPGA.
1. Create an IP block with Verilog codes in the "src" folder.
2. Add 'zynq7 processing system ip' and 'top_lenet_axi4lite ip' . In this case, the clock frequency of the zynq is set to 50Mhz.

   ![image](https://github.com/wjdtmdals29/Lenet_axi4lite/assets/109125304/dba94c68-32f0-4703-8174-5b71a7d5957f)

3. After proceeding with Bitstream, extract the .xsa file by 'Hardware export'.
4. Run Vitis IDE and create a project.
5. 'Stack size' and 'Heap size' are set to 200000.
6. Add the file 'lenet_vitis.c' and then 'build' and then 'run hardware'. (File location : Vitis\)
7. When you enter '1' in the Serial Terminal, it generates 1000 random data and then runs on SW and FPGA.
8. It can be seen that both the result value of SW and the result value of FPGA are the same.

   ![image](https://github.com/wjdtmdals29/Lenet_axi4lite/assets/109125304/735df438-5f90-44e1-967f-1e5a65ffdf83)


Therefore, it is possible to indirectly prove that the designed HW design operates normally.
