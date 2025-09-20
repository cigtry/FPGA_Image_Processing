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
// Last modified Date:     2024/05/29 15:37:35 
// Last Version:           V1.0 
// Descriptions:            
//---------------------------------------------------------------------------------------- 
// Created by:             USER_NAME
// Created date:           2024/05/29 15:37:35 
// Version:                V1.0 
// TEXT NAME:              generate_5x5_winndows.v 
// PATH:                   C:\Users\maccura\Desktop\code-main\fpga\gauss_filter\src\generate_5x5_winndows.v 
// Descriptions:            
//                          
//---------------------------------------------------------------------------------------- 
//****************************************************************************************// 

module generate_5x5_winndows#(
parameter DATA_WIDTH = 8,
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
  input          [  DATA_WIDTH-1:00]                       pre_img_data    ,

    //  Image data has been processed
  output wire                                    matrix_img_vsync,//  processed Image data vsync valid signal
  output wire                                    matrix_img_hsync ,//  processed Image data href vaild  signal
  output wire                                    matrix_img_valid,//  processed Image data href vaild  signal
  output reg                                     matrix_top_edge_flag,//  processed Image top edge
  output reg                                     matrix_bottom_edge_flag,//  processed Image bottom edge
  output reg                                     matrix_left_edge_flag,//  processed Image left edge
  output reg                                     matrix_right_edge_flag,//  processed Image right edge
  output reg     [   DATA_WIDTH-1: 0]                       matrix_p11      ,//  
  output reg     [   DATA_WIDTH-1: 0]                       matrix_p12      ,
  output reg     [   DATA_WIDTH-1: 0]                       matrix_p13      ,
  output reg     [   DATA_WIDTH-1: 0]                       matrix_p14      ,//  
  output reg     [   DATA_WIDTH-1: 0]                       matrix_p15      ,
  output reg     [   DATA_WIDTH-1: 0]                       matrix_p21      ,//  
  output reg     [   DATA_WIDTH-1: 0]                       matrix_p22      ,
  output reg     [   DATA_WIDTH-1: 0]                       matrix_p23      ,
  output reg     [   DATA_WIDTH-1: 0]                       matrix_p24      ,//  
  output reg     [   DATA_WIDTH-1: 0]                       matrix_p25      ,
  output reg     [   DATA_WIDTH-1: 0]                       matrix_p31      ,//  
  output reg     [   DATA_WIDTH-1: 0]                       matrix_p32      ,
  output reg     [   DATA_WIDTH-1: 0]                       matrix_p33      ,
  output reg     [   DATA_WIDTH-1: 0]                       matrix_p34      ,//  
  output reg     [   DATA_WIDTH-1: 0]                       matrix_p35      ,
  output reg     [   DATA_WIDTH-1: 0]                       matrix_p41      ,//  
  output reg     [   DATA_WIDTH-1: 0]                       matrix_p42      ,
  output reg     [   DATA_WIDTH-1: 0]                       matrix_p43      ,
  output reg     [   DATA_WIDTH-1: 0]                       matrix_p44      ,//  
  output reg     [   DATA_WIDTH-1: 0]                       matrix_p45      ,
  output reg     [   DATA_WIDTH-1: 0]                       matrix_p51      ,//  
  output reg     [   DATA_WIDTH-1: 0]                       matrix_p52      ,
  output reg     [   DATA_WIDTH-1: 0]                       matrix_p53      ,
  output reg     [   DATA_WIDTH-1: 0]                       matrix_p54      ,//  
  output reg     [   DATA_WIDTH-1: 0]                       matrix_p55      

);

  reg            [  10:00]                       h_cnt           ;
  reg            [  09:00]                       v_cnt           ;
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

  reg                                            time_rebuid_flag  ;
  reg                                            time_rebuid_flag_d;
  reg                                            time_rebuid_flag_d0;
  always @ (posedge clk or negedge rst_n)begin //延时一行
    if(!rst_n)begin
      time_rebuid_flag <= 1'b0;
    end
    else if(pos_img_vsync || (v_cnt == V_TOTAL- 2'd3 && h_cnt == H_TOTAL - 1'b1) )begin
      time_rebuid_flag <= 1'b0;
    end
    else if(!time_rebuid_flag && pos_img_hsync)begin
      time_rebuid_flag <= 1'b1;
    end
    else begin
      time_rebuid_flag <= time_rebuid_flag;
    end
  end                                                               //always end
    always @ (posedge clk or negedge rst_n)begin//延时两行
    if(!rst_n)begin
      time_rebuid_flag_d <= 1'b0;
    end
    else if(pos_img_vsync || (v_cnt == V_TOTAL- 2'd2 && h_cnt == H_TOTAL - 1'b1) )begin
      time_rebuid_flag_d <= 1'b0;
    end
    else if(!time_rebuid_flag_d && time_rebuid_flag&& pos_img_hsync)begin
      time_rebuid_flag_d <= 1'b1;
    end
    else begin
      time_rebuid_flag_d <= time_rebuid_flag_d;
    end
  end                                                               //always end
      always @ (posedge clk or negedge rst_n)begin//延时三行并开始恢复图像时序
    if(!rst_n)begin
      time_rebuid_flag_d0 <= 1'b0;
    end
    else if(pos_img_vsync || (v_cnt == V_TOTAL- 1'b1 && h_cnt == H_TOTAL - 1'b1) )begin
      time_rebuid_flag_d0 <= 1'b0;
    end
    else if(!time_rebuid_flag_d0 && time_rebuid_flag_d&& pos_img_hsync)begin
      time_rebuid_flag_d0 <= 1'b1;
    end
    else begin
      time_rebuid_flag_d0 <= time_rebuid_flag_d0;
    end
  end                                                               //always end
  
  always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      h_cnt <= 11'd0;
    end
    else if(pos_img_vsync ||  h_cnt == H_TOTAL - 1'b1)begin
      h_cnt <= 11'd0;
    end
    else if(time_rebuid_flag || time_rebuid_flag_d || time_rebuid_flag_d0 )begin
      h_cnt <= h_cnt + 1'b1;
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
    else if((time_rebuid_flag_d0) && (h_cnt == H_TOTAL- 1'b1))begin
      v_cnt <= v_cnt + 1'b1;
    end
    else begin
      v_cnt <= v_cnt ;
    end
  end                                                               //always end
  //fifo1缓存当前输入的前第四行数据
  wire                                           img_vsync       ;
  wire                                           img_hsync       ;
  wire                                           img_valid       ;
  wire                                           img_valid_erea,img_valid_erea0,img_valid_erea1;

  assign                                             img_vsync      = (time_rebuid_flag_d && v_cnt < V_SYNC) ?  1'b1 : 1'b0;

  assign                                             img_hsync      = (time_rebuid_flag_d && h_cnt < H_SYNC) ? 1'b1 : 1'b0;
  assign img_valid_erea0= ((((h_cnt >= H_SYNC+H_BACK) && (h_cnt < H_SYNC+H_BACK+H_DISP))&&((v_cnt >= V_SYNC+V_BACK-2) && (v_cnt < V_SYNC+V_BACK+V_DISP-2)))) ;
  assign img_valid_erea1= ((((h_cnt >= H_SYNC+H_BACK) && (h_cnt < H_SYNC+H_BACK+H_DISP))&&((v_cnt >= V_SYNC+V_BACK-1) && (v_cnt < V_SYNC+V_BACK+V_DISP-1)))) ;
  assign img_valid_erea= ((((h_cnt >= H_SYNC+H_BACK) && (h_cnt < H_SYNC+H_BACK+H_DISP))&&((v_cnt >= V_SYNC+V_BACK) && (v_cnt < V_SYNC+V_BACK+V_DISP)))) ;
  assign img_valid =(img_valid_erea1 && time_rebuid_flag_d) ?  1'b1 : 1'b0;

  

  
  wire                                           fifo1_wr_en     ;
  wire           [   DATA_WIDTH-1: 0]                       fifo1_din       ;
  wire                                           fifo1_rd_en     ;
  wire           [   DATA_WIDTH-1: 0]                       fifo1_dout      ;
  assign                                         fifo1_din      = pre_img_data;
  assign                                         fifo1_wr_en    = pre_img_valid;
  assign                                         fifo1_rd_en    = (img_valid_erea0 && time_rebuid_flag) ?  1'b1 : 1'b0;


sync_fifo#(
  .C_FIFO_WIDTH                                      (DATA_WIDTH              ),
  .C_FIFO_DEPTH                                      (2048           ) 
)
 u1_sync_fifo(
  .rst                                               (!rst_n ||pre_img_vsync        ),
  .clk                                               (clk            ),
  .wr_en                                             (fifo1_wr_en    ),
  .din                                               (fifo1_din      ),
  .full                                              (               ),
  .rd_en                                             (fifo1_rd_en    ),
  .dout                                              (fifo1_dout     ),
  .empty                                             (               ),
  .data_count                                        (               ) 
);

//fifo2缓存当前输入的前第三行数据
  wire                                           fifo2_wr_en     ;
  wire           [   DATA_WIDTH-1: 0]                       fifo2_din       ;
  wire                                           fifo2_rd_en     ;
  wire           [   DATA_WIDTH-1: 0]                       fifo2_dout      ;

  assign                                             fifo2_wr_en    = fifo1_rd_en;
  assign                                             fifo2_din      = fifo1_dout;
  assign                                             fifo2_rd_en    =(img_valid_erea1 && time_rebuid_flag_d) ?  1'b1 : 1'b0;

sync_fifo#(
  .C_FIFO_WIDTH                                      (DATA_WIDTH              ),
  .C_FIFO_DEPTH                                      (2048           ) 
)
 u2_sync_fifo(
  .rst                                               (!rst_n  ||pre_img_vsync       ),
  .clk                                               (clk            ),
  .wr_en                                             (fifo2_wr_en    ),
  .din                                               (fifo2_din      ),
  .full                                              (               ),
  .rd_en                                             (fifo2_rd_en    ),
  .dout                                              (fifo2_dout     ),
  .empty                                             (               ),
  .data_count                                        (               ) 
);
//fifo3缓存当前输入的前第二行数据
  wire                                           fifo3_wr_en     ;
  wire           [   DATA_WIDTH-1: 0]                       fifo3_din       ;
  wire                                           fifo3_rd_en     ;
  wire           [   DATA_WIDTH-1: 0]                       fifo3_dout      ;

  assign                                             fifo3_wr_en    = fifo2_rd_en;
  assign                                             fifo3_din      = fifo2_dout;
  assign                                             fifo3_rd_en    =(img_valid_erea && time_rebuid_flag_d0) ?  1'b1 : 1'b0;

sync_fifo#(
  .C_FIFO_WIDTH                                      (DATA_WIDTH              ),
  .C_FIFO_DEPTH                                      (2048           ) 
)
 u3_sync_fifo(
  .rst                                               (!rst_n  ||pre_img_vsync       ),
  .clk                                               (clk            ),
  .wr_en                                             (fifo3_wr_en    ),
  .din                                               (fifo3_din      ),
  .full                                              (               ),
  .rd_en                                             (fifo3_rd_en    ),
  .dout                                              (fifo3_dout     ),
  .empty                                             (               ),
  .data_count                                        (               ) 
);
//fifo4缓存当前输入的前第二行数据
  wire                                           fifo4_wr_en     ;
  wire           [   DATA_WIDTH-1: 0]                       fifo4_din       ;
  wire                                           fifo4_rd_en     ;
  wire           [   DATA_WIDTH-1: 0]                       fifo4_dout      ;

  assign                                             fifo4_wr_en    = fifo3_rd_en;
  assign                                             fifo4_din      = fifo3_dout;
  assign                                             fifo4_rd_en    =(v_cnt > V_SYNC+V_BACK)&&img_valid_erea ? 1'b1 : 1'b0;

