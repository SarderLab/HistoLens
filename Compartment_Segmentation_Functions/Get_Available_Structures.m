% --- Function to get the available structures list for each slide
function available_structures = Get_Available_Structures(app)

% Iterating through slide names and structure annotation IDs
slide_names = app.Slide_Names;
structures = app.Structure_Names{:,1};
ann_ids = app.Structure_Names{:,2};

available_structures = {};
for s = 1:length(slide_names)
    current_slide = slide_names{s};
    
    wsi_ext = strsplit(current_slide,'.');
    wsi_ext = wsi_ext{end};

    if strcmp(app.Annotation_Format,'XML')
        current_ann = strcat(app.Slide_Path,filesep,strrep(current_slide,wsi_ext,'xml'));
        current_ann = xmlread(current_ann);

        annotations = current_ann.getElementsByTagName('Annotation');
    
        include_structures = {};
        for st = 1:length(structures)
            current_structure = structures{st};
            
            structure_idx = str2double(ann_ids);
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

    elseif strcmp(app.Annotation_Format,'JSON')
        current_ann = strcat(app.Slide_Path,filesep,strrep(current_slide,wsi_ext,'json'));

        if ~isfile(current_ann)
            current_ann = strrep(current_ann,'.json','.geojson');
        end
        current_ann = jsondecode(current_ann);

        % Haven't figured out a good way to do multi-compartment with json
        % annotations yet so just pass it if it has anything
        if ~isempty(current_ann)
            include_structures = structures;
        else
            include_structures = [];
        end
    end
    
    available_structures = [available_structures,{include_structures}];
end

