
%读取图片并转换成ycbcr格式
clear all;close all;clc;
IMG1 = imread('../picture/Scart.jpg');
h = size(IMG1 , 1);
w = size(IMG1 , 2);

subplot(221);imshow(IMG1);title("RGB");
% Y = (R*76+G*150+B*29) >> 8 
% Cb = (-R*43 - G*84 + B*128 + 32768) >> 8
% Cr = (R*128 - G*107 -B*20 + 32768) >> 8
IMG1 = double(IMG1);
IMG_YCbCr = zeros(h,w,3);

for i = 1:h
    for j=1:w
        R= IMG1(i,j,1);
        G= IMG1(i,j,2);
        B= IMG1(i,j,3);
        IMG_YCbCr(i,j,1) = bitshift(( R*76 + G*150 + B*29),-8);
        IMG_YCbCr(i,j,2) = bitshift((-R*43 - G*84 + B*128 + 32768),-8);
        IMG_YCbCr(i,j,3) = bitshift(( R*128 - G*107 - B*20 + 32768),-8);
    end
end

% figure ;
IMG_YCbCr = uint8(IMG_YCbCr);
subplot(221);imshow(IMG_YCbCr);title("IMG_YCbCr");
subplot(222);imshow(IMG_YCbCr(:,:,1));title("y");
subplot(223);imshow(IMG_YCbCr(:,:,2));title("cb");
subplot(224);imshow(IMG_YCbCr(:,:,3));title("cr");


