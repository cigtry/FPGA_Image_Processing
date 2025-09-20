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
// Last modified Date:     2024/05/31 14:58:12 
// Last Version:           V1.0 
// Descriptions:            
//---------------------------------------------------------------------------------------- 
// Created by:             USER_NAME
// Created date:           2024/05/31 14:58:12 
// Version:                V1.0 
// TEXT NAME:              region_bin.v 
// PATH:                   C:\Users\maccura\Desktop\code-main\fpga\region_bin\src\region_bin.v 
// Descriptions:            
//                          
//---------------------------------------------------------------------------------------- 
//****************************************************************************************// 

module region_bin#(
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
)    u_generate_5x5_winndows(
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

  reg            [  10:00]                       data_sum1       ;
  reg            [  10:00]                       data_sum2       ;
  reg            [  10:00]                       data_sum3       ;
  reg            [  10:00]                       data_sum4       ;
  reg            [  10:00]                       data_sum5       ;
  reg            [  12:00]                       data_sum        ;

always @(posedge clk ) begin
  data_sum1 <= matrix_p11 + matrix_p12 + matrix_p13 + matrix_p14 + matrix_p15;
  data_sum2 <= matrix_p21 + matrix_p22 + matrix_p23 + matrix_p24 + matrix_p25;
  data_sum3 <= matrix_p31 + matrix_p32 + matrix_p33 + matrix_p34 + matrix_p35;
  data_sum4 <= matrix_p41 + matrix_p42 + matrix_p43 + matrix_p44 + matrix_p45;
  data_sum5 <= matrix_p51 + matrix_p52 + matrix_p53 + matrix_p54 + matrix_p55;
  data_sum <= data_sum1 + data_sum2 + data_sum3 + data_sum4 + data_sum5;
end

  reg            [  31:00]                       mult_resualt    ;

always @(posedge clk ) begin
  mult_resualt <= data_sum * 20'd603980;
end
  wire           [DATA_WIDTH-1:00]               thresh          ;
  assign                                             thresh         = mult_resualt[31:24];
  
  reg            [DATA_WIDTH-1:00]               matrix_p33_d0   ;
  reg            [DATA_WIDTH-1:00]               matrix_p33_d1   ;
  reg            [DATA_WIDTH-1:00]               matrix_p33_d2   ;

    always @(posedge clk)begin
      matrix_p33_d2 <= matrix_p33_d1;
      matrix_p33_d1 <= matrix_p33_d0;
      matrix_p33_d0 <= matrix_p33;
    end

  reg            [   2: 0]                       martix_img_hsync_d  ;
  reg            [   2: 0]                       martix_img_vsync_d  ;
  reg            [   2: 0]                       martix_img_valid_d  ;
  reg            [   2: 0]                       martix_img_edge_d  ;

  always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      martix_img_hsync_d <= 3'b0;
      martix_img_vsync_d <= 3'b0;
      martix_img_valid_d <= 3'b0;
      martix_img_edge_d  <= 3'b0;
    end
    else begin
      martix_img_hsync_d <= {martix_img_hsync_d[1:0],matrix_img_hsync};
      martix_img_vsync_d <= {martix_img_vsync_d[1:0],matrix_img_vsync};
      martix_img_valid_d <= {martix_img_valid_d[1:0],matrix_img_valid};
      martix_img_edge_d  <= {martix_img_edge_d[1:0] ,(matrix_left_edge_flag|matrix_right_edge_flag|matrix_top_edge_flag|matrix_bottom_edge_flag)};
    end
  end                                                               //always end

always @ (posedge clk or negedge rst_n)begin
  if(!rst_n)begin
    post_img_hsync <= 1'b0;
    post_img_vsync <= 1'b0;
    post_img_valid <= 1'b0;
  end
  else begin
    post_img_hsync <= martix_img_hsync_d[2];
    post_img_vsync <= martix_img_vsync_d[2];
    post_img_valid <= martix_img_valid_d[2];
  end
end                                                                 //always end

always @ (posedge clk or negedge rst_n)begin
  if(!rst_n)begin
    post_img_data <= 8'b0;
  end
  else if(martix_img_edge_d[2])begin
    post_img_data <= 8'd255;
  end
  else if(matrix_p33_d2 > thresh)begin
    post_img_data <= 8'd255;
  end
  else begin
    post_img_data <= 8'b0;
  end
end                                                                 //always end
  

endmodule
