//bmp_to_videoStream.sv
//用24bit BMP图片文件产生视频流
//本模块不能被综合，只能用来当仿真

module bmp_to_videoStream    #
(    //1280*720 分辨率时序参数
    parameter  H_SYNC   =  11'd40   ,   //行同步
    parameter  H_BACK   =  11'd220  ,  //行显示后沿
    parameter  H_DISP   =  11'd1280 , //行有效数据
    parameter  H_FRONT  =  11'd110  ,  //行显示前沿
    parameter  H_TOTAL  =  11'd1650 , //行扫描周期

    parameter  V_SYNC   =  11'd5    ,    //场同步
    parameter  V_BACK   =  11'd20   ,   //场显示后沿
    parameter  V_DISP   =  11'd720  ,  //场有效数据
    parameter  V_FRONT  =  11'd5    ,    //场显示前沿
    parameter  V_TOTAL  =  11'd750  ,  //场扫描周期
  parameter                                          iBMP_FILE_PATH = ""    ,							//缺省的 bmp 文件路径
  parameter                                          iBMP_FILE_NAME = "vin.bmp"//缺省的 bmp 文件名
)
(
  input                                          clk             ,
  input                                          rst_n           ,
  output   logic                                 vout_vsync      ,//输出数据场同步信号
  output   logic                                 vout_hsync      ,//输出数据行同步信号
  output   logic[2:0][7:0]  		                 vout_dat        ,//输出视频数据
  output      logic				                       vout_valid      ,//输出视频数据有效
  input                                          vout_begin      ,//开始转换
  output                                         vout_done       ,//转换结束
  output         [  15: 0]                       vout_xres       ,//输出视频水平分辨率
  output         [  15: 0]                       vout_yres        //输出视频垂直分辨率
);


    logic    [0:53][7:0]    bmp_header;                             //BMP 图像文件头
    logic    [31:0]        offsetBits;                              //BMP 图像数据位置
    logic    [31:0]        width;                                   //BMP 图像宽度
    logic    [31:0]        height;                                  //BMP 图像高度
    logic    [31:0]        sizeImage;                               //BMP 图像大小(字节)
    logic    [31:0]        sizePixel;                               //BMP 像素数量(像素个数)
    logic    [31:0]        sizeBmpFile;                             //BMP 图像文件大小(字节)
    logic    [31:0]        BufferLineWidth;                         //BMP 每行大小，单位字节，每行大小需要4字节对齐
    integer                                        bmp_rp          ;
    initial
    begin
        $display("iBMP_FILE_NAME = %s%s\n",iBMP_FILE_PATH,iBMP_FILE_NAME);
        bmp_rp    = $fopen({iBMP_FILE_PATH,iBMP_FILE_NAME},"rb");
        $fread(bmp_header,bmp_rp);                                  //读图片文件头信息

        if(bmp_header[0] != 8'h42 || bmp_header[1] != 8'h4d || bmp_rp == 0) begin
            $display("bmp file format error!!!!!!!!!!!!!!!!\n");
            $fclose(bmp_rp);
            $stop;
        end
        else begin
            sizeBmpFile       = {bmp_header[05],bmp_header[04],bmp_header[03],bmp_header[02]};
            offsetBits        = {bmp_header[13],bmp_header[12],bmp_header[11],bmp_header[10]};
            width             = {bmp_header[21],bmp_header[20],bmp_header[19],bmp_header[18]};
            height            = {bmp_header[25],bmp_header[24],bmp_header[23],bmp_header[22]};
            sizeImage         = {bmp_header[37],bmp_header[36],bmp_header[35],bmp_header[34]};
            sizePixel         = width * height;
            BufferLineWidth   = (width*(bmp_header[28]>>3)+(bmp_header[28]>>3)) & 32'hffff_fffc;       //BMP 文件，每行需要4字节对齐
            $display("vin BMP File Size         = 0x%h",sizeBmpFile);
            $display("vin Image data offset     = 0x%h",offsetBits);
            $display("vin Image width           = 0x%h",width);
            $display("vin Image heigh           = 0x%h",height);
            $display("vin Image size            = 0x%h",sizeImage);
            $display("vin Image pixel number    = 0x%h",sizePixel);
            $display("vin Image BufferLineWidth = 0x%h\n",BufferLineWidth);
            $fseek(bmp_rp,offsetBits,0);                            //将读文件指针移到图片数据去
        end
    end

    logic                     vout_begin_d;
    logic                     pos_beign;
    always_ff @( posedge clk ) begin 
      vout_begin_d <= vout_begin;
    end
    assign    pos_beign =  vout_begin &  (~vout_begin_d) ;

    logic             [31:0]      row_cnt;//行计数器
    logic             [31:0]      col_cnt;//列计数器
    logic                         vout_busy;
    always_ff @( posedge clk ) begin 
      if(!rst_n)begin
        vout_busy <= 1'b0;
      end
      else if(pos_beign && (!vout_busy))begin
        vout_busy <= 1'b1;
      end
      else if((row_cnt == (V_TOTAL - 1) ) && (col_cnt == (H_TOTAL - 1 )))begin
        vout_busy <= 1'b0;
      end
      else begin
        vout_busy <= vout_busy;
      end
    end

    always_ff @( posedge clk ) begin 
      if(!rst_n)begin
        col_cnt <= 32'b0;
      end
      else if(!vout_busy )begin
        col_cnt <= 32'b0;
      end
      else if(col_cnt == (H_TOTAL - 1))begin
        col_cnt <= 32'b0;
      end
      else begin
        col_cnt <= col_cnt + 1;
      end
    end
    
    always_ff @( posedge clk ) begin 
      if(!rst_n)begin
        row_cnt <= 32'b0;
      end
      else if(!vout_busy )begin
        row_cnt <= 32'b0;
      end
      else if(col_cnt == (H_TOTAL - 1))begin
        row_cnt <= row_cnt + 1;
      end
      else begin
        row_cnt <= row_cnt;
      end
    end

    always_ff @(posedge clk ) begin 
      if (!rst_n) begin
        vout_vsync <= 1'b0;
      end
      else if(vout_busy)begin
        if (row_cnt < V_SYNC) begin
          vout_vsync <= 1'b1;
        end
        else begin
          vout_vsync <= 1'b0;
        end
      end
      else begin
        vout_vsync <= 1'b0;
      end
    end

    always_ff @(posedge clk ) begin 
      if (!rst_n) begin
        vout_hsync <= 1'b0;
      end
      else if(vout_busy)begin
        if (col_cnt < H_SYNC) begin
          vout_hsync <= 1'b1;
        end
        else begin
          vout_hsync <= 1'b0;
        end
      end
      else begin
        vout_hsync <= 1'b0;
      end
    end

    always_ff @( posedge clk ) begin 
      if (!rst_n) begin
        vout_valid <= 1'b0;
      end
      else if(vout_busy)begin
        if (((col_cnt >= H_SYNC+H_BACK) && (col_cnt < H_SYNC+H_BACK+H_DISP))
                 &&((row_cnt >= V_SYNC+V_BACK) && (row_cnt < V_SYNC+V_BACK+V_DISP))) begin
          vout_valid <= 1'b1;
        end
        else begin
          vout_valid <= 1'b0;
        end
      end
      else begin
        vout_valid <= 1'b0;
      end
    end

   logic    [0:2][7:0]    pixel_dat;
  assign                                             vout_xres      = width;
  assign                                             vout_yres      = height;

  assign                                             vout_dat[0]    = pixel_dat[0];
  assign                                             vout_dat[1]    = pixel_dat[1];
  assign                                             vout_dat[2]    = pixel_dat[2];



    always_ff@(posedge clk)
    begin
        if(rst_n == 0 || pos_beign )begin
            pixel_dat    <= 0;
            $fseek(bmp_rp,offsetBits,0);                            //将读文件指针移到图片数据去
        end
        else if(((col_cnt >= H_SYNC+H_BACK) && (col_cnt < H_SYNC+H_BACK+H_DISP))
              &&((row_cnt >= V_SYNC+V_BACK) && (row_cnt < V_SYNC+V_BACK+V_DISP)))begin
                if(col_cnt == H_SYNC+H_BACK - 1)begin                                    //判断行首
                    $fseek(bmp_rp,offsetBits+(BufferLineWidth*(row_cnt-V_SYNC-V_BACK-1)),0);//将读文件指针移到图片数据的当前行首
                    $fread(pixel_dat,bmp_rp);
                end
                else begin
                    $fread(pixel_dat,bmp_rp);
                end
            end
        else begin
                pixel_dat    <= 0;
        end
    end                                                             //	always_ff
  assign    vout_done = (row_cnt == (V_TOTAL - 1) ) && (col_cnt == (H_TOTAL - 1 ) );
endmodule



	


