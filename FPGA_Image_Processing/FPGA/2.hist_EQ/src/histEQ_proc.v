`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////
//Company        :    maccura    
//Engineer        :    FuXin     
//Creat Date      :    2023-01-01
//Design Name      :             
//Module Name      :             
//Project Name      :            
//Target Devices    :            
//Tool Version      :            
//Description      :             
//Revisoion      :               
//Additional Comments  :          
//
////////////////////////////////////////////////////////////////
module histEQ_proc#(
  parameter Index = 32,
  parameter Multiplier = 2281701,
  parameter                                          H_DISP         = 11'd800, //行有效数据
  parameter                                          V_DISP         = 11'd600//场有效数据
)(
  input   wire                    clk              , //system clock 50MHz
  input   wire                    rst_n            , //reset, low valid
  
  input   wire                    pre_img_vsync    ,
  input   wire                    pre_img_hsync    ,
  input   wire                    pre_img_valid    ,
  input   wire    [07:00]         pre_img_gray     ,

  input  wire    [07:00]          pixel_level      ,
  input  wire    [20:00]          pixel_cnt_num    ,
  input  wire                     pixel_level_vld  ,
  output reg                      pixel_write_ok   ,

  output   wire                   post_img_vsync   ,
  output   wire                   post_img_hsync   ,
  output   wire                   post_img_valid   ,
  output   wire    [07:00]        post_img_gray    
);
    //创建一个二维数组用于存储灰度级的个数
    reg  [20:00]    mem    [255:00];
    reg  [Index+7 : 00]   mult_result;
    reg  [20:00]    gray_data_reg;//存储映射的数据用于运算
    reg  [2:0]      img_vsync_r;
    reg  [2:0]      img_hsync_r;
    reg  [2:0]      img_valid_r;
    reg  [7:0]      img_gray_reg;//储存乘法的数据并四舍五入
    //帧头和帧尾
     reg            [  11: 0]                       cnt_herf        ;
    reg            [   9: 0]                       cnt_vsync       ;
    //检测到场同步信号的下降沿开始采集信号
    reg                                            cmos_vsync_r    ;
    reg                                            cmos_vsync_r1   ;
    wire                                           cmos_vsync_neg  ;
  always @(posedge clk) begin
    cmos_vsync_r <= pre_img_vsync;
    cmos_vsync_r1 <= cmos_vsync_r;
  end
  assign                                             cmos_vsync_neg = (!cmos_vsync_r) &  cmos_vsync_r1;


  always @(posedge clk or negedge rst_n)begin
    if(!rst_n)
      cnt_herf <= 12'd0;
    else if(cmos_vsync_neg)
      cnt_herf <= 12'd0;
    else if(cnt_herf == (H_DISP ) - 12'b1)
      cnt_herf <= 12'd0;
    else if(pre_img_valid)
      cnt_herf <= cnt_herf + 12'b1;
    else
      cnt_herf <= cnt_herf ;
  end

  always @(posedge clk or negedge rst_n)begin
    if(!rst_n)
      cnt_vsync <= 10'd0;
    else if((cnt_vsync == V_DISP- 10'b1) && (cnt_herf == (H_DISP) - 12'b1))
      cnt_vsync <= 10'd0;
    else if(cnt_herf == (H_DISP) - 12'b1)
      cnt_vsync <= cnt_vsync + 10'b1;
    else
      cnt_vsync <= cnt_vsync;
  end



    assign    img_sop = pre_img_valid &&(cnt_herf == 12'b1) && (cnt_vsync == 10'b0) ;
    assign    img_eop = pre_img_valid && (cnt_herf == (H_DISP) - 12'b1) && (cnt_vsync == V_DISP - 10'b1) ;

    //将统计模块的数据存入数组里面
    integer i;
    always @ (posedge clk or negedge rst_n)begin 
      if(!rst_n)begin  
         for(i=0;i<256;i=i+1)begin
          mem[i] <= 20'b0;
        end
      end  
      else if( pixel_level_vld)begin  
        mem[pixel_level] <= pixel_cnt_num;
      end  
      else begin  
         mem[pixel_level] <= mem[pixel_level] ;
      end  
    end //always end
    
    always @ (posedge clk or negedge rst_n)begin 
      if(!rst_n)begin  
        pixel_write_ok <= 1'b0;
      end  
      else if((pixel_level == 255) && pixel_level_vld)begin  
        pixel_write_ok <= 1'b1;
      end  
      else begin  
        pixel_write_ok <= 1'b0;
      end  
    end //always end
    
    always @ (posedge clk or negedge rst_n)begin 
      if(!rst_n)begin  
        gray_data_reg <= 20'd0;
      end  
      else if(pre_img_valid)begin  
        gray_data_reg <= mem[pre_img_gray];
      end  
      else begin  
        gray_data_reg <= gray_data_reg ;
      end  
    end //always end
    
    always @ (posedge clk or negedge rst_n)begin 
      if(!rst_n)begin  
        img_vsync_r <= 2'b0;
        img_hsync_r <= 2'b0;
        img_valid_r <= 2'b0;
      end  
      else begin  
        img_vsync_r <= {img_vsync_r[1:0], pre_img_vsync};
        img_hsync_r <= {img_hsync_r[1:0], pre_img_hsync};
        img_valid_r <= {img_valid_r[1:0], pre_img_valid};
      end  
    end //always end
    
    always @ (posedge clk or negedge rst_n)begin 
      if(!rst_n)begin  
        mult_result <= {Index+8{1'b0} };
      end  
      else if(img_valid_r[0])begin  
        mult_result <= gray_data_reg * Multiplier;
      end  
      else begin  
        mult_result <= mult_result;
      end  
    end //always end
    
    always @ (posedge clk or negedge rst_n)begin 
      if(!rst_n)begin  
        img_gray_reg <= 8'b0;
      end  
      else if(img_valid_r[1])begin  
        img_gray_reg <= mult_result[(Index+7)-:8] + mult_result[Index-1];
      end  
      else begin  
        img_gray_reg <= img_gray_reg;
      end  
    end //always end

    assign    post_img_gray =  img_gray_reg ;
    assign    post_img_vsync = img_vsync_r[2];
    assign    post_img_hsync = img_hsync_r[2];
    assign    post_img_valid = img_valid_r[2];
endmodule 