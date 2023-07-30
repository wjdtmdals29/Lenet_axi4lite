/*******************************************************************************
Author: Seungmin Jeong
Associated Filename: lenet_vitis.c
*******************************************************************************/

#include <stdio.h>
#include "xil_printf.h"
#include "xil_types.h"
#include "xparameters.h"
#include "xil_io.h"
#include "xil_exception.h"
#include "xtime_l.h"
#include "featuremap.h"
#include "weight_conv1.h"
#include "weight_conv2.h"
#include "weight_fc.h"
#include "bias.h"
#include <stdlib.h>
#include <time.h>
#define max(x, y) (x) > (y) ? (x) : (y)

#define ksize 5
#define NUM_TESTIMAGE 10000
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

#define LENET_CE_ADDR             0x00
#define LENET_WEIGHT_ADDR          0x04
#define LENET_BIAS_ADDR          0x08
#define LENET_FMAP_ADDR          0x0C

#define LENET_RESULT_EN_ADDR       0x10
#define LENET_RESULT_END_ADDR       0x14
#define LENET_RESULT_ADDR          0x18
#define LENET_RESET_ADDR          0x1C

#define FMAP_SIZE          784
#define WEIGHT_SIZE         3220
#define BIAS_SIZE         10
#define CONV1_WEIGHT_SIZE   100
#define CONV2_WEIGHT_SIZE    1200
#define FC_WEIGHT_SIZE       1920
#define FC_BIAS_SIZE      10

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

signed int out1[och1][ochsize1][ochsize1];
   signed int out1_relu[och1][ochsize1][ochsize1];
   signed int out1_max[och1][(ochsize1) / 2][(ochsize1) / 2];

   signed int out2[och2][ochsize2][ochsize2];
   signed int out2_relu[och2][ochsize2][ochsize2];
   signed int out2_max[och2][(ochsize2) / 2][(ochsize2) / 2];
  signed int fmap1[NUM_TESTIMAGE][ich1][ichsize1][ichsize1];
  signed int fmap2[ich2][ichsize2][ichsize2];
  signed int weight1[ich1][och1][ksize][ksize];
  signed int weight2[ich2][och2][ksize][ksize];
  signed int fcmap[ich3];
  signed int weight_fc[och3][ich3];
  signed int bias_fc[och3];
  signed int out3[och3];
  signed int out3_relu[och3];

  signed int fmap_HW[NUM_TESTIMAGE][FMAP_SIZE];
  signed int weight_HW[WEIGHT_SIZE];
  signed int bias_HW[BIAS_SIZE];
  int Expected_result = -1;
  int imagecount = 0;
  int pixelcount = 0;
  int weightcount = 0;
   unsigned int k = 0;
   unsigned int w = 0;
   int count_image = 0;
   int testnum_count = 0;
   double SW_stack_processing_time = 0;
   double FPGA_stack_processing_time = 0;
   //ouble FPGA_stack_senddata_time = 0;
   double SW_match_count = 0;
   double FPGA_match_count = 0;
   double ref_c_run_time = 0;
   double ref_v_run_time = 0;
   double ref_v_send_data_time = 0;
   int result_SW = 0;
    int result_FPGA = 0;
