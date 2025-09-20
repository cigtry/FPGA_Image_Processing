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
module hist_stat#(
  parameter                                          H_DISP         = 11'd800, //行有效数据
  parameter                                          V_DISP         = 11'd600//场有效数据
)(
  input   wire                    clk             , //system clock 50MHz
  input   wire                    rst_n           , //reset, low valid
  
  input   wire                    pre_img_vsync   ,
  input   wire                    pre_img_hsync   ,
  input   wire                    pre_img_valid     ,
  input   wire    [07:00]         pre_img_gray    ,

  output  reg     [07:00]         pixel_level_data,
  output  reg     [20:00]         pixel_cnt_num   ,
  output  reg                     pixel_level_vld
);
    //创建一个二维数组用于累积灰度级的个数
    reg  [20:00]    mem    [255:00];
    reg  [07:00]         pixel_level;

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

    reg     stat_end_flag;//一帧图像统计完成标志，在统计完成后置1，将统计数据发送完成后置0；
    reg     stat_end_flag_r;
    wire    neg_stat_end_flag;

    always @ (posedge clk or negedge rst_n)begin 
      if(!rst_n)begin  
        stat_end_flag_r <=1'b0;
      end  
      else begin  
        stat_end_flag_r <= stat_end_flag;
      end  
    end //always end

    assign    neg_stat_end_flag = !stat_end_flag  & stat_end_flag_r;

    //初始化数组，在数据有效时开始统计
    integer i;
    always @(posedge clk or negedge rst_n) begin
      if(!rst_n ||  neg_stat_end_flag )begin
        for(i=0;i<256;i=i+1)begin
          mem[i] <= 20'b0;
        end
      end
      else if(pre_img_valid)begin
        mem[pre_img_gray] <= mem[pre_img_gray] + 1'b1;
      end
      else begin
        mem[pre_img_gray] <= mem[pre_img_gray];
      end
    end

    always @ (posedge clk or negedge rst_n)begin 
      if(!rst_n)begin  
        stat_end_flag <= 1'b0;
      end  
      else if(pixel_level == 8'd255)begin  
        stat_end_flag <= 1'b0;
      end  
      else if(img_eop)begin
        stat_end_flag <= 1'b1;
      end
      else begin  
        stat_end_flag <= stat_end_flag;
      end  
    end //always end

    always @ (posedge clk or negedge rst_n)begin 
      if(!rst_n)begin  
        pixel_level <= 8'd0;
      end  
      else if(stat_end_flag)begin  
        pixel_level <= pixel_level + 1'b1;
      end  
      else begin  
        pixel_level <= 8'd0;
      end  
    end //always end

    always @ (posedge clk or negedge rst_n)begin 
      if(!rst_n)begin  
        pixel_cnt_num <= 21'b0;
      end  
      else if(stat_end_flag)begin  
        pixel_cnt_num <= pixel_cnt_num + mem[pixel_level];
      end  
      else begin  
        pixel_cnt_num <= 21'b0;
      end  
    end //always end

    always @ (posedge clk or negedge rst_n)begin 
      if(!rst_n)begin  
        pixel_level_vld <= 1'b0;
      end  
      else if(stat_end_flag)begin  
        pixel_level_vld <= 1'b1;
      end  
      else begin  
        pixel_level_vld <= 1'b0;
      end  
    end //always end

    always @ (posedge clk or negedge rst_n)begin 
      if(!rst_n)begin  
        pixel_level_data <= 8'd0;
      end  
      else begin  
        pixel_level_data <= pixel_level;
      end  
    end //always end

endmodule 