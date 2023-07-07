/*******************************************************************************
#Author: Seungmin.Jeong
#Purpose: C code / lenet(my model)
#Revision History: 2023.07.03
*******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#define max(x, y) (x) > (y) ? (x) : (y)
#define TestImage 1000
#define ksize 5

#define ich1 1
#define och1 4
#define ichsize1 28
#define ochsize1 ichsize1-ksize+1

#define ich2 och1
#define och2 12
#define ichsize2 (ochsize1)/2
#define ochsize2 ichsize2-ksize+1

#define ich3 och2*ichsize3*ichsize3
#define ichsize3 (ochsize2)/2
#define och3 10
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
    return result; 
  }
  else if(max_final == b){
    result = 1;
    return result; 
  }
  else if(max_final == c){
    result = 2;
    return result; 
  }
  else if(max_final == d){
    result = 3;
    return result; 
  }
  else if(max_final == e){
    result = 4;
    return result; 
  }
  else if(max_final == f){
    result = 5;
    return result; 
  }
  else if(max_final == g){
    result = 6;
    return result; 
  }
  else if(max_final == h){
    result = 7;
    return result; 
  }
  else if(max_final == i){
    result = 8;
    return result; 
  }
  else if(max_final == j){
    result = 9;
    return result; 
  }
}
int relu(int x)
{
	if (x > 0) return x;
	return 0;
}
  /// global variable to prevent stack overflow ///
  signed int out1[och1][ochsize1][ochsize1];
	signed int out1_relu[och1][ochsize1][ochsize1];
	signed int out1_max[och1][(ochsize1) / 2][(ochsize1) / 2];

	signed int out2[och2][ochsize2][ochsize2];
	signed int out2_relu[och2][ochsize2][ochsize2];
	signed int out2_max[och2][(ochsize2) / 2][(ochsize2) / 2];
  signed int fmap1[TestImage][ich1][ichsize1][ichsize1];
  signed int fmap2[ich2][ichsize2][ichsize2];
  signed int weight1[ich1][och1][ksize][ksize];
  signed int weight1_HW[ich1][och1][ksize][ksize];
  signed int weight2[ich2][och2][ksize][ksize];
  signed int weight2_HW[ich2][och2][ksize][ksize];
  signed int fcmap[ich3];
  signed int weight_fc[och3][ich3];
  signed int weight_fc_HW[och3][ich3];
  signed int bias_fc[och3];
  signed int bias_fc_HW[och3];
  signed int out3[och3];
  signed int out3_relu[och3];
  int Actual_result = 0;
  int Expected_result = -1;
  double count_match = 0;
  double count_mismatch = 0;

int main()
{ 
	signed int testimagenum, i, m, n, p, q, j, b;
  int count_img = 0;
  FILE *fp_fmap;
  FILE *fp_weight1;
  FILE *fp_weight2;
  FILE *fp_weight2_ch1;
  FILE *fp_weight2_ch2;
  FILE *fp_weight2_ch3;
  FILE *fp_weight2_ch4;
  FILE *fp_weight_fc;
  FILE *fp_bias_fc;
  srand(time(NULL));
  signed int random;
  
  Actual_result = 0;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////Real values////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//<num0>100images,<num1>100images,<num2>100images,<num3>100images,<num4>100images,<num5>100images,<num6>100images,<num7>100images,<num8>100images,<num9>100images
fp_fmap = fopen("test_num_0to9_1000.txt", "r"); 
for(testimagenum = 0; testimagenum < TestImage; testimagenum = testimagenum+1){
	for (i = 0; i < ich1; i++) {
		for (m = 0; m < ichsize1; m++) {
			for (n = 0; n < ichsize1; n++) {
        fscanf(fp_fmap,"%d",&fmap1[testimagenum][i][m][n]);
			}
		}
	}
  
}
fclose(fp_fmap);

fp_weight1 = fopen("SW_conv1_weight.txt", "r");
	for (i = 0; i < ich1; i++) {
		for (p = 0; p < och1; p++) {
			for (m = 0; m < ksize; m++) {
				for (n = 0; n < ksize; n++) {
          fscanf(fp_weight1,"%d",&weight1[i][p][m][n]);
        }
			}
		}
	}
fclose(fp_weight1);
fp_weight2 = fopen("SW_conv2_weight.txt", "r");
	for (i = 0; i < ich2; i++) {
		for (p = 0; p < och2; p++) {
			for (m = 0; m < ksize; m++) {
				for (n = 0; n < ksize; n++) {
          fscanf(fp_weight2,"%d",&weight2[i][p][m][n]);
        }
			}
		}
	}
  fclose(fp_weight2);
	
  fp_weight_fc = fopen("SW_fc_weight.txt", "r");
	for (i = 0; i < och3; i++) {
		for (p = 0; p < ich3; p++) {
      fscanf(fp_weight_fc,"%d",&weight_fc[i][p]);
    }
  }
  fclose(fp_weight_fc);
  fp_bias_fc = fopen("SW_fc_bias.txt", "r");
  for (i = 0; i < och3; i++) {
    fscanf(fp_bias_fc,"%d",&bias_fc[i]);
  }
  fclose(fp_bias_fc);
/////////////////////Start 1000times/////////////////////

  while(count_img < TestImage){
    /////////////////////Initialize/////////////////////
    for (m = 0; m < ochsize1; m++) {
			for (n = 0; n < ochsize1; n++) {
						for (j = 0; j < och1; j++) {
							out1[j][m][n] = 0;
			}
		}
	}
	for (j = 0; j < och1; j++) {
		for (m = 0; m < ochsize1; m++) {
			for (n = 0; n < ochsize1; n++) {
				out1_relu[j][m][n] = 0;
			}
		}
	}
	for (j = 0; j < och1; j++) {
		for (m = 0; m < ochsize1; m = m + 2) {
			for (n = 0; n < ochsize1; n = n + 2) {
				out1_max[j][m / 2][n / 2] = 0;
			}
		}
	}
  for (i = 0; i < ich2; i = i + 1) {
		for (m = 0; m < ichsize2; m = m + 1) {
			for (n = 0; n < ichsize2; n = n + 1) {
        fmap2[i][m][n] = 0;
      }
    }
  }
		for (m = 0; m < ochsize2; m++) {
			for (n = 0; n < ochsize2; n++) {
						for (j = 0; j < och2; j++) {
							out2[j][m][n] = 0;
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
  }
  for (i = 0; i < och3; i = i + 1){
    out3_relu[i] = 0;
  }

  /////////////////////if 0<=count_img <100, Expected result = 0/////////////////////
  /////////////////////if 700<=count_img <800, Expected result = 7/////////////////////
    if((count_img % 100) == 0){
    Expected_result = Expected_result + 1;
  }
	for (i = 0; i < ich1; i++) {
		for (m = 0; m < ochsize1; m++) {
			for (n = 0; n < ochsize1; n++) {
				for (p = 0; p < ksize; p++) {
					for (q = 0; q < ksize; q++) {
						for (j = 0; j < och1; j++) {
							out1[j][m][n] += (fmap1[count_img][i][m + p][n + q] * weight1[i][j][p][q]);
						}
					}
				}
			}
		}
	}
	for (j = 0; j < och1; j++) {
		for (m = 0; m < ochsize1; m++) {
			for (n = 0; n < ochsize1; n++) {
			}
		}
	}
	for (j = 0; j < och1; j++) {
		for (m = 0; m < ochsize1; m++) {
			for (n = 0; n < ochsize1; n++) {
				out1_relu[j][m][n] = relu(out1[j][m][n]);
			}
		}
	}
	/////////////////////  maxpooler  /////////////////////
	for (j = 0; j < och1; j++) {
		for (m = 0; m < ochsize1; m = m + 2) {
			for (n = 0; n < ochsize1; n = n + 2) {
				out1_max[j][m / 2][n / 2] = Max(out1_relu[j][m][n], out1_relu[j][m][n + 1], out1_relu[j][m + 1][n], out1_relu[j][m + 1][n + 1]);
			}
		}
	}
  for (i = 0; i < ich2; i = i + 1) {
		for (m = 0; m < ichsize2; m = m + 1) {
			for (n = 0; n < ichsize2; n = n + 1) {
        ///////////////////// truncate bit /////////////////////
        for(b = 0; b < 3; b = b + 1) {
          out1_max[i][m][n] = out1_max[i][m][n] - (out1_max[i][m][n]*0.5);
        }
        fmap2[i][m][n] = out1_max[i][m][n];
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
	for (j = 0; j < och2; j++) {
		for (m = 0; m < ochsize2; m++) {
			for (n = 0; n < ochsize2; n++) {
			}
		}
	}
	/////////////////////  relu function  /////////////////////
  for (j = 0; j < och2; j++) {
	  for (m = 0; m < ochsize2; m++) {
		  for (n = 0; n < ochsize2; n++) {
			  out2_relu[j][m][n] = relu(out2[j][m][n]);
		  }
	  }
  }
	/////////////////////  maxpooler  /////////////////////
  for (j = 0; j < och2; j++) {
	  for (m = 0; m < ochsize2; m = m + 2) {
		  for (n = 0; n < ochsize2; n = n + 2) {
			  out2_max[j][m / 2][n / 2] = Max(out2_relu[j][m][n], out2_relu[j][m][n + 1], out2_relu[j][m + 1][n], out2_relu[j][m + 1][n + 1]);
		  }
	  }
  }
  for (i = 0; i < och2; i = i + 1) {
		for (m = 0; m < ichsize3; m = m + 1) {
			for (n = 0; n < ichsize3; n = n + 1) {
        ///////////////////// truncate bit /////////////////////
        //for(b = 0; b < 3; b = b + 1) {
          //out2_max[i][m][n] = out2_max[i][m][n] - (out2_max[i][m][n]*0.5);
        //}
        fcmap[(i*ichsize3*ichsize3)+(m*ichsize3)+n] = out2_max[i][m][n];
      }
    }
  }
  for (i = 0; i < och3; i = i + 1){
    for (m = 0; m < ich3; m = m + 1) {
      out3[i] = out3[i] + (fcmap[m]*weight_fc[i][m]);
    }
    out3[i] = out3[i] + bias_fc[i];
  }
  for (i = 0; i < och3; i = i + 1){
    out3_relu[i] = relu(out3[i]);
    ///////////////////// truncate bit /////////////////////
        //for(b = 0; b < 3; b = b + 1) {
          //out3_relu[i] = out3_relu[i] - (out3_relu[i]*0.5);
        //}
  }
  Actual_result = Max_class(out3_relu[0],out3_relu[1],out3_relu[2],out3_relu[3],out3_relu[4],out3_relu[5],out3_relu[6],out3_relu[7],out3_relu[8],out3_relu[9]);
  //////////////Compare(Actual result vs SW result)//////////////
  if(Actual_result == Expected_result){
    count_match = count_match + 1;
  }
  else if(Actual_result != Expected_result){
    count_mismatch = count_mismatch + 1;
    printf("[%d]Mismatch!! Expected result = %d, Actual result = %d\n",count_img,Expected_result, Actual_result);
  }
  count_img = count_img + 1;
  }
  if((count_match + count_mismatch) != TestImage){
    printf("Error!!\n");
    printf("Count image != Number of Test image\n");
    printf("Match count = %.f, Mismatch count = %.f",count_match, count_mismatch);
  }
  else if((count_match + count_mismatch) == TestImage){
    printf("Complete All %d image test processing\n",TestImage);
    printf("Match count = %.f, Mismatch count = %.f\n",count_match, count_mismatch);
    double accuracy = (count_match/TestImage)*100;
    printf("Accuracy = %.2f%%\n",accuracy);
  }
	return 0;
}