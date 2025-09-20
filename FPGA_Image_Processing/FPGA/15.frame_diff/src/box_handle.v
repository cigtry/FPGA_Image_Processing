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
// Last modified Date:     2024/06/11 14:29:40 
// Last Version:           V1.0 
// Descriptions:            
//---------------------------------------------------------------------------------------- 
// Created by:             USER_NAME
// Created date:           2024/06/11 14:29:40 
// Version:                V1.0 
// TEXT NAME:              box_handle.v 
// PATH:                   C:\Users\maccura\Desktop\code-main\fpga\frame_diff\src\box_handle.v 
// Descriptions:            
//                          
//---------------------------------------------------------------------------------------- 
//****************************************************************************************// 

module box_handle#(
  parameter                                          H_SYNC         = 11'd40,   //行同步
  parameter                                          H_BACK         = 11'd220,  //行显示后沿
  parameter                                          H_DISP         = 11'd1280, //行有效数据
  parameter                                          H_FRONT        = 11'd110,  //行显示前沿
  parameter                                          H_TOTAL        = 11'd1650, //行扫描周期

  parameter                                          V_SYNC         = 11'd5 ,    //场同步
  parameter                                          V_BACK         = 11'd20,   //场显示后沿
  parameter                                          V_DISP         = 11'd720,  //场有效数据
  parameter                                          V_FRONT        = 11'd5 ,    //场显示前沿
  parameter                                          V_TOTAL        = 11'd750,  //场扫描周期
  parameter                                          Box_Boundary_size= 500   
)(
  input                                          clk             ,
  input                                          rst_n           ,
  input                                          pre_img_vsync   ,
  input                                          pre_img_hsync   ,
  input                                          pre_img_valid   ,
  input                                          pre_img_data    ,
  output reg                                     box_flag        ,
  output reg     [  10:00]                       top_edge        ,
  output reg     [  10:00]                       bottom_edge     ,
  output reg     [  10:00]                       left_edge       ,
  output reg     [  10:00]                       right_edge       
);


  reg            [  10:00]                       h_cnt           ;
  reg            [  09:00]                       v_cnt           ;
  reg                                            cnt_flag        ;
  reg                                            pre_img_vsync_d  ;
  reg                                            pre_img_hsync_d  ;
  wire                                           pos_img_vsync   ;
  assign                                             pos_img_vsync  = pre_img_vsync && !pre_img_vsync_d;
  wire                                           pos_img_hsync   ;
  assign                                             pos_img_hsync  = pre_img_hsync && !pre_img_hsync_d;

  always @ (posedge clk or negedge rst_n)begin                      //
    if(!rst_n)begin
      pre_img_vsync_d <= 1'b0;
      pre_img_hsync_d <= 1'b0;
    end
    else begin
      pre_img_vsync_d <= pre_img_vsync;
      pre_img_hsync_d <= pre_img_hsync;
    end
  end                                                               //always end
  always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      cnt_flag <= 1'b0;
    end
    else if(pos_img_vsync)begin
      cnt_flag <= 1'b1;
    end
    else if((v_cnt == V_TOTAL- 1'b1 && h_cnt == H_TOTAL - 1'b1))begin
      cnt_flag <= 1'b0;
    end
    else begin
      cnt_flag <= cnt_flag;
    end
  end                                                               //always end
  
  always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      h_cnt <= 11'd0;
    end
    else if(pos_img_vsync ||  h_cnt == H_TOTAL - 1'b1)begin
      h_cnt <= 11'd0;
    end
    else if(cnt_flag)begin
      h_cnt <= h_cnt + 1'b1 ;
    end
    else begin
      h_cnt <= h_cnt;
    end
  end                                                               //always end

  always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      v_cnt <= 10'd0;
    end
    else if(pos_img_vsync || (v_cnt == V_TOTAL- 1'b1 && h_cnt == H_TOTAL - 1'b1))begin
      v_cnt <= 10'd0;
    end
    else if(h_cnt == H_TOTAL- 1'b1)begin
      v_cnt <= v_cnt + 1'b1;
    end
    else begin
      v_cnt <= v_cnt ;
    end
  end                                                               //always end
  reg            [  10:00]                       top_edge_r      ;
  reg            [  10:00]                       bottom_edge_r   ;
  reg            [  10:00]                       left_edge_r     ;
  reg            [  10:00]                       right_edge_r    ;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      top_edge_r <= 11'd0;
    end
    else if(pos_img_vsync)begin
      top_edge_r <= 11'd0;
    end
    else if(pre_img_valid && (pre_img_data )&& (top_edge_r == 11'd0)) begin
      top_edge_r <= v_cnt;
    end
    else begin
      top_edge_r <= top_edge_r ;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      bottom_edge_r <= 11'd0;
    end
    else if(pos_img_vsync)begin
      bottom_edge_r <= 11'd0;
    end
    else if (pre_img_valid &&(pre_img_data )) begin
      if ((bottom_edge_r < v_cnt) && (bottom_edge_r <top_edge_r + Box_Boundary_size )) begin
        bottom_edge_r <= v_cnt;
      end
      else begin
        bottom_edge_r <= bottom_edge_r;
      end
    end
    else begin
      bottom_edge_r <= bottom_edge_r;
    end
  end

    always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      left_edge_r <= 11'd0;
    end
    else if(pos_img_vsync)begin
      left_edge_r <= 11'd0;
    end
    else if(pre_img_valid &&(pre_img_data )&& (left_edge_r == 11'd0)) begin
      left_edge_r <= h_cnt;
    end
    else if(pre_img_valid &&(pre_img_data ) )begin
      if (left_edge_r > h_cnt) begin
        left_edge_r <= h_cnt;
      end
      else begin
        left_edge_r <= left_edge_r;
      end
    end
    else begin
      left_edge_r <= left_edge_r ;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      right_edge_r <= 11'd0;
    end
    else if(pos_img_vsync)begin
      right_edge_r <= 11'd0;
    end
    else if(pre_img_valid &&((pre_img_data )&& (right_edge_r == 11'd0)) || ((right_edge_r > left_edge_r + Box_Boundary_size ))) begin
      right_edge_r <= left_edge_r + Box_Boundary_size ;
    end
    else if (pre_img_valid &&(pre_img_data )) begin
      if ((right_edge_r < h_cnt) && (right_edge_r < left_edge_r + Box_Boundary_size )) begin
        right_edge_r <= h_cnt;
      end
      else begin
        right_edge_r <= right_edge_r;
      end
    end
    else begin
      right_edge_r <= right_edge_r;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      box_flag <= 1'b0;
    end
    else if(pos_img_vsync)begin
      box_flag <= 1'b0;
    end
    else if(pre_img_valid &&(pre_img_data) )begin
      box_flag <= 1'b1;
    end
    else begin
      box_flag <= box_flag;
    end
  end
  always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
    top_edge     <= 11'd0;
    bottom_edge  <= 11'd0;
    left_edge    <= 11'd0;
    right_edge   <= 11'd0;
    end
    else if((v_cnt == V_TOTAL- 1'b1 && h_cnt == H_TOTAL - 1'b1))begin
      top_edge     <= top_edge_r;
      bottom_edge  <= bottom_edge_r;
      left_edge    <= left_edge_r;
      right_edge   <= right_edge_r;
    end
    else begin
      top_edge     <= top_edge     ;
      bottom_edge  <= bottom_edge  ;
      left_edge    <= left_edge    ;
      right_edge   <= right_edge   ;
    end
  end                                                               //always end
  
                                                                   
endmodule
