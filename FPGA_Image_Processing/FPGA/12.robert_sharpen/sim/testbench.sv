`timescale  1ns/1ns
module testbench;

//----------------------------------------------------------------------
//  clk & rst_n
  reg                                            clk             ;
  reg                                            rst_n           ;
initial
begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

initial
begin
    rst_n = 1'b0;
    repeat(50) @(posedge clk);
    rst_n = 1'b1;
end
//------------------------------ ----------------------------------------
logic                      pre_img_vsync;
logic                      pre_img_hsync;
logic                      pre_img_valid;
logic      [07:0]          pre_img_data;
  wire                                           vout_done       ;
logic    [15:0]    bmp1_xres;
logic    [15:0]    bmp1_yres;
  reg                                            vout_begin    =0;
task  vout_begin_task;                                              //任务名
    // input  ;
    begin
      repeat(5) @(posedge clk);
      vout_begin = 1;
      repeat(5) @(posedge clk);
      vout_begin = 0;
    end
endtask : vout_begin_task
  parameter                                          H_SYNC         = 11'd128;   //行同步
  parameter                                          H_BACK         = 11'd88;  //行显示后沿
  parameter                                          H_DISP         = 11'd800; //行有效数据
  parameter                                          H_FRONT        = 11'd40;  //行显示前沿
  parameter                                          H_TOTAL        = 11'd1056; //行扫描周期

  parameter                                          V_SYNC         = 11'd4 ;    //场同步
  parameter                                          V_BACK         = 11'd23;   //场显示后沿
  parameter                                          V_DISP         = 11'd600;  //场有效数据
  parameter                                          V_FRONT        = 11'd1 ;    //场显示前沿
  parameter                                          V_TOTAL        = 11'd628;  //场扫描周期
  parameter                                          VIN_BMP_FILE   = "RGB2YCBCR.bmp";
  parameter                                          VIN_BMP_PATH   = "../../../../picture/";
  parameter                                          VOUT_BMP_PATH  = VIN_BMP_PATH;//"../../../../../vouBmpV/";
  parameter                                          VOUT_BMP_NAME  = "robert_sharpen";

  wire                                           post_img_vsync  ;
  wire                                           post_img_hsync  ;
  wire                                           post_img_valid  ;
  wire           [  07:00]                       post_img_data   ;

bmp_to_videoStream_8bit    #
(
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
  .iBMP_FILE_PATH                                    (VIN_BMP_PATH   ),
  .iBMP_FILE_NAME                                    (VIN_BMP_FILE)  ) 
U_bmp_to_videoStream_8bit(
  .clk                                               (clk            ),
  .rst_n                                             (rst_n          ),
  .vout_vsync                                        (pre_img_vsync  ),//输出数据场同步信号
  .vout_hsync                                        (pre_img_hsync  ),//输出数据行同步信号
  .vout_dat                                          (pre_img_data   ),//输出视频数据
  .vout_valid                                        (pre_img_valid  ),//输出视频数据有效
  .vout_begin                                        (vout_begin     ),//开始转换
  .vout_done                                         (vout_done      ),//转换结束
  .vout_xres                                         (bmp1_xres      ),//输出视频水平分辨率
  .vout_yres                                         (bmp1_yres      ) //输出视频垂直分辨率
);
robert_sharpen#(
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
 u_robert_sharpen(
  .clk                                               (clk            ),
  .rst_n                                             (rst_n          ),
  .pre_img_vsync                                     (pre_img_vsync  ),
  .pre_img_hsync                                     (pre_img_hsync  ),
  .pre_img_valid                                     (pre_img_valid  ),
  .pre_img_data                                      (pre_img_data   ),
  .post_img_vsync                                    (post_img_vsync ),
  .post_img_hsync                                    (post_img_hsync ),
  .post_img_valid                                    (post_img_valid ),
  .post_img_data                                     (post_img_data  ) 
);

    bmp_for_videoStream    #
    (
  .iREADY                                            (10             ),//插入 0-10 级流控信号， 10 是满级全速无等待
  .iBMP_FILE_PATH                                    (VOUT_BMP_PATH  ),
  .iBMP_FILE_NAME                                    (VOUT_BMP_NAME  ) 
    )
    u_bmp_for_videoStream
    (
  .clk                                               (clk            ),
  .rst_n                                             (rst_n          ),
  .vin_dat                                           (post_img_data  ),//视频数据
  .vin_valid                                         (post_img_valid ),//视频数据有效
  .vin_ready                                         (v2_ready       ),//准备好
  .frame_sync_n                                      (~post_img_vsync),//视频帧同步复位，低有效
  .vin_xres                                          (bmp1_xres      ),//视频水平分辨率
  .vin_yres                                          (bmp1_yres      ) //视频垂直分辨率
    );

initial
begin
    wait(rst_n);
    repeat(5) @(posedge clk);
      vout_begin_task ;
      @(posedge clk);
      wait(vout_done);

end
endmodule