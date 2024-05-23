% Function to read XML annotation files
function [bbox_coords,mask_coords,mpp] = Read_XML_Annotations(filepath,structure_idx,image_id)

read_xml = xmlread(filepath);
annotations = read_xml.getElementsByTagName('Annotation');

try
    mpp = read_xml.getElementsByTagName('Annotations');
    mpp = str2double(mpp.item(0).getAttribute('MicronsPerPixel'));
catch
    mpp = [];
end


if length(structure_idx)>1
    structure_regions = cell(1);
    n_structures = zeros(1);
    for s = 1:length(structure_idx)
        structure_regions = [structure_regions;{annotations.item(structure_idx(s)-1)}];
        n_structures(s) = annotations.item(structure_idx(s)-1).getElementsByTagName('Region').getLength;

    end

    structure_regions = structure_regions(2:end);
    pre_search_num = image_id;
    ann_count = 0;
    while pre_search_num>0 && ann_count<=length(n_structures)
        ann_count = ann_count+1;
        current_sr = n_structures(ann_count);
        pre_search_num = pre_search_num-current_sr;
    end
    img_id = pre_search_num + n_structures(ann_count)-1;
    regions = structure_regions{ann_count}.getElementsByTagName('Region');

else
    structure_regions = annotations.item(structure_idx-1);
    if ~isempty(structure_regions)
        regions = structure_regions.getElementsByTagName('Region');
        img_id = image_id-1;
    end
end

% display('Testing Read_XML_Annotations Line 35')
% n_structures
% img_id
% regions.getLength

% Pulling out specific region vertices
reg = regions.item(img_id);
verts = reg.getElementsByTagName('Vertex');
xy = zeros(verts.getLength-1,2);
for vi = 0:verts.getLength-1
    x = str2double(verts.item(vi).getAttribute('X'));
    y = str2double(verts.item(vi).getAttribute('Y'));

    xy(vi+1,:) = [x,y];
end

bbox_coords = [min(xy(:,1))-100,max(xy(:,1))+100,min(xy(:,2))-100,max(xy(:,2))+100];

% Creating mask
mask_coords = zeros(size(xy));
mask_coords(:,1) = xy(:,1)-bbox_coords(1);
mask_coords(:,2) = xy(:,2)-bbox_coords(3);


