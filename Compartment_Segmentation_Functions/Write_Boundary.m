% --- Function to write edited boundary points to source XML file
function Write_Boundary(app)

% Getting current axis
current_tab = app.TabGroup.SelectedTab;
stain_idx = find(strcmp(current_tab.Title,app.Stain_Table.Properties.VariableNames));
current_axis = app.Stain_Img_Axes(stain_idx);

% Getting the xml filename
slide_idx = app.Slide_Pair_Index;
slide_name = app.Stain_Table{slide_idx,stain_idx};

% Checking if 'svs' is in slide_name
slide_name = strrep(slide_name,'.svs','');

xml_filepath = strcat(app.Slide_Path{stain_idx},slide_name,'.xml');
xml_filepath = xml_filepath{1};

% Getting current image name (which has the index)
current_label = app.Current_Img.ImgLabel;
current_idx = strsplit(current_label,'_');
current_idx = current_idx{end};

% Getting the bounding box coordinates
% 3:4 = rows, 1:2 = columns
bbox_coords = app.Current_Img.BoundaryMask{2};

% Getting the current position of the Editable_Boundary
% points are [x,y] format
current_position = app.Editable_Boundary.Position;

% Adjusting current points to full resolution position
current_position = current_position+[bbox_coords(1),bbox_coords(3)];

% reading xml
read_xml = xmlread(xml_filepath);

% current structure and ID
current_structure = app.StructureNameDropDown.Value;
structure_idx = app.Structure_Names.(current_structure).Annotation_ID;

annotations = read_xml.getElementsByTagName('Annotation');
structure_regions = annotations.item(structure_idx-1);
regions = structure_regions.getElementsByTagName('Region');
reg = regions.item(str2double(current_idx));
verts = reg.getElementsByTagName('Vertex');

current_idx = str2double(current_idx);


% Creating the replacement node object (from struct)
struct_og = xml2struct(xml_filepath);
if iscell(struct_og.Annotations.Annotation)
    annotations = struct_og.Annotations.Annotation{structure_idx};
else
    annotations = struct_og.Annotations.Annotation;
end
regions_og = annotations.Regions.Region{current_idx};

rep_region = regions_og;
rep_region.Vertices = [];
for i = 1:length(current_position)
    rep_region.Vertices.Vertex{1,i}.Attributes.X = num2str(round(current_position(i,1)));
    rep_region.Vertices.Vertex{1,i}.Attributes.Y = num2str(round(current_position(i,2)));
end

if iscell(struct_og.Annotations.Annotation)
    struct_mod = struct_og;
    struct_mod.Annotations.Annotation{structure_idx}.Regions.Region{current_idx}.Attributes = [];
    struct_mod.Annotations.Annotation{structure_idx}.Regions.Region{current_idx}.Attributes = rep_region.Attributes;
    
    struct_mod.Annotations.Annotation{structure_idx}.Regions.Region{current_idx}.Vertices = [];
    struct_mod.Annotations.Annotation{structure_idx}.Regions.Region{current_idx}.Vertices = rep_region.Vertices;
else
    struct_mod = struct_og;
    struct_mod.Annotations.Annotation.Regions.Region{current_idx}.Attributes = [];
    struct_mod.Annotations.Annotation.Regions.Region{current_idx}.Attributes = rep_region.Attributes;
    struct_mod.Annotations.Annotation.Regions.Region{current_idx}.Vertices = [];
    struct_mod.Annotations.Annotation.Regions.Region{current_idx}.Vertices = rep_region.Vertices;

end


struct2xml(struct_mod,xml_filepath)



