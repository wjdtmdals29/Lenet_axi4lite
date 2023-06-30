/*******************************************************************************
Author: joohan.kim (https://blog.naver.com/chacagea)
Associated Filename: main.c
Purpose: LENET Core test (Demo)
Revision History: March 08, 2020 - initial release
*******************************************************************************/

#include <stdio.h>
#include "xil_printf.h"
#include "xil_types.h"
#include "xparameters.h"
#include "xil_io.h"
#include "xil_exception.h"
#include "xtime_l.h"
#include <stdlib.h>
#include <time.h>
#define max(x, y) (x) > (y) ? (x) : (y)

#define ksize 5

#define ich1 1
#define och1 4
#define ichsize1 28
#define ochsize1 ichsize1-ksize+1
#define bwtrunc1 20-16

#define ich2 och1
#define och2 12
#define ichsize2 (ochsize1)/2
#define ochsize2 ichsize2-ksize+1
#define bwtrunc2 27-16

#define ich3 och2*ichsize3*ichsize3
#define ichsize3 (ochsize2)/2
#define bwtruncfc 30-16
#define och3 10

#define LENET_CE_ADDR 				0x00
#define LENET_WEIGHT_ADDR 			0x04
#define LENET_BIAS_ADDR 			0x08
#define LENET_FMAP_ADDR 			0x0C

#define LENET_RESULT_EN_ADDR 		0x10
#define LENET_RESULT_END_ADDR 		0x14
#define LENET_RESULT_ADDR 			0x18
#define LENET_RESET_ADDR 			0x1C

#define FMAP_SIZE 			784
#define WEIGHT_SIZE			3220
#define BIAS_SIZE			10
#define CONV1_WEIGHT_SIZE	100
#define CONV2_WEIGHT_SIZE 	1200
#define FC_WEIGHT_SIZE 		1920
#define FC_BIAS_SIZE		10

int Max(int a, int b, int c, int d)
{
	int max1 = max(a, b);
	int max2 = max(c, d);
	int max3 = max(max1, max2);
	return max3;
}
int Max_class(int a, int b, int c, int d, int e, int f, int g, int h, int i, int j)
{
  int result;
	int max1 = max(a, b);
	int max2 = max(c, d);
	int max3 = max(e, f);
  int max4 = max(g, h);
  int max5 = max(i, j);
  int max2_0 = max(max1, max2);
  int max2_1 = max(max3, max4);
  int max3_0 = max(max2_0, max2_1);
  int max_final = max(max3_0, max5);
  if(max_final == a){
    result = 0;
  }
  else if(max_final == b){
    result = 1;
  }
  else if(max_final == c){
    result = 2; 
  }
  else if(max_final == d){
    result = 3;
  }
  else if(max_final == e){
    result = 4;
  }
  else if(max_final == f){
    result = 5;
  }
  else if(max_final == g){
    result = 6;
  }
  else if(max_final == h){
    result = 7;
  }
  else if(max_final == i){
    result = 8;
  }
  else if(max_final == j){
    result = 9;
  }
	return result;
}
int relu(int x)
{
	if (x > 0) return x;
	return 0;
}


