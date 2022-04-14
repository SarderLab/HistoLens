% --- Function to extract random image from .svs file
function Extract_Rand_Img(app,event,structure_idx)

slide_idx = randi(length(app.Slide_Names));

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

annotations = read_xml.getElementsByTagName('Annotation');
structure_regions = annotations.item(structure_idx-1);
regions = structure_regions.getElementsByTagName('Region');

% More efficient method for extracting random image without having to get
% every image in that slide first
img_idx = randi(regions.getLength)-1;
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

if ~isempty(app.StainNorm_Params)
    
    %assignin('base','pre_norm_img',new_img)
    norm_img = normalizeStaining(new_img,240,0.15,1,app.StainNorm_Params.Means,...
        app.StainNorm_Params.Maxs);

    app.Norm_Img = norm_img;
    %assignin('base','norm_img',norm_img)
end

    
app.Current_Img = new_img;

app.Current_Mask = mask;


