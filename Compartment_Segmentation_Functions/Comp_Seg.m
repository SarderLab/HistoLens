% --- Function to carry out compartment segmentation according to user
% specifications. This new method is more flexible to various stain types
% and removes segmentation hierarchy as a user-specified parameter
function comp_img = Comp_Seg(Seg_Params,img,mask)

seg_fields = fieldnames(Seg_Params);
% Getting current method for sub-compartment segmentation
if ismember('Colorspace',seg_fields)
    method_idx = 1;
elseif ismember('Stain',seg_fields)
    method_idx = 2;
elseif ismember('Path',seg_fields)
    method_idx = 3;
end

stains = seg_fields(contains(seg_fields,'Stain'));

if method_idx==1
    % Using color transforms
    color_opts = {'RGB','HSV','LAB'};
    colorspace_idx = find(strcmp(Seg_Params.Colorspace,color_opts));
    
    if colorspace_idx == 1
        color_img = img;
    elseif colorspace_idx == 2
        color_img = rgb2hsv(img);
    elseif colorspace_idx == 3
        color_img = rgb2lab(img);
    end
elseif method_idx==2

    [stain1,stain2,stain3] = colour_deconvolution(img,Seg_Params.Stain);

    color_img = cat(3,imcomplement(stain1),imcomplement(stain2),imcomplement(stain3));
end

current_mask = mask;
[mask_h,mask_w] = size(current_mask);
combined_comps = zeros(mask_h,mask_w,length(stains));

for s = 1:length(stains)

    params = Seg_Params.(stains{s});

    % Remainder mask is what is left to segment from
    in_use_mask = squeeze(sum(combined_comps,3))>0;
    remainder_mask = current_mask & ~(in_use_mask);

    comp_mask = color_img(:,:,params.Channel);
    comp_mask(~remainder_mask)=0;

    % Thresholding the compartment mask according to input threshold
    % and threshold direction
    if params.Threshold>1

        if ~params.ThresholdDir 
            comp_mask = im2bw(comp_mask,params.Threshold/255);
        else
            comp_mask = im2bw(comp_mask,1-(params.Threshold/255));
        end
    else
        if ~params.ThresholdDir
            comp_mask = im2bw(comp_mask,params.Threshold);
        else
            comp_mask = im2bw(comp_mask,1-params.Threshold);
        end
    end

    comp_mask = bwareaopen(comp_mask,params.MinSize);
    
    % Splitting adjacent nuclei if there is a value recorded for
    % Splitting
    if params.Splitting
        comp_mask = imfill(comp_mask,'holes');
        comp_mask = split_nuclei_functional(comp_mask,params.Splitting);
    end

    combined_comps(:,:,s) = uint8(comp_mask);

end

% Setting the remaining pixels to be the last one
in_use_mask = squeeze(sum(combined_comps,3))>0;
remainder_mask = current_mask & ~(in_use_mask);
combined_comps(:,:,end) = uint8(remainder_mask);

comp_img = combined_comps;















