%利用 matlab的自带处理函数与fpga做对比
clc;close all;clear all;
IMG_gray=imread('../picture/RGB2YCBCR.bmp');
IMG_gray=uint8(IMG_gray);
h = size(IMG_gray,1);
w = size(IMG_gray,2);
imshow(IMG_gray);%显示原图
title("原图灰度图");

%%
figure;
img_heast_eq = histeq(IMG_gray);
imshow(img_heast_eq);%显示直方图拉伸
title("直方图拉伸");

%%
figure;
img_constast = imadjust(IMG_gray,[0.3 0.7],[0 1]); % 增强对比度
imshow(img_constast);%显示增强对比度
title("增强对比度");

%%
figure;
img_gamma=zeros(h,w);
for i = 1 :h
   for j = 1:w
        img_gamma(i,j) = (255/255.^2.2)*double(IMG_gray(i,j)).^2.2; % gamma映射
   end
end
img_gamma=uint8(img_gamma);
imshow(img_gamma);%gamma映射
title("gamma映射");

%%
figure;
img_avreage=imfilter(IMG_gray,fspecial('average',3),'replicate');
imshow(img_avreage);%均值滤波
title("均值滤波");

%%
figure;
img_med=medfilt2(IMG_gray,[3,3]);
imshow(img_med);%中值滤波
title("中值滤波");

%%
figure;
g=fspecial('gaussian',[5,5],3);
img_gauss=imfilter(IMG_gray,g,'replicate');
imshow(img_gauss);%高斯滤波
title("高斯滤波");

%%
figure;
img_bilateral=bfilter2(IMG_gray,5,3,0.1);
imshow(img_bilateral);%双边滤波
title("双边滤波");

%%
figure;
img_region=region_bin_auto(IMG_gray,5,0.9);
imshow(img_region);%局部二值化
title("局部二值化");


%%
figure;
img_sobel=sobel_detector(IMG_gray,127);
imshow(img_sobel);%sobel边沿检测
title("sobel边沿检测");

%%
figure;
img__erosion=bin_erosion(img_sobel);
imshow(img__erosion);%腐蚀
title("腐蚀");

%%
figure;
img_dialtion=bin_dialtion(img__erosion);
imshow(img_dialtion);%膨胀
title("膨胀");

%%
figure;
img_robert=Robert_Edge_Detector(IMG_gray);
img_robert=img_robert + IMG_gray;
imshow(img_robert);%robert锐化
title("robert锐化");

%%
figure;
img_sobel=Sobel_Edge_Detector(IMG_gray);
img_sobel = img_sobel + IMG_gray;
imshow(img_sobel);%sobel锐化
title("sobel锐化");


%%
figure;
img_laplacian=Laplacian_Edge_Detector(IMG_gray);
 img_laplacian = uint8(img_laplacian + double(IMG_gray));
imshow(img_laplacian);%laplacian锐化
title("laplacian锐化");










