%
% 2016-01-18
%   1.��ȡ�ı��еĵ�һ��BLOCK������Ϊ4:2:0��YUV����
%   2.���ı���ȡ��Y,U,V�����ݣ�Ȼ������� *.yuv�ļ���
% ����� ��7yuv���򿪣�������ʽΪ YVU420 planar YV12 ��������ʾ
%   3.���г���ʱ��ע���޸����롢������ݵ��ļ�����
%   4.������������һ��������720p��ͼƬ���ݣ�Ҫ����1080P��Ҫ�����޸�
%
%  ��磺���420��ת����ʾ�ű����޸�ͼƬ�ߴ�Vs*Hs ��720P��1080P��,
% Ȼ��ֱ�����У����ѡ�������ļ������ؿ�������ǰĿ¼�£������ɵȴ����н��
clc;close all;clear 

%%
% rgb2ycbcr
posy = 1;posv = 2;posu = 3; %���������������˳��

%%ͨ�� GUI ѡ�� *.txt �����ļ�
[FileName, PathName, FilterIndex] = uigetfile('*.txt');
filename = [PathName,FileName]  
fid_txtin = fopen(filename,'r');
%
%86400/24 = 3600
%%
%!!!!
%%�����ͼ���Ӧ�ĳߴ�Vs*Hs
FRAME_NUM = 1            %%֡��, txt�ļ����м�֡yuv����
% Hs = 96; Vs = 128;       %%128*96
Hs = 720; Vs = 1280;    %%720p
% Hs = 1080;Vs = 1920;   %%1080p
Hs = FRAME_NUM*Hs
Vs = FRAME_NUM*Vs
YY = []; UU=[]; VV=[]; 
for rcount = 1:Hs/16            %45*16 = 720 �����1080P����Ƭ���޸�45Ϊ 1080/16=67
    Y = []; U=[]; V=[];
    for colcount = 1:Vs/16      %80*16=1280 �����1080P����Ƭ���޸�80Ϊ 1920/16=120
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
% ������ݵ��ļ���
% datestr(now) ��ȡʱ�亯��
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
cmd_str = ['7yuv.exe ',filename_buff]  %%���7yuv ·�����ߵ��û���������
dos(cmd_str)

