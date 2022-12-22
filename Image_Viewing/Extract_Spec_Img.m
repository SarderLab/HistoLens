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

% Getting contents of slide path
dir_contents = dir(app.Slide_Path);
dir_contents = dir_contents(~ismember({dir_contents.name},{'.','..'}));
dir_contents = dir_contents(~contains({dir_contents.name},{'.xml','.csv'}));
dir_contents = dir_contents(contains({dir_contents.name},'.svs'));
dir_contents = {dir_contents.name};

if any(contains(dir_contents,'.'))
    dir_contents = cellfun(@(x) strsplit(x,'.'),dir_contents,'UniformOutput',false);
    dir_contents = cellfun(@(x) x{1},dir_contents,'UniformOutput',false);
end

% Finding slide that contains that slide name (should grab it even without
% specifying the file type
slide_idx = find(contains(dir_contents,slide_name));
slide_idx_name = strcat('Slide_Idx_',num2str(slide_idx));
if ~isempty(slide_idx)
    slide_path = strcat(app.Slide_Path,filesep,dir_contents{slide_idx});
    xml_path = strsplit(slide_path,'.');
    xml_path = strcat(xml_path{1},'.xml');
    
    read_xml = xmlread(xml_path);
    annotations = read_xml.getElementsByTagName('Annotation');
    
    mpp = read_xml.getElementsByTagName('Annotations');
    mpp = str2double(mpp.item(0).getAttribute('MicronsPerPixel'));
    
    if ~isnan(mpp)
        app.MPP = mpp;
    end
    
    % Adjustments for if multiple annotation IDs are combined into a single
    % structure (See Compartment_Segmentation_Functions/Extract_Rand_Img.m
    % Lines 23-67 for more complete description)
    structure_id = app.structure_idx.(app.Structure);
    if length(structure_id)>1
        structure_regions = cell(1);
        n_structures = zeros(1);
        for s = 1:length(structure_id)
            structure_regions = [structure_regions;{annotations.item(structure_id(s)-1)}];
            n_structures(s) = annotations.item(structure_id(s)-1).getLength;
        end
        structure_regions = structure_regions(2:end);
        pre_search_num = img_id;
        ann_count = 0;
        while pre_search_num>0 && ann_count<=length(n_structures)
            ann_count = ann_count+1;
            current_sr = n_structures(ann_count);
            pre_search_num = pre_search_num-current_sr;
        end
        img_id = pre_search_num+n_structures(ann_count)-1;
        regions = structure_regions{ann_count}.getElementsByTagName('Region');
    else
        structure_regions = annotations.item(structure_id-1);
        regions = structure_regions.getElementsByTagName('Region');
        img_id = img_id-1;
    end
    
    % Pulling out specific region
    reg = regions.item(img_id);
    verts = reg.getElementsByTagName('Vertex');
    xy = zeros(verts.getLength-1,2);
    for vi = 0:verts.getLength-1
        x = str2double(verts.item(vi).getAttribute('X'));
        y = str2double(verts.item(vi).getAttribute('Y'));
    
        xy(vi+1,:) = [x,y];
    end
    
    bbox_coords = [min(xy(:,1))-100,max(xy(:,1))+100,min(xy(:,2))-100,max(xy(:,2))+100];
    % creating mask
    mask_coords(:,1) = xy(:,1)-bbox_coords(1);
    mask_coords(:,2) = xy(:,2)-bbox_coords(3);
    
    raw_I = imread(strcat(slide_path,'.svs'),'Index',1,'PixelRegion',{bbox_coords(3:4),bbox_coords(1:2)});
    mask = poly2mask(mask_coords(:,1),mask_coords(:,2),size(raw_I,1),size(raw_I,2));
    
    if ismember('StainNormalization',fieldnames(app.Seg_Params))
        norm_I = normalizeStaining(raw_I,240,0.15,1,app.Seg_Params.StainNormalization.Means,...
            app.Seg_Params.StainNormalization.Maxs);
    else
        norm_I = raw_I;
    end
    
    current_seg_params = app.Seg_Params.(slide_idx_name).CompartmentSegmentation;
    if ~ismember('Path',fieldnames(current_seg_params))

        composite = Comp_Seg_Gen(app.Seg_Params.(slide_idx_name).CompartmentSegmentation,norm_I,mask);
    else
        % Special case hack I hate this
        %raw_I = imresize(raw_I,4);
        %norm_I = imresize(norm_I,4);
        %mask = imresize(mask,4);
        % It's okay, past Sam, I'll make the bad lines go away.
        
        img_name = strcat(slide_name,'_',num2str(img_id));
        composite = Comp_Seg_Gen(current_seg_params,norm_I,img_name);
    end
else

    f = msgbox({'Could not find',slide_name,' in ',app.Slide_Path});
end


