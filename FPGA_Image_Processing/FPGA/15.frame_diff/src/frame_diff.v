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
// Last modified Date:     2024/06/11 13:53:45 
// Last Version:           V1.0 
// Descriptions:            
//---------------------------------------------------------------------------------------- 
// Created by:             USER_NAME
// Created date:           2024/06/11 13:53:45 
// Version:                V1.0 
// TEXT NAME:              frame_diff.v 
// PATH:                   C:\Users\maccura\Desktop\code-main\fpga\frame_diff\src\frame_diff.v 
// Descriptions:            
//                          
//---------------------------------------------------------------------------------------- 
//****************************************************************************************// 

module frame_diff#(
    parameter DIFF_THESH = 8'd50
)(
  input                                          clk             ,
  input                                          rst_n           ,
  //当前帧输入图像
  input                                          pre_img_vsync   ,
  input                                          pre_img_hsync   ,
  input                                          pre_img_valid   ,
  input          [  07:00]                       pre_img_data    ,
  //前1 | 2 帧输入图像
  //output reg                                     pre_frame_img_vsync,
  //output reg                                     pre_frame_img_hsync,
  //output wire                                    pre_frame_img_req,
  input          [  07:00]                       pre_frame_img_data,


  output reg                                     post_img_vsync  ,
  output reg                                     post_img_hsync  ,
  output reg                                     post_img_valid  ,
  output reg     [  07:00]                       post_img_data    
);

  

  //两帧相减得到差分帧数据
  reg  [07:00]  frame_diff_data;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      frame_diff_data <= 8'h00;
    end
    else if(pre_img_data > pre_frame_img_data)begin
      frame_diff_data <= pre_img_data - pre_frame_img_data;
    end
    else begin
      frame_diff_data <= pre_frame_img_data - pre_img_data;
    end
  end

  //差分帧阈值处理
  always @(posedge clk ) begin
    if(frame_diff_data > DIFF_THESH )begin
      post_img_data <= frame_diff_data;
    end
    else begin
      post_img_data <= 8'h0;
    end
  end
  reg   pre_img_vsync_d;
  reg   pre_img_hsync_d;
  reg   pre_img_valid_d;

  always @(posedge clk ) begin
    pre_img_vsync_d <= pre_img_vsync;
    pre_img_hsync_d <= pre_img_hsync;
    pre_img_valid_d <= pre_img_valid;
  end

  always @(posedge clk ) begin
    post_img_vsync <= pre_img_vsync_d ;
    post_img_hsync <= pre_img_hsync_d ;
    post_img_valid <= pre_img_valid_d ;
  end
                                                                   
endmodule
