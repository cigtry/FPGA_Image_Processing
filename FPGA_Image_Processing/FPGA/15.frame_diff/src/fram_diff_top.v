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
// Last modified Date:     2024/06/11 15:10:43 
// Last Version:           V1.0 
// Descriptions:            
//---------------------------------------------------------------------------------------- 
// Created by:             USER_NAME
// Created date:           2024/06/11 15:10:43 
// Version:                V1.0 
// TEXT NAME:              fram_diff_top.v 
// PATH:                   C:\Users\maccura\Desktop\code-main\fpga\frame_diff\src\fram_diff_top.v 
// Descriptions:            
//                          
//---------------------------------------------------------------------------------------- 
//****************************************************************************************// 

module fram_diff_top#(
  parameter                                          H_SYNC         = 11'd40  ,   //行同步
  parameter                                          H_BACK         = 11'd220 ,  //行显示后沿
  parameter                                          H_DISP         = 11'd1280, //行有效数据
  parameter                                          H_FRONT        = 11'd110 ,  //行显示前沿
  parameter                                          H_TOTAL        = 11'd1650, //行扫描周期

  parameter                                          V_SYNC         = 11'd5   ,    //场同步
  parameter                                          V_BACK         = 11'd20  ,   //场显示后沿
  parameter                                          V_DISP         = 11'd720 ,  //场有效数据
  parameter                                          V_FRONT        = 11'd5   ,    //场显示前沿
  parameter                                          V_TOTAL        = 11'd750     //场扫描周期
)(
  input                                          clk             ,
  input                                          rst_n           ,
      //当前帧输入图像
  input                                          pre_img_vsync   ,
  input                                          pre_img_hsync   ,
  input                                          pre_img_valid   ,
  input          [  23:00]                       pre_img_data    ,
  //前1 | 2 帧输入图像
  input          [  23:00]                       pre_frame_img_data,

  output                                         post_img_vsync  ,
  output                                         post_img_hsync  ,
  output                                         post_img_valid  ,
  output         [  23:00]                       post_img_data    
);
/*rgb565灰度化*/
  wire                                           rgb2ycbcr_post_img_vsync  ;
  wire                                           rgb2ycbcr_post_img_herf  ;
  wire                                           rgb2ycbcr_post_img_valid  ;
  wire           [   7: 0]                       rgb2ycbcr_post_img_Y  ;
rgb2ycbcr u_rgb2ycbcr(
  .clk                                               (clk            ),// system clock 50MHz
  .rst_n                                             (rst_n          ),// reset, low valid
  .per_img_vsync                                     (pre_img_vsync  ),
  .per_img_herf                                      (pre_img_hsync  ),
  .per_img_valid                                     (pre_img_valid  ),
  .per_img_red                                       (pre_img_data [23:16]),
  .per_img_green                                     (pre_img_data[15:8] ),
  .per_img_blue                                      (pre_img_data[7:0]  ),
  .post_img_vsync                                    (rgb2ycbcr_post_img_vsync),
  .post_img_herf                                     (rgb2ycbcr_post_img_herf ),
  .post_img_valid                                    (rgb2ycbcr_post_img_valid),
  .post_img_Y                                        (rgb2ycbcr_post_img_Y    ),
  .post_img_Cb                                       (               ),
  .post_img_Cr                                       (               ) 
);
  wire           [   7: 0]                       rgb2ycbcr_post_img_Y2  ;
rgb2ycbcr u_rgb2ycbcr2(
  .clk                                               (clk            ),// system clock 50MHz
  .rst_n                                             (rst_n          ),// reset, low valid
  .per_img_vsync                                     (pre_img_vsync  ),
  .per_img_herf                                      (pre_img_hsync  ),
  .per_img_valid                                     (pre_img_valid  ),
  .per_img_red                                       (pre_frame_img_data[23:16]),
  .per_img_green                                     (pre_frame_img_data[15:8] ),
  .per_img_blue                                      (pre_frame_img_data[7:0]  ),
  .post_img_vsync                                    (               ),
  .post_img_herf                                     (               ),
  .post_img_valid                                    (               ),
  .post_img_Y                                        (rgb2ycbcr_post_img_Y2),
  .post_img_Cb                                       (               ),
  .post_img_Cr                                       (               ) 
);


//帧间差计算
  wire                                           frame_diff_post_img_vsync  ;
  wire                                           frame_diff_post_img_hsync  ;
  wire                                           frame_diff_post_img_valid  ;
  wire           [  07:00]                       frame_diff_post_img_data  ;

