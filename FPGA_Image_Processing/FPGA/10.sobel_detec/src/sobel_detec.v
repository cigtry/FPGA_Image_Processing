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
// Last modified Date:     2024/05/31 17:22:24 
// Last Version:           V1.0 
// Descriptions:            
//---------------------------------------------------------------------------------------- 
// Created by:             USER_NAME
// Created date:           2024/05/31 17:22:24 
// Version:                V1.0 
// TEXT NAME:              sobel_detec.v 
// PATH:                   C:\Users\maccura\Desktop\code-main\fpga\sobel_detec\src\sobel_detec.v 
// Descriptions:            
//                          
//---------------------------------------------------------------------------------------- 
//****************************************************************************************// 

module sobel_detec#(
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
  input          [DATA_WIDTH-1:00]               thresh          ,
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
) u_generate_3x3_winndows(
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

//----------------------------------------------------------------------
//            [p11,p12,p13]   [-1,0,1]
//  Gx_data = [p21,p22,p23] * [-2,0,2] = (p13+2*p23+p33) - (p11+2*p21+p31)
//            [p31,p32,p33]   [-1,0,1]
//
//            [p11,p12,p13]   [-1,-2,-1]
//  Gy_data = [p21,p22,p23] * [ 0, 0, 0] = (p31+2*p32+p33) - (p11+2*p12+p13)
//            [p31,p32,p33]   [ 1, 2, 1]
//  
//  G_data = sqrt(Gx_data^2 + Gy_data^2)
  reg            [   9: 0]                       Gx_data_tmp1    ;
  reg            [   9: 0]                       Gx_data_tmp2    ;
  reg            [   9: 0]                       Gy_data_tmp1    ;
  reg            [   9: 0]                       Gy_data_tmp2    ;
  reg      signed[  10: 0]                       Gx_data         ;
  reg      signed[  10: 0]                       Gy_data         ;
  reg      signed[  21: 0]                       Gx_square_data  ;
  reg      signed[  21: 0]                       Gy_square_data  ;
  reg            [  20: 0]                       G_square_data   ;
  wire           [  10: 0]                       G_data          ;

always @(posedge clk)
begin
    Gx_data_tmp1   <= matrix_p13 + {matrix_p23,1'b0} + matrix_p33;
    Gx_data_tmp2   <= matrix_p11 + {matrix_p21,1'b0} + matrix_p31;
    Gy_data_tmp1   <= matrix_p31 + {matrix_p32,1'b0} + matrix_p33;
    Gy_data_tmp2   <= matrix_p11 + {matrix_p12,1'b0} + matrix_p13;
    Gx_data        <= $signed({1'b0,Gx_data_tmp1}) - $signed({1'b0,Gx_data_tmp2});
    Gy_data        <= $signed({1'b0,Gy_data_tmp1}) - $signed({1'b0,Gy_data_tmp2});
    Gx_square_data <= $signed(Gx_data) * $signed(Gx_data);
    Gy_square_data <= $signed(Gy_data) * $signed(Gy_data);
    G_square_data  <= Gx_square_data[20:0] + Gy_square_data[20:0];
end

sqrt u_sqrt
(
  .sys_clk                                           (clk            ),
  .sys_rst                                           (~rst_n         ),
  .din                                               (G_square_data  ),
  .din_valid                                         (1'b1           ),
  .dout                                              (G_data         ),
  .dout_valid                                        (               ) 
);

 //  lag 16 clocks signal sync
  reg            [  15:00]                       matrix_img_vsync_r1  ;
  reg            [  15:00]                       matrix_img_hsync_r1  ;
  reg            [  15:00]                       matrix_edge_flag_r1  ;
  reg            [  15:00]                       matrix_img_valid_r1  ;


always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        matrix_img_vsync_r1 <= 16'b0;
        matrix_img_hsync_r1 <= 16'b0;
        matrix_edge_flag_r1 <= 16'b0;
        matrix_img_valid_r1 <= 16'b0;
    end
    else
    begin
        matrix_img_vsync_r1 <= {matrix_img_vsync_r1[15:0],matrix_img_vsync};
        matrix_img_hsync_r1  <={matrix_img_hsync_r1[15:0],matrix_img_hsync};
        matrix_img_valid_r1 <= {matrix_img_valid_r1[15:0],matrix_img_valid};
        matrix_edge_flag_r1 <= {matrix_edge_flag_r1[15:0],matrix_top_edge_flag | matrix_bottom_edge_flag | matrix_left_edge_flag | matrix_right_edge_flag};
    end
end
                
  always @ (posedge clk or negedge rst_n)begin
  if(!rst_n)begin
    post_img_hsync <= 1'b0;
    post_img_vsync <= 1'b0;
    post_img_valid <= 1'b0;
  end
  else begin
    post_img_hsync <= matrix_img_hsync_r1 [15];
    post_img_vsync <= matrix_img_vsync_r1 [15];
    post_img_valid <=  matrix_img_valid_r1[15];
  end
end                                                                 //always end

always @ (posedge clk or negedge rst_n)begin
  if(!rst_n)begin
    post_img_data <= 8'b0;
  end
  else if(matrix_edge_flag_r1[15])begin
    post_img_data <= 8'd255;
  end
  else if(G_data > thresh)begin
    post_img_data <= 8'd255;
  end
  else begin
    post_img_data <= 8'b0;
  end
end                                                                 //always end

endmodule
