%
% 2016-01-18
%   1.读取文本中的第一个BLOCK，数据为4:2:0的YUV数据
%   2.从文本中取出Y,U,V的数据，然后输出到 *.yuv文件，
% 用软件 “7yuv”打开，调整格式为 YVU420 planar YV12 可正常显示
%   3.运行程序时，注意修改输入、输出数据的文件名。
%   4.本程序读入的是一张完整的720p的图片数据，要用于1080P需要略作修改
%
%  斌哥：这个420的转换显示脚本先修改图片尺寸Vs*Hs （720P或1080P）,
% 然后直接运行，点击选择输入文件（不必拷贝到当前目录下），即可等待运行结果
clc;close all;clear 

%%
% rgb2ycbcr
posy = 1;posv = 2;posu = 3; %根据数据来定义的顺序

%%通过 GUI 选择 *.txt 输入文件
[FileName, PathName, FilterIndex] = uigetfile('*.txt');
filename = [PathName,FileName]  
fid_txtin = fopen(filename,'r');
%
%86400/24 = 3600
%%
%!!!!
%%请更改图像对应的尺寸Vs*Hs
FRAME_NUM = 1            %%帧数, txt文件中有几帧yuv数据
% Hs = 96; Vs = 128;       %%128*96
Hs = 720; Vs = 1280;    %%720p
% Hs = 1080;Vs = 1920;   %%1080p
Hs = FRAME_NUM*Hs
Vs = FRAME_NUM*Vs
YY = []; UU=[]; VV=[]; 
for rcount = 1:Hs/16            %45*16 = 720 如果是1080P的照片请修改45为 1080/16=67
    Y = []; U=[]; V=[];
    for colcount = 1:Vs/16      %80*16=1280 如果是1080P的照片请修改80为 1920/16=120
        inblock = zeros(16,20,3);
        inblock(:,:,posy) = fscanf(fid_txtin,'%02x',[20 16])';
        tempuv = fscanf(fid_txtin,'%02x',[20 8])';
        %inblock(1:8,:,posv) = fscanf(fid_txtin,'%2x',[8 20]);

        inblock(1:8,1:10,posu) = tempuv(1:8,1:10); 
        inblock(1:8,11:20,posu) = tempuv(1:8,1:10);
        inblock(9:16,:,posu) = inblock(1:8,:,posu);

        inblock(1:8,1:10,posv) = tempuv(1:8,11:20);
        inblock(1:8,11:20,posv) = inblock(1:8,1:10,posv) ; 
        inblock(9:16,:,posv) = inblock(1:8,:,posv);
        inblock = uint8(inblock);
        % Y = inblock(:,:,posy);
        % U = inblock(:,:,posu);
        % V = inblock(:,:,posv);
        %%
        imgblock = zeros(16,16,3);
        for yuv=1:3
            for row=1:16
                incol = 1;
                for column=1:4:16
                    %
                    imgblock(row,column+0,yuv) = inblock(row,incol+0,yuv); 
                    %
                    tempH = bitshift(inblock(row,incol+1,yuv),-2);
                    tempH = bitshift(tempH,4);
                    tempL = bitand(inblock(row,incol+1,yuv),3);
                    tempL = bitshift(tempL,2);
                    tempL = tempL + bitshift(inblock(row,incol+2,yuv),-6);
                    temp = tempH+tempL;
                    imgblock(row,column+1,yuv) = temp;
                    %
                    tempH = bitshift(inblock(row,incol+2,yuv),4);
                    tempL = bitshift(inblock(row,incol+3,yuv),-4);
                    temp = tempH+tempL;
                    imgblock(row,column+2,yuv) = temp;    
                    %
                    tempH = bitand(inblock(row,incol+3,yuv),3);
                    tempH = bitshift(tempH,6);
                    tempL = bitshift(inblock(row,incol+4,yuv),-2);
                    temp = tempH + tempL;
                    imgblock(row,column+3,yuv) = temp;  
                    incol = incol+5;
                end
            end
        end
        tempy = imgblock(:,:,1);
        tempu = imgblock(1:8,1:8,2);
        tempv = imgblock(1:8,1:8,3);
        tempy = fliplr(tempy);
        tempu = fliplr(tempu);
        tempv = fliplr(tempv);
        Y = [Y tempy];
        U = [U tempu];
        V = [V tempv];
        %tempy = uint8(imgblock(:,:,1))';
        %tempy = reshape(tempy,1,16*16);
        %tempu = uint8(imgblock(:,:,2))';
        %tempu = reshape(tempu,1,16*16);
        %tempv = uint8(imgblock(:,:,3))';
        %tempv = reshape(tempv,1,16*16);
    end
    Y = uint8(Y)';
    Y = reshape(Y,1,16*16*Vs/16);
    U = uint8(U)';
    U = reshape(U,1,16*16*Vs/16/4);
    V = uint8(V)';
    V = reshape(V,1,16*16*Vs/16/4);
    YY = [YY Y];
    UU = [UU U];
    VV = [VV V];
end
fclose(fid_txtin);

% % imgYUV = uint8(cat(3,Y,U,V));
% % imgRGB = ycbcr2rgb(imgYUV);
% % imshow(imgRGB(1:16,:));

%%
% 输出数据的文件名
% datestr(now) 获取时间函数
%
filename_out = ['yuvout_',datestr(now,30),'.yuv'] %
fid_txtout = fopen(filename_out,'wb');
    fwrite(fid_txtout,YY,'uint8');
    fwrite(fid_txtout,VV,'uint8');
    fwrite(fid_txtout,UU,'uint8');
fclose(fid_txtout);
filename_buff = 'yuvout_dispbuff.yuv'
cmd_str = ['copy ',filename_out,' ',filename_buff]
dos(cmd_str)
% yuvpath = [pwd,'\\',filename_buff]
cmd_str = ['7yuv.exe ',filename_buff]  %%添加7yuv 路径工具到用户环境变量
dos(cmd_str)

