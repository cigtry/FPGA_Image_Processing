//bmp_for_videoStream.sv
//将视频流输出写入 BMP 图片文件
//本模块不能被综合，只能用来当仿真

module bmp_for_videoStream_24bit	#
(
	parameter	iREADY			= 10,			//插入 0-10 级流控信号， 10 是满级全速无等待
  parameter                                          iBMP_FILE_PATH = ""    ,
  parameter                                          iBMP_FILE_NAME = ""   
)
(
	input					clk,
	input					rst_n,
	input					frame_sync_n,		//输入视频帧同步复位，低有效
	output					vin_ready,
	input	[2:0][7:0]		vin_dat,			//输入视频数据
	input					vin_valid,			//输入视频数据有效
	input	[15:0]			vin_xres,			//输入视频水平分辨率
	input	[15:0]			vin_yres			//输入视频垂直分辨率
);

	string	FILE_NAME;

	logic	[7:0]		fn = 0;				//帧计数
	logic	[0:53][7:0]	bmp_header;			//BMP 图像文件头
	logic	[31:0]		offsetBits;			//BMP 图像数据位置
	logic	[31:0]		width;				//BMP 图像宽度
	logic	[31:0]		height;				//BMP 图像高度
	logic	[31:0]		sizeImage;			//BMP 图像大小(字节)
	logic	[31:0]		sizePixel;			//BMP 像素数量(像素个数)
	logic	[31:0]		sizeBmpFile;		//BMP 图像文件大小(字节)

	logic	[31:0]		pixel_cnt	= 0;	//像素计数器
	logic				wr_end_flag	= 0;	//写文件结束标记
	logic	[3:0]		cnt = '1;			//延时计数器，在帧同步脉冲到来后，延时一段时间再输出视频流数据

	logic	[15:0]		sx;					//水平像素计数器
	logic	[15:0]		sy;					//垂直像素计数器
	logic	[15:0]		addr_cnt;			//图片数据水平线地址计数器

	integer 			bmp_wp = 0;			//文件指针
	integer 			i;
    logic    [15:0]    ready_cnt    = 0;
    logic            vin_ready_r = 0;
	assign	offsetBits	= $bits(bmp_header)/8;
	assign	vin_ready	= vin_ready_r;		//流控信号

	always_ff@(posedge clk)
	begin
		if(rst_n == 0)
			cnt <= '1;						//延时计数器，在帧同步脉冲到来后，延时一段时间再输出视频流数据
		else if(frame_sync_n == 0)
			cnt <= 0;
		else if( cnt != '1 )
			cnt <= cnt + 1;
	end

	always_ff@(posedge clk)
	begin
		case(cnt)
		1:	begin
				width		= vin_xres;
				height		= vin_yres;
				sizePixel	= width*height;
				sizeImage	= ((width*3+3)&16'hfffc)*height;			//BMP 像素占用内存大小，必须是4的倍数
				sizeBmpFile	= offsetBits + sizeImage;

				{bmp_header[01],bmp_header[00]}									= 16'h4d42;		//BM	TYPE
				{bmp_header[05],bmp_header[04],bmp_header[03],bmp_header[02]}	= sizeBmpFile;	//SizeBmpFile
				{bmp_header[09],bmp_header[08],bmp_header[07],bmp_header[06]}	= '0;			//Reserverd
				{bmp_header[13],bmp_header[12],bmp_header[11],bmp_header[10]}	= offsetBits;	//OffsetBits
				
				{bmp_header[17],bmp_header[16],bmp_header[15],bmp_header[14]}	= 32'h0000_0028;//Size
				{bmp_header[21],bmp_header[20],bmp_header[19],bmp_header[18]}	= width;		//Width
				{bmp_header[25],bmp_header[24],bmp_header[23],bmp_header[22]}	= height;		//Height
				{bmp_header[27],bmp_header[26]}									= 16'h0001;		//Planes
				{bmp_header[29],bmp_header[28]}									= 16'h0018;		//Bitcount
				{bmp_header[33],bmp_header[32],bmp_header[31],bmp_header[30]}	= '0;			//Compression
				{bmp_header[37],bmp_header[36],bmp_header[35],bmp_header[34]}	= '0;	//sizeImage;	//SizeImage
				{bmp_header[41],bmp_header[40],bmp_header[39],bmp_header[38]}	= 32'h0000_c40e;//XPelsPermeter
				{bmp_header[45],bmp_header[44],bmp_header[43],bmp_header[42]}	= 32'h0000_c40e;//YPelsPermeter
				{bmp_header[49],bmp_header[48],bmp_header[47],bmp_header[46]}	= '0;			//ClrUsed
				{bmp_header[53],bmp_header[52],bmp_header[51],bmp_header[50]}	= '0;			//ClrImportant
				fn			<= fn + 1;
			end
		2:	begin
				$display("vout BMP File Size      = 0x%h",sizeBmpFile);
				$display("vout Image data offset  = 0x%h",offsetBits);
				$display("vout Image width        = 0x%h",width);
				$display("vout Image heigh        = 0x%h",height);
				$display("vout Image size         = 0x%h\n",sizeImage);
                FILE_NAME = $sformatf("%s%s%s",iBMP_FILE_PATH,iBMP_FILE_NAME,".bmp");//BMP 图片文件名
                $display("bmp file name = %s !",FILE_NAME);
			end
		3:	begin
				bmp_wp	= $fopen(FILE_NAME,"wb+");

				if(bmp_wp == 0)begin					//文件建立打开失败 ？
					$display("%s file open error !",FILE_NAME);
					$stop;
				end
			end
		4:	begin
				for(i=0;i<offsetBits;i++)
				begin
					if(bmp_wp == 0)begin				//文件建立打开失败 ？
						$display("%s file open error !",FILE_NAME);
						$stop;
					end
					else begin							//文件建立打开成功
						$fwrite(bmp_wp,"%c",	bmp_header[i]);
					end
				end
			end
		default:;
		endcase
	end
	
	always_ff@(posedge clk)
	begin
		if(frame_sync_n == 0 || rst_n == 0 || cnt != '1)begin
			pixel_cnt	<= 0;
			sx			<= 0;
			sy			<= 0;
			addr_cnt	<= 0;
			wr_end_flag	<= 0;
		end
		else if( vin_ready == 1 && vin_valid == 1 )begin			//视频数据有效 写文件没结束
			pixel_cnt	<= pixel_cnt + 1;			//像素计数器
			if(sx < width -1)begin
				sx			<= sx + 1;				//水平扫描计数
				addr_cnt	<= addr_cnt + 3;		//水平地址计数，一个像素3个字节
			end
			else begin
				sx			<= 0;
				addr_cnt	<= 0;
				sy			<= sy + 1;				//垂直扫描计数，该计数器目前没有使用
			end

			if(bmp_wp == 0)begin					//文件建立打开成功
				$display("%s file open error !",FILE_NAME);
				$stop;
			end
			
			if( wr_end_flag == 0 )
			begin
				if(sx != width-1)begin					//判断当前扫描像素是否行尾
					$fwrite(bmp_wp,"%c%c%c",vin_dat[0],vin_dat[1],vin_dat[2]);	//写像素
				end
				else begin						//每行像素占用的字节数必须是4的倍数
					case(addr_cnt[1:0])
					2'b00:	$fwrite(bmp_wp,"%c%c%c%c",		vin_dat[0],vin_dat[1],vin_dat[2],0);		//
					2'b01:	$fwrite(bmp_wp,"%c%c%c",		vin_dat[0],vin_dat[1],vin_dat[2]);			///
					2'b10:	$fwrite(bmp_wp,"%c%c%c%c%c%c",	vin_dat[0],vin_dat[1],vin_dat[2],0,0,0);	
					2'b11:	$fwrite(bmp_wp,"%c%c%c%c%c",	vin_dat[0],vin_dat[1],vin_dat[2],0,0);		//
					endcase
				end
			end
		end

		if( wr_end_flag	== 0 && pixel_cnt > sizePixel -1)begin		//判断像素计数器是否到结束
			wr_end_flag	<= 1;					//置写文件结束标记
			$fclose(bmp_wp);
//			$stop;
		end
	end	//	always_ff
	

	always_ff@(posedge clk)
	begin
		if(frame_sync_n == 0 || rst_n == 0 || ready_cnt >= 9 || cnt != '1)begin
			ready_cnt	<= 0;
		end
		else if(ready_cnt < 9)
			ready_cnt	<= ready_cnt + 1;
	end
	
	always_ff@(posedge clk)
	begin
		if(frame_sync_n == 0 || rst_n == 0 || cnt != '1)begin
			vin_ready_r	<= 0;
		end
		else if(ready_cnt < iREADY || iREADY == 10)
			vin_ready_r	<= 1;
		else
			vin_ready_r	<= 0;
	end

endmodule

