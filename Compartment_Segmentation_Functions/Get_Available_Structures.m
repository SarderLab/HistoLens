% --- Function to get the available structures list for each slide
function available_structures = Get_Available_Structures(app)

% Iterating through slide names and structure annotation IDs
slide_names = app.Slide_Names;
structures = fieldnames(app.Structure_Names);

available_structures = {};
for s = 1:length(slide_names)
    current_xml = slide_names{s};
    current_xml = xmlread(strcat(app.Slide_Path,filesep,strrep(current_xml,'.svs','.xml')));
    
    annotations = current_xml.getElementsByTagName('Annotation');

    include_structures = {};
    for st = 1:length(structures)
        current_structure = structures{st};
        
        structure_idx = app.Structure_Names.(current_structure).Annotation_ID;
        include_array = zeros(1,length(structure_idx));
        for si = 1:length(structure_idx)
            structure_regions = annotations.item(structure_idx(si)-1);
            if ~isempty(structure_regions)
                regions = structure_regions.getElementsByTagName('Region');
                structure_num = regions.getLength;
                if structure_num>0
                    include_array(si) = 1;
                else
                    include_array(si) = 0;
                end
            else
                include_array(si) = 0;
            end
        end

        if any(include_array,'all')
            include_structures = [include_structures;current_structure];
        end
    end

    available_structures = [available_structures,{include_structures}];
end

