% --- Function for loading information from experiment file
function structure_info = Load_Experiment(app)

% Reading experiment file and converting to struct
exp_file = app.Experiment_File;
exp_struct = readstruct(exp_file);

% Current Slide Directory
if any(ismember(fieldnames(exp_struct),'Slide_Directory'))
    slide_directory = exp_struct.Slide_Directory;

    % Checking if that directory is present, if not then prompt for
    % directory of slides and adjust experiment file which is from another
    % user
    if ~exist(slide_directory,'dir')
        slide_directory = uigetdir(pwd,'Select folder containing slides:');
    end
end

% Checking number of slides is the same as in slide directory (check for
% added or missing slides)

% Loading slide-level normalization values if present
% if ismember('SlideNormalization',fieldnames(exp_struct))
%     structure_info.Slide_Normalization = Load_Slide_Normalization(exp_struct.SlideNormalization);
% end

% Loading global stain normalization values if present (Move this to be
% non-structure specific. It should be the same stain for each structure if
% it's on the same slide)
if ismember('StainNormalization',fieldnames(exp_struct))
    app.Seg_Params.StainNormalization = Load_Slide_Normalization(exp_struct.StainNormalization);
end

% Loading structure-specific information
structure_list = fieldnames(exp_struct.Structure);
structure_list = structure_list(~ismember(structure_list,'StainNormalization'));

% "structure_name" here will be the structure-idx-name
app.Structure_Names = cell(1,2);
for st = 1:length(structure_list)
    structure_name = structure_list{st};
    % Loading annotation id(s) for a given structure
    %structure_info.(structure_name).AnnotationID = exp_struct.Structure.(structure_name).AnnotationID;
    structure_original_name = exp_struct.Structure.(structure_name).Structure_Name;
    annotation_ids = arrayfun(@num2str,exp_struct.Structure.(structure_name).AnnotationID,'UniformOutput',false);
    app.Structure_Names = [app.Structure_Names;{structure_original_name{1},annotation_ids{1}}];

end
app.Structure_Names(1,:) = [];

% Loading slide-level compartment segmentation values
slide_names = fieldnames(exp_struct);
slide_names = slide_names(contains(slide_names,'Slide_Idx'));
for slide = 1:length(slide_names)
    current_slide = slide_names{slide};
    comp_seg = exp_struct.(current_slide).CompartmentSegmentation;
    app.Seg_Params.(current_slide).CompartmentSegmentation = Load_Compartment_Segmentation(comp_seg);
end

for st = 1:length(structure_list)
    structure_name = structure_list{st};
    structure_idx_name = strcat('Structure_',num2str(st));

    % Loading features from experiment file
    structure_info.(structure_idx_name).FeatureSet = Special_Struct2Table(exp_struct.Structure.(structure_idx_name).FeatureSet);
    
    % Loading metadata labels from experiment file (duplicating for
    % slide-level labels)
    if ismember('Aligned_Labels',fieldnames(exp_struct.Structure.(structure_idx_name)))
        labels = fieldnames(exp_struct.Structure.(structure_idx_name).Aligned_Labels);
        for f = 1:length(labels)
            label_name = labels{f};
            if ~strcmp(label_name,'AllLabels')
                structure_info.(structure_idx_name).Aligned_Labels.(label_name).Aligned = unique(Special_Struct2Table(exp_struct.Structure.(structure_idx_name).Aligned_Labels.(label_name).Aligned));
                structure_info.(structure_idx_name).Aligned_Labels.(label_name).Sub_Class = exp_struct.Structure.(structure_idx_name).Aligned_Labels.(label_name).Sub_Class;
                structure_info.(structure_idx_name).Aligned_Labels.(label_name).Name = exp_struct.Structure.(structure_idx_name).Aligned_Labels.(label_name).Name;
            end
        end
        structure_info.(structure_idx_name).Aligned_Labels.AllLabels = cellstr(exp_struct.Structure.(structure_idx_name).Aligned_Labels.AllLabels');
    end

    % Loading structure-level label feature rankings (Load method string
    % separately)
    if ismember('Feat_Rank',fieldnames(exp_struct.Structure.(structure_idx_name)))
        structure_info.(structure_idx_name).Feat_Rank.Table = Special_Struct2Table(exp_struct.Structure.(structure_idx_name).Feat_Rank.Table);
        structure_info.(structure_idx_name).Feat_Rank.Method = exp_struct.Structure.(structure_idx_name).Feat_Rank.Method;
        structure_info.(structure_idx_name).Feat_Rank.Scores = exp_struct.Structure.(structure_idx_name).Feat_Rank.Scores;
        
        % For if all the ranks listed here are numbers
        if ~isnumeric(exp_struct.Structure.(structure_idx_name).Feat_Rank.AllRanks)
            structure_info.(structure_idx_name).Feat_Rank.AllRanks = cellstr(exp_struct.Structure.(structure_idx_name).Feat_Rank.AllRanks');
        else
            structure_info.(structure_idx_name).Feat_Rank.AllRanks = arrayfun(@num2str,exp_struct.Structure.(structure_idx_name).Feat_Rank.AllRanks,'UniformOutput',false)';
        end
    end
end


app.Slide_Path = slide_directory;
app.Experiment_Struct = exp_struct;


