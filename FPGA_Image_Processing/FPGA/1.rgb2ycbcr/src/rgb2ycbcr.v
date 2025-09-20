`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////
//Company				:		maccura	
//Engineer				:		FuXin	
//Creat Date			:		2023-01-01
//Design Name			:					
//Module Name			:					
//Project Name			:					
//Target Devices		:					
//Tool Version			:					
//Description			:					
//Revisoion			:					
//Additional Comments	:					
//
////////////////////////////////////////////////////////////////
module rgb2ycbcr(
  input             clk           , //system clock 50MHz
  input             rst_n         , //reset, low valid
  
  input             per_img_vsync ,
  input             per_img_herf  ,
  input             per_img_valid , 
  input    [7:0]    per_img_red   ,
  input    [7:0]    per_img_green ,
  input    [7:0]    per_img_blue  ,
             
  output            post_img_vsync,
  output            post_img_herf ,
  output            post_img_valid,
  output   [7:0]    post_img_Y    ,
  output   [7:0]    post_img_Cb   ,
  output   [7:0]    post_img_Cr   
);
//Parameter Declarations
  reg       [15:0]     img_red_r0,img_red_r1,img_red_r2;
  reg       [15:0]     img_green_r0,img_green_r1,img_green_r2;
  reg       [15:0]     img_blue_r0,img_blue_r1,img_blue_r2;

  always @(posedge clk) begin
    img_red_r0 <= (per_img_red * 76);
    img_red_r1 <= (per_img_red * 43);
    img_red_r2 <= (per_img_red * 128);

    img_green_r0<=(per_img_green * 150);
    img_green_r1<=(per_img_green * 84);
    img_green_r2<=(per_img_green * 107);

    img_blue_r0<=(per_img_blue * 29);
    img_blue_r1<=(per_img_blue * 128);
    img_blue_r2<=(per_img_blue * 20);
  end

  reg      [15:0]        sum_Y,sum_Cb,sum_Cr;

  always @(posedge clk) begin
    sum_Y <= img_red_r0 + img_green_r0 + img_blue_r0;
    sum_Cb<= img_blue_r1 - img_red_r1 - img_green_r1 + 16'd32768;
    sum_Cr<= img_red_r2 - img_green_r2 - img_blue_r2 + 16'd32768;
  end

  reg     [7:0]           img_Y,img_Cb,img_Cr;
  always @(posedge clk) begin
    img_Y  <= sum_Y[15:8];
    img_Cb <= sum_Cb[15:8];
    img_Cr <= sum_Cr[15:8];
  end

  reg     [2:0]        per_img_herf_r,per_img_vsync_r,per_img_valid_r;

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
      per_img_vsync_r<=3'b0;
      per_img_herf_r<=3'b0;
      per_img_valid_r<=3'b0;
    end
    else begin
      per_img_vsync_r <= {per_img_vsync_r[1:0],per_img_vsync};
      per_img_herf_r <= {per_img_herf_r[1:0],per_img_herf};
      per_img_valid_r <= {per_img_valid_r[1:0], per_img_valid};
    end
  end

  assign    post_img_Cb = post_img_valid? img_Cb : 8'h0  ;
  assign    post_img_Y =  post_img_valid? img_Y  : 8'h0  ;
  assign    post_img_Cr = post_img_valid? img_Cr : 8'h0  ;
  assign    post_img_valid = per_img_valid_r[2];
  assign    post_img_herf = per_img_herf_r[2]   ;
  assign    post_img_vsync = per_img_vsync_r[2]   ;

endmodule 