% --- Function to extract random image from .svs file
function Extract_Rand_Img(app,structure_num)

current_structure = app.SelectStructureDropDown.Value;
slide_idx = app.Slide_Idx;
structure_idx = app.Structure_Names.(current_structure).Annotation_ID;

% % Getting the xml filename
if contains(app.Slide_Names{slide_idx},'.svs')
    file_name = strrep(app.Slide_Names{slide_idx},'.svs','.xml');
else
    file_name = strrep(app.Slide_Names{slide_idx},'.ndpi','.xml');
end

read_xml = xmlread(strcat(app.Slide_Path,filesep,file_name));

try
    mpp = read_xml.getElementsByTagName('Annotations');
    mpp = str2double(mpp.item(0).getAttribute('MicronsPerPixel'));
    app.MPP = mpp;
end

% For combined annotation ids, annotations can't be referenced with .item()
annotations = read_xml.getElementsByTagName('Annotation');
structure_regions = {};
n_structures = zeros(1);
for s = 1:length(structure_idx)
    if ~isempty(annotations.item(structure_idx(s)-1))
        structure_regions = [structure_regions;{annotations.item(structure_idx(s)-1)}];
        n_structures(s) = annotations.item(structure_idx(s)-1).getElementsByTagName('Region').getLength;
    else
        n_structures(s) = 0;
    end
end
% n_structures is an array containing the number of structures for each
% annotation id that is used for this current structure. Given a current
% structure number, have to determine which one of the structure_regions to
% use and what index that image is in that annotation id.

if isempty(structure_regions)
    msgbox(strcat([file_name,' has no members of class: ',current_structure]))
else

    % Finding which set of regions to use for a given structure_num
    pre_search_num = structure_num;
    if length(structure_regions)>1
        % number of structures in the first annotation id
        ann_count = 0;
        while pre_search_num>0 && ann_count<length(n_structures)
            ann_count = ann_count+1;
            current_sr = n_structures(ann_count);
            pre_search_num = pre_search_num-current_sr;
            %display('Extract_Rand_Img: Line 52')
        end
        % Outcome of this while loop is a negative value in pre_search_num
        % and ann_count which corresponds to structure region. To get
        % index of specific structure within a given annotation id, add the
        % negative pre_search_num value to the n_structures of the
        % ann_count structure region. (subtract 1 for zero-indexed xml
        % reader :p)
        img_idx = pre_search_num+n_structures(ann_count)-1;
        regions = structure_regions{ann_count}.getElementsByTagName('Region');
        %display('Extract_Rand_Img: Line 61-62')
    else
        img_idx = structure_num-1;
        regions = structure_regions{1}.getElementsByTagName('Region');
        %display('Extract_Rand_Img: Line 65-66')
    end
    
    reg = regions.item(img_idx);
    verts = reg.getElementsByTagName('Vertex');

    xy = zeros(verts.getLength-1,2);
    
    for vi = 0:verts.getLength-1
        x = str2double(verts.item(vi).getAttribute('X'));
        y = str2double(verts.item(vi).getAttribute('Y'));
        xy(vi+1,:) = [x,y];
    end
    
    img_verts = xy;
    
    bbox_coords = [min(img_verts(:,1))-100,max(img_verts(:,1))+100,min(img_verts(:,2))-100,max(img_verts(:,2))+100];
    
    mask_coords = zeros(size(img_verts,1),size(img_verts,2));
    mask_coords(:,1) = img_verts(:,1)-bbox_coords(1);
    mask_coords(:,2) = img_verts(:,2)-bbox_coords(3);
    
    % 3:4 = rows, 1:2 = columns
    new_img = imread(strcat(app.Slide_Path,filesep,app.Slide_Names{slide_idx}),'Index',1,'PixelRegion',{bbox_coords(3:4),bbox_coords(1:2)});
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
 end

