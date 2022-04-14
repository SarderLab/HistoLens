% --- Function to extract random image from .svs file, specialized for the
% case where there might be multiple stains present
function Advanced_Extract_Rand_Img(app)

%slide_idx = app.Slide_Pair_Index;
slide_idx = 1;

% Either one or multiple
slide_name = app.Stain_Table{slide_idx,:};

% Assuming, for now, that only the first column of the stain table has
% images with annotations

xml_filename = slide_name{1};
xml_filename = strrep(xml_filename,'.svs','');
xml_filename = strcat(xml_filename,'.xml');

read_xml = xmlread(strcat(app.Slide_Path{1},filesep,xml_filename));

% Getting current structure annotation ID
current_structure = app.StructureNameDropDown.Value;
structure_idx = app.Structure_Names.(current_structure).Annotation_ID;

% For multiple included
if length(structure_idx)>1
    structure_idx = structure_idx(randi(length(structure_idx)));
end

annotations = read_xml.getElementsByTagName('Annotation');
structure_regions = annotations.item(structure_idx-1);
regions = structure_regions.getElementsByTagName('Region');

img_idx = randi(regions.getLength)-1;
reg = regions.item(img_idx);
verts = reg.getElementsByTagName('Vertex');
img_verts = zeros(verts.getLength-1,2);

for vi = 0:verts.getLength-1
    x = str2double(verts.item(vi).getAttribute('X'));
    y = str2double(verts.item(vi).getAttribute('Y'));
    img_verts(vi+1,:) = [x,y];
end

bbox_coords = [min(img_verts(:,1))-100,max(img_verts(:,1))+100,min(img_verts(:,2))-100,max(img_verts(:,2))+100];
% creating mask
mask_coords = zeros(size(img_verts,1),size(img_verts,2));
mask_coords(:,1) = img_verts(:,1)-bbox_coords(1);
mask_coords(:,2) = img_verts(:,2)-bbox_coords(3);

img_name = strcat(strrep(xml_filename,'.xml',''),'_',num2str(img_idx));

% Using saved registration transform to align multiple stains if they are
% present
% Edit this later for more than two stains
if length(app.Slide_Path)>1

    current_transform = [app.Registration_Transforms.Transform];
    current_transform = current_transform(slide_idx);
    current_reference = [app.Registration_Transforms.Reference];
    current_reference = current_reference(slide_idx);

    [xT,yT] = transformPointsForward(current_transform,img_verts(:,1),img_verts(:,2));
    [xI,yI] = worldToIntrinsic(current_reference,xT,yT);

    new_bbox = [min(xI)-100,max(xI)+100,min(yI)-100,max(yI)+100];

    slide_name2 = app.Stain_Table{slide_idx,2};
    if ~contains(slide_name2,'.svs')
        slide_name2 = strcat(slide_name2,'.svs');
    end
    app.Current_Img.Image2 = imread(strcat(app.Slide_Path{2},filesep,slide_name2{1}),...
        'Index',1,'PixelRegion',{new_bbox(3:4),new_bbox(1:2)});

    cla(app.Stain_Img_Axes(2))
    imshow(app.Current_Img.Image2,'Parent',app.Stain_Img_Axes(2))

    app.Current_Img.Image1 = imread(strcat(app.Slide_Path{1},filesep,strrep(xml_filename,'.xml','.svs')),...
        'Index',1,'PixelRegion',{bbox_coords(3:4),bbox_coords(1:2)});
    app.Current_Img.ImgLabel = img_name;
    app.Current_Img.BoundaryMask{1} = poly2mask(mask_coords(:,1),mask_coords(:,2),...
        size(app.Current_Img.Image1,1),size(app.Current_Img.Image1,2));
    app.Current_Img.BoundaryMask{2} = bbox_coords;

    cla(app.Stain_Img_Axes(1))
    imshow(app.Current_Img.Image1,'Parent',app.Stain_Img_Axes(1))

else
    app.Current_Img.Image1 = imread(strcat(app.Slide_Path{1},filesep,strrep(xml_filename,'.xml','.svs')),...
        'Index',1,'PixelRegion',{bbox_coords(3:4),bbox_coords(1:2)});
    app.Current_Img.ImgLabel = img_name;
    app.Current_Img.BoundaryMask{1} = poly2mask(mask_coords(:,1),mask_coords(:,2),...
        size(app.Current_Img.Image1,1),size(app.Current_Img.Image1,2));
    app.Current_Img.BoundaryMask{2} = bbox_coords;

    cla(app.Stain_Img_Axes)
    imshow(app.Current_Img.Image1,'Parent',app.Stain_Img_Axes)

end









