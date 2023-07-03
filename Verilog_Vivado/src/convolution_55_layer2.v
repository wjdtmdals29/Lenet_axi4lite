/*******************************************************************************
#Author: Seungmin.Jeong(Graduated from Kwangwoon University, Seoul, Korea 2023.02)
#Purpose: verilog code / 55 convolution filter
#Revision History: 2023.07.03
*******************************************************************************/
`timescale 1ns / 1ps
module convolution_55_layer2 #(parameter I_BW = 8, O_CONV_BW = 20, O_BW = 16, I_SIZE = 28, K_SIZE = 5, W_BW = 8, CI = 1, CO = 4)
  (
  clk, ce, global_rst_n, rst, self_rst, user_reset,
  i_fmap, i_weight,
  o_conv_result,
  o_conv_valid, o_conv_end, o_conv_all_end
  );

`include "clog2_function.vh"
localparam s = 1;
localparam cnt_channel_width = clog2(CO);

input                                        clk, ce, global_rst_n,rst, self_rst, user_reset;
input signed      [I_BW-1:0]                 i_fmap;
input signed      [CO*(K_SIZE*K_SIZE)*W_BW-1:0] i_weight;
output signed     [O_CONV_BW-1:0]            o_conv_result;
output                                       o_conv_valid;
output                                       o_conv_end;
output                                       o_conv_all_end;

reg [O_BW-1:0] r_count, r_count2, r_count3;
reg            r_en1,r_en2,r_en3;

wire signed [O_CONV_BW-1:0] w_tmp [K_SIZE*K_SIZE+1:0];
wire signed [W_BW-1:0] w_weight [0:K_SIZE*K_SIZE-1];
wire signed [O_CONV_BW-1:0] w_conv_result;
wire signed w_conv_end;
wire signed w_conv_valid;

reg [cnt_channel_width:0] r_co_cnt;
reg signed [W_BW-1:0] r_weight [0:K_SIZE*K_SIZE-1];
integer k;
always@(*) begin
  for(k=0;k<K_SIZE*K_SIZE;k=k+1)begin
  r_weight[k][W_BW-1:0] = i_weight[(r_co_cnt*K_SIZE*K_SIZE*W_BW)+W_BW*k +: W_BW]; 		
  end
end


reg r_ce[0:K_SIZE*K_SIZE-1];

assign w_tmp[0] = 0;
integer c;
always@(posedge clk or negedge global_rst_n) begin
  if(!global_rst_n) begin
    for(c=0;c<=K_SIZE*K_SIZE-1;c=c+1) begin
      r_ce[c] <= 1'b0;
    end
  end
  else if(rst||self_rst||user_reset) begin
    for(c=0;c<=K_SIZE*K_SIZE-1;c=c+1) begin
      r_ce[c] <= 1'b0;
    end
  end
  else begin
    for(c=0;c<=K_SIZE*K_SIZE-2;c=c+1) begin
      r_ce[c+1] <= r_ce[c];
    end
    r_ce[0] <= ce;
  end
end