frame_diff#(
  .DIFF_THESH     (50)
) u_frame_diff(
  .clk                                               (clk            ),
  .rst_n                                             (rst_n          ),
  //当前帧输入图像
  .pre_img_vsync                                     (rgb2ycbcr_post_img_vsync),
  .pre_img_hsync                                     (rgb2ycbcr_post_img_herf),
  .pre_img_valid                                     (rgb2ycbcr_post_img_valid),
  .pre_img_data                                      (rgb2ycbcr_post_img_Y),
  //前1 | 2 帧输入图像
  .pre_frame_img_data                                (rgb2ycbcr_post_img_Y2),

  .post_img_vsync                                    (frame_diff_post_img_vsync),
  .post_img_hsync                                    (frame_diff_post_img_hsync),
  .post_img_valid                                    (frame_diff_post_img_valid),
  .post_img_data                                     (frame_diff_post_img_data ) 
);


                                                                   
  //局部二值化
  wire                                           region_bin_post_img_vsync  ;
  wire                                           region_bin_post_img_hsync  ;
  wire                                           region_bin_post_img_valid  ;
  wire                                           region_bin_post_img_data  ;

region_bin#(
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
) u_region_bin(
  .clk                                               (clk            ),
  .rst_n                                             (rst_n          ),
  .pre_img_vsync                                     (frame_diff_post_img_vsync ),
  .pre_img_hsync                                     (frame_diff_post_img_hsync ),
  .pre_img_valid                                     (frame_diff_post_img_valid ),
  .pre_img_data                                      (frame_diff_post_img_data  ),
  .post_img_vsync                                    (region_bin_post_img_vsync    ),
  .post_img_hsync                                    (region_bin_post_img_hsync    ),
  .post_img_valid                                    (region_bin_post_img_valid    ),
  .post_img_data                                     (region_bin_post_img_data     ) 
);
wire                                      sobel_detec_post_img_vsync;
wire                                      sobel_detec_post_img_hsync;
wire                                      sobel_detec_post_img_valid;
wire         [07:00]                      sobel_detec_post_img_data ;

sobel_detec#(
  .DATA_WIDTH                                        (8              ),
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
)
 u_sobel_detec(
  .clk                                               (clk            ),
  .rst_n                                             (rst_n          ),
  .thresh                                            (127            ),
  .pre_img_vsync                                     (frame_diff_post_img_vsync ),
  .pre_img_hsync                                     (frame_diff_post_img_hsync ),
  .pre_img_valid                                     (frame_diff_post_img_valid ),
  .pre_img_data                                      (frame_diff_post_img_data  ),
  .post_img_vsync                                    (sobel_detec_post_img_vsync ),
  .post_img_hsync                                    (sobel_detec_post_img_hsync ),
  .post_img_valid                                    (sobel_detec_post_img_valid ),
  .post_img_data                                     (sobel_detec_post_img_data  ) 
);


//腐蚀
  wire                                           erosion_post_img_vsync  ;
  wire                                           erosion_post_img_hsync  ;
  wire                                           erosion_post_img_valid  ;
  wire                                           erosion_post_img_data  ;

bin_erosion_dilation#(
  .H_SYNC                                            (H_SYNC         ),
  .H_BACK                                            (H_BACK         ),
  .H_DISP                                            (H_DISP         ),
  .H_FRONT                                           (H_FRONT        ),
  .H_TOTAL                                           (H_TOTAL        ),
  .V_SYNC                                            (V_SYNC         ),
  .V_BACK                                            (V_BACK         ),
  .V_DISP                                            (V_DISP         ),
  .V_FRONT                                           (V_FRONT        ),
  .V_TOTAL                                           (V_TOTAL        ),
  .EROSION_DILATION                                  (0              ),
  .THRESH                                            (9              ) 
)
 u_bin_erosion (
  .clk                                               (clk            ),
  .rst_n                                             (rst_n          ),
  .pre_img_vsync                                     (sobel_detec_post_img_vsync   ),
  .pre_img_hsync                                     (sobel_detec_post_img_hsync   ),
  .pre_img_valid                                     (sobel_detec_post_img_valid   ),
  .pre_img_data                                      (sobel_detec_post_img_data[0]    ),
  .post_img_vsync                                    (erosion_post_img_vsync),
  .post_img_hsync                                    (erosion_post_img_hsync),
  .post_img_valid                                    (erosion_post_img_valid),
  .post_img_data                                     (erosion_post_img_data) 
);
/*   assign                                             post_img_vsync = erosion_post_img_vsync  ;
  assign                                             post_img_hsync = erosion_post_img_hsync;
  assign                                             post_img_valid = erosion_post_img_valid;
  assign                                             post_img_data  = erosion_post_img_data  ?  8'd255 : 8'd0;   */