int main()
{
   int inbyte_in;
   int end;
   signed int i, m, n, p, q, j, b;

   while (1)
   {
      print ("********************** Start *********************** \r\n ");
      print ("Press '1' Start \r\n");
      print ("Press '2' Exit \r\n");
      //print ("Selection:");
      inbyte_in = inbyte ();
      print ("\r\n");
      print ("\r\n");

      XTime tStart, tEnd;

      switch (inbyte_in)
      {
         case '1': // Show all registers
         srand(tStart);
         //print("***********reset SW*************\n");
         
         SW_match_count = 0;
         FPGA_match_count = 0;
         testnum_count = 0;
         ref_c_run_time = 0;
         ref_v_run_time = 0;
         ref_v_send_data_time = 0;
         SW_stack_processing_time = 0;
         FPGA_stack_processing_time = 0;
         //FPGA_stack_senddata_time = 0;

        for(int image = 0; image < NUM_TESTIMAGE; image = image + 1){
            k = 0;
         for (i = 0; i < ich1; i++) {
            for (m = 0; m < ichsize1; m++) {
               for (n = 0; n < ichsize1; n++) {
                  fmap1[image][i][m][n] = 0;
                  fmap_HW[image][k] = 0;
                  k = k+1;
               }
            }
         }
         }
         k = 0;
         w = 0;
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
        for(int image = 0; image < NUM_TESTIMAGE; image = image + 1){
        k = 0;
      for (i = 0; i < ich1; i++) {
            for (m = 0; m < ichsize1; m++) {
               for (n = 0; n < ichsize1; n++) {
                    fmap1[image][i][m][n] = feature_map[pixelcount];
                  fmap_HW[image][k] = feature_map[pixelcount];
                  pixelcount = pixelcount+1;
                  k = k+1;
               }
            }
         }
      }
      pixelcount = 0;
         k = 0;
         w = 0;
         for (i = 0; i < ich1; i++) {
            for (p = 0; p < och1; p++) {
               for (m = 0; m < ksize; m++) {
                  for (n = 0; n < ksize; n++) {
                     weight1[i][p][m][n] = weight_conv1[weightcount];
                     weight_HW[w] = weight_conv1[weightcount];
                     weightcount = weightcount+1;
                     w = w+1;
                    }
               }
            }
         }
         weightcount = 0;
         for (i = 0; i < ich2; i++) {
            for (p = 0; p < och2; p++) {
               for (m = 0; m < ksize; m++) {
                  for (n = 0; n < ksize; n++) {
                     weight2[i][p][m][n] = weight_conv2[weightcount];
                     weight_HW[w] = weight_conv2[weightcount];
                     weightcount = weightcount+1;
                     w = w+1;
                    }
               }
            }
         }
         weightcount = 0;
         for (i = 0; i < och3; i++) {
            for (p = 0; p < ich3; p++) {
               weight_fc[i][p] = weight_fclayer[weightcount];
               weight_HW[w] = weight_fclayer[weightcount];
               weightcount = weightcount+1;
               w = w+1;
             }
           }
           weightcount = 0;
         w = 0;
           for (i = 0; i < och3; i++) {
             bias_fc[i] = bias[i];
            bias_HW[i] = bias[i];
        }

        ////////////////////////10000 Image Processing Strat////////////////////////
         while(imagecount < NUM_TESTIMAGE){
          if((imagecount % 1000) == 0){
          Expected_result = Expected_result + 1;
          }
          for (m = 0; m < ochsize1; m++) {
			      for (n = 0; n < ochsize1; n++) {
						for (j = 0; j < och1; j++) {
							out1[j][m][n] = 0;
              out1_relu[j][m][n] = 0;
			      }
		      }
	      }
	      for (j = 0; j < och1; j++) {
		      for (m = 0; m < ochsize1; m = m + 2) {
		      	for (n = 0; n < ochsize1; n = n + 2) {
		      		out1_max[j][m / 2][n / 2] = 0;
              fmap2[j][m / 2][n / 2] = 0;
			      }
		      }
	      }
		      for (m = 0; m < ochsize2; m++) {
			      for (n = 0; n < ochsize2; n++) {
			      			for (j = 0; j < och2; j++) {
			      				out2[j][m][n] = 0;
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
        for (i = 0; i < och2; i = i + 1) {
	      	for (m = 0; m < ichsize3; m = m + 1) {
	      		for (n = 0; n < ichsize3; n = n + 1) {
              fcmap[(i*ichsize3*ichsize3)+(m*ichsize3)+n] = 0;
            }
          }
        }
        for (i = 0; i < och3; i = i + 1){
            out3[i] = 0;
            bias_fc[i] = 0;
            out3_relu[i] = 0;
        }
            result_SW = 0;
      
/////////////////// LENET Run in PS /////////////////////////////
            //printf("============[SW] LENET Run in PS(SW) .=============\n");
            XTime_GetTime(&tStart);
   for (i = 0; i < ich1; i++) {
      for (m = 0; m < ochsize1; m++) {
         for (n = 0; n < ochsize1; n++) {
            for (p = 0; p < ksize; p++) {
               for (q = 0; q < ksize; q++) {
                  for (j = 0; j < och1; j++) {
                     out1[j][m][n] += (fmap1[imagecount][i][m + p][n + q] * weight1[i][j][p][q]); //Convolution
                     out1_relu[j][m][n] = relu(out1[j][m][n]); //Relu function
                  }
               }
            }
         }
      }
   }
   /////////////////////  maxpooler  /////////////////////
   for (j = 0; j < och1; j++) {
      for (m = 0; m < ochsize1; m = m + 2) {
         for (n = 0; n < ochsize1; n = n + 2) {
          //maxpool
            out1_max[j][m / 2][n / 2] = Max(out1_relu[j][m][n], out1_relu[j][m][n + 1], out1_relu[j][m + 1][n], out1_relu[j][m + 1][n + 1]);
            fmap2[i][m][n] = out1_max[j][m / 2][n / 2];
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
                     out2[j][m][n] += (fmap2[i][m + p][n + q] * weight2[i][j][p][q]); //Convolution
                     out2_relu[j][m][n] = relu(out2[j][m][n]); //Relu function
                  }
               }
            }
         }
      }
   }
   /////////////////////  maxpooler  /////////////////////
  for (j = 0; j < och2; j++) {
     for (m = 0; m < ochsize2; m = m + 2) {
        for (n = 0; n < ochsize2; n = n + 2) {
           out2_max[j][m / 2][n / 2] = Max(out2_relu[j][m][n], out2_relu[j][m][n + 1], out2_relu[j][m + 1][n], out2_relu[j][m + 1][n + 1]);
        //truncate **I don't resolve this problem. If i don't truncate 3bits, then the result return error value** Please solve this
          for(b = 0; b < 3; b = b + 1) {
            out2_max[j][m / 2][n / 2] = out2_max[j][m / 2][n / 2] - (out2_max[j][m / 2][n / 2]*0.5);
          }
        /////////////
          fcmap[(j*ichsize3*ichsize3)+((m / 2)*ichsize3)+(n / 2)] = out2_max[j][m / 2][n / 2];
          }
        }
     }

  ////////////////////////////////////////////////////////////////////////////////////
   ///////////////////////////  Strat Fully Connected layer  ////////////////////////////
   ////////////////////////////////////////////////////////////////////////////////////
  for (i = 0; i < och3; i = i + 1){
    for (m = 0; m < ich3; m = m + 1) {
      out3[i] = out3[i] + (fcmap[m]*weight_fc[i][m]);
    }
    out3[i] = out3[i] + bias_fc[i];
    out3_relu[i] = relu(out3[i]);
  }
  result_SW = Max_class(out3_relu[0],out3_relu[1],out3_relu[2],out3_relu[3],
  out3_relu[4],out3_relu[5],out3_relu[6],out3_relu[7],out3_relu[8],out3_relu[9]);

            XTime_GetTime(&tEnd);
            ref_c_run_time = 1.0 * (tEnd - tStart) / (COUNTS_PER_SECOND/1000000);
            SW_stack_processing_time = SW_stack_processing_time + ref_c_run_time;
    ////////////////////////////////////////////////////////////////////////////////////        
////////////////////////////// LENET Run in PL /////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////
            //printf("============[FPGA] LENET Run in PL .=============\n");
            //XTime_GetTime(&tStart);
            Xil_Out32 ((XPAR_TOP_LENET_AXI4LITE_0_BASEADDR + LENET_RESET_ADDR), 0x00000000); // 
            Xil_Out32 ((XPAR_TOP_LENET_AXI4LITE_0_BASEADDR + LENET_RESET_ADDR), 0x00000001); // HIGH reset
            Xil_Out32 ((XPAR_TOP_LENET_AXI4LITE_0_BASEADDR + LENET_RESET_ADDR), 0x00000000); // 
            Xil_Out32 ((XPAR_TOP_LENET_AXI4LITE_0_BASEADDR + LENET_CE_ADDR), 0x00000001); // clock enable
            for (i = 0 ; i < WEIGHT_SIZE; i ++){
               Xil_Out32 ((XPAR_TOP_LENET_AXI4LITE_0_BASEADDR + LENET_WEIGHT_ADDR), weight_HW[i]);
            }
            for (i = 0 ; i < BIAS_SIZE; i ++){
               Xil_Out32 ((XPAR_TOP_LENET_AXI4LITE_0_BASEADDR + LENET_BIAS_ADDR), bias_HW[i]);
            }
            for (i = 0; i < FMAP_SIZE; i++) {
                 Xil_Out32 ((XPAR_TOP_LENET_AXI4LITE_0_BASEADDR + LENET_FMAP_ADDR), fmap_HW[imagecount][i]);
            }
            XTime_GetTime(&tStart);
            while(1) {
               end = (int) Xil_In32 ((XPAR_TOP_LENET_AXI4LITE_0_BASEADDR + LENET_RESULT_END_ADDR));
               if(end == 1){
                   result_FPGA = (int) Xil_In32 ((u32) (XPAR_TOP_LENET_AXI4LITE_0_BASEADDR + LENET_RESULT_ADDR));
                  break;
               }
            }
            XTime_GetTime(&tEnd);
            Xil_Out32 ((u32) (XPAR_TOP_LENET_AXI4LITE_0_BASEADDR + LENET_CE_ADDR), (u32) 0);
            ref_v_run_time = 1.0 * (tEnd - tStart) / (COUNTS_PER_SECOND/1000000);
            FPGA_stack_processing_time = FPGA_stack_processing_time + ref_v_run_time;
            
            if(Expected_result == result_SW){
              SW_match_count = SW_match_count + 1;
            }
            if(Expected_result == result_FPGA){
              FPGA_match_count = FPGA_match_count + 1;
            }
            printf("[%d Image Done] [SW]Accuracy =  %.2f%%  [FPGA]Accuracy =  %.2f%%\n",imagecount,
                   (SW_match_count/(imagecount+1))*100, (FPGA_match_count/(imagecount+1))*100);
            imagecount = imagecount+1;

         }

         printf("[SW] Match Count = %.f    [FPGA] Match count = %.f\n",SW_match_count,FPGA_match_count);
         printf("[SW] Accuracy = %.2f%%    ", (SW_match_count/NUM_TESTIMAGE)*100);
         printf("[FPGA] Accuracy = %.2f%%\n", (FPGA_match_count/NUM_TESTIMAGE)*100);
         
         printf("[SW] Average processing time = %.2f us    ", (SW_stack_processing_time/NUM_TESTIMAGE));
         printf("[FPGA] Average processing time = %.2f us\n", (FPGA_stack_processing_time/NUM_TESTIMAGE));
         printf("[FPGA] speed faster %.2f times than [SW]\n", (SW_stack_processing_time/FPGA_stack_processing_time));
         break;
         case '2': // exit
            print ("exit \r\n");
            return 0;
      
      
      print ("\r\n");
      }
   }
    return 0;
}
