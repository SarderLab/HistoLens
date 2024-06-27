% --- Function to extract a specific image given an ImgLabel
function [raw_I,norm_I,mask,composite] = Extract_Spec_Img(app,event,img_name)

% Getting the slide name and img id from feature set row
%img_name = app.Full_Feature_set.(app.Structure).ImgLabel{find(strcmp(app.Full_Feature_set.(app.Structure).ImgLabel,img_name))};
name_parts = strsplit(img_name,'_');
if length(name_parts)==2
    slide_name = name_parts{1};
else
    if iscell(name_parts)
        slide_name = strjoin(name_parts(1:end-1),'_');
    else
        slide_name = strjoin(name_parts{1:end-1},'_');
    end
end

img_id = name_parts{end};
img_id = strsplit(img_id,'.');
img_id = str2double(img_id{1});

% Getting the annotation ids
structure_row = find(strcmp(app.Structure,app.Structure_Names(:,1)));
annotation_ids = app.Structure_Names{structure_row,2};
annotation_ids = str2double(strsplit(annotation_ids,','));

% Getting contents of slide path
dir_contents = dir(app.Slide_Path);
dir_contents = dir_contents(~ismember({dir_contents.name},{'.','..'}));
dir_contents = dir_contents(~contains({dir_contents.name},{'.xml','.json','.geojson','.csv'}));
dir_contents = dir_contents(contains({dir_contents.name},app.WSI_Formats));
dir_contents = {dir_contents.name};

% Removing WSI extension from dir contents and finding slide_name
split_names = cellfun(@(x) strsplit(x,'.'),dir_contents,'UniformOutput',false);
wsi_exts = cellfun(@(x) x{end}, split_names, 'UniformOutput',false);

compare_names = {};
for i = 1:length(split_names)
    if length(split_names{i})>2
        compare_names(i) = strjoin(split_names{i}{1:end-1},'.');
    else
        compare_names(i) = split_names{i}(1);
    end
end


% Finding slide that contains that slide name (should grab it even without
% specifying the file type
slide_idx = find(strcmp(compare_names,slide_name));
slide_idx_name = strcat('Slide_Idx_',num2str(slide_idx));
if ~isempty(slide_idx)
    slide_path = strcat(app.Slide_Path,filesep,dir_contents{slide_idx});
    
    if contains(slide_path,'.')
        ann_path = strsplit(slide_path,'.');
        wsi_ext = ann_path{end};
        if length(ann_path)>2
            ann_path = strjoin(ann_path(1:end-1),'.');
        else
            ann_path = ann_path{1};
        end
    end

    if strcmp(app.Annotation_Format,'XML')
        ann_path = strcat(ann_path,'.xml');
        [bbox_coords,mask_coords,mpp] = Read_XML_Annotations(ann_path,annotation_ids,img_id);
    
    elseif strcmp(app.Annotation_Format,'JSON')
        if isfile(strcat(ann_path,'.json'))
            json_path = strcat(ann_path,'.json');
        else
            json_path = strcat(ann_path,'.geojson');
        end
        [bbox_coords,mask_coords] = Read_JSON_Annotations(json_path,img_id);
    end

    if ismember(wsi_ext,{'svs', 'png','jpg','jpeg','tif','tiff'})
        raw_I = imread(slide_path,'Index',1,'PixelRegion',{bbox_coords(3:4),bbox_coords(1:2)});
    else
        % Reading image with openslide
        min_x = bbox_coords(1);
        min_y = bbox_coords(3);
        range_x = bbox_coords(2)-bbox_coords(1);
        range_y = bbox_coords(4)-bbox_coords(3);

        slide_pointer = openslide_open(slide_path);

        raw_I = openslide_read_region(slide_pointer,min_x,min_y,range_x,range_y);
        raw_I = raw_I(2:end,:,:);

        openslide_close(slide_pointer)
    end

    mask = poly2mask(mask_coords(:,1),mask_coords(:,2),size(raw_I,1),size(raw_I,2));
    
    if ismember('StainNormalization',fieldnames(app.Seg_Params))
        norm_I = normalizeStaining(raw_I,240,0.15,1,app.Seg_Params.StainNormalization.Means,...
            app.Seg_Params.StainNormalization.Maxs);
    else
        norm_I = raw_I;
    end
    
    current_seg_params = app.Seg_Params.(slide_idx_name).CompartmentSegmentation;
    if ~ismember('Path',fieldnames(current_seg_params))

        composite = Comp_Seg(app.Seg_Params.(slide_idx_name).CompartmentSegmentation,norm_I,mask);
    else

        img_name = strcat(slide_name,'_',num2str(img_id));
        composite = Comp_Seg(current_seg_params,norm_I,img_name);
    end
else

    f = msgbox({'Could not find',slide_name,' in ',app.Slide_Path});
end

if ~isempty(app.Baseline_MPP)
    mpp_scale = mpp/app.Baseline_MPP;
    
    if ~isnan(mpp_scale)
        % Resizing images according to mpp_scale
        raw_I = imresize(raw_I,mpp_scale,'bilinear');
        norm_I = imresize(norm_I,mpp_scale,'bilinear');
        mask = imresize(mask,mpp_scale,'bilinear');
        composite = imresize(composite,mpp_scale,'bilinear');
    end
end



