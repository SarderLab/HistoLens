% --- Function to extract random image from .svs file
function Extract_Rand_Img(app,structure_num)

current_structure = app.SelectStructureDropDown.Value;
slide_idx = app.Slide_Idx;

% Finding the row with this structure name
structure_row = find(strcmp(app.SelectStructureDropDown.Value,app.Structure_Names{:,1}));

annotation_ids = app.Structure_Names{structure_row,2};
annotation_ids = str2double(strsplit(annotation_ids{1},','));

if contains(app.Slide_Names{slide_idx},'.')
    wsi_ext = strsplit(app.Slide_Names{slide_idx},'.');
    wsi_ext = wsi_ext{end};
end

% % Getting the xml filename
if contains(app.Slide_Names{slide_idx},wsi_ext)
    if strcmp(app.Annotation_Format,'XML')
        file_name = strrep(app.Slide_Names{slide_idx},wsi_ext,'xml');
    else
        file_name = strrep(app.Slide_Names{slide_idx},wsi_ext,'json');
        if ~isfile(strcat(app.Slide_Path,filesep,file_name))
            file_name = strrep(file_name,'.json','.geojson');
        end
    end
else
    if strcmp(app.Annotation_Format,'XML')
        file_name = strrep(app.Slide_Names{slide_idx},wsi_ext,'xml');
    else
        file_name = strrep(app.Slide_Names{slide_idx},wsi_ext,'json');
        if ~isfile(strcat(app.Slide_Path,filesep,file_name))
            file_name = strrep(file_name,'.json','.geojson');
        end
    end
end


if strcmp(app.Annotation_Format,'XML')
    
    xml_path = strcat(app.Slide_Path,filesep,file_name);
    [bbox_coords,mask_coords] = Read_XML_Annotations(xml_path,annotation_ids,structure_num);
else
    json_path = strcat(app.Slide_Path,filesep,file_name);
    [bbox_coords,mask_coords] = Read_JSON_Annotations(json_path,structure_num);
end

% 3:4 = rows, 1:2 = columns

if strcmp(wsi_ext,'svs')
    new_img = imread(strcat(app.Slide_Path,filesep,app.Slide_Names{slide_idx}),'Index',1,'PixelRegion',{bbox_coords(3:4),bbox_coords(1:2)});
else
    % Reading image with openslide_read_region
    min_x = bbox_coords(1);
    min_y = bbox_coords(3);
    range_x = bbox_coords(2)-bbox_coords(1);
    range_y = bbox_coords(4)-bbox_coords(3);

    slide_pointer = openslide_open(strcat(slide_path,'.',wsi_ext));

    new_img = openslide_read_region(slide_pointer,min_x,min_y,range_x,range_y);
    new_img = new_img(2:end,:,:);

    openslide_close(slide_pointer)
end


mask = poly2mask(mask_coords(:,1),mask_coords(:,2),size(new_img,1),size(new_img,2));

app.Current_Name = app.Slide_Names{slide_idx};

if ~isempty(app.StainNorm_Params) && ~any(app.StainNorm_Params.Means==0,'all') && ~any(app.StainNorm_Params.Maxs==0,'all')
    norm_img = normalizeStaining(new_img,240,0.15,1,app.StainNorm_Params.Means,...
        app.StainNorm_Params.Maxs);

    app.Norm_Img = norm_img;
else
    app.Norm_Img = [];
end
        
app.Current_Img = new_img;
app.Current_Mask = mask;
% end