generate
genvar i;
  for(i = 0;i<K_SIZE*K_SIZE;i=i+1)
  begin: MAC
    if((i+1)%K_SIZE == 0)                       
    begin
      if(i==K_SIZE*K_SIZE-1)                       
      begin 
      mac #(.I_BW(I_BW),.W_BW(W_BW),.O_CONV_BW(O_CONV_BW)) u_mac(     
        .clk(clk),                      
        .ce(r_ce[i]),                         
        .global_rst_n(global_rst_n),
        .rst(rst||self_rst||user_reset),             
        .i_data1(i_fmap),                 
        .i_data2(r_weight[i]),                   
        .i_data_before(w_tmp[i]),                    
        .o_data(w_conv_result)                      
        );
      end
      else
      begin
      wire signed [O_CONV_BW-1:0] w_tmp2;
      mac #(.I_BW(I_BW),.W_BW(W_BW),.O_CONV_BW(O_CONV_BW)) u_mac(                   
        .clk(clk),                      
        .ce(r_ce[i]),                         
        .global_rst_n(global_rst_n),
        .rst(rst||self_rst||user_reset),                 
        .i_data1(i_fmap),                 
        .i_data2(r_weight[i]),                   
        .i_data_before(w_tmp[i]),                    
        .o_data(w_tmp2)    
        );
      
      variable_shift_reg #(.WIDTH(O_CONV_BW),.SIZE(I_SIZE-K_SIZE)) u_SR (
          .clk(clk),                
          .ce(ce),               
          .global_rst_n(global_rst_n),
          .rst(rst||self_rst||user_reset),   
          .i_data(w_tmp2),           
          .o_data(w_tmp[i+1])             
          );
      end
    end
    else
    begin
    
   mac #(.I_BW(I_BW),.W_BW(W_BW),.O_CONV_BW(O_CONV_BW)) u_mac2(                    
      .clk(clk),                      
      .ce(r_ce[i]),                         
      .global_rst_n(global_rst_n),
      .rst(rst||self_rst||user_reset),               
      .i_data1(i_fmap),                 
      .i_data2(r_weight[i]),                   
      .i_data_before(w_tmp[i]),                    
      .o_data(w_tmp[i+1])    
      );
    end 
  end 
endgenerate


reg r_conv_end;
reg r_conv_valid;

always@(posedge clk or negedge global_rst_n) begin
  if(self_rst)begin
    r_co_cnt <= r_co_cnt+1;
  end
  else if(user_reset) begin
    r_co_cnt <= {(cnt_channel_width+1){1'b0}};
  end
  else if(!global_rst_n) begin
    r_co_cnt <= {(cnt_channel_width+1){1'b0}};
  end
end

always@(posedge clk or negedge global_rst_n) 
begin
  r_conv_end <= w_conv_end;
  r_conv_valid <= w_conv_valid;

  if(!global_rst_n)
  begin
    r_count <=1'b0;                      
    r_count2<=1'b0;                      
    r_count3<=1'b0;                       
    r_en1<=1'b0;
    r_en2<=1'b1;
    r_en3<=1'b0;
    r_conv_end <= 1'b0;
    r_conv_valid <= 1'b0;
  end
  else if (rst||user_reset) begin
    r_count <=1'b0;                     
    r_count2<=1'b0;                      
    r_count3<=1'b0;                        
    r_en1<=1'b0;
    r_en2<=1'b1;
    r_en3<=1'b0;
    r_conv_end <= 1'b0;
    r_conv_valid <= 1'b0;
  end
  else begin
    if(ce)
    begin
    if(r_count == (K_SIZE-1)*I_SIZE+K_SIZE-1)       
    begin
      r_en1 <= 1'b1;
      r_count <= r_count+1'b1;
    end
    else
    begin 
      r_count<= r_count+1'b1;
    end
  end
  if(r_en1 && r_en2) 
  begin
    if(r_count2 == I_SIZE-K_SIZE)
    begin
      r_count2 <= 1'b0;
      r_en2 <= 1'b0;
    end
    else 
    begin
      r_count2 <= r_count2 + 1'b1;
    end
  end
  
  if(~r_en2) 
  begin
  if(r_count3 == K_SIZE-2)
  begin
    r_count3 <= 1'b0;
    r_en2 <= 1'b1;
  end
  else
    r_count3 <= r_count3 + 1'b1;
  end
  if(((r_count2 + 1) % s == 0)||(r_count3 == K_SIZE-2)||(r_count == (K_SIZE-1)*I_SIZE+K_SIZE-1))
  begin                                                                                                                        
    r_en3 <= 1'b1;                                                                                                                             
  end
  else 
    r_en3 <= 1'b0;
end
end
  assign o_conv_result = w_conv_result;
  assign w_conv_end = (r_count >= I_SIZE*I_SIZE+2) ? 1'b1 : 1'b0;
	assign w_conv_valid = (r_en1&&r_en2&&r_en3)&&(~o_conv_end);

  assign o_conv_all_end    = (r_co_cnt == CO)   ? 1'b1 : 1'b0;
  assign o_conv_valid = r_conv_valid;
  assign o_conv_end   = r_conv_end;
endmodule