% --- Function to save sample compartment segmentations to a selected
% folder
function Generate_Sample_Compartments(app,save_folder,save_number)

% Getting contents of slide path
dir_contents = dir(app.Slide_Path);
dir_contents = dir_contents(contains({dir_contents.name},app.WSI_Formats));
dir_contents = {dir_contents.name};

% Getting the current annotation id(s)
structure_row = find(strcmp(app.Structure,app.Structure_Names(:,1)));
annotation_ids = app.Structure_Names{structure_row,2};
annotation_ids = str2double(strsplit(annotation_ids,','));

% if any(contains(dir_contents,'.'))
%     dir_contents = cellfun(@(x) strsplit(x,'.'),dir_contents,'UniformOutput',false);
%     dir_contents = cellfun(@(x) x{1}, dir_contents,'UniformOutput',false);
% end

slide_wb = waitbar(0,'Saving Example Compartment segmentations',...
    'CreateCancelBtn','setappdata(gcbf,"canceling",1)');

% Iterate through WSIs and pull sample images (up to save_number per slide)
for slide = 1:length(dir_contents)

    % Adding cancel button
    if getappdata(slide_wb,'canceling')
        break
    end

    slide_name = dir_contents{slide};
    if contains(slide_name,'.')
        ann_path = strsplit(slide_name,'.');
        wsi_ext = ann_path{end};
        ann_path = ann_path{1};
    end

    if ~strcmp(wsi_ext,'svs')
        slide_pointer = openslide_open(strcat(app.Slide_Path,filesep,slide_name));
    else
        slide_pointer = [];
    end

    slide_idx_name = strcat('Slide_Idx_',num2str(slide));

    slide_path = strcat(app.Slide_Path,filesep,slide_name);
    img_ids = 1:save_number;

    if strcmp(app.Annotation_Format,'XML')
        ann_path = strcat(app.Slide_Path,filesep,ann_path,'.xml');
    else
        ann_path = strcat(app.Slide_Path,filesep,ann_path,'.json');
        if ~isfile(ann_path)
            ann_path = strrep(ann_path,'.json','.geojson');
        end
    end

    try
        for img = 1:length(img_ids)

            if strcmp(app.Annotation_Format,'XML')
                [bbox_coords,mask_coords] = Read_XML_Annotations(ann_path,annotation_ids,img_ids(img));
            else
                [bbox_coords,mask_coords] = Read_JSON_Annotations(ann_path,img_ids(img));
            end
       

            if strcmp(wsi_ext,'svs')
                raw_I = imread(slide_path,'Index',1,'PixelRegion',{bbox_coords(3:4),bbox_coords(1:2)});
            else
                min_x = bbox_coords(1);
                min_y = bbox_coords(3);
                range_x = bbox_coords(2)-bbox_coords(1);
                range_y = bbox_coords(4)-bbox_coords(3);

                raw_I = openslide_read_region(slide_pointer,min_x,min_y,range_x,range_y);
            end

            mask = poly2mask(mask_coords(:,1),mask_coords(:,2),size(raw_I,1),size(raw_I,2));
    
            if ismember('StainNormalization',fieldnames(app.Seg_Params))
                norm_I = normalizeStaining(raw_I,240,0.15,1,app.Seg_Params.StainNormalization.Means,...
                    app.Seg_Params.StainNormalization.Maxs);
            else
                norm_I = raw_I;
            end

            composite = Comp_Seg_Gen(app.Seg_Params.(slide_idx_name).CompartmentSegmentation,norm_I,mask);

            save_name = strcat(save_folder,filesep,strrep(slide_name,strcat('.',wsi_ext),''),num2str(img_ids(img)));
            comp_save_name = strcat(save_name,'_comp.png');
            raw_save_name = strcat(save_name,'_raw.png');

            imwrite(composite,comp_save_name)
            imwrite(raw_I,raw_save_name)
        end
    end

    waitbar(slide/length(dir_contents),slide_wb,strcat('On slide:',num2str(slide),'of:',num2str(length(dir_contents))))
end
waitbar(1,slide_wb,'Done!')
pause(0.2)
delete(slide_wb)





