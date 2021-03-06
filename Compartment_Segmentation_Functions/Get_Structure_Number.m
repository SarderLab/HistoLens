% --- Function to get the number of structures present in a slide
function structure_num = Get_Structure_Number(app)

slide_idx = app.Slide_Idx.(app.SelectStructureDropDown.Value);
structure_idx = app.Structure_Names.(app.SelectStructureDropDown.Value).Annotation_ID;

% % Getting the xml filename
if contains(app.Slide_Names{slide_idx},'.svs')
    file_name = strrep(app.Slide_Names{slide_idx},'.svs','.xml');
else
    file_name = strrep(app.Slide_Names{slide_idx},'.ndpi','.xml');
end

display(strcat('Current file is',file_name))
read_xml = xmlread(strcat(app.Slide_Path,filesep,file_name));

try
    mpp = read_xml.getElementsByTagName('Annotations');
    mpp = str2double(mpp.item(0).getAttribute('MicronsPerPixel'));
    app.MPP = mpp;
end

annotations = read_xml.getElementsByTagName('Annotation');
structure_regions = annotations.item(structure_idx-1);

regions = structure_regions.getElementsByTagName('Region');

structure_num = regions.getLength;



