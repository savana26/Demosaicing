%Implementation of BTES algorithm of paper "binary tree-based generic
%demosaicking algorithm for multispectral filter arrays" by Lidan Miao.
%Vol 15 No. 11 Nov 2006, Transactions on image processing

% This program is for 6 band multispectral images.
function  [newimg img]=btes6(img)
%clc; clear all; close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%read small spectral gap image
% for i=1:6
%     fnamee=['complete_ms_data\balloons_ms\balloons_ms_0' num2str(i)];
%     img(1:512,1:512,i)=imread(fnamee,'png');
% end
% img=im2double(img);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%read a multispectral image of four bands
% m=1829;n=2034;dim=6; 
% img=multibandread('MultispectralData\img1999',[ m n dim],...
%                         'uint8=>uint8',0,'bsq','ieee-le');
% %Since image is large so taking only 500 by 500
% img=im2double(img(1000:1500,1000:1500,:));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%img=randi(255,15,14,4);
%make no.of rows and cols as multiple of 4 so that
% we can apply filters of band 1 and 2.

img=img(1:floor(size(img,1)/4)*4,1:floor(size(img,2)/4)*4,:);
[m n dim]=size(img) ;%redefine variables m, n , dim
%imshow(img(:,:,[4 3 2 ])); %img is in double

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%make the template for mask

temp(:,:,1)=[1 0; 0 0];
temp(:,:,2)=[1 0; 0 0]; %1 and 2 are kept same
temp(:,:,3)=[0 0; 0 1];
temp(:,:,4)=[0 0; 0 1];%3 and 4 are kept same
temp(:,:,5)=[0 1; 0 0];
temp(:,:,6)=[0 0; 1 0];

mask=zeros(size(img));
rawimg=zeros(size(img));

for i=4:6
    mask(:,:,i)=repmat(temp(:,:,i),m/2,n/2);
end
%mask for band 1
temp=[1 0 0 0;0 0 0 0; 0 0 1 0 ; 0 0 0 0];
mask(:,:,1)=repmat(temp,m/4,n/4);
%mask for band 2
temp=[0 0 1 0;0 0 0 0;1 0 0 0  ; 0 0 0 0];
mask(:,:,2)=repmat(temp,m/4,n/4);
%mask for band 3
temp=[0 0 0 0;0 1 0 0;0 0 0 0  ; 0 0 0 1];
mask(:,:,3)=repmat(temp,m/4,n/4);
%mask for band 4
temp=[0 0 0 0;0 0 0 1;0 0 0 0; 0 1 0 0];
mask(:,:,4)=repmat(temp,m/4,n/4);




%multiply the mask wih individual bands to get band values at specific
%points such that rawimg have individual band values.
for i=1:6
    rawimg(:,:,i)=mask(:,:,i).*img(:,:,i);
end

%% Do the interpolation

[m n dim]=size(rawimg);
newimg=zeros(size(rawimg));

%Band 1 interpolation
%firstly do downsampling by 2 and then interpolate
temp=rawimg(1:2:end,1:2:end,1);
temp1=BTESonestep(temp,1,1,'odd');
b1=temp+temp1;
b1=upsample(upsample(b1',2)',2);
%now this band 1 have reached level 2 so use that 
%procedure to further interpolate band 1.
temp=BTESonestep(b1,1,1,'even');
temp1=BTESonestep(temp,1,1,'odd');
newimg(:,:,1)=temp+temp1;

%Band 2 interpolation
%firstly do downsampling by 2 and then interpolate
temp=rawimg(1:2:end,1:2:end,2);
temp1=BTESonestep(temp,1,1,'odd');
b2=temp+temp1;
b2=upsample(upsample(b2',2)',2);
%now this band 2 have reached level 2 so use that 
%procedure to further interpolate band 2.
temp=BTESonestep(b2,1,1,'even');
temp1=BTESonestep(temp,1,1,'odd');
newimg(:,:,2)=temp+temp1;

%Band 3 interpolation
%firstly do downsampling by 2 and then interpolate
temp=rawimg(2:2:end,2:2:end,3);
temp1=BTESonestep(temp,2,2,'odd');
b3=temp+temp1;
b3=upsample(upsample(b3',2)',2);
temp=b3;
b3(1,:)=0;
b3(:,1)=0;
b3(2:end,2:end)=temp(1:end-1,1:end-1);
%now this band 3 have reached level 2 so use that 
%procedure to further interpolate band 2.
temp=BTESonestep(b3,2,2,'even');
temp1=BTESonestep(temp,2,2,'odd');
newimg(:,:,3)=temp+temp1;


%Band 4 interpolation
%firstly do downsampling by 2 and then interpolate
temp=rawimg(2:2:end,2:2:end,4);
temp1=BTESonestep(temp,2,2,'odd');
b4=temp+temp1;
b4=upsample(upsample(b4',2)',2);
temp=b4;
b4(1,:)=0;
b4(:,1)=0;
b4(2:end,2:end)=temp(1:end-1,1:end-1);
%now this band 4 have reached level 2 so use that 
%procedure to further interpolate band 2.
temp=BTESonestep(b4,2,2,'even');
temp1=BTESonestep(temp,2,2,'odd');
newimg(:,:,4)=temp+temp1;
  
%Band 5 interpolation
temp=BTESonestep(rawimg(:,:,5),1,2,'even');
temp1=BTESonestep(temp,1,1,'odd');
newimg(:,:,5)=temp+temp1;

%Band 6 interpolation
temp=BTESonestep(rawimg(:,:,6),2,1,'even');
temp1=BTESonestep(temp,1,1,'odd');
newimg(:,:,6)=temp+temp1;
  


%%  
%Now just calculate rms error but before that
%it is mandatory to convert image to uint8. 
% img=im2uint8(img);
% newimg=im2uint8(newimg);
% [rmse psnr]=RMSE(double(img),double(newimg),10)
%img=im2uint16(img);
%newimg=im2uint16(newimg);
% [rmse,psnr]=RMSE16(double(img),double(newimg),10)
% 
% 
% for i=1 :dim
%     img(:,:,i)=histeq(img(:,:,i));
%     newimg(:,:,i)=histeq(newimg(:,:,i));
% end
% imshow(img(:,:,[4 3 2]))
% figure,imshow(newimg(:,:,[ 4 3 2]))
% 
