`timescale 1ns / 1ps
//****************************************VSCODE PLUG-IN**********************************// 
//---------------------------------------------------------------------------------------- 
// IDE :                   VSCODE      
// VSCODE plug-in version: Verilog-Hdl-Format-1.8.20240408
// VSCODE plug-in author : Jiang Percy 
//---------------------------------------------------------------------------------------- 
//****************************************Copyright (c)***********************************// 
// Copyright(C)            COMPANY_NAME
// All rights reserved      
// File name:               
// Last modified Date:     2024/05/31 10:31:26 
// Last Version:           V1.0 
// Descriptions:            
//---------------------------------------------------------------------------------------- 
// Created by:             USER_NAME
// Created date:           2024/05/31 10:31:26 
// Version:                V1.0 
// TEXT NAME:              bilateral_filter.v 
// PATH:                   C:\Users\maccura\Desktop\code-main\fpga\bilateral_filter\src\bilateral_filter.v 
// Descriptions:            
//                          
//---------------------------------------------------------------------------------------- 
//****************************************************************************************// 

module bilateral_filter#(
  parameter                                          DATA_WIDTH     = 8     ,
  parameter                                          H_SYNC         = 11'd40,   //行同步
  parameter                                          H_BACK         = 11'd220,  //行显示后沿
  parameter                                          H_DISP         = 11'd1280, //行有效数据
  parameter                                          H_FRONT        = 11'd110,  //行显示前沿
  parameter                                          H_TOTAL        = 11'd1650, //行扫描周期

  parameter                                          V_SYNC         = 11'd5 ,    //场同步
  parameter                                          V_BACK         = 11'd20,   //场显示后沿
  parameter                                          V_DISP         = 11'd720,  //场有效数据
  parameter                                          V_FRONT        = 11'd5 ,    //场显示前沿
  parameter                                          V_TOTAL        = 11'd750//场扫描周期
)(
  input                                          clk             ,
  input                                          rst_n           ,
  input                                          pre_img_vsync   ,
  input                                          pre_img_hsync   ,
  input                                          pre_img_valid   ,
  input          [DATA_WIDTH-1:00]               pre_img_data    ,

  output reg                                     post_img_vsync  ,
  output reg                                     post_img_hsync  ,
  output reg                                     post_img_valid  ,
  output reg     [DATA_WIDTH-1:00]               post_img_data    

);

  wire                                           matrix_img_vsync  ;
  wire                                           matrix_img_hsync  ;
  wire                                           matrix_img_valid  ;
  wire                                           matrix_top_edge_flag  ;
  wire                                           matrix_bottom_edge_flag  ;
  wire                                           matrix_left_edge_flag  ;
  wire                                           matrix_right_edge_flag  ;
  wire           [   7: 0]                       matrix_p11      ;
  wire           [   7: 0]                       matrix_p12      ;
  wire           [   7: 0]                       matrix_p13      ;
  wire           [   7: 0]                       matrix_p21      ;
  wire           [   7: 0]                       matrix_p22      ;
  wire           [   7: 0]                       matrix_p23      ;
  wire           [   7: 0]                       matrix_p31      ;
  wire           [   7: 0]                       matrix_p32      ;
  wire           [   7: 0]                       matrix_p33      ;

generate_3x3_winndows#(
  .DATA_WIDTH                                        (DATA_WIDTH     ),
  .H_SYNC                                            (H_SYNC         ),
  .H_BACK                                            (H_BACK         ),
  .H_DISP                                            (H_DISP         ),
  .H_FRONT                                           (H_FRONT        ),
  .H_TOTAL                                           (H_TOTAL        ),
  .V_SYNC                                            (V_SYNC         ),
  .V_BACK                                            (V_BACK         ),
  .V_DISP                                            (V_DISP         ),
  .V_FRONT                                           (V_FRONT        ),
  .V_TOTAL                                           (V_TOTAL        ) 
)   u_generate_3x3_winndows(
  .clk                                               (clk            ),
  .rst_n                                             (rst_n          ),
  .pre_img_vsync                                     (pre_img_vsync  ),
  .pre_img_hsync                                     (pre_img_hsync  ),
  .pre_img_valid                                     (pre_img_valid  ),
  .pre_img_data                                      (pre_img_data   ),
    //  Image data has been processed
  .matrix_img_vsync                                  (matrix_img_vsync),
  .matrix_img_hsync                                  (matrix_img_hsync),
  .matrix_img_valid                                  (matrix_img_valid),
  .matrix_top_edge_flag                              (matrix_top_edge_flag),
  .matrix_bottom_edge_flag                           (matrix_bottom_edge_flag),
  .matrix_left_edge_flag                             (matrix_left_edge_flag),
  .matrix_right_edge_flag                            (matrix_right_edge_flag),
  .matrix_p11                                        (matrix_p11     ),
  .matrix_p12                                        (matrix_p12     ),
  .matrix_p13                                        (matrix_p13     ),
  .matrix_p21                                        (matrix_p21     ),
  .matrix_p22                                        (matrix_p22     ),
  .matrix_p23                                        (matrix_p23     ),
  .matrix_p31                                        (matrix_p31     ),
  .matrix_p32                                        (matrix_p32     ),
  .matrix_p33                                        (matrix_p33     ) 
);

//计算滑窗中心周围同中心的绝对差值，利用查找表的方式映射出对应的相似度模板
  reg            [DATA_WIDTH-1:00]               p11_minus_p22_abs  ;
  reg            [DATA_WIDTH-1:00]               p12_minus_p22_abs  ;
  reg            [DATA_WIDTH-1:00]               p13_minus_p22_abs  ;
  reg            [DATA_WIDTH-1:00]               p21_minus_p22_abs  ;
  reg            [DATA_WIDTH-1:00]               p22_minus_p22_abs  ;
  reg            [DATA_WIDTH-1:00]               p23_minus_p22_abs  ;
  reg            [DATA_WIDTH-1:00]               p31_minus_p22_abs  ;
  reg            [DATA_WIDTH-1:00]               p32_minus_p22_abs  ;
  reg            [DATA_WIDTH-1:00]               p33_minus_p22_abs  ;

  always @(posedge clk ) begin
    if(matrix_p11 > matrix_p22) begin
      p11_minus_p22_abs <= matrix_p11 - matrix_p22;
    end
    else begin
      p11_minus_p22_abs <= matrix_p22 - matrix_p11;
    end
  end

  always @(posedge clk ) begin
    if(matrix_p12 > matrix_p22) begin
      p12_minus_p22_abs <= matrix_p12 - matrix_p22;
    end
    else begin
      p12_minus_p22_abs <= matrix_p22 - matrix_p12;
    end
  end

  always @(posedge clk ) begin
    if(matrix_p13 > matrix_p22) begin
      p13_minus_p22_abs <= matrix_p13 - matrix_p22;
    end
    else begin
      p13_minus_p22_abs <= matrix_p22 - matrix_p13;
    end
  end

  always @(posedge clk ) begin
    if(matrix_p21 > matrix_p22) begin
      p21_minus_p22_abs <= matrix_p21 - matrix_p22;
    end
    else begin
      p21_minus_p22_abs <= matrix_p22 - matrix_p21;
    end
  end

  always @(posedge clk ) begin
    p22_minus_p22_abs <= 8'h00;
  end

  always @(posedge clk ) begin
    if(matrix_p23 > matrix_p22) begin
      p23_minus_p22_abs <= matrix_p23 - matrix_p22;
    end
    else begin
      p23_minus_p22_abs <= matrix_p22 - matrix_p23;
    end
  end
  
  always @(posedge clk ) begin
    if(matrix_p31 > matrix_p22) begin
      p31_minus_p22_abs <= matrix_p31 - matrix_p22;
    end
    else begin
      p31_minus_p22_abs <= matrix_p22 - matrix_p31;
    end
  end

  always @(posedge clk ) begin
    if(matrix_p32 > matrix_p22) begin
      p32_minus_p22_abs <= matrix_p32 - matrix_p22;
    end
    else begin
      p32_minus_p22_abs <= matrix_p22 - matrix_p32;
    end
  end

  always @(posedge clk ) begin
    if(matrix_p33 > matrix_p22) begin
      p33_minus_p22_abs <= matrix_p33 - matrix_p22;
    end
    else begin
      p33_minus_p22_abs <= matrix_p22 - matrix_p33;
    end
  end

  wire           [  09:00]                       similary_p11_p22  ;
  wire           [  09:00]                       similary_p12_p22  ;
  wire           [  09:00]                       similary_p13_p22  ;
  wire           [  09:00]                       similary_p21_p22  ;
  wire           [  09:00]                       similary_p22_p22  ;
  wire           [  09:00]                       similary_p23_p22  ;
  wire           [  09:00]                       similary_p31_p22  ;
  wire           [  09:00]                       similary_p32_p22  ;
  wire           [  09:00]                       similary_p33_p22  ;



Similary_LUT p11_p22 (
  .Pre_Data                                          (p11_minus_p22_abs),
  .Post_Data                                         (similary_p11_p22) 
);

Similary_LUT p12_p22 (
  .Pre_Data                                          (p12_minus_p22_abs),
  .Post_Data                                         (similary_p12_p22) 
);
Similary_LUT p13_p22 (
  .Pre_Data                                          (p13_minus_p22_abs),
  .Post_Data                                         (similary_p13_p22) 
);
Similary_LUT p21_p22 (
  .Pre_Data                                          (p21_minus_p22_abs),
  .Post_Data                                         (similary_p21_p22) 
);
Similary_LUT p22_p22 (
  .Pre_Data                                          (p22_minus_p22_abs),
  .Post_Data                                         (similary_p22_p22) 
);
Similary_LUT p23_p22 (
  .Pre_Data                                          (p23_minus_p22_abs),
  .Post_Data                                         (similary_p23_p22) 
);
Similary_LUT p31_p22 (
  .Pre_Data                                          (p31_minus_p22_abs),
  .Post_Data                                         (similary_p31_p22) 
);
Similary_LUT p32_p22 (
  .Pre_Data                                          (p32_minus_p22_abs),
  .Post_Data                                         (similary_p32_p22) 
);
Similary_LUT p33_p22 (
  .Pre_Data                                          (p33_minus_p22_abs),
  .Post_Data                                         (similary_p33_p22) 
);

//高斯模板 * 相似度模板得到双边滤波权重 
//----------------------------------------------------------------------
//      [g11,g12,g13]   [109,115,109]
//  g = [g21,g22,g23] = [115,122,115]
//      [g31,g32,g33]   [109,115,109]
  localparam                                         g11            = 7'd109;
  localparam                                         g12            = 7'd115;
  localparam                                         g13            = 7'd109;
  localparam                                         g21            = 7'd115;
  localparam                                         g22            = 7'd122;
  localparam                                         g23            = 7'd115;
  localparam                                         g31            = 7'd109;
  localparam                                         g32            = 7'd115;
  localparam                                         g33            = 7'd109;

  reg            [  16: 0]                       s11_mult_g11    ;
  reg            [  16: 0]                       s12_mult_g21    ;
  reg            [  16: 0]                       s13_mult_g31    ;
  reg            [  16: 0]                       s11_mult_g12    ;
  reg            [  16: 0]                       s12_mult_g22    ;
  reg            [  16: 0]                       s13_mult_g32    ;
  reg            [  16: 0]                       s11_mult_g13    ;
  reg            [  16: 0]                       s12_mult_g23    ;
  reg            [  16: 0]                       s13_mult_g33    ;
  reg            [  16: 0]                       s21_mult_g11    ;
  reg            [  16: 0]                       s22_mult_g21    ;
  reg            [  16: 0]                       s23_mult_g31    ;
  reg            [  16: 0]                       s21_mult_g12    ;
  reg            [  16: 0]                       s22_mult_g22    ;
  reg            [  16: 0]                       s23_mult_g32    ;
  reg            [  16: 0]                       s21_mult_g13    ;
  reg            [  16: 0]                       s22_mult_g23    ;
  reg            [  16: 0]                       s23_mult_g33    ;
  reg            [  16: 0]                       s31_mult_g11    ;
  reg            [  16: 0]                       s32_mult_g21    ;
  reg            [  16: 0]                       s33_mult_g31    ;
  reg            [  16: 0]                       s31_mult_g12    ;
  reg            [  16: 0]                       s32_mult_g22    ;
  reg            [  16: 0]                       s33_mult_g32    ;
  reg            [  16: 0]                       s31_mult_g13    ;
  reg            [  16: 0]                       s32_mult_g23    ;
  reg            [  16: 0]                       s33_mult_g33    ;

always @(posedge clk)
begin
    s11_mult_g11 <= similary_p11_p22 * g11;
    s12_mult_g21 <= similary_p12_p22 * g21;
    s13_mult_g31 <= similary_p13_p22 * g31;
    s11_mult_g12 <= similary_p11_p22 * g12;
    s12_mult_g22 <= similary_p12_p22 * g22;
    s13_mult_g32 <= similary_p13_p22 * g32;
    s11_mult_g13 <= similary_p11_p22 * g13;
    s12_mult_g23 <= similary_p12_p22 * g23;
    s13_mult_g33 <= similary_p13_p22 * g33;
    s21_mult_g11 <= similary_p21_p22 * g11;
    s22_mult_g21 <= similary_p22_p22 * g21;
    s23_mult_g31 <= similary_p23_p22 * g31;
    s21_mult_g12 <= similary_p21_p22 * g12;
    s22_mult_g22 <= similary_p22_p22 * g22;
    s23_mult_g32 <= similary_p23_p22 * g32;
    s21_mult_g13 <= similary_p21_p22 * g13;
    s22_mult_g23 <= similary_p22_p22 * g23;
    s23_mult_g33 <= similary_p23_p22 * g33;
    s31_mult_g11 <= similary_p31_p22 * g11;
    s32_mult_g21 <= similary_p32_p22 * g21;
    s33_mult_g31 <= similary_p33_p22 * g31;
    s31_mult_g12 <= similary_p31_p22 * g12;
    s32_mult_g22 <= similary_p32_p22 * g22;
    s33_mult_g32 <= similary_p33_p22 * g32;
    s31_mult_g13 <= similary_p31_p22 * g13;
    s32_mult_g23 <= similary_p32_p22 * g23;
    s33_mult_g33 <= similary_p33_p22 * g33;
end
//矩阵乘法 c[i][j] = sum(A[I][K] * B[K][I]) for  k = 1  -- n
//----------------------------------------------------------------------
  reg            [  18: 0]                       weight11        ;
  reg            [  18: 0]                       weight12        ;
  reg            [  18: 0]                       weight13        ;
  reg            [  18: 0]                       weight21        ;
  reg            [  18: 0]                       weight22        ;
  reg            [  18: 0]                       weight23        ;
  reg            [  18: 0]                       weight31        ;
  reg            [  18: 0]                       weight32        ;
  reg            [  18: 0]                       weight33        ;

always @(posedge clk)
begin
    weight11 <= s11_mult_g11 + s12_mult_g21 + s13_mult_g31;
    weight12 <= s11_mult_g12 + s12_mult_g22 + s13_mult_g32;
    weight13 <= s11_mult_g13 + s12_mult_g23 + s13_mult_g33;
    weight21 <= s21_mult_g11 + s22_mult_g21 + s23_mult_g31;
    weight22 <= s21_mult_g12 + s22_mult_g22 + s23_mult_g32;
    weight23 <= s21_mult_g13 + s22_mult_g23 + s23_mult_g33;
    weight31 <= s31_mult_g11 + s32_mult_g21 + s33_mult_g31;
    weight32 <= s31_mult_g12 + s32_mult_g22 + s33_mult_g32;
    weight33 <= s31_mult_g13 + s32_mult_g23 + s33_mult_g33;
end

//双边滤波权重归一化处理
  reg            [  20:00]                       weight_sum_tmp1  ;
  reg            [  20:00]                       weight_sum_tmp2  ;
  reg            [  20:00]                       weight_sum_tmp3  ;
  reg            [  22:00]                       weight_sum      ;

always @(posedge clk ) begin
  weight_sum_tmp1 <= weight11 + weight12+weight13;
  weight_sum_tmp2 <= weight21 + weight22+weight23;
  weight_sum_tmp3 <= weight31 + weight32+weight33;
  weight_sum <= weight_sum_tmp1 +weight_sum_tmp2 +weight_sum_tmp3;
end

  reg            [  18: 0]                       weight11_d1     ;
  reg            [  18: 0]                       weight12_d1     ;
  reg            [  18: 0]                       weight13_d1     ;
  reg            [  18: 0]                       weight21_d1     ;
  reg            [  18: 0]                       weight22_d1     ;
  reg            [  18: 0]                       weight23_d1     ;
  reg            [  18: 0]                       weight31_d1     ;
  reg            [  18: 0]                       weight32_d1     ;
  reg            [  18: 0]                       weight33_d1     ;
  reg            [  18: 0]                       weight11_d2     ;
  reg            [  18: 0]                       weight12_d2     ;
  reg            [  18: 0]                       weight13_d2     ;
  reg            [  18: 0]                       weight21_d2     ;
  reg            [  18: 0]                       weight22_d2     ;
  reg            [  18: 0]                       weight23_d2     ;
  reg            [  18: 0]                       weight31_d2     ;
  reg            [  18: 0]                       weight32_d2     ;
  reg            [  18: 0]                       weight33_d2     ;

always @(posedge clk ) begin
  weight11_d1 <= weight11;
  weight12_d1 <= weight12;
  weight13_d1 <= weight13;
  weight21_d1 <= weight21;
  weight22_d1 <= weight22;
  weight23_d1 <= weight23;
  weight31_d1 <= weight31;
  weight32_d1 <= weight32;
  weight33_d1 <= weight33;
  weight11_d2 <= weight11_d1;
  weight12_d2 <= weight12_d1;
  weight13_d2 <= weight13_d1;
  weight21_d2 <= weight21_d1;
  weight22_d2 <= weight22_d1;
  weight23_d2 <= weight23_d1;
  weight31_d2 <= weight31_d1;
  weight32_d2 <= weight32_d1;
  weight33_d2 <= weight33_d1;

end


  reg            [   9: 0]                       norm_weight11   ;
  reg            [   9: 0]                       norm_weight12   ;
  reg            [   9: 0]                       norm_weight13   ;
  reg            [   9: 0]                       norm_weight21   ;
  reg            [   9: 0]                       norm_weight22   ;
  reg            [   9: 0]                       norm_weight23   ;
  reg            [   9: 0]                       norm_weight31   ;
  reg            [   9: 0]                       norm_weight32   ;
  reg            [   9: 0]                       norm_weight33   ;

always @(posedge clk ) begin
  norm_weight11 <= {weight11_d2,10'b0} / weight_sum;
  norm_weight12 <= {weight12_d2,10'b0} / weight_sum;
  norm_weight13 <= {weight13_d2,10'b0} / weight_sum;
  norm_weight21 <= {weight21_d2,10'b0} / weight_sum;
  norm_weight22 <= {weight22_d2,10'b0} / weight_sum;
  norm_weight23 <= {weight23_d2,10'b0} / weight_sum;
  norm_weight31 <= {weight31_d2,10'b0} / weight_sum;
  norm_weight32 <= {weight32_d2,10'b0} / weight_sum;
  norm_weight33 <= {weight33_d2,10'b0} / weight_sum;
end


//窗口输出延迟6个时钟周期 因为前面生成双边滤波权重需要6个时钟周期



  localparam                                         C_CLK_LATENCY  = 6     ;
  reg            [DATA_WIDTH-1: 0]               matrix_p11_d        [C_CLK_LATENCY - 1 :0]  ;
  reg            [DATA_WIDTH-1: 0]               matrix_p12_d        [C_CLK_LATENCY - 1 :0]  ;
  reg            [DATA_WIDTH-1: 0]               matrix_p13_d        [C_CLK_LATENCY - 1 :0]  ;
  reg            [DATA_WIDTH-1: 0]               matrix_p21_d        [C_CLK_LATENCY - 1 :0]  ;
  reg            [DATA_WIDTH-1: 0]               matrix_p22_d        [C_CLK_LATENCY - 1 :0]  ;
  reg            [DATA_WIDTH-1: 0]               matrix_p23_d        [C_CLK_LATENCY - 1 :0]  ;
  reg            [DATA_WIDTH-1: 0]               matrix_p31_d        [C_CLK_LATENCY - 1 :0]  ;
  reg            [DATA_WIDTH-1: 0]               matrix_p32_d        [C_CLK_LATENCY - 1 :0]  ;
  reg            [DATA_WIDTH-1: 0]               matrix_p33_d        [C_CLK_LATENCY - 1 :0]  ;
genvar i;
generate
  for(i = 0; i < C_CLK_LATENCY-1; i = i + 1)begin : martix_delay_6
    always @(posedge clk)begin
        matrix_p11_d[i+1] <= matrix_p11_d[i];
        matrix_p21_d[i+1] <= matrix_p21_d[i];
        matrix_p31_d[i+1] <= matrix_p31_d[i];
        matrix_p12_d[i+1] <= matrix_p12_d[i];
        matrix_p22_d[i+1] <= matrix_p22_d[i];
        matrix_p32_d[i+1] <= matrix_p32_d[i];
        matrix_p13_d[i+1] <= matrix_p13_d[i];
        matrix_p23_d[i+1] <= matrix_p23_d[i];
        matrix_p33_d[i+1] <= matrix_p33_d[i];

        matrix_p11_d[0] <= matrix_p11;
        matrix_p21_d[0] <= matrix_p21;
        matrix_p31_d[0] <= matrix_p31;
        matrix_p12_d[0] <= matrix_p12;
        matrix_p22_d[0] <= matrix_p22;
        matrix_p32_d[0] <= matrix_p32;
        matrix_p13_d[0] <= matrix_p13;
        matrix_p23_d[0] <= matrix_p23;
        matrix_p33_d[0] <= matrix_p33;
    end
  end
endgenerate


//计算窗口和权重的卷积
  reg            [  17: 0]                       mult_p11_w11    ;
  reg            [  17: 0]                       mult_p21_w21    ;
  reg            [  17: 0]                       mult_p31_w31    ;
  reg            [  17: 0]                       mult_p12_w12    ;
  reg            [  17: 0]                       mult_p22_w22    ;
  reg            [  17: 0]                       mult_p32_w32    ;
  reg            [  17: 0]                       mult_p13_w13    ;
  reg            [  17: 0]                       mult_p23_w23    ;
  reg            [  17: 0]                       mult_p33_w33    ;

always @(posedge clk ) begin
  mult_p11_w11 <= matrix_p11_d[5] * norm_weight11;
  mult_p21_w21 <= matrix_p21_d[5] * norm_weight21;
  mult_p31_w31 <= matrix_p31_d[5] * norm_weight31;

  mult_p12_w12 <= matrix_p12_d[5] * norm_weight12;
  mult_p22_w22 <= matrix_p22_d[5] * norm_weight22;
  mult_p32_w32 <= matrix_p32_d[5] * norm_weight32;

  mult_p13_w13 <= matrix_p13_d[5] * norm_weight13;
  mult_p23_w23 <= matrix_p23_d[5] * norm_weight23;
  mult_p33_w33 <= matrix_p33_d[5] * norm_weight33;
end

//----------------------------------------------------------------------
  reg            [  17: 0]                       sum_result_tmp1  ;
  reg            [  17: 0]                       sum_result_tmp2  ;
  reg            [  17: 0]                       sum_result_tmp3  ;
  reg            [  17: 0]                       sum_result      ;

always @(posedge clk)
begin
    sum_result_tmp1 <= mult_p11_w11 + mult_p21_w21 + mult_p31_w31;
    sum_result_tmp2 <= mult_p12_w12 + mult_p22_w22 + mult_p32_w32;
    sum_result_tmp3 <= mult_p13_w13 + mult_p23_w23 + mult_p33_w33;
    sum_result      <= sum_result_tmp1 + sum_result_tmp2 + sum_result_tmp3;
end
//将窗口中间值再延迟3拍
  reg            [DATA_WIDTH-1: 0]               matrix_p22_d1       [2 :0]  ;
genvar j;
generate
  for(j = 0; j < 3-1; j = j + 1)begin : martix_delay_9
    always @(posedge clk)begin
          matrix_p22_d1[j+1] <= matrix_p22_d1[j];
          matrix_p22_d1[0] <= matrix_p22_d[C_CLK_LATENCY - 1 ];
    end
  end
endgenerate

  reg            [ 9-1:00]                       matrix_img_vsync_d  ;
  reg            [ 9-1:00]                       matrix_img_hsync_d  ;
  reg            [ 9-1:00]                       matrix_img_valid_d  ;
  reg            [ 9-1:00]                       matrix_img_edge_flag  ;

always @ (posedge clk or negedge rst_n)begin
  if(!rst_n)begin
    matrix_img_vsync_d    <= 9'b0;
    matrix_img_hsync_d    <= 9'b0;
    matrix_img_valid_d    <= 9'b0;
    matrix_img_edge_flag  <= 9'b0;
  end
  else begin
    matrix_img_vsync_d    <=  { matrix_img_vsync_d[8:0], matrix_img_vsync };
    matrix_img_hsync_d    <=  { matrix_img_hsync_d[8:0], matrix_img_hsync };
    matrix_img_valid_d    <=  { matrix_img_valid_d[8:0], matrix_img_valid };
    matrix_img_edge_flag  <=  { matrix_img_edge_flag[8:0], (matrix_top_edge_flag | matrix_bottom_edge_flag | matrix_left_edge_flag | matrix_right_edge_flag) };
  end
end                                                                 //always end

always @(posedge clk ) begin
  post_img_vsync   <= matrix_img_vsync_d[8];
  post_img_hsync   <= matrix_img_hsync_d[8];
  post_img_valid   <= matrix_img_valid_d[8];

end

always @(posedge clk ) begin
  if (matrix_img_edge_flag) begin
    post_img_data <= matrix_p22_d1[2];
  end
  else begin
    post_img_data <= sum_result[17:10] + sum_result[9];
  end
end

endmodule
