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
// Last modified Date:     2024/05/28 17:10:22 
// Last Version:           V1.0 
// Descriptions:            
//---------------------------------------------------------------------------------------- 
// Created by:             USER_NAME
// Created date:           2024/05/28 17:10:22 
// Version:                V1.0 
// TEXT NAME:              med_filter.v 
// PATH:                   C:\Users\maccura\Desktop\code-main\fpga\med_filter\src\med_filter.v 
// Descriptions:            
//                          
//---------------------------------------------------------------------------------------- 
//****************************************************************************************// 

module med_filter#(
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

  output wire                                    post_img_vsync  ,
  output wire                                    post_img_hsync  ,
  output wire                                    post_img_valid  ,
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
  wire           [DATA_WIDTH-1: 0]               matrix_p21      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p22      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p23      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p31      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p32      ;
  wire           [DATA_WIDTH-1: 0]               matrix_p33      ;

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
)  u_generate_3x3_winndows(
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

  //Logic Description
  //分别求第一行的最大值，中间值 ，最小值
  reg            [DATA_WIDTH-1: 0]               row1_max_data,row1_med_data,row1_min_data  ;

  always @(posedge clk ) begin
    if((matrix_p11>=matrix_p12)&&(matrix_p11>=matrix_p13))
      row1_max_data <= matrix_p11;
    else if((matrix_p12>=matrix_p11)&&(matrix_p12>=matrix_p13))
      row1_max_data <= matrix_p12;
    else
      row1_max_data <= matrix_p13;
  end

  always @(posedge clk ) begin
    if(((matrix_p11<=matrix_p12)&&(matrix_p11>=matrix_p13))  ||  ((matrix_p11>=matrix_p12)&&(matrix_p11<=matrix_p13)))
      row1_med_data<=matrix_p11;
    else if(((matrix_p12<=matrix_p11)&&(matrix_p12>=matrix_p13))  ||  ((matrix_p12>=matrix_p11)&&(matrix_p12<=matrix_p13)))
      row1_med_data<=matrix_p12;
    else
      row1_med_data<=matrix_p13;
  end

  always @(posedge clk ) begin
    if((matrix_p11<=matrix_p12)&&(matrix_p11<=matrix_p13))
      row1_min_data <= matrix_p11;
    else if((matrix_p12<=matrix_p11)&&(matrix_p12<=matrix_p13))
      row1_min_data <= matrix_p12;
    else
      row1_min_data <= matrix_p13;
  end
//分别求第二行的最大值，中间值 ，最小值
  reg            [DATA_WIDTH-1: 0]               row2_max_data,row2_med_data,row2_min_data  ;

  always @(posedge clk ) begin
    if((matrix_p21>=matrix_p22)&&(matrix_p21>=matrix_p23))
      row2_max_data <= matrix_p21;
    else if((matrix_p22>=matrix_p21)&&(matrix_p22>=matrix_p23))
      row2_max_data <= matrix_p22;
    else
      row2_max_data <= matrix_p23;
  end

  always @(posedge clk ) begin
    if(((matrix_p21<=matrix_p22)&&(matrix_p21>=matrix_p23))  ||  ((matrix_p21>=matrix_p22)&&(matrix_p21<=matrix_p23)))
      row2_med_data<=matrix_p21;
    else if(((matrix_p22<=matrix_p21)&&(matrix_p22>=matrix_p23))  ||  ((matrix_p22>=matrix_p21)&&(matrix_p22<=matrix_p23)))
      row2_med_data<=matrix_p22;
    else
      row2_med_data<=matrix_p23;
  end

  always @(posedge clk ) begin
    if((matrix_p21<=matrix_p22)&&(matrix_p21<=matrix_p23))
      row2_min_data <= matrix_p21;
    else if((matrix_p22<=matrix_p21)&&(matrix_p22<=matrix_p23))
      row2_min_data <= matrix_p22;
    else
      row2_min_data <= matrix_p23;
  end
//分别求第三行的最大值，中间值 ，最小值
  reg            [DATA_WIDTH-1: 0]               row3_max_data,row3_med_data,row3_min_data  ;

  always @(posedge clk ) begin
    if((matrix_p31>=matrix_p32)&&(matrix_p31>=matrix_p33))
      row3_max_data <= matrix_p31;
    else if((matrix_p32>=matrix_p31)&&(matrix_p32>=matrix_p33))
      row3_max_data <= matrix_p32;
    else
      row3_max_data <= matrix_p33;
  end

  always @(posedge clk ) begin
    if(((matrix_p31<=matrix_p32)&&(matrix_p31>=matrix_p33))  ||  ((matrix_p31>=matrix_p32)&&(matrix_p31<=matrix_p33)))
      row3_med_data<=matrix_p31;
    else if(((matrix_p32<=matrix_p31)&&(matrix_p32>=matrix_p33))  ||  ((matrix_p32>=matrix_p31)&&(matrix_p32<=matrix_p33)))
      row3_med_data<=matrix_p32;
    else
      row3_med_data<=matrix_p33;
  end

  always @(posedge clk ) begin
    if((matrix_p31<=matrix_p32)&&(matrix_p31<=matrix_p33))
      row3_min_data <= matrix_p31;
    else if((matrix_p32<=matrix_p31)&&(matrix_p32<=matrix_p33))
      row3_min_data <= matrix_p32;
    else
      row3_min_data <= matrix_p33;
  end
//分别求3个最大值里的最小值，3个中间值里的中间值，3个最小值里的最大值
  reg            [DATA_WIDTH-1: 0]               min_of_max_data,med_of_med_data,max_of_min_data  ;

  always @(posedge clk ) begin
    if((row1_min_data>=row2_min_data)&&(row1_min_data>=row3_min_data))
      max_of_min_data <= row1_min_data;
    else if((row2_min_data>=row1_min_data)&&(row2_min_data>=row3_min_data))
      max_of_min_data <= row2_min_data;
    else
      max_of_min_data <= row3_min_data;
  end

  always @(posedge clk) begin
    if(((row1_med_data>=row2_med_data)&&(row1_med_data<=row3_med_data)) || ((row1_med_data<=row2_med_data)&&(row1_med_data>=row3_med_data)))
      med_of_med_data <= row1_med_data;
    else if(((row2_med_data>=row1_med_data)&&(row2_med_data<=row3_med_data)) || ((row2_med_data<=row1_med_data)&&(row2_med_data>=row3_med_data)))
      med_of_med_data <= row2_med_data;
    else
      med_of_med_data <= row3_med_data;
  end

  always @(posedge clk ) begin
    if((row1_max_data<=row2_max_data)&&(row1_max_data<=row3_max_data))
      min_of_max_data <= row1_max_data;
    else if((row2_max_data<=row1_max_data)&&(row2_max_data<=row3_max_data))
      min_of_max_data <= row2_max_data;
    else
      min_of_max_data <= row3_max_data;
  end
  //求中间值
  reg            [DATA_WIDTH-1: 0]               median_data     ;

  always @(posedge clk) begin
    if(((min_of_max_data>=max_of_min_data)&&(min_of_max_data<=med_of_med_data)) || ((min_of_max_data<=max_of_min_data)&&(min_of_max_data>=med_of_med_data)))
      median_data <= min_of_max_data;
    else if(((max_of_min_data >=min_of_max_data)&&(max_of_min_data<=med_of_med_data)) || ((max_of_min_data<=min_of_max_data)&&(max_of_min_data>=med_of_med_data)))
      median_data <= max_of_min_data;
    else
      median_data <= med_of_med_data;
  end
  //延时4拍输出
  reg            [   2: 0]                       img_left_r,img_right_r,img_top_r,img_bottom_r  ;
  reg            [   3: 0]                       post_img_hsync_r,post_img_vsync_r,post_img_valid_r  ;
  reg            [DATA_WIDTH-1: 0]               matrix_p22_r1,matrix_p22_r2,matrix_p22_r3  ;

  always @(posedge clk ) begin
    img_left_r        <=  {img_left_r[1:0],matrix_left_edge_flag};
    img_right_r       <=  {img_right_r[1:0],matrix_right_edge_flag};
    img_top_r         <=  {img_top_r[1:0],matrix_top_edge_flag};
    img_bottom_r      <=  {img_bottom_r[1:0],matrix_bottom_edge_flag};
    post_img_hsync_r  <=  {post_img_hsync_r[2:0],matrix_img_hsync};
    post_img_vsync_r  <=  {post_img_vsync_r[2:0],matrix_img_vsync};
    post_img_valid_r  <=  {post_img_valid_r[2:0],matrix_img_valid};
    matrix_p22_r1     <=  matrix_p22;
    matrix_p22_r2     <=  matrix_p22_r1;
    matrix_p22_r3     <=  matrix_p22_r2;
  end
    always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
      post_img_data <= 8'b0;
    else if(post_img_valid_r[2]&&(img_left_r[2]|img_right_r[2]|img_top_r[2]|img_bottom_r[2]))begin
      post_img_data <= matrix_p22_r3;
    end
    else if(post_img_valid_r[2])
      post_img_data <= median_data;
    else
      post_img_data <= post_img_data;
  end

  assign                                             post_img_hsync = post_img_hsync_r[3];
  assign                                             post_img_vsync = post_img_vsync_r[3];
  assign                                             post_img_valid = post_img_valid_r[3];
endmodule
