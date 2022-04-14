
% Determining what default values should be for colorspace and color
% deconvolution thresholding
clc
clear all
close all

%% Colorspace

[filename,path] = uigetfile('*');
glom_img = imread(strcat(path,filesep,filename));

[filename,path] = uigetfile('*');
mask_img = imread(strcat(path,filesep,filename));

hsv_img = rgb2hsv(glom_img);

combined_comps = zeros(size(glom_img));

% nuclei order = 1
nuc_mask = hsv_img(:,:,2);
nuc_mask(~mask_img) = 0;
figure, imshow(nuc_mask)
nuc_mask = im2bw(nuc_mask);
figure, imshow(nuc_mask);
nuc_mask = uint8(nuc_mask).*mask_img;
figure, imshow(nuc_mask)
nuc_mask = bwareaopen(nuc_mask,50);
figure, imshow(nuc_mask)
nuc_mask = imfill(nuc_mask,'holes');
figure, imshow(nuc_mask)
nuc_mask = split_nuclei_functional(nuc_mask);
figure, imshow(nuc_mask)

pause(1)
close all
combined_comps(:,:,3) = uint8(nuc_mask);

in_use_mask = combined_comps(:,:,1)|combined_comps(:,:,2)|combined_comps(:,:,3);
remainder_mask = uint8(mask_img & ~(in_use_mask));

% mesangium order = 2
mes_mask = hsv_img(:,:,2);
mes_mask(~remainder_mask)=0;
figure, imshow(mes_mask)
mes_mask = im2bw(mes_mask,0.2);
figure, imshow(mes_mask)
mes_mask = bwareaopen(mes_mask,10);
figure, imshow(mes_mask)

pause(1)
close all
combined_comps(:,:,2) = uint8(mes_mask);

in_use_mask = combined_comps(:,:,1)|combined_comps(:,:,2)|combined_comps(:,:,3);
remainder_mask = mask_img & ~(in_use_mask);

% luminal order = 3
lum_mask = remainder_mask;
figure, imshow(lum_mask)

pause(1)
close all
combined_comps(:,:,1) = uint8(lum_mask);

figure, imshow(combined_comps),title('Final')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Now testing for color deconvolution
[filename,path] = uigetfile('*');
glom_img = imread(strcat(path,filesep,filename));

[filename,path] = uigetfile('*');
mask_img = imread(strcat(path,filesep,filename));

[stain1,stain2,stain3] = colour_deconvolution(glom_img,'H PAS');
stain_img = cat(3,imcomplement(stain1),imcomplement(stain2),imcomplement(stain3));

combined_comps = zeros(size(glom_img));

% nuclei order = 1
nuc_mask = stain_img(:,:,1);
nuc_mask(~mask_img)=0;
figure, imshow(nuc_mask)
nuc_mask = im2bw(nuc_mask);
figure, imshow(nuc_mask)
nuc_mask = bwareaopen(nuc_mask,30);
figure, imshow(nuc_mask)
nuc_mask = imfill(nuc_mask,'holes');
figure, imshow(nuc_mask)
nuc_mask = split_nuclei_functional(nuc_mask);
figure, imshow(nuc_mask)
combined_comps(:,:,3) = uint8(nuc_mask);
pause(1)
close all

in_use_mask = combined_comps(:,:,1)|combined_comps(:,:,2)|combined_comps(:,:,3);
remainder_mask = mask_img & ~(in_use_mask);

% mesangium order = 2
mes_mask = stain_img(:,:,2);
mes_mask(~remainder_mask) = 0;
figure, imshow(mes_mask)
mes_mask = im2bw(mes_mask,0.2);
figure, imshow(mes_mask)
mes_mask = bwareaopen(mes_mask,10);
figure, imshow(mes_mask)

combined_comps(:,:,2) = uint8(mes_mask);
pause(1)
close all

in_use_mask = combined_comps(:,:,1)|combined_comps(:,:,2)|combined_comps(:,:,3);
remainder_mask = mask_img & ~(in_use_mask);

% luminal space order = 3
lum_mask = remainder_mask;
figure, imshow(lum_mask)

combined_comps(:,:,1) = uint8(lum_mask);

pause(1)
close all

figure, imshow(combined_comps),title('Final')