int main()
{
	int inbyte_in;
	int en;
	signed int i, m, n, p, q, j, b;
	signed int out1[och1][ochsize1][ochsize1];
	signed int out1_relu[och1][ochsize1][ochsize1];
	signed int out1_max[och1][(ochsize1) / 2][(ochsize1) / 2];

	signed int out2[och2][ochsize2][ochsize2];
	signed int out2_relu[och2][ochsize2][ochsize2];
	signed int out2_max[och2][(ochsize2) / 2][(ochsize2) / 2];
  signed int fmap1[ich1][ichsize1][ichsize1];
  signed int fmap2[ich2][ichsize2][ichsize2];
  signed int weight1[ich1][och1][ksize][ksize];
  signed int weight2[ich2][och2][ksize][ksize];
  signed int fcmap[ich3];
  signed int weight_fc[och3][ich3];
  signed int bias_fc[och3];
  signed int out3[och3];
  signed int out3_relu[och3];

  signed int fmap_HW[FMAP_SIZE];
  signed int weight_HW[WEIGHT_SIZE];
  signed int bias_HW[BIAS_SIZE];

  signed int result_SW;
	
  signed int result_0_rtl2;  
	unsigned int k = 0;
	unsigned int w = 0;
	double ref_c_run_time;
	double ref_v_run_time;
	XTime ref_c_run_cycle;
	XTime ref_v_run_cycle;

	while (1)
	{
		print ("********************** Start *********************** \r\n ");
		print ("Press '1' Start \r\n");
		print ("Press '2' Exit \r\n");
		print ("Selection:");
		inbyte_in = inbyte ();
		print ("\r\n");
		print ("\r\n");

		XTime tStart, tEnd;

		switch (inbyte_in)
		{
			case '1': // Show all registers
			srand(tStart);
			print("***********reset SW*************\n");
			
			for (i = 0; i < ich1; i++) {
				for (m = 0; m < ichsize1; m++) {
					for (n = 0; n < ichsize1; n++) {
    		    		fmap1[i][m][n] = 0;
						fmap_HW[k] = 0;
						k = k+1;
					}
				}
			}
			k = 0;
			for (i = 0; i < ich1; i++) {
				for (p = 0; p < och1; p++) {
					for (m = 0; m < ksize; m++) {
						for (n = 0; n < ksize; n++) {
    		      			weight1[i][p][m][n] = 0 ;
							weight_HW[w] = 0;
							w = w+1;
    		    		}
					}
				}
			}
			for (i = 0; i < ich2; i++) {
				for (p = 0; p < och2; p++) {
					for (m = 0; m < ksize; m++) {
						for (n = 0; n < ksize; n++) {
							weight2[i][p][m][n] = 0 ;
							weight_HW[w] = 0;
							w = w+1;
        				}
					}
				}
			}
			for (i = 0; i < och3; i++) {
				for (p = 0; p < ich3; p++) {
					weight_fc[i][p] = 0;
					weight_HW[w] = 0;
					w = w+1;
    			}
  			}
			w = 0;
 		 	for (i = 0; i < och3; i++) {
    			bias_fc[i] = 0;
				bias_HW[i] = 0;
  		}
		for (i = 0; i < ich1; i++) {
			for (m = 0; m < ochsize1; m++) {
				for (n = 0; n < ochsize1; n++) {
					for (p = 0; p < ksize; p++) {
						for (q = 0; q < ksize; q++) {
							for (j = 0; j < och1; j++) {
								out1[j][m][n] = 0;
							}
						}
					}
				}
			}
		}
		for (m = 0; m < ochsize1; m++) {
			for (n = 0; n < ochsize1; n++) {
				for (j = 0; j < och1; j++) {
					out1_relu[j][m][n] = 0;
				}
			}
		}
		for (m = 0; m < ochsize1; m = m + 2) {
			for (n = 0; n < ochsize1; n = n + 2) {
				for (j = 0; j < och1; j++) {
					out1_max[j][m / 2][n / 2] = 0;
				}
			}
		}

		for (i = 0; i < ich2; i++) {
			for (m = 0; m < ochsize2; m++) {
				for (n = 0; n < ochsize2; n++) {
					for (p = 0; p < ksize; p++) {
						for (q = 0; q < ksize; q++) {
							for (j = 0; j < och2; j++) {
								out2[j][m][n] = 0;
							}
						}
					}
				}
			}
		}
    	for (j = 0; j < och2; j++) {
		    for (m = 0; m < ochsize2; m++) {
			    for (n = 0; n < ochsize2; n++) {
				    out2_relu[j][m][n] = 0;
			    }
		    }
    	}
  		for (j = 0; j < och2; j++) {
	  		for (m = 0; m < ochsize2; m = m + 2) {
		  		for (n = 0; n < ochsize2; n = n + 2) {
			 		 out2_max[j][m / 2][n / 2] = 0;
		  		}
	 		 }
 		 }
		for (i = 0; i < och3; i = i + 1){
    		out3[i] = 0;
		}
		for (i = 0; i < och3; i = i + 1){
  			out3_relu[i] = 0;
		}
		result_SW = 0;
				print("***********reset SW DONE*************\n");
				print("***********generate random data*************\n");
		for (i = 0; i < ich1; i++) {
				for (m = 0; m < ichsize1; m++) {
					for (n = 0; n < ichsize1; n++) {
    		    		fmap1[i][m][n] = rand()%256;
						fmap_HW[k] = fmap1[i][m][n];
						k = k+1;
					}
				}
			}
			k = 0;
			w = 0;
			for (i = 0; i < ich1; i++) {
				for (p = 0; p < och1; p++) {
					for (m = 0; m < ksize; m++) {
						for (n = 0; n < ksize; n++) {
    		      			weight1[i][p][m][n] = rand()%256 - 128;
							weight_HW[w] = weight1[i][p][m][n];
							w = w+1;
    		    		}
					}
				}
			}
			for (i = 0; i < ich2; i++) {
				for (p = 0; p < och2; p++) {
					for (m = 0; m < ksize; m++) {
						for (n = 0; n < ksize; n++) {
							weight2[i][p][m][n] = rand()%256 - 128;
							weight_HW[w] = weight2[i][p][m][n];
							w = w+1;
        				}
					}
				}
			}
			for (i = 0; i < och3; i++) {
				for (p = 0; p < ich3; p++) {
					weight_fc[i][p] = rand()%256 - 128;
					weight_HW[w] = weight_fc[i][p];
					w = w+1;
    			}
  			}
			w = 0;
 		 	for (i = 0; i < och3; i++) {
    			bias_fc[i] = rand()%256 - 128;
				bias_HW[i] = bias_fc[i];
  		}
		print("***********generate random data DONE*************\n");
/////////////////// LENET Run in PS /////////////////////////////

				printf("============[CPU] LENET Run in PS(SW) .=============\n");
				XTime_GetTime(&tStart);

	/////////////////////  Convolution layer1  /////////////////////
	for (i = 0; i < ich1; i++) {
		for (m = 0; m < ochsize1; m++) {
			for (n = 0; n < ochsize1; n++) {
				for (p = 0; p < ksize; p++) {
					for (q = 0; q < ksize; q++) {
						for (j = 0; j < och1; j++) {
							out1[j][m][n] += (fmap1[i][m + p][n + q] * weight1[i][j][p][q]);
						}
					}
				}
			}
		}
	}
	/////////////////////  relu function  /////////////////////
	for (j = 0; j < och1; j++) {
		//printf("\n\nout1 channel%d relu\n",j);
		for (m = 0; m < ochsize1; m++) {
			//printf("\n");
			for (n = 0; n < ochsize1; n++) {
				out1_relu[j][m][n] = relu(out1[j][m][n]);
				//printf("%d ", out1_relu[j][m][n]);
			}
		}
	}
	/////////////////////  maxpooler  /////////////////////
	for (j = 0; j < och1; j++) {
		//printf("\n\nout1 channel%d max\n", j);
		for (m = 0; m < ochsize1; m = m + 2) {
			//printf("\n");
			for (n = 0; n < ochsize1; n = n + 2) {
				out1_max[j][m / 2][n / 2] = Max(out1_relu[j][m][n], out1_relu[j][m][n + 1], out1_relu[j][m + 1][n], out1_relu[j][m + 1][n + 1]);
				//printf("%d ", out1_max[j][m / 2][n / 2]);
			}
		}
	}
  for (i = 0; i < ich2; i = i + 1) {
    //printf("\n\nout1 channel%d truncate\n", i);
		for (m = 0; m < ichsize2; m = m + 1) {
      //printf("\n");
			for (n = 0; n < ichsize2; n = n + 1) {
        for(b = 0; b < bwtrunc1; b = b + 1) {
          out1_max[i][m][n] = out1_max[i][m][n] - (out1_max[i][m][n]*0.5);
        }
        fmap2[i][m][n] = out1_max[i][m][n];
        //printf("%d ",fmap2[i][m][n]);
      }
    }
  }
	////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////  Strat convolution layer 2  ////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////
	for (i = 0; i < ich2; i++) {
		for (m = 0; m < ochsize2; m++) {
			for (n = 0; n < ochsize2; n++) {
				for (p = 0; p < ksize; p++) {
					for (q = 0; q < ksize; q++) {
						for (j = 0; j < och2; j++) {
							out2[j][m][n] += (fmap2[i][m + p][n + q] * weight2[i][j][p][q]);
						}
					}
				}
			}
		}
	}
	/////////////////////  relu function  /////////////////////
  for (j = 0; j < och2; j++) {
    //printf("\n\nout2 channel%d relu\n",j);
	  for (m = 0; m < ochsize2; m++) {
		  //printf("\n");
		  for (n = 0; n < ochsize2; n++) {
			  out2_relu[j][m][n] = relu(out2[j][m][n]);
			  //printf("%d ", out2_relu[j][m][n]);
		  }
	  }
  }
	/////////////////////  maxpooler  /////////////////////
  for (j = 0; j < och2; j++) {
    //printf("\n\nout2 channel%d max\n",j);
	  for (m = 0; m < ochsize2; m = m + 2) {
		  //printf("\n");
		  for (n = 0; n < ochsize2; n = n + 2) {
			  out2_max[j][m / 2][n / 2] = Max(out2_relu[j][m][n], out2_relu[j][m][n + 1], out2_relu[j][m + 1][n], out2_relu[j][m + 1][n + 1]);
			  //printf("%d ", out2_max[j][m / 2][n / 2]);
		  }
	  }
  }
  for (i = 0; i < och2; i = i + 1) {
    //printf("\n\nout2 channel%d truncate\n", i);
		for (m = 0; m < ichsize3; m = m + 1) {
      //printf("\n");
			for (n = 0; n < ichsize3; n = n + 1) {
        for(b = 0; b < bwtrunc2; b = b + 1) {
          out2_max[i][m][n] = out2_max[i][m][n] - (out2_max[i][m][n]*0.5);
        }
        fcmap[(i*ichsize3*ichsize3)+(m*ichsize3)+n] = out2_max[i][m][n];
        //printf("%d ",fcmap[(i*ichsize3*ichsize3)+(m*ichsize3)+n]);
      }
    }
  }
  //printf("\n");
  for (i = 0; i < och3; i = i + 1){
    //printf("\nout3(fc) channel%d = ", i);
    for (m = 0; m < ich3; m = m + 1) {
      out3[i] = out3[i] + (fcmap[m]*weight_fc[i][m]);
      //printf(" %d : %d ",m,out3[i]);
    }
    out3[i] = out3[i] + bias_fc[i];
    //printf("%d\n",out3[i]);
  }
  for (i = 0; i < och3; i = i + 1){
    //printf("\nout3(fc) channel%d relu = ", i);
    out3_relu[i] = relu(out3[i]);
    for(b = 0; b < bwtruncfc; b = b + 1) {
          out3_relu[i] = out3_relu[i] - (out3_relu[i]*0.5);
        }
    //printf("%d\n",out3_relu[i]);
  }
  result_SW = Max_class(out3_relu[0],out3_relu[1],out3_relu[2],out3_relu[3],
  out3_relu[4],out3_relu[5],out3_relu[6],out3_relu[7],out3_relu[8],out3_relu[9]);


				XTime_GetTime(&tEnd);
				ref_c_run_cycle = 2*(tEnd - tStart);
				ref_c_run_time = 1.0 * (tEnd - tStart) / (COUNTS_PER_SECOND/1000000);
				printf("[CPU] Output took %llu clock cycles.\n", ref_c_run_cycle);
				printf("[CPU] Output took %.2f us.\n", ref_c_run_time);
				printf("[CPU] result : %d\n", result_SW);

/////////////////// LENET Run in PL /////////////////////////////
				printf("============[FPGA] LENET Run in PL .=============\n");
				XTime_GetTime(&tStart);
				Xil_Out32 ((u32) (XPAR_TOP_LENET_AXI4LITE_0_BASEADDR + LENET_RESET_ADDR), (u32) 0); // run
				Xil_Out32 ((u32) (XPAR_TOP_LENET_AXI4LITE_0_BASEADDR + LENET_RESET_ADDR), (u32) 1); // run
				Xil_Out32 ((u32) (XPAR_TOP_LENET_AXI4LITE_0_BASEADDR + LENET_RESET_ADDR), (u32) 0); // run
				Xil_Out32 ((u32) (XPAR_TOP_LENET_AXI4LITE_0_BASEADDR + LENET_RESET_ADDR), (u32) 1); // run
				for (i = 0 ; i < WEIGHT_SIZE; i ++){
					Xil_Out32 ((u32) (XPAR_TOP_LENET_AXI4LITE_0_BASEADDR + LENET_WEIGHT_ADDR), (u32) weight_HW[i]);
				}
				for (i = 0 ; i < BIAS_SIZE; i ++){
					Xil_Out32 ((u32) (XPAR_TOP_LENET_AXI4LITE_0_BASEADDR + LENET_BIAS_ADDR), (u32) bias_HW[i]);
				}
				for (i = 0; i < FMAP_SIZE; i++) {
    		    	Xil_Out32 ((u32) (XPAR_TOP_LENET_AXI4LITE_0_BASEADDR + LENET_FMAP_ADDR), (u32) fmap_HW[i]);
				}
				XTime_GetTime(&tEnd);
				ref_v_send_data_time = 1.0 * (tEnd - tStart) / (COUNTS_PER_SECOND/1000000);
				printf("[FPGA] Send datas %.2f us.\n", ref_v_send_data_time);
				XTime_GetTime(&tStart);

				while(1) {
					end = (int) Xil_In32 ((u32) (XPAR_TOP_LENET_AXI4LITE_0_BASEADDR + LENET_RESULT_END_ADDR));
          			//result_0_rtl1 = (int) Xil_In32 ((u32) (XPAR_TOP_LENET_AXI4LITE_0_BASEADDR + LENET_RESULT_ADDR));
          			//printf("my result : %d\n", result_0_rtl1);
					if(end == 1)
          			result_0_rtl2 = (int) Xil_In32 ((u32) (XPAR_TOP_LENET_AXI4LITE_0_BASEADDR + LENET_RESULT_ADDR));
          			printf("my result : %d\n", result_0_rtl2);
						break;
				}
				//result_0_rtl0 = (int) Xil_In32 ((u32) (XPAR_TOP_LENET_AXI4LITE_0_BASEADDR + LENET_RESULT_ADDR));
				Xil_Out32 ((u32) (XPAR_TOP_LENET_AXI4LITE_0_BASEADDR + LENET_CE_ADDR), (u32) 0);
				XTime_GetTime(&tEnd);
				ref_v_run_cycle = 2*(tEnd - tStart);
				ref_v_run_time = 1.0 * (tEnd - tStart) / (COUNTS_PER_SECOND/1000000);
				printf("[FPGA] Output took %llu clock cycles.\n", ref_v_run_cycle);
				printf("[FPGA] Output took %.2f us.\n", ref_v_run_time);
				printf("[FPGA] result : %d\n", result_0_rtl2);

				if(result_SW != result_0_rtl2) {
					printf("[Mismatch] result_C : %d vs result_V : %d\n", result_SW, result_0_rtl2);
					print ("exit \r\n");
					//return 0;
          break;
				}
				printf("[Match] REF_C vs RTL_V \n");
				double perf_ratio = ref_c_run_cycle / ref_v_run_cycle;
				printf("[Match] RTL_V is  %.2f times faster than REF_C  \n", perf_ratio);
				printf("[Match] The difference between RTL_V and REF_C is %.2f us.  \n", ref_c_run_time - ref_v_run_time);
				break;
			case '2': // exit
				print ("exit \r\n");
				return 0;
		}
		print ("\r\n");
	}
    return 0;
}