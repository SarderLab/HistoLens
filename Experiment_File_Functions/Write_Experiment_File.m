% --- Function to write Experiment File including features and segmentation
% parameters. Update later to write labels and feature ranks
function Write_Experiment_File(app)

% Key information to include:
%
%   Global info
%       Stain Normalization (optional)
%       Slide Directory (prompt user if not present or different when
%       loading)
%
%   Structure info
%       Annotation IDs
%       Compartment Segmentation
%       Features

% User specified experiment name (already confirmed to be valid varname)
%experiment_name = app.Experiment_File;

% Starting Experiment struct with global info
% Slide Directory
Experiment_Struct.Slide_Directory = app.Slide_Path;
% Stain Normalization (if added)
if ismember('StainNormalization',fieldnames(app.Seg_Params))
    char_means = num2str(app.Seg_Params.StainNormalization.Means);
    char_maxs = num2str(app.Seg_Params.StainNormalization.Maxs);
    for i = 1:3
        norm_means.(strcat('Row_',num2str(i))) = strjoin(strsplit(char_means(i,:),'  '),',');
        norm_maxs.(strcat('Row_',num2str(i))) = strjoin(strsplit(char_maxs(i,:),'  '),',');
    end

    Experiment_Struct.StainNormalization.Means = norm_means;
    Experiment_Struct.StainNormalization.Maxs = norm_maxs;
end

% Storing structure-level information
%structures = fieldnames(app.Structure_Names);
structures = app.Structure_Names{:,1};
for i = 1:length(structures)
    structure = structures{i};
    structure_idx_name = strcat('Structure_',num2str(i));
    
    % Finding the row with this structure name
    structure_row = find(strcmp(structure,app.Structure_Names{:,1}));
    annotation_ids = app.Structure_Names{structure_row,2};

    Experiment_Struct.Structure.(structure_idx_name).AnnotationID = annotation_ids;
    Experiment_Struct.Structure.(structure_idx_name).Structure_Name = structure;
end

% Recording slide-level compartment segmentation procedures
slide_names = fieldnames(app.Final_Seg_Params);
for slide = 1:length(slide_names)
    current_slide = slide_names{slide};
    if contains(current_slide,'Slide_Idx')
        Experiment_Struct.(current_slide).SlideName = app.Final_Seg_Params.(current_slide).SlideName;
        Experiment_Struct.(current_slide).CompartmentSegmentation = app.Final_Seg_Params.(current_slide).CompartmentSegmentation;
    end
end

%display(strcat('Saving experiment file to:',strcat(app.Slide_Path,filesep,app.Experiment_File,'.xml')));
%writestruct(Experiment_Struct,strcat(app.Slide_Path,filesep,app.Experiment_File,'.xml'),'StructNodeName','HistoLensExperimentParameters')
% Saving experiment struct to the main app so that it can be updated as new
% labels are added
app.Experiment_Struct = Experiment_Struct;