%%
%简单地说:
%A为给定图像，归一化到[0,1]的矩阵
%W为双边滤波器（核）的边长/2
%定义域方差σd记为SIGMA(1),值域方差σr记为SIGMA(2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pre-process input and select appropriate filter.
function B = bfilter2(A,n,sigma_d, sigma_r)

% clear all;   close all;  clc;
% A = rgb2gray(imread('../../0_images/Scart.jpg'));    % 读取jpg图像
% n = 5; sigma_d = 3;  sigma_r =0.1;  

A = im2double(A);
w=floor(n/2);

% Pre-compute Gaussian distance weights.
[X,Y] = meshgrid(-w:w,-w:w);
G = exp(-(X.^2+Y.^2)/(2*sigma_d^2));

% Create waitbar.
h = waitbar(0,'Applying bilateral filter...');
set(h,'Name','Bilateral Filter Progress');

% Apply bilateral filter.
%计算值域核H 并与定义域核G 乘积得到双边权重函数F
dim = size(A);
B = zeros(dim);
for i = 1:dim(1)
   for j = 1:dim(2)
         if(i<w+1 || i>dim(1)-w || j<w+1 || j>dim(2)-w)
            B(i,j) = A(i,j);    %边缘像素取原值
         else
%          % Extract local region.
%          iMin = max(i-w,1);
%          iMax = min(i+w,dim(1));
%          jMin = max(j-w,1);
%          jMax = min(j+w,dim(2));
%          else
            I = A(i-w:i+w, j-w:j+w);

         %定义当前核所作用的区域为(iMin:iMax,jMin:jMax)
%          I = A(iMin:iMax,jMin:jMax);%提取该区域的源图像值赋给I

         % Compute Gaussian intensity weights.
         
         H = exp(-(I-A(i,j)).^2/(2*sigma_r^2));
         % Calculate bilateral filter response.
         F = H.*G;
         B(i,j) = sum(F(:).*I(:))/sum(F(:));
         end

   end
   waitbar(i/dim(1));
end

% Close waitbar.
close(h);
B = im2uint8(B);

%     subplot(121);imshow(A);title('【1】原始图像');
%     subplot(122);imshow(B);title('【2】双边滤波结果');
end
%%
% 灰度图像布局自动二值化实现
% IMG为输入的灰度图像
% n为求阈值的窗口大小，为奇数
% p为阈值的缩放
function Q=region_bin_auto(IMG,n,p)    

[h,w] = size(IMG); 
Q = zeros(h,w);
win = zeros(n,n);

bar = waitbar(0,'Speed of auto region binarization process...');  %创建进度条
for i=1 : h
    for j=1:w
        if(i<(n-1)/2+1 || i>h-(n-1)/2 || j<(n-1)/2+1 || j>w-(n-1)/2)
            Q(i,j) = 255; 	 %边缘像素不计算，直接赋255
        else
            win =  IMG(i-(n-1)/2:i+(n-1)/2,  j-(n-1)/2:j+(n-1)/2);    %n*n窗口的矩阵
            thresh = floor( sum(sum(win))/(n*n) * p);
%             thresh = floor(sum(win,'all')/(n*n) * p);
            if(win((n-1)/2+1,(n-1)/2+1) < thresh)
                Q(i,j) = 0;
            else
                Q(i,j) = 255;
            end
        end
    end  
    waitbar(i/h);
end 
close(bar);   % Close waitbar.

Q=uint8(Q);
end

%%
function Q=sobel_detector(IMG,thresh) 

[h,w] = size(IMG); 
Q = ones(h,w);

% -------------------------------------------------------------------------
%         Gx                  Gy				  Pixel
% [   -1  0   +1  ]   [   -1  -2   -1 ]     [   P1  P2   P3 ]
% [   -2  0   +2  ]   [   0   0    0  ]     [   P4  P5   P6 ]
% [   -1  0   +1  ]   [   +1  +2   +1 ]     [   P7  P8   P9 ]
Sobel_X = [-1, 0, 1, -2, 0, 2, -1, 0, 1];   % Weight x
Sobel_Y = [-1,-2,-1,  0, 0, 0,  1, 2, 1];   % Weight y

IMG_Gray = double(IMG);    
IMG_Sobel = ones(h,w);    

n=3;
for i=1 : h
    for j=1:w
        if(i<(n-1)/2+1 || i>h-(n-1)/2 || j<(n-1)/2+1 || j>w-(n-1)/2)
            IMG_Sobel(i,j) = 0; 	 %边缘像素不处理
        else
            temp1 = Sobel_X(1) * IMG_Gray(i-1,j-1) 	+ Sobel_X(2) * IMG_Gray(i-1,j)	+ Sobel_X(3) * IMG_Gray(i-1,j+1) +...
                    Sobel_X(4) * IMG_Gray(i,j-1) 	+ Sobel_X(5) * IMG_Gray(i,j) 	+ Sobel_X(6) * IMG_Gray(i,j+1) +...
                    Sobel_X(7) * IMG_Gray(i+1,j-1) 	+ Sobel_X(8) * IMG_Gray(i+1,j)	+ Sobel_X(9) * IMG_Gray(i+1,j+1);
            temp2 = Sobel_Y(1) * IMG_Gray(i-1,j-1)	+ Sobel_Y(2) * IMG_Gray(i-1,j)	+ Sobel_Y(3) * IMG_Gray(i-1,j+1) +...
                    Sobel_Y(4) * IMG_Gray(i,j-1) 	+ Sobel_Y(5) * IMG_Gray(i,j) 	+ Sobel_Y(6) * IMG_Gray(i,j+1) +...
                    Sobel_Y(7) * IMG_Gray(i+1,j-1) 	+ Sobel_Y(8) * IMG_Gray(i+1,j)	+ Sobel_Y(9) * IMG_Gray(i+1,j+1);
            temp3 = sqrt(temp1^2 + temp2^2);
            if(uint8(temp3) > thresh)
                IMG_Sobel(i,j) = 1;
            else
                IMG_Sobel(i,j) = 0; 
            end
        end
    end
end

Q=IMG_Sobel;
end

%%
function Q=bin_erosion(IMG) 

[h,w] = size(IMG); 
IMG_Erosion = ones(h,w);    

% -------------------------------------------------------------------------
n=3;
for i=1:h
    for j=1:w
        if(i<(n-1)/2+1 || i>h-(n-1)/2 || j<(n-1)/2+1 || j>w-(n-1)/2)
            IMG_Erosion(i,j) = 0; 	 %边缘像素不处理
        else
			IMG_Erosion(i,j) = IMG(i-1,j-1) & IMG(i-1,j) & IMG(i-1,j+1) &...
                               IMG(i,j-1)   & IMG(i,j)   & IMG(i,j+1)   &...
                               IMG(i+1,j-1) & IMG(i+1,j) & IMG(i+1,j+1);
        end
    end
end

Q = IMG_Erosion;
end

%%
function Q=bin_dialtion(IMG) 

[h,w] = size(IMG); 
IMG_Dilation = ones(h,w);    

% -------------------------------------------------------------------------
n=3;
for i=1 : h
    for j=1:w
        if(i<(n-1)/2+1 || i>h-(n-1)/2 || j<(n-1)/2+1 || j>w-(n-1)/2)
            IMG_Dilation(i,j) = 0; 	%边缘像素不处理
        else
			IMG_Dilation(i,j) = IMG(i-1,j-1) | IMG(i-1,j) | IMG(i-1,j+1) |...
                                IMG(i,j-1)   | IMG(i,j)   | IMG(i,j+1)   |...
                                IMG(i+1,j-1) | IMG(i+1,j) | IMG(i+1,j+1);
        end
    end
end

Q = IMG_Dilation;
end

%%
% 灰度图像Robert边缘检测算法实现
% IMG为输入的灰度图像
% Q为输出的灰度图像
function Q = Robert_Edge_Detector(IMG)

[h,w] = size(IMG);              % 获取图像的高度h和宽度w
Q = zeros(h,w);                 % 初始化Q为全0的h*w大小的图像

% -------------------------------------------------------------------------
%       Wx             Wy             Pixel
% [   0  +1  ]   [  +1   0  ]     [  P1  P2  ]
% [  -1   0  ]   [   0  -1  ]     [  P3  P4  ]
Wx = [0,1;-1,0];          % Weight x
Wy = [1,0;0,-1];          % Weight y

IMG = double(IMG);

for i = 1 : h
    for j = 1 : w
        if(i>h-1 || j>w-1)
            Q(i,j) = 0;             % 图像右边缘和下边缘像素不处理
        else
            Gx = Wx(1,1)*IMG(i  ,j) + Wx(1,2)*IMG(i  ,j+1) +...
                 Wx(2,1)*IMG(i+1,j) + Wx(2,2)*IMG(i+1,j+1);
            Gy = Wy(1,1)*IMG(i  ,j) + Wy(1,2)*IMG(i  ,j+1) +...
                 Wy(2,1)*IMG(i+1,j) + Wy(2,2)*IMG(i+1,j+1);
            Q(i,j) = sqrt(Gx^2 + Gy^2);
        end
    end  
end 
Q=uint8(Q);
end

%%
% 灰度图像Sobel边缘检测算法实现
% IMG为输入的灰度图像
% Q为输出的灰度图像
function Q = Sobel_Edge_Detector(IMG)

[h,w] = size(IMG);              % 获取图像的高度h和宽度w
Q = zeros(h,w);                 % 初始化Q为全0的h*w大小的图像

% -------------------------------------------------------------------------
%         Wx                Wy               Pixel
% [  -1   0  +1  ]   [  -1 -2  -1]     [  P1  P2  P3]
% [  -2   0  +2  ]   [   0  0   0]     [  P4  P5  P6]
% [  -1   0  +1  ]   [  +1 +2  +1]     [  P7  P8  P9]
Wx = [-1,0,1;-2,0,2;-1,0,1];         % Weight x
Wy = [-1,-2,-1;0,0,0;1,2,1];         % Weight y

IMG = double(IMG);

for i = 1 : h
    for j = 1 : w
        if(i<2 || i>h-1 || j<2 || j>w-1)
            Q(i,j) = 0;             % 边缘像素不处理
        else
            Gx = Wx(1,1)*IMG(i-1,j-1) + Wx(1,2)*IMG(i-1,j) + Wx(1,3)*IMG(i-1,j+1) +...
                 Wx(2,1)*IMG(i  ,j-1) + Wx(2,2)*IMG(i  ,j) + Wx(2,3)*IMG(i  ,j+1) +...
                 Wx(3,1)*IMG(i+1,j-1) + Wx(3,2)*IMG(i+1,j) + Wx(3,3)*IMG(i+1,j+1);
            Gy = Wy(1,1)*IMG(i-1,j-1) + Wy(1,2)*IMG(i-1,j) + Wy(1,3)*IMG(i-1,j+1) +...
                 Wy(2,1)*IMG(i  ,j-1) + Wy(2,2)*IMG(i  ,j) + Wy(2,3)*IMG(i  ,j+1) +...
                 Wy(3,1)*IMG(i+1,j-1) + Wy(3,2)*IMG(i+1,j) + Wy(3,3)*IMG(i+1,j+1);
            Q(i,j) = sqrt(Gx^2 + Gy^2);
        end
    end  
end 
Q=uint8(Q);
end

%%
% 灰度图像Laplacian边缘检测算法实现
% IMG为输入的灰度图像
% Q为输出的灰度图像
function Q = Laplacian_Edge_Detector(IMG)

[h,w] = size(IMG);              % 获取图像的高度h和宽度w
Q = zeros(h,w);                 % 初始化Q为全0的h*w大小的图像

% -------------------------------------------------------------------------
%         W                Pixel
% [   0  -1   0  ]   [  P1  P2  P3]
% [  -1   4  -1  ]   [  P4  P5  P6]
% [   0  +1   0  ]   [  P7  P8  P9]
W = [0,-1,0;-1,4,-1;0,-1,0];    % Weight 

IMG = double(IMG);

for i = 1 : h
    for j = 1 : w
        if(i<2 || i>h-1 || j<2 || j>w-1)
            Q(i,j) = 0;             % 边缘像素不处理
        else
            Q(i,j) = W(1,1)*IMG(i-1,j-1) + W(1,2)*IMG(i-1,j) + W(1,3)*IMG(i-1,j+1) +...
                     W(2,1)*IMG(i  ,j-1) + W(2,2)*IMG(i  ,j) + W(2,3)*IMG(i  ,j+1) +...
                     W(3,1)*IMG(i+1,j-1) + W(3,2)*IMG(i+1,j) + W(3,3)*IMG(i+1,j+1);
        end
    end  
end 
end