sync_fifo#(
  .C_FIFO_WIDTH                                      (DATA_WIDTH              ),
  .C_FIFO_DEPTH                                      (2048           ) 
)
 u4_sync_fifo(
  .rst                                               (!rst_n ||pre_img_vsync        ),
  .clk                                               (clk            ),
  .wr_en                                             (fifo4_wr_en    ),
  .din                                               (fifo4_din      ),
  .full                                              (               ),
  .rd_en                                             (fifo4_rd_en    ),
  .dout                                              (fifo4_dout     ),
  .empty                                             (               ),
  .data_count                                        (               ) 
);

  always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      {matrix_p11, matrix_p12, matrix_p13,matrix_p14, matrix_p15} <= 40'b0;
      {matrix_p21, matrix_p22, matrix_p23,matrix_p24, matrix_p25} <= 40'b0;
      {matrix_p31, matrix_p32, matrix_p33,matrix_p34, matrix_p35} <= 40'b0;
      {matrix_p41, matrix_p42, matrix_p43,matrix_p44, matrix_p45} <= 40'b0;
      {matrix_p51, matrix_p52, matrix_p53,matrix_p54, matrix_p55} <= 40'b0;
    end
    else begin
        {matrix_p11, matrix_p12, matrix_p13,matrix_p14, matrix_p15} <= {matrix_p12, matrix_p13,matrix_p14, matrix_p15, fifo4_dout};//  5st row input
        {matrix_p21, matrix_p22, matrix_p23,matrix_p24, matrix_p25} <= {matrix_p22, matrix_p23,matrix_p24, matrix_p25, fifo3_dout};//  4st row input
        {matrix_p31, matrix_p32, matrix_p33,matrix_p34, matrix_p35} <= {matrix_p32, matrix_p33,matrix_p34, matrix_p35, fifo2_dout};//  3st row input
        {matrix_p41, matrix_p42, matrix_p43,matrix_p44, matrix_p45} <= {matrix_p42, matrix_p43,matrix_p44, matrix_p45, fifo1_dout};//  2st row input
        {matrix_p51, matrix_p52, matrix_p53,matrix_p54, matrix_p55} <= {matrix_p52, matrix_p53,matrix_p54, matrix_p55, pre_img_data};//  1st row input
    end
  end
  reg            [   2: 0]                       img_vsync_d     ;
  reg            [   2: 0]                       img_hsync_d     ;
  reg            [   2: 0]                       img_valid_d     ;
    always @ (posedge clk or negedge rst_n)begin
      if(!rst_n)begin
        img_vsync_d <= 2'b0;
        img_hsync_d <= 2'b0;
        img_valid_d <= 2'b0;
      end
      else begin
        img_vsync_d <= {img_vsync_d[1:0],img_vsync};
        img_hsync_d <= {img_hsync_d[1:0],img_hsync};
        img_valid_d <= {img_valid_d[1:0],img_valid};
      end
    end                                                             //always end

  reg                                    top_flag,left_flag,right_flag,bottom_flag  ;
  always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      top_flag    <= 1'b0;
    end
    else if(((v_cnt == V_SYNC + V_BACK -1 )||(v_cnt == V_SYNC + V_BACK  )) && fifo3_wr_en )begin
      top_flag    <= 1'b1;
    end
    else begin
      top_flag    <= 1'b0;
    end
  end                                                               //always end
  always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      left_flag    <= 1'b0;
    end
    else if(((h_cnt == H_SYNC + H_BACK)||(h_cnt == H_SYNC + H_BACK + 1))&& fifo3_wr_en  )begin
      left_flag    <= 1'b1;
    end
    else begin
      left_flag    <= 1'b0;
    end
  end                                                               //always end

  always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      right_flag    <= 1'b0;
    end
    else if(((h_cnt == H_SYNC + H_BACK +H_DISP -1 ) ||(h_cnt == H_SYNC + H_BACK +H_DISP -2 ) )&& fifo3_wr_en )begin
      right_flag    <= 1'b1;
    end
    else begin
      right_flag    <= 1'b0;
    end
  end                                                               //always end

  always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      bottom_flag    <= 1'b0;
    end
    else if(((v_cnt == V_SYNC + V_BACK+ V_DISP -2 )||(v_cnt == V_SYNC + V_BACK+ V_DISP -3 ) )&& fifo3_wr_en )begin
      bottom_flag    <= 1'b1;
    end
    else begin
      bottom_flag    <= 1'b0;
    end
  end                                                               //always end


    
    

  assign                                             matrix_img_vsync= img_vsync_d[2];
  assign                                             matrix_img_hsync= img_hsync_d[2];
  assign                                             matrix_img_valid= img_valid_d[2];
  reg                            top_flag_d,left_flag_d,right_flag_d,bottom_flag_d  ;

  always @(posedge clk ) begin
      top_flag_d    <= top_flag;
      left_flag_d   <= left_flag;
      right_flag_d  <= right_flag;
      bottom_flag_d <= bottom_flag;
      matrix_top_edge_flag    <=top_flag_d ;   
      matrix_bottom_edge_flag <=bottom_flag_d  ;     
      matrix_left_edge_flag   <=left_flag_d  ;    
      matrix_right_edge_flag  <=right_flag_d ;   
  end



endmodule
