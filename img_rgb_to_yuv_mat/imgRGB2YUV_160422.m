%%%%
% @@@@hy 2016-04-22
% 1. 读入一张 filename = *.jpg 的图片，可以是720P或1280P
% 2. 图片的 RGB 转为YUV格式，输出到 *.txt 和 *_444.yuv文件
% 3. 将YUV4:4:4 转为 YUYV4:2:2 packed，输出数据到 *_422yuyv.yuv
% 4. 将YUV4:4:4 转为 4:2:0 planar，输出数据到 *_420yv12.yuv
% 文件将被输出到创建的 .\*out\ 目录下
% 
%%%%
clc;close all;clear 
YES = 1; NO = 0;
%YES表示输出该文件，请用户配置
yuv444_out_txt = NO;   
yuv444_out_yuv = NO;

yuv422_out_txt = YES; 
yuv422_out_yuv = YES;

yuv420_out_txt = NO; 
yuv420_out_yuv = NO;

%%
% 读入照片，并获取除掉后缀名的字符串
% eg: filename = 'Penguins_720p.jpg';
%     filestr  = filename(1:findstr(filename,'.jpg')-1)
% 结果 >> filestr  = 'Penguins_720p'
filename = 'Lena-Katina-Image-640x480.jpg';
filestr = filename(1:findstr(filename,'.jpg')-1);
filepath = ['.\' filestr 'out\']
mkdir(filepath);
filestr = [filepath filestr];
RGBimg =imread(filename);
figure;imshow(RGBimg);

YUVimg = rgb2ycbcr(RGBimg);     %%% rgb -> yuv
figure;imshow((YUVimg));

[imgHeight imgWidth imgDim] = size(YUVimg);         %%
yuvimout = zeros(1,imgHeight*imgWidth*imgDim);
Y = YUVimg(:,:,1);     % Y 矩阵
U = YUVimg(:,:,2);     % U 矩阵
V = YUVimg(:,:,3);     % V 矩阵
Yvec = reshape(YUVimg(:,:,1)',1,imgHeight*imgWidth); % 矩阵整理成行向量
Uvec = reshape(YUVimg(:,:,2)',1,imgHeight*imgWidth);
Vvec = reshape(YUVimg(:,:,3)',1,imgHeight*imgWidth);
yuvimout(1:3:imgHeight*imgWidth*imgDim) = Yvec;
yuvimout(2:3:imgHeight*imgWidth*imgDim) = Uvec;
yuvimout(3:3:imgHeight*imgWidth*imgDim) = Vvec;

%%
% 输出图像的yuv数据到 .txt
%
if yuv444_out_txt == YES
    filename = [filestr '_444.txt'];
    fid= fopen(filename,'w');
        fprintf(fid,'%02x\n',yuvimout);
    fclose(fid);
    disp('yuv444_out_txt YES');
else
    disp('yuv444_out_txt NO');
end
%%
% 输出图像的yuv数据到 .yuv
% 四个像素为：[Y0 U0 V0] [Y1 U1 V1] [Y2 U2 V2] [Y3 U3 V3]
%
% 存放的码流：[Y0 U0 V0] [Y1 U1 V1] [Y2 U2 V2] [Y3 U3 V3]
%
% 映射的像素: [Y0 U0 V0] [Y1 U1 V1] [Y2 U2 V2] [Y3 U3 V3]
if yuv444_out_yuv == YES
    filename = [filestr '_444.yuv'];
    fid= fopen(filename,'wb');
        fwrite(fid,yuvimout,'uint8');
    fclose(fid);
    disp('yuv444_out_yuv YES');
else
    disp('yuv444_out_yuv NO');
end
%%
% YUV4:4:4 -->> YUYV 4:2:2
% 四个像素为：[Y0 U0 V0] [Y1 U1 V1] [Y2 U2 V2] [Y3 U3 V3]
%
% 存放的码流：[Y0 U0] [Y1 V1] [Y2 U2] [Y3 V3]
%
% 映射的像素: [Y0 U0 V1] [Y1 U0 V1] [Y2 U2 V3] [Y3 U2 V3]
%%%
len = imgHeight*imgWidth+imgHeight*imgWidth/2+imgHeight*imgWidth/2;
yuv422out = zeros(1,len);
yuv422sampY = Y;
yuv422sampU = U(:,1:2:size(U,2));
yuv422sampV = V(:,2:2:size(V,2));
yuv422out(1:2:len) = reshape(yuv422sampY',1,[]);  %%% 注意要转置
yuv422out(2:4:len) = reshape(yuv422sampU',1,[]);
yuv422out(4:4:len) = reshape(yuv422sampV',1,[]);
% yuv422out(1:2:len) = Yvec;
% yuv422out(2:4:len) = Uvec(1:2:length(Uvec)); %%% U0 U2 U4
% yuv422out(4:4:len) = Vvec(2:2:length(Vvec)); %%% V1 V3 V5

%%
% 输出图像的yuv422数据到 .txt
%
if yuv422_out_txt == YES
    filename = [filestr '_422.txt'];
    fid= fopen(filename,'w');
        fprintf(fid,'%02x\n',yuv422out);
    fclose(fid);
    disp('yuv422_out_txt YES');
else
    disp('yuv422_out_txt NO');
end
% output yuyv422 to .yuv file
if yuv422_out_yuv == YES
    filename = [filestr '_422yuyv.yuv'];
    fid= fopen(filename,'wb');
        fwrite(fid,yuv422out,'uint8');
    fclose(fid);
    disp('yuv422_out_yuv YES');
else
    disp('yuv422_out_yuv NO');
end
%%
% YUV4:4:4 -->> YUYV 4:2:0
% output yuyv422 to .yuv file
% 四个像素为：[Y0 U0 V0] [Y1 U1 V1] [Y2 U2 V2] [Y3 U3 V3]
%
% 存放的码流：[Y0 U0] [Y1 V1] [Y2 U2] [Y3 V3]
%
% 映射的像素: [Y0 U0 V1] [Y1 U0 V1] [Y2 U2 V3] [Y3 U2 V3]
%%%
len = imgHeight*imgWidth+imgHeight*imgWidth/4+imgHeight*imgWidth/4;
yuv420out = [];
yuv420sampY = Y;
yuv420sampU = U(1:2:size(U,1),1:2:size(U,2));
yuv420sampV = V(2:2:size(V,1),1:2:size(V,2));
%%%yuv420out = [y v u]  % yuv420 yv12 format
yuv420out = [yuv420out reshape(yuv420sampY',1,[])];    %Y 注意要转置
yuv420out = [yuv420out reshape(yuv420sampV',1,[])];    %V
yuv420out = [yuv420out reshape(yuv420sampU',1,[])];    %U

%%
% 输出图像的yuv422数据到 .txt
%
if yuv420_out_txt == YES
    filename = [filestr '_420.txt'];
    fid= fopen(filename,'w');
        fprintf(fid,'%02x\n',yuv420out);
    fclose(fid);
    disp('yuv420_out_txt YES');
else
    disp('yuv420_out_txt NO');
end
% output yuyv420 to .yuv file
if yuv420_out_yuv == YES
    filename = [filestr '_420yv12.yuv'];
    fid= fopen(filename,'wb');
        fwrite(fid,yuv420out,'uint8');
    fclose(fid);
    disp('yuv420_out_yuv YES');
else
    disp('yuv420_out_yuv NO');
end

disp('---program run susseed---');
disp('---press any key to close all figure---');
system('pause');
close all;
