clear all;clc;

Threshold = 127;%阈值
E = 7;%图像对比度增强程度

fp_gray = fopen('..\fpga\contrast\Curve_Contrast_Array.v', 'w');
fprintf(fp_gray,'//Curve Threshold = %d , E= %d\n',Threshold,E);
fprintf(fp_gray,'module  Curve_Contrast_Array ( \n');
fprintf(fp_gray,'  input  wire   [07:00]    pre_data, \n');
fprintf(fp_gray,'  output reg    [07:00]    post_data \n');
fprintf(fp_gray,');\n');
fprintf(fp_gray,'  \n');
fprintf(fp_gray,'  always @(*) begin \n');
fprintf(fp_gray,'    case(pre_data)    \n');
Gray_ARRAY = zeros(1,256);
for i=1:256
    Gray_ARRAY(1,i) = (1./(1+(Threshold./(i-1)).^E))*255;
     Gray_ARRAY(1,i) = uint8( Gray_ARRAY(1,i));
     fprintf(fp_gray,'      8''h%s : post_data = 8''h%s; \n',dec2hex(i-1,2),dec2hex( Gray_ARRAY(1,i),2));
end
fprintf(fp_gray,'    endcase    \n');
fprintf(fp_gray,'  end \n');
fprintf(fp_gray,'  \n');
fprintf(fp_gray,'endmodule \n');