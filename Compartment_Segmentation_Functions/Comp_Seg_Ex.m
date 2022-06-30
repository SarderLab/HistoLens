% --- Function to carry out compartment segmentation according to user
% specifications to generate new image
function Comp_Seg_Ex(app)

structure = app.SelectStructureDropDown.Value;

% Get current method for compartment segmentation
sel_butt = app.SegmentationMethodButtonGroup.SelectedObject;
string_vals = {app.SegmentationMethodButtonGroup.Buttons.Text};
butt_idx = find(strcmp(sel_butt.Text,string_vals));

if ~isempty(app.Norm_Img)
    % Have to write out all of the different segmentation procedures here
    % Colorspace segmentations
    if butt_idx==1
        
        % Getting the selected color-transform 
        colorspace_opts = {'RGB (Red, Green, Blue)','HSV (Hue, Saturation, Value)',...
            'LAB'};
        colorspace_idx = find(strcmp(app.Seg_Params.(structure).Colorspace,colorspace_opts));
        if colorspace_idx == 1
            color_img = app.Norm_Img;
        end
        if colorspace_idx == 2
            color_img = rgb2hsv(app.Norm_Img);
        end
        if colorspace_idx == 3
            color_img = rgb2lab(app.Norm_Img);
        end
        
        % Get order of segmentation hierarchy
        order = [app.Seg_Params.(structure).PAS.Order,...
            app.Seg_Params.(structure).Luminal.Order,...
            app.Seg_Params.(structure).Nuclei.Order];
        [sorted, ~] = sort(order,'ascend');
        % order_idx here will be relative order of luminal, PAS, and
        % nuclei
        % if order is [3,1,2], meaning [luminal order, PAS order, nuclei order],
        % then order_idx will be [2,3,1] meaning that the first item is the
        % second compartment channel (PAS), the second is the third compartment
        % channel (nuclei), and the third is the first compartment channel
        % (luminal)
        [~,order_idx] = ismember(sorted,order);
        
        current_mask = app.Current_Mask;
        combined_comps = zeros(size(color_img));
        
        % Storing parameters in same order as "order" array, referred to by
        % order_idx
        comp_params = [app.Seg_Params.(structure).PAS,...
            app.Seg_Params.(structure).Luminal,...
            app.Seg_Params.(structure).Nuclei];
        
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
        
        app.Current_Comp = combined_comps;
        
        if strcmp(app.Knob.Value,'Sub-Compartment Mask')
            axes (app.UIAxes_Comp)
            imshow(app.Current_Comp,'Parent',app.UIAxes_Comp)
    
        end
    end
    
    % Color Deconvolution
    if butt_idx == 2
        color_img = app.Norm_Img;
        
        [stain1, stain2, stain3] = colour_deconvolution(color_img,Seg_Params.Stain);

        stain_img = cat(3,imcomplement(stain1),imcomplement(stain2),imcomplement(stain3));
            
        % Get order of segmentation hierarchy
        order = [app.Seg_Params.(structure).PAS.Order,...
            app.Seg_Params.(structure).Luminal.Order,...
            app.Seg_Params.(structure).Nuclei.Order];
        [sorted, ~] = sort(order,'ascend');
        % order_idx here will be relative order of luminal, PAS, and
        % nuclei
        % if order is [3,1,2], meaning [luminal order, PAS order, nuclei order],
        % then order_idx will be [2,3,1] meaning that the first item is the
        % second compartment channel (PAS), the second is the third compartment
        % channel (nuclei), and the third is the first compartment channel
        % (luminal)
        [~,order_idx] = ismember(sorted,order);
        
        current_mask = app.Current_Mask;
        combined_comps = zeros(size(color_img));
        
        % Storing parameters in same order as "order" array, referred to by
        % order_idx
        comp_params = [app.Seg_Params.(structure).PAS,...
            app.Seg_Params.(structure).Luminal,...
            app.Seg_Params.(structure).Nuclei];
        
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
                comp_mask = split_nuclei_functional(comp_mask, params.Splitting);
            end
            
            combined_comps(:,:,comp) = uint8(comp_mask);
        end
    
        in_use_mask = combined_comps(:,:,1)|combined_comps(:,:,2)|combined_comps(:,:,3);
        remainder_mask = current_mask & ~(in_use_mask);
            
        combined_comps(:,:,order_idx(end)) = uint8(remainder_mask);
        
        app.Current_Comp = combined_comps;
        
        if strcmp(app.Knob.Value,'Sub-Compartment Mask')
            axes (app.UIAxes_Comp)
            imshow(app.Current_Comp,'Parent',app.UIAxes_Comp)
        end
        
    end
    
    % Custom segmentations folder
    if butt_idx == 3
        
        display('Using custom segmentation folder')
        % Loading compartment segmentation from folder
        % Current_Name = slide name
        img_name = strcat(strrep(app.Current_Name,'.svs',''),'_',num2str(app.structure_num.Current));
        img_name = strcat(img_name,'.png');
        comp_path = strcat(app.Seg_Params.(app.SelectStructureDropDown.Value).Path,filesep,img_name);

        try
            app.Current_Comp = imread(comp_path);
        catch
            try
                app.Current_Comp = imread(strrep(comp_path,'.png','.jpg'));
            catch
                try
                    app.Current_Comp = imread(strrep(comp_path,'.png','.tif'));
                catch
                    msgbox(strcat(img_name,'_Not found in_',comp_path));
                end
            end
        end
        
    end
    
end


