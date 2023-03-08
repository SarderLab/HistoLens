% --- Function to get the number of structures present in a slide
function structure_num = Get_Structure_Number(app)

slide_idx = app.Slide_Idx;

% Finding the row with this structure name
structure_row = find(strcmp(app.SelectStructureDropDown.Value,app.Structure_Names{:,1}));
annotation_ids = str2double(app.Structure_Names{structure_row,2});

% Getting annotations file name
wsi_ext = strsplit(app.Slide_Names{slide_idx},'.');
wsi_ext = wsi_ext{end};

display(strcat('Current file is:',app.Slide_Names{slide_idx}))

if strcmp(app.Annotation_Format,'XML')
    file_name = strrep(app.Slide_Names{slide_idx},wsi_ext,'xml');
    
    read_xml = xmlread(strcat(app.Slide_Path,filesep,file_name));

    try
        mpp = read_xml.getElementsByTagName('Annotations');
        mpp = str2double(mpp.item(0).getAttribute('MicronsPerPixel'));
        app.MPP = mpp;
    end
    try
    structure_num=0;
    for s = 1:length(annotation_ids)
        annotations = read_xml.getElementsByTagName('Annotation');
        structure_regions = annotations.item(annotation_ids(s)-1);
        
        regions = structure_regions.getElementsByTagName('Region');
        
        structure_num = structure_num + regions.getLength;
    end

    catch
        structure_num = 0;
    end
else

    file_name = strrep(app.Slide_Names{slide_idx},wsi_ext,'json');

    if ~isfile(strcat(app.Slide_Path,filesep,file_name))
        file_name = strrep(app.Slide_Names{slide_idx},wsi_ext,'geojson');
    end

    read_json = jsondecode(strcat(app.Slide_Path,filesep,file_name));

    structure_num = length(read_json);
end



