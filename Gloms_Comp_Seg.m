%--- Function to carry out custom compartment segmentation
function combined_comps = Comp_Seg(img,mask)
%
%
%
% Stain Deconvolution
[stain1,stain2,stain3] = colour_deconvolution(img,'H PAS');
channel_img = cat(3,imcomplement(stain1),imcomplement(stain2),imcomplement(stain3));
%
% Segmentation Hierarchy
order_idx = [3,1,2];
%
% Initializing compartment segmentation
combined_comps = zeros(size(img));
%
%
%Nuclei Segmentation
%
%
% Remainder mask generation
in_use_mask = combined_comps(:,:,1)|combined_comps(:,:,2)|combined_comps(:,:,3);
remainder_mask = mask & ~(in_use_mask);
%
comp_mask = channel_img(:,:,1);
comp_mask(~remainder_mask) = 0;
comp_mask = im2bw(comp_mask,0.68627);
comp_mask = bwareaopen(comp_mask,30);
%
% Extra Processing for Nuclei
comp_mask = imfill(comp_mask,'holes');
comp_mask = split_nuclei_functional(comp_mask);
combined_comps(:,:,3) = comp_mask;
%
%
%PAS Segmentation
%
%
% Remainder mask generation
in_use_mask = combined_comps(:,:,1)|combined_comps(:,:,2)|combined_comps(:,:,3);
remainder_mask = mask & ~(in_use_mask);
%
comp_mask = channel_img(:,:,2);
comp_mask(~remainder_mask) = 0;
comp_mask = im2bw(comp_mask,0.047059);
comp_mask = bwareaopen(comp_mask,45);
combined_comps(:,:,1) = comp_mask;
%
%
%Luminal Segmentation
%
%
% Remainder mask generation
in_use_mask = combined_comps(:,:,1)|combined_comps(:,:,2)|combined_comps(:,:,3);
remainder_mask = mask & ~(in_use_mask);
%
%
combined_comps(:,:,2) = remainder_mask;