//膨胀
  wire                                           dilation_post_img_vsync  ;
  wire                                           dilation_post_img_hsync  ;
  wire                                           dilation_post_img_valid  ;
  wire                                           dilation_post_img_data  ;

bin_erosion_dilation#(
  .H_SYNC                                            (H_SYNC         ),
  .H_BACK                                            (H_BACK         ),
  .H_DISP                                            (H_DISP         ),
  .H_FRONT                                           (H_FRONT        ),
  .H_TOTAL                                           (H_TOTAL        ),
  .V_SYNC                                            (V_SYNC         ),
  .V_BACK                                            (V_BACK         ),
  .V_DISP                                            (V_DISP         ),
  .V_FRONT                                           (V_FRONT        ),
  .V_TOTAL                                           (V_TOTAL        ),
  .EROSION_DILATION                                  (1              ),
  .THRESH                                            (1              ) 
)
 u_bin_dilation (
  .clk                                               (clk            ),
  .rst_n                                             (rst_n          ),
  .pre_img_vsync                                     (erosion_post_img_vsync),
  .pre_img_hsync                                     (erosion_post_img_hsync),
  .pre_img_valid                                     (erosion_post_img_valid),
  .pre_img_data                                      (erosion_post_img_data ),
  .post_img_vsync                                    (dilation_post_img_vsync),
  .post_img_hsync                                    (dilation_post_img_hsync),
  .post_img_valid                                    (dilation_post_img_valid),
  .post_img_data                                     (dilation_post_img_data ) 
);


  //assign                                             post_img_vsync = dilation_post_img_vsync;
  //assign                                             post_img_hsync = dilation_post_img_hsync;
  //assign                                             post_img_valid = dilation_post_img_valid;
  //assign                                             post_img_data  = dilation_post_img_data  ?  8'd255 : 8'd0;

  //包围框大小
  wire                                        box_flag        ;
  wire        [  10:00]                       top_edge        ;
  wire        [  10:00]                       bottom_edge     ;
  wire        [  10:00]                       left_edge       ;
  wire        [  10:00]                       right_edge      ;


box_handle#(
  .H_SYNC                                            (H_SYNC         ),
  .H_BACK                                            (H_BACK         ),
  .H_DISP                                            (H_DISP         ),
  .H_FRONT                                           (H_FRONT        ),
  .H_TOTAL                                           (H_TOTAL        ),
  .V_SYNC                                            (V_SYNC         ),
  .V_BACK                                            (V_BACK         ),
  .V_DISP                                            (V_DISP         ),
  .V_FRONT                                           (V_FRONT        ),
  .V_TOTAL                                           (V_TOTAL        ),
  .Box_Boundary_size                                 (200           ) 
)
 u_box_handle(
  .clk                                               (clk            ),
  .rst_n                                             (rst_n          ),
  .pre_img_vsync                                     (dilation_post_img_vsync ),
  .pre_img_hsync                                     (dilation_post_img_hsync ),
  .pre_img_valid                                     (dilation_post_img_valid ),
  .pre_img_data                                      (dilation_post_img_data  ),
  .box_flag                                          (box_flag       ),
  .top_edge                                          (top_edge       ),
  .bottom_edge                                       (bottom_edge    ),
  .left_edge                                         (left_edge      ),
  .right_edge                                        (right_edge     ) 
);
 


draw_box#(
   .H_SYNC         (H_SYNC        ),
   .H_BACK         (H_BACK        ),
   .H_DISP         (H_DISP        ),
   .H_FRONT        (H_FRONT       ),
   .H_TOTAL        (H_TOTAL       ),
   .V_SYNC         (V_SYNC        ),
   .V_BACK         (V_BACK        ),
   .V_DISP         (V_DISP        ),
   .V_FRONT        (V_FRONT       ),
   .V_TOTAL        (V_TOTAL       )
)
 u_draw_box(
    .clk                                (clk                       ),
    .rst_n                              (rst_n                     ),
    .pre_img_vsync                      (pre_img_vsync             ),
    .pre_img_hsync                      (pre_img_hsync             ),
    .pre_img_valid                      (pre_img_valid             ),
    .pre_img_data                       (pre_img_data              ),
    .box_flag                           (1                         ),
    .top_edge                           (top_edge                  ),
    .bottom_edge                        (bottom_edge               ),
    .left_edge                          (left_edge                 ),
    .right_edge                         (right_edge                ),
    .post_img_vsync                     (post_img_vsync            ),
    .post_img_hsync                     (post_img_hsync            ),
    .post_img_valid                     (post_img_valid            ),
    .post_img_data                      (post_img_data             )
);


endmodule
