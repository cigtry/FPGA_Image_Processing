clc;
IMG_gray=imread('../picture/RGB2YCBCR.bmp');
IMG_gray=uint8(IMG_gray);
 %IMG_gray = rgb2gray(IMG_gray);
h = size(IMG_gray,1);
w = size(IMG_gray,2);
subplot(121);imshow(IMG_gray);
a = fix(float2int_func(h,w));
numpixel = zeros(1,256);
for i =1:h
    for j=1:w
        numpixel(IMG_gray(i,j)+ 1) = numpixel(IMG_gray(i,j)+ 1) + 1;
    end
end

cumpixel = zeros(1,256);
for i = 1:256
   if i==1
       cumpixel(i) = numpixel(i);
   else
        cumpixel(i) =  cumpixel(i-1) + numpixel(i);
   end
end

IMG_EQ = zeros(h,w);
for i =1:h
    for j=1:w
        IMG_EQ(i,j) = cumpixel(IMG_gray(i,j)+ 1) /a;
    end
end
IMG_EQ = uint8(IMG_EQ);
subplot(122);imshow(IMG_EQ);


numpixel2 = zeros(1,256);
for i =1:h
    for j=1:w
        numpixel2(IMG_EQ(i,j)+ 1) = numpixel2(IMG_EQ(i,j)+ 1) + 1;
    end
end
cumpixel2 = zeros(1,256);
for i = 1:256
   if i==1
       cumpixel2(i) = numpixel2(i);
   else
        cumpixel2(i) =  cumpixel2(i-1) + numpixel2(i);
   end
end
figure;
subplot(221);bar(cumpixel);title("原图灰度级数累积")
subplot(222);bar(cumpixel2);title("拉伸后灰度级数累积")
subplot(223);imhist(IMG_gray);title("原图")
subplot(224);imhist(IMG_EQ);title("拉伸后")
function a= float2int_func(h,w)
a = (h*w)/255;
fprintf("a:%.20f\r\n",a);
b = 1/a;
fprintf("b:%.20f\r\n",b);
 num = [];
for l=1:32
    m =  (2^l) / a ;
    m = floor(m);
    c = m / (2^l);
    num(l) = c;
end
d = abs(num -b);
[~,Index] = min(d);
fprintf("Index : %d \n", Index);
 m = (2^Index) / a;
 m = floor(m);
 fprintf("m:%.d\r\n",m);
 fprintf("num(%d):%.20f\r\n",Index,num(Index));
end