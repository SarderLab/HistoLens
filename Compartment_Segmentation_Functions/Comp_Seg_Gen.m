% --- Function to carry out compartment segmentation according to user
% specifications to generate new image
function comp_img = Comp_Seg_Gen(Seg_Params,img,mask)

% Get current method for compartment segmentation
if ismember('Colorspace',fieldnames(Seg_Params))
    method_idx = 1;
end
if ismember('Stain',fieldnames(Seg_Params))
    method_idx = 2;
end
if ismember('Path',fieldnames(Seg_Params))
    method_idx = 3;
end


% Have to write out all of the different segmentation procedures here
% Colorspace segmentations
if method_idx==1
    
    % Getting the selected color-transform 
    colorspace_opts = {'RGB (Red, Green, Blue)','HSV (Hue, Saturation, Value)',...
        'LAB'};
    colorspace_idx = find(strcmp(Seg_Params.Colorspace,colorspace_opts));
    if colorspace_idx == 1
        color_img = img;
    end
    if colorspace_idx == 2
        color_img = rgb2hsv(img);
    end
    if colorspace_idx == 3
        color_img = rgb2lab(img);
    end
    
    % Get order of segmentation hierarchy
    order = [Seg_Params.PAS.Order,...
        Seg_Params.Luminal.Order,...
        Seg_Params.Nuclei.Order];
    [sorted, ~] = sort(order,'ascend');
    % order_idx here will be relative order of Luminal, PAS, and
    % nuclei
    % if order is [3,1,2], meaning [Luminal order, PAS order, nuclei order],
    % then order_idx will be [2,3,1] meaning that the first item is the
    % second compartment channel (PAS), the second is the third compartment
    % channel (nuclei), and the third is the first compartment channel
    % (Luminal)
    [~,order_idx] = ismember(sorted,order);
    
    current_mask = mask;
    combined_comps = zeros(size(color_img));
    
    % Storing parameters in same order as "order" array, referred to by
    % order_idx
    comp_params = [Seg_Params.PAS,...
        Seg_Params.Luminal,...
        Seg_Params.Nuclei];
    
    % Segmenting compartments in defined order (iterating through order
    % idx)
    for comp = order_idx(1:end-1)
        
        % comp = current compartment
        % Getting parameters
        params = comp_params(comp);
        
        % Remainder mask is what is left to segment from
        in_use_mask = combined_comps(:,:,1)|combined_comps(:,:,2)|combined_comps(:,:,3);
        remainder_mask = current_mask & ~(in_use_mask);
        
        comp_mask = color_img(:,:,params.Channel);
        comp_mask(~remainder_mask)=0;
        if params.Threshold>1
            comp_mask = im2bw(comp_mask,params.Threshold/255);
        else
            comp_mask = im2bw(comp_mask,params.Threshold);
        end
        comp_mask = bwareaopen(comp_mask,params.MinSize);
        
        if comp==3
            comp_mask = imfill(comp_mask,'holes');
            %comp_mask = bwpropfilt(comp_mask,'Eccentricity',[-0.10,0.85]);

            comp_mask = split_nuclei_functional(comp_mask,params.Splitting);
        end
        
        combined_comps(:,:,comp) = uint8(comp_mask);
    end

    in_use_mask = combined_comps(:,:,1)|combined_comps(:,:,2)|combined_comps(:,:,3);
    remainder_mask = current_mask & ~(in_use_mask);
    combined_comps(:,:,order_idx(end)) = uint8(remainder_mask);
    
    comp_img = combined_comps;
    
end

% Color Deconvolution
if method_idx == 2
    color_img = img;
    
    [stain1, stain2, stain3] = colour_deconvolution(color_img,Seg_Params.Stain);

    stain_img = cat(3,imcomplement(stain1),imcomplement(stain2),imcomplement(stain3));
        
    % Get order of segmentation hierarchy
    order = [Seg_Params.PAS.Order,...
        Seg_Params.Luminal.Order,...
        Seg_Params.Nuclei.Order];
    [sorted, ~] = sort(order,'ascend');
    % order_idx here will be relative order of Luminal, PAS, and
    % nuclei
    % if order is [3,1,2], meaning [Luminal order, PAS order, nuclei order],
    % then order_idx will be [2,3,1] meaning that the first item is the
    % second compartment channel (PAS), the second is the third compartment
    % channel (nuclei), and the third is the first compartment channel
    % (Luminal)
    [~,order_idx] = ismember(sorted,order);
    
    current_mask = mask;
    combined_comps = zeros(size(color_img));
    
    % Storing parameters in same order as "order" array, referred to by
    % order_idx
    comp_params = [Seg_Params.PAS,...
        Seg_Params.Luminal,...
        Seg_Params.Nuclei];
    
    % Segmenting compartments in defined order (iterating through order
    % idx)
    for comp = order_idx(1:end-1)
        
        % comp = current compartment
        % Getting parameters
        params = comp_params(comp);
        
        % Remainder mask is what is left to segment from
        in_use_mask = combined_comps(:,:,1)|combined_comps(:,:,2)|combined_comps(:,:,3);
        remainder_mask = current_mask & ~(in_use_mask);
        
        comp_mask = stain_img(:,:,params.Channel);
        comp_mask(~remainder_mask) = 0;
        if params.Threshold>1
            comp_mask = im2bw(comp_mask,params.Threshold/255);
        else
            comp_mask = im2bw(comp_mask,params.Threshold);
        end
        comp_mask = bwareaopen(comp_mask,params.MinSize);
        
        if comp==3
            comp_mask = imfill(comp_mask,'holes');
            %comp_mask = bwpropfilt(comp_mask,'Eccentricity',[-0.10,0.85]);

            comp_mask = split_nuclei_functional(comp_mask,params.Splitting);
        end
        
        combined_comps(:,:,comp) = uint8(comp_mask);
    end

    in_use_mask = combined_comps(:,:,1)|combined_comps(:,:,2)|combined_comps(:,:,3);
    remainder_mask = current_mask & ~(in_use_mask);
        
    combined_comps(:,:,order_idx(end)) = uint8(remainder_mask);
    
    comp_img = combined_comps;
    
end

% Custom segmentations folder
if method_idx == 3
    % Loading compartment segmentation from folder
    % Current_Name = slide name
    img_name = mask;
    comp_path = strcat(Seg_Params.Path,filesep,img_name);

    try
        comp_img = imread(strcat(comp_path,'.png'));
        assignin('base','comp_img',comp_img)
    catch
        try
            comp_img = imread(strcat(comp_path,'.jpg'));
        catch
            try
                comp_img = imread(strcat(comp_path,'.tif'));
            catch
                msgbox(strcat(img_name,'_Not found in_',comp_path));
            end
        end
    end
    
    % Reading in compartment masks, have to normalize and resize (just for
    % safety)
    comp_img = comp_img./255;
    comp_img = imresize(comp_img,[size(img,1),size(img,2)],'nearest');
    assignin('base','comp_img',comp_img)
    assignin('base','img',img)

end



