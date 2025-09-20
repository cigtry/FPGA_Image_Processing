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
// Last modified Date:     2024/06/12 11:13:15 
// Last Version:           V1.0 
// Descriptions:            
//---------------------------------------------------------------------------------------- 
// Created by:             USER_NAME
// Created date:           2024/06/12 11:13:15 
// Version:                V1.0 
// TEXT NAME:              draw_box.v 
// PATH:                   C:\Users\maccura\Desktop\code-main\fpga\frame_diff\src\draw_box.v 
// Descriptions:            
//                          
//---------------------------------------------------------------------------------------- 
//****************************************************************************************// 

module draw_box#(
parameter  H_SYNC   =  11'd40   ,   //行同步
parameter  H_BACK   =  11'd220  ,  //行显示后沿
parameter  H_DISP   =  11'd1280 , //行有效数据
parameter  H_FRONT  =  11'd110  ,  //行显示前沿
parameter  H_TOTAL  =  11'd1650 , //行扫描周期

parameter  V_SYNC   =  11'd5    ,    //场同步
parameter  V_BACK   =  11'd20   ,   //场显示后沿
parameter  V_DISP   =  11'd720  ,  //场有效数据
parameter  V_FRONT  =  11'd5    ,    //场显示前沿
parameter  V_TOTAL  =  11'd750    //场扫描周期
)(
  input                                          clk             ,
  input                                          rst_n           ,
  input                                          pre_img_vsync   ,
  input                                          pre_img_hsync   ,
  input                                          pre_img_valid   ,
  input          [  23:00]                       pre_img_data    ,

  input                                          box_flag        ,
  input          [  10:00]                       top_edge        ,
  input          [  10:00]                       bottom_edge     ,
  input          [  10:00]                       left_edge       ,
  input          [  10:00]                       right_edge      ,

  output reg                                     post_img_vsync  ,
  output reg                                     post_img_hsync  ,
  output reg                                     post_img_valid  ,
  output reg     [  23:00]                       post_img_data    
);


  reg            [  10:00]                       h_cnt           ;
  reg            [  09:00]                       v_cnt           ;
  reg                                            cnt_flag;
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
  end //always end
  
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
                                                                   
  always @ (posedge clk or negedge rst_n)begin 
    if(!rst_n)begin  
      post_img_vsync   <= 1'b0;
      post_img_hsync   <= 1'b0;
      post_img_valid   <= 1'b0;
      post_img_data    <= 8'b0;
    end  
    else begin  
      post_img_vsync <= pre_img_vsync ;
      post_img_hsync <= pre_img_hsync ;
      post_img_valid <= pre_img_valid ;
      if (box_flag) begin
         if(((h_cnt == left_edge)) &&  (v_cnt >=top_edge )  && (v_cnt <=bottom_edge))begin
          post_img_data <= 24'hffffff;
        end
        else if(( (h_cnt == right_edge)) &&  (v_cnt >=top_edge )  && (v_cnt <=bottom_edge))begin
          post_img_data <= 24'hff0000;
        end
        else if ((h_cnt >= left_edge) && (h_cnt <= right_edge) && ((v_cnt == top_edge )  )) begin
          post_img_data <= 24'h00ff00;
        end
        else if ((h_cnt >= left_edge) && (h_cnt <= right_edge) && ( (v_cnt ==bottom_edge))) begin
          post_img_data <= 24'h0000ff;
        end
        else begin
          post_img_data <= pre_img_data;
        end
      end
      else begin
        post_img_data <= pre_img_data;
      end
    end  
  end //always end
  

endmodule
