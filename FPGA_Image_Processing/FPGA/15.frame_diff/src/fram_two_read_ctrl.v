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
// Last modified Date:     2024/07/24 14:02:48 
// Last Version:           V1.0 
// Descriptions:            
//---------------------------------------------------------------------------------------- 
// Created by:             USER_NAME
// Created date:           2024/07/24 14:02:48 
// Version:                V1.0 
// TEXT NAME:              axi_ddr3_adpter.v 
// PATH:                   C:\Users\maccura\Desktop\code_main\fpga\axi_interface\axi_ddr3_adpter.v 
// Descriptions:            
//                          
//---------------------------------------------------------------------------------------- 
//****************************************************************************************// 

module fram_two_read_ctrl#(
    parameter integer C_M_AXI_ADDR_WIDTH    = 30,
    parameter integer C_M_AXI_DATA_WIDTH    = 128,
    parameter integer DDR_WR_LEN            = 128,                  //写突发长度 128 个 64bit
    parameter integer DDR_RD_LEN            = 128                   //读突发长度 128 个 64bit 
    )(
  input                                          clk             ,
  input                                          rst_n           ,

  input                                          wr_clk          ,
  input                                          wr_rst          ,
  input          [C_M_AXI_ADDR_WIDTH - 1 : 00]   wr_addr_begin   ,
  input          [C_M_AXI_ADDR_WIDTH - 1 : 00]   wr_addr_end     ,
  input                                          wr_data_valid   ,
  input          [  15:00]                       wr_data_in      ,

  input                                          rd_clk          ,
  input                                          rd_rst          ,
  input                                          rd_data_req     ,
  output                                         wr_flag_done    ,
  input          [C_M_AXI_ADDR_WIDTH - 1 : 00]   rd_addr_begin   ,
  input          [C_M_AXI_ADDR_WIDTH - 1 : 00]   rd_addr_end     ,
  output         [  15:00]                       rd_data_out     ,
  output                                         rd_valid_out    ,
  output         [  15:00]                       rd_data_out1    ,
  output                                         rd_valid_out1   ,
 //user port
  output reg                                     wr_start        ,
  output wire    [C_M_AXI_ADDR_WIDTH - 1 : 00]   wr_addr         ,
  output wire    [  07:00]                       wr_len          ,
  output wire    [C_M_AXI_DATA_WIDTH - 1 : 00]   wr_data         ,
  input  wire                                    wr_req          ,
  input  wire                                    wr_busy         ,
  input  wire                                    wr_done         ,

  output reg                                     rd_start        ,
  output wire    [C_M_AXI_ADDR_WIDTH - 1 : 00]   rd_addr         ,
  input  wire    [C_M_AXI_DATA_WIDTH-1: 0]       rd_data         ,
  output wire    [  07:00]                       rd_len          ,
  input  wire                                    rd_done         ,
  input  wire                                    rd_busy         ,
  input  wire                                    rd_vld           
);

  reg                                            wr_burst_start_reg  ;
  reg            [C_M_AXI_ADDR_WIDTH - 1 : 00]   wr_addr_reg     ;
  reg                                            rd_burst_start_reg  ;
  reg            [C_M_AXI_ADDR_WIDTH - 1 : 00]   rd_addr_reg     ;
  reg                                            rd_burst_start_reg1  ;
  reg            [C_M_AXI_ADDR_WIDTH - 1 : 00]   rd_addr_reg1    ;
  reg                                            wr_rst_reg1     ;
  reg                                            wr_rst_reg2     ;
  reg                                            rd_rst_reg1     ;
  reg                                            rd_rst_reg2     ;

  reg                                            read_done_r     ;
  reg                                            rd_data_en      ;
  //**************************************************************//
  wire                                           wr_fifo_full    ;
  wire                                           wr_fifo_empty   ;
  wire           [  15:00]                       wr_fifo_din     ;
  wire                                           wr_fifo_wr_en   ;
  wire           [ 127:00]                       wr_fifo_dout    ;
  wire                                           wr_fifo_rd_en   ;
  wire           [  10:00]                       wr_fifo_rd_data_count  ;
  wire           [  13:00]                       wr_fifo_wr_data_count  ;

  assign                                             wr_fifo_din    = wr_data_in;
  assign                                             wr_fifo_wr_en  = wr_data_valid;
  assign                                             wr_data        = wr_fifo_dout;
  assign                                             wr_fifo_rd_en  = wr_req&&(!wr_fifo_empty);
  //**************************************************************//
  reg                                            rd_addr_switch_flag  ;
  wire                                           rd_fifo_full    ;
  wire                                           rd_fifo_empty   ;
  wire           [ 127:00]                       rd_fifo_din     ;
  wire                                           rd_fifo_wr_en   ;
  wire           [  15:00]                       rd_fifo_dout    ;
  wire                                           rd_fifo_rd_en   ;
  wire           [  13:00]                       rd_fifo_rd_data_count  ;
  wire           [  10:00]                       rd_fifo_wr_data_count  ;
  assign                                             rd_fifo_din    = rd_data;
  assign                                             rd_fifo_wr_en  = rd_vld && rd_addr_switch_flag;
  assign                                             rd_data_out    = rd_fifo_dout;
  assign                                             rd_valid_out   = rd_data_req&(!rd_fifo_empty);
  assign                                             rd_fifo_rd_en  = rd_data_req;

  wire                                           rd_fifo_full1   ;
  wire                                           rd_fifo_empty1  ;
  wire           [ 127:00]                       rd_fifo_din1    ;
  wire                                           rd_fifo_wr_en1  ;
  wire           [  15:00]                       rd_fifo_dout1   ;
  wire                                           rd_fifo_rd_en1  ;
  wire           [  13:00]                       rd_fifo_rd_data_count1  ;
  wire           [  10:00]                       rd_fifo_wr_data_count1  ;
  assign                                             rd_fifo_din1   = rd_data;
  assign                                             rd_fifo_wr_en1 = rd_vld&& (~rd_addr_switch_flag);
  assign                                             rd_data_out1   = rd_fifo_dout1;
  assign                                             rd_valid_out1  = rd_data_req&(!rd_fifo_empty1);
  assign                                             rd_fifo_rd_en1 = rd_data_req;
  //
  always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      wr_start <= 1'b0;
    end
    else begin
      wr_start <=wr_burst_start_reg;
    end
  end                                                               //always end
  
  assign                                             wr_addr        = wr_addr_reg;
  assign                                             wr_len         = DDR_WR_LEN;

  always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      rd_start <= 1'b0;
    end
    else begin
      if (~rd_addr_switch_flag) begin
        rd_start <=rd_burst_start_reg;
      end
      else begin
        rd_start <= rd_burst_start_reg1;
      end
      
    end
  end                                                               //always end

  assign                                             rd_addr        = rd_addr_switch_flag ? rd_addr_reg1 :rd_addr_reg;
  assign                                             rd_len         = DDR_RD_LEN;

  always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      wr_rst_reg1 <= 1'b0;
      wr_rst_reg2 <= 1'b0;
      rd_rst_reg1 <= 1'b0;
      rd_rst_reg2 <= 1'b0;
    end
    else begin
      wr_rst_reg1 <= wr_rst;
      wr_rst_reg2 <= wr_rst_reg1;
      rd_rst_reg1 <= rd_rst;
      rd_rst_reg2 <= rd_rst_reg1;
    end
  end                                                               //always end

  //产生写请求
  always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      wr_burst_start_reg <= 1'b0;
    end
    else if((wr_fifo_rd_data_count >=DDR_WR_LEN)&& (wr_busy==1'b0) )begin
      wr_burst_start_reg <= 1'b1;
    end
    else begin
      wr_burst_start_reg <= 1'b0;
    end
  end                                                               //always end

  reg            [  01:00]                       addr_bank       ;
  reg            [C_M_AXI_ADDR_WIDTH - 1 : 00]   wr_addr_b       ;
  reg            [C_M_AXI_ADDR_WIDTH - 1 : 00]   wr_addr_e       ;
  reg                                            pos_addr_bank   ;
  
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      addr_bank <= 1'b0;
    end
    else if((wr_addr_reg >= wr_addr_e)&&(pos_addr_bank==1'b0))begin
      addr_bank <= addr_bank + 1'b1;
    end
    else begin
      addr_bank <= addr_bank;
    end
  end

 always @(*)begin
       wr_addr_b <= wr_addr_begin + ((wr_addr_end - wr_addr_begin+1) ) *addr_bank;
       wr_addr_e <= wr_addr_end +   ((wr_addr_end - wr_addr_begin+1) ) *addr_bank;
 end


  always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      pos_addr_bank <= 1'b0;
    end
    else if((wr_addr_reg >= wr_addr_e))begin
      pos_addr_bank <= 1'b1;
    end
    else begin
      pos_addr_bank <= 1'b0;
    end
  end                                                               //always end

  //完成一次突发对写地址进行相加
  always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      wr_addr_reg <= wr_addr_b;
    end
    else if(wr_rst_reg1 & (~wr_rst_reg2))begin
      wr_addr_reg <= wr_addr_b;
    end
    else if(pos_addr_bank ||(wr_addr_reg >= wr_addr_e) ) begin
      wr_addr_reg <= wr_addr_b;
    end
    else if(wr_done == 1'b1)begin
      wr_addr_reg <= wr_addr_reg + (DDR_WR_LEN *(C_M_AXI_DATA_WIDTH/8));//128bit /8 =16个字节 
      end
    else begin
      wr_addr_reg <= wr_addr_reg;
    end
  end                                                               //always end

  always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      rd_data_en <= 1'b0;
    end
    else if((addr_bank == 3 )&& (wr_done == 1'b1))begin
      rd_data_en <= 1'b1;
    end
    else begin
      rd_data_en <= rd_data_en;
    end
  end                                                               //always end
  assign wr_flag_done = rd_data_en;
  

  reg            [  01:00]                       rd_addr_bank    ;
  reg            [C_M_AXI_ADDR_WIDTH - 1 : 00]   rd_addr_b       ;
  reg            [C_M_AXI_ADDR_WIDTH - 1 : 00]   rd_addr_e       ;
  reg                                            pos_rd_addr_bank  ;
  wire            [  01:00]                       rd_addr_bank_add    ;
  assign rd_addr_bank_add = (rd_addr_bank + 1);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rd_addr_bank <= 1'b1;
    end
    else if((rd_addr_reg >= rd_addr_e)&&(rd_addr_bank_add!=addr_bank)&&(!pos_rd_addr_bank))begin
      rd_addr_bank <= rd_addr_bank + 1'b1;
    end
    else begin
      rd_addr_bank <= rd_addr_bank;
    end
  end

  always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      pos_rd_addr_bank <= 1'b0;
    end
    else if((rd_addr_reg >= rd_addr_e))begin
      pos_rd_addr_bank <= 1'b1;
    end
    else begin
      pos_rd_addr_bank <= 1'b0;
    end
  end                                                               //always end

 always @(*)begin
      rd_addr_b <= rd_addr_begin + ((rd_addr_end - rd_addr_begin +1)) * rd_addr_bank;
      rd_addr_e <= rd_addr_end +   ((rd_addr_end - rd_addr_begin+1))  * rd_addr_bank;
 end

  //读请求
  always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      rd_burst_start_reg <= 1'b0;
    end
    else if((rd_fifo_wr_data_count <= 10'd1000 - DDR_RD_LEN) && (rd_busy == 1'b0) && (rd_data_en == 1'b1)&&(rd_addr_reg <= rd_addr_e)&&(!rd_addr_switch_flag))begin
      rd_burst_start_reg <= 1'b1;
    end
    else begin
      rd_burst_start_reg <= 1'b0;
    end
  end                                                               //always end

  //读地址
  always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        rd_addr_reg <= rd_addr_b;
    end
    else if(rd_rst_reg1 & (~rd_rst_reg2))begin
      rd_addr_reg <= rd_addr_b;
    end
    else if(pos_rd_addr_bank || (rd_addr_reg >= rd_addr_e))begin
      rd_addr_reg <= rd_addr_b;
    end
    else if(((rd_done == 1'b1) && (read_done_r == 1'b0)) && (!rd_addr_switch_flag))begin
      rd_addr_reg <= rd_addr_reg + (DDR_WR_LEN *(C_M_AXI_DATA_WIDTH/8));
    end
    else begin
      rd_addr_reg <= rd_addr_reg;
    end
  end                                                               //always end

/************************************************************************/
/**************************差帧******************************************/
  reg            [  01:00]                       rd_addr_bank1   ;
  reg            [C_M_AXI_ADDR_WIDTH - 1 : 00]   rd_addr_b1      ;
  reg            [C_M_AXI_ADDR_WIDTH - 1 : 00]   rd_addr_e1      ;
  reg                                            pos_rd_addr_bank1  ;
    wire            [  01:00]                       rd_addr_bank_add1    ;
  assign rd_addr_bank_add1 = (rd_addr_bank1 + 1);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rd_addr_bank1 <= 1'b0;
    end
    else if((rd_addr_reg1 >= rd_addr_e1)&&(rd_addr_bank_add1!=rd_addr_bank)&&(!pos_rd_addr_bank1))begin
      rd_addr_bank1 <= rd_addr_bank1 + 1'b1;
    end
    else begin
      rd_addr_bank1 <= rd_addr_bank1;
    end
  end

  always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      pos_rd_addr_bank1 <= 1'b0;
    end
    else if((rd_addr_reg1 >= rd_addr_e1))begin
      pos_rd_addr_bank1 <= 1'b1;
    end
    else begin
      pos_rd_addr_bank1 <= 1'b0;
    end
  end                                                               //always end

 always @(*)begin
      rd_addr_b1 <= rd_addr_begin + ((rd_addr_end - rd_addr_begin +1)) * rd_addr_bank1;
      rd_addr_e1 <= rd_addr_end +   ((rd_addr_end - rd_addr_begin+1))  * rd_addr_bank1;
 end

  //读请求
  always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      rd_burst_start_reg1 <= 1'b0;
    end
    else if((rd_fifo_wr_data_count1 <= 10'd1000 - DDR_RD_LEN) && (rd_busy == 1'b0) && (rd_data_en == 1'b1)&&(rd_addr_reg1 <= rd_addr_e1)&&(rd_addr_switch_flag))begin
      rd_burst_start_reg1 <= 1'b1;
    end
    else begin
      rd_burst_start_reg1 <= 1'b0;
    end
  end                                                               //always end

  //读地址
  always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        rd_addr_reg1 <= rd_addr_b1;
    end
    else if(rd_rst_reg1 & (~rd_rst_reg2))begin
      rd_addr_reg1 <= rd_addr_b1;
    end
    else if(pos_rd_addr_bank1 || (rd_addr_reg1 >= rd_addr_e1))begin
      rd_addr_reg1 <= rd_addr_b1;
    end
    else if(((rd_done == 1'b1) && (read_done_r == 1'b0)) && (rd_addr_switch_flag))begin
      rd_addr_reg1 <= rd_addr_reg1 + (DDR_WR_LEN *(C_M_AXI_DATA_WIDTH/8));
    end
    else begin
      rd_addr_reg1 <= rd_addr_reg1;
    end
  end                                                               //always end

  always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      read_done_r <= 1'b0;
    end
    else begin
      read_done_r <= rd_done;
    end
  end                                                               //always end
  
  always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      rd_addr_switch_flag <= 1'b0;
    end
    else if((rd_done == 1'b1) && (read_done_r == 1'b0))begin
      rd_addr_switch_flag <= ~rd_addr_switch_flag;
    end
    else begin
      rd_addr_switch_flag <= rd_addr_switch_flag;
    end
  end                                                               //always end
  
wr_ddr3_fifo u_wr_ddr3_fifo (
  .wr_clk                                            (wr_clk         ),// input wire wr_clk
  .wr_rst                                            (!wr_rst_reg2   ),// input wire wr_rst
  .rd_clk                                            (clk            ),// input wire rd_clk
  .rd_rst                                            (!rst_n         ),// input wire rd_rst
  .din                                               (wr_fifo_din    ),// input wire [15 : 0] din
  .wr_en                                             (wr_fifo_wr_en  ),// input wire wr_en
  .rd_en                                             (wr_fifo_rd_en  ),// input wire rd_en
  .dout                                              (wr_fifo_dout   ),// output wire [127 : 0] dout
  .full                                              (wr_fifo_full   ),// output wire full
  .empty                                             (wr_fifo_empty  ),// output wire empty
  .rd_data_count                                     (wr_fifo_rd_data_count),// output wire [10 : 0] rd_data_count
  .wr_data_count                                     (wr_fifo_wr_data_count) // output wire [13 : 0] wr_data_count
);

  rd_ddr3_fifo u_rd_ddr3_fifo (
  .wr_clk                                            (clk            ),// input wire wr_clk
  .wr_rst                                            (!rst_n        ),// input wire wr_rst
  .rd_clk                                            (rd_clk         ),// input wire rd_clk
  .rd_rst                                            (!rd_rst   ),// input wire rd_rst
  .din                                               (rd_fifo_din    ),// input wire [127 : 0] din
  .wr_en                                             (rd_fifo_wr_en  ),// input wire wr_en
  .rd_en                                             (rd_fifo_rd_en  ),// input wire rd_en
  .dout                                              (rd_fifo_dout   ),// output wire [15 : 0] dout
  .full                                              (rd_fifo_full   ),// output wire full
  .empty                                             (rd_fifo_empty  ),// output wire empty
  .rd_data_count                                     (rd_fifo_rd_data_count),// output wire [13 : 0] rd_data_count
  .wr_data_count                                     (rd_fifo_wr_data_count) // output wire [10 : 0] wr_data_count
);

  rd_ddr3_fifo u_rd_ddr3_fifo1 (
  .wr_clk                                            (clk            ),// input wire wr_clk
  .wr_rst                                            (!wr_rst        ),// input wire wr_rst
  .rd_clk                                            (rd_clk         ),// input wire rd_clk
  .rd_rst                                            (!rd_rst   ),// input wire rd_rst
  .din                                               (rd_fifo_din1   ),// input wire [127 : 0] din
  .wr_en                                             (rd_fifo_wr_en1 ),// input wire wr_en
  .rd_en                                             (rd_fifo_rd_en1 ),// input wire rd_en
  .dout                                              (rd_fifo_dout1  ),// output wire [15 : 0] dout
  .full                                              (rd_fifo_full1  ),// output wire full
  .empty                                             (rd_fifo_empty1 ),// output wire empty
  .rd_data_count                                     (rd_fifo_rd_data_count1),// output wire [13 : 0] rd_data_count
  .wr_data_count                                     (rd_fifo_wr_data_count1) // output wire [10 : 0] wr_data_count
);

endmodule
