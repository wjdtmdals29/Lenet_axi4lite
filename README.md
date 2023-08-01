# Lenet axi4-lite simulation and work on fpga board
[Contents]
* H/W expression
1. Lenet & AXI4-lite I/F IP block simulation
2. AXI4 Lite I/F Address mapping
3. Processing order
4. Simulation Result
* S/W Algorithm test
1. Lenet on SW(C language)
* Implementaion result
1. Timing Summary
2. Power
3. Resource utillization
* Lenet on FPGA(Zybo z7 20)
1. Steps how get .xsa file and work in Vitis
2. Demo Video in Vitis

# H/W expression
* Lenet & AXI4-lite I/F IP block simulation
1. Generate ip (File location : Verilog_Vivado\src\)
2. Create new project -> Tools -> Create and package new ip -> Create AXI4 Peripheral -> Select 'Verify Peripheral IP using AXI4 VIP' in 'Create Peripheral' step -> Finish
3. Delete basic IP and replace myip (1. Generate ip (File location : Verilog_Vivado\src)). And connect (M_AXI - s00_axi), (aclk - s00_axi_aclk), (aresetn - s00_axi_aresetn)

    ![image](https://github.com/wjdtmdals29/Lenet_axi4lite/assets/109125304/306e23d2-8691-4175-996c-e2f512cf906d)
   
4. Open 'XX_v1_0_tb.sv'
5. Delete the existing code and copy and paste the code from Verilog_Vivado\tb\ip_tb.sv
6. Run Simulation

* AXI4 Lite I/F Address mapping
0x00 : write clock enable

0x04 : write data(weight)

0x08 : write data(bias)

0x0C : write data(feature map)

0x10 : read 'en' signal(inference processing en)

0x14 : read 'end' signal(inference processing en)

0x18 : read data(inference result)

0x1C : User reset_pos(HIGH reset)

* Processing order
1. User reset
2. Clock enable
3. Write weight data(buffer_Weight)
4. Write bias data(buffer_Bias)
5. Write feature map data(SPBram)
6. Start inference
7. Read classification en, end, result
8. DONE


* Simulation Result
Check the results of entering one data in order from the numbers 0 to 9.

1. AXI4 lite Interface(Write and Read data)

![image](https://github.com/wjdtmdals29/Lenet_axi4lite/assets/109125304/6c00d81f-7f96-4ad3-9db9-d0b21f0741d1)
****If want to see more detail, try simulation and check 'WRITE address & data', 'READ address & data(inference result)'.
    
2. TCL console

![image](https://github.com/wjdtmdals29/Lenet_axi4lite/assets/109125304/0ae38478-2d52-4e87-856b-40f1c8539d40)

# S/W Algorithm test 
* Lenet in SW(C language)
(File location : SW\lenet.c)
Test 10000 images.
Accuracy = 98.19%

![image](https://github.com/wjdtmdals29/Lenet_axi4lite/assets/109125304/770b1038-a020-4cc1-b1d0-1dccd4d0758f)

So, it confirmed that the algorithm of the C code is works normally.

# Implementaion result
I run this model frequency of clock at 50Mhz.

* Timing Summary

![image](https://github.com/wjdtmdals29/Lenet_axi4lite/assets/109125304/18b6b312-6ee8-4327-8d4d-a01adb7bdff5)

* Power

![image](https://github.com/wjdtmdals29/Lenet_axi4lite/assets/109125304/95160f2a-161b-4716-9047-9799dcb2d45e)

* Resource utillization

![image](https://github.com/wjdtmdals29/Lenet_axi4lite/assets/109125304/80a23b57-7b2f-4c47-9d93-cfe4ab8ac061)


# Lenet in FPGA
Test 10000 images in FPGA.
1. Create an IP block with Verilog codes in the "Verilog_Vivado\src".
2. Add 'zynq7 processing system ip' and 'top_lenet_axi4lite ip' . In this case, the clock frequency of the zynq is set to 50Mhz.

![image](https://github.com/wjdtmdals29/Lenet_axi4lite/assets/109125304/dba94c68-32f0-4703-8174-5b71a7d5957f)

3. After proceeding with Bitstream, extract the .xsa file by 'Hardware export'.
4. Run Vitis IDE and create a project.
5. 'Stack size' and 'Heap size' are set to 0x4000000.
6. Add files located "C_vitis" and then 'build' and then 'run hardware'. 

![image](https://github.com/wjdtmdals29/Lenet_axi4lite/assets/109125304/f69c8e1b-68cf-4427-8cb8-65bde836023f)

8. When you enter '1' in the Serial Terminal, a total of 10,000 image data, 1000 from the numbers 0 to 9, are sequentially input, and weight and bias data are input.
9. At the end of processe, the final result can be found in the Serial Terminal.

![image](https://github.com/wjdtmdals29/Lenet_axi4lite/assets/109125304/57428c9b-ed68-469b-9cf5-911f8d81b591)


* [SW] Accuracy = 98.19%          [SW] Average processing time = 17552 us                
* [FPGA] Accuracy = 97.99%        [FPGA] Average processing time = 99.51 us

# Demo Video in Vitis 

https://github.com/wjdtmdals29/Lenet_axi4lite/assets/109125304/08727345-8ffc-45bd-9042-def2cd10cb8c

# [NOTE]
* You can synthesis and implementation at clock speed 70Mhz and it is possible. But in this time, i set up the speed at 50Mhz.
* The result when i set up clock frquency at 70Mhz is here.

![image](https://github.com/wjdtmdals29/Lenet_axi4lite/assets/109125304/d1591a99-bbc0-4e9d-beed-7ed77515454e)


