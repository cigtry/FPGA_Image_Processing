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
// Last modified Date:     2024/05/29 15:53:08 
// Last Version:           V1.0 
// Descriptions:            
//---------------------------------------------------------------------------------------- 
// Created by:             USER_NAME
// Created date:           2024/05/29 15:53:08 
// Version:                V1.0 
// TEXT NAME:              gauss_filter.v 
// PATH:                   C:\Users\maccura\Desktop\code-main\fpga\gauss_filter\src\gauss_filter.v 
// Descriptions:            高斯模板
//                          32	38	40	38	32
//                          38	45	47	45	38
//                          40	47	50	47	40
//                          38	45	47	45	38
//                          32	38	40	38	32
//---------------------------------------------------------------------------------------- 
//****************************************************************************************// 

module gauss_filter#(
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
  wire           [DATA_WIDTH-1: 0]               matrix_p11      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p12      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p13      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p14      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p15      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p21      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p22      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p23      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p24      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p25      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p31      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p32      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p33      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p34      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p35      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p41      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p42      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p43      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p44      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p45      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p51      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p52      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p53      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p54      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p55      ;

generate_5x5_winndows#(
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
)  u_generate_5x5_winndows(
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
  .matrix_p14                                        (matrix_p14     ),
  .matrix_p15                                        (matrix_p15     ),
  .matrix_p21                                        (matrix_p21     ),
  .matrix_p22                                        (matrix_p22     ),
  .matrix_p23                                        (matrix_p23     ),
  .matrix_p24                                        (matrix_p24     ),
  .matrix_p25                                        (matrix_p25     ),
  .matrix_p31                                        (matrix_p31     ),
  .matrix_p32                                        (matrix_p32     ),
  .matrix_p33                                        (matrix_p33     ),
  .matrix_p34                                        (matrix_p34     ),
  .matrix_p35                                        (matrix_p35     ),
  .matrix_p41                                        (matrix_p41     ),
  .matrix_p42                                        (matrix_p42     ),
  .matrix_p43                                        (matrix_p43     ),
  .matrix_p44                                        (matrix_p44     ),
  .matrix_p45                                        (matrix_p45     ),
  .matrix_p51                                        (matrix_p51     ),
  .matrix_p52                                        (matrix_p52     ),
  .matrix_p53                                        (matrix_p53     ),
  .matrix_p54                                        (matrix_p54     ),
  .matrix_p55                                        (matrix_p55     ) 
);

  reg            [  13:00]                       mult_result11,mult_result12,mult_result13,mult_result14,mult_result15  ;
  reg            [  13:00]                       mult_result21,mult_result22,mult_result23,mult_result24,mult_result25  ;
  reg            [  13:00]                       mult_result31,mult_result32,mult_result33,mult_result34,mult_result35  ;
  reg            [  13:00]                       mult_result41,mult_result42,mult_result43,mult_result44,mult_result45  ;
  reg            [  13:00]                       mult_result51,mult_result52,mult_result53,mult_result54,mult_result55  ;
  always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      mult_result11<=14'h00;mult_result12<=14'h00;mult_result13<=14'h00;mult_result14<=14'h00;mult_result15<=14'h00;
      mult_result21<=14'h00;mult_result22<=14'h00;mult_result23<=14'h00;mult_result24<=14'h00;mult_result25<=14'h00;
      mult_result31<=14'h00;mult_result32<=14'h00;mult_result33<=14'h00;mult_result34<=14'h00;mult_result35<=14'h00;
      mult_result41<=14'h00;mult_result42<=14'h00;mult_result43<=14'h00;mult_result44<=14'h00;mult_result45<=14'h00;
      mult_result51<=14'h00;mult_result52<=14'h00;mult_result53<=14'h00;mult_result54<=14'h00;mult_result55<=14'h00;
    end
    else begin
      mult_result11<=matrix_p11 * 32 ;mult_result12<= matrix_p12 * 38;mult_result13<= matrix_p13 * 40;mult_result14<= matrix_p14 * 38;mult_result15<= matrix_p15 * 32;
      mult_result21<=matrix_p21 * 38 ;mult_result22<= matrix_p22 * 45;mult_result23<= matrix_p23 * 47;mult_result24<= matrix_p24 * 45;mult_result25<= matrix_p25 * 38;
      mult_result31<=matrix_p31 * 40 ;mult_result32<= matrix_p32 * 47;mult_result33<= matrix_p33 * 50;mult_result34<= matrix_p34 * 47;mult_result35<= matrix_p35 * 40;
      mult_result41<=matrix_p41 * 38 ;mult_result42<= matrix_p42 * 45;mult_result43<= matrix_p43 * 47;mult_result44<= matrix_p44 * 45;mult_result45<= matrix_p45 * 38;
      mult_result51<=matrix_p51 * 32 ;mult_result52<= matrix_p52 * 38;mult_result53<= matrix_p53 * 40;mult_result54<= matrix_p54 * 38;mult_result55<= matrix_p55 * 32;
    end
  end                                                               //always end

  reg            [  15:00]                       sum_result1,sum_result2,sum_result3,sum_result4,sum_result5  ;
  
  always @(posedge clk ) begin
    sum_result1 <= mult_result11+mult_result12+mult_result13+mult_result14+mult_result15;
    sum_result2 <= mult_result21+mult_result22+mult_result23+mult_result24+mult_result25;
    sum_result3 <= mult_result31+mult_result32+mult_result33+mult_result34+mult_result35;
    sum_result4 <= mult_result41+mult_result42+mult_result43+mult_result44+mult_result45;
    sum_result5 <= mult_result51+mult_result52+mult_result53+mult_result54+mult_result55;
  end

  reg            [  17:00]                       sum_result      ;
  always @(posedge clk ) begin
    sum_result <= sum_result1+sum_result2+sum_result3+sum_result4+sum_result5;
  end

  reg            [DATA_WIDTH-1:00]               pixle_data      ;
  always @(posedge clk ) begin
    pixle_data <= sum_result[17:10] + sum_result[9];
  end

  reg            [   3: 0]                       martix_img_hsync_d  ;
  reg            [   3: 0]                       martix_img_vsync_d  ;
  reg            [   3: 0]                       martix_img_valid_d  ;
  reg            [   3: 0]                       martix_img_edge_d  ;

  always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      martix_img_hsync_d <= 4'b0;
      martix_img_vsync_d <= 4'b0;
      martix_img_valid_d <= 4'b0;
      martix_img_edge_d  <= 4'b0;
    end
    else begin
      martix_img_hsync_d <= {martix_img_hsync_d[2:0],matrix_img_hsync};
      martix_img_vsync_d <= {martix_img_vsync_d[2:0],matrix_img_vsync};
      martix_img_valid_d <= {martix_img_valid_d[2:0],matrix_img_valid};
      martix_img_edge_d  <= {martix_img_edge_d[2:0] ,(matrix_left_edge_flag|matrix_right_edge_flag|matrix_top_edge_flag|matrix_bottom_edge_flag)};
    end
  end                                                               //always end

  reg            [DATA_WIDTH-1: 0]               matrix_data_d0  ;
  reg            [DATA_WIDTH-1: 0]               matrix_data_d1  ;
  reg            [DATA_WIDTH-1: 0]               matrix_data_d2  ;
  reg            [DATA_WIDTH-1: 0]               matrix_data_d3  ;
  always @(posedge clk)
begin
    matrix_data_d0<= matrix_p33;
    matrix_data_d1<= matrix_data_d0;
    matrix_data_d2<= matrix_data_d1;
    matrix_data_d3<= matrix_data_d2;
end

always @ (posedge clk or negedge rst_n)begin
  if(!rst_n)begin
    post_img_hsync <= 1'b0;
    post_img_vsync <= 1'b0;
    post_img_valid <= 1'b0;
  end
  else begin
    post_img_hsync <= martix_img_hsync_d[3];
    post_img_vsync <= martix_img_vsync_d[3];
    post_img_valid <= martix_img_valid_d[3];
  end
end                                                                 //always end

always @ (posedge clk or negedge rst_n)begin
  if(!rst_n)begin
    post_img_data <= 8'b0;
  end
  else begin
    if (martix_img_edge_d[3]) begin
      post_img_data <= matrix_data_d3;
    end
    else begin
      post_img_data <= pixle_data;
    end
  end
end                                                                 //always end


  
  
endmodule
