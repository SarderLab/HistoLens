% --- Function for loading Catch N Release experiment from experiment file
function structure_info = Load_Catch_N_Release(app)

% Read experiment file
exp_file = app.Experiment_File;

exp_struct = xml2struct(exp_file);
% Experiment Name
experiment_name = fieldnames(exp_struct);
experiment_name = experiment_name{1};

if any(ismember(fieldnames(exp_struct.(experiment_name)),'Slide_Directory'))
    slide_directory = exp_struct.(experiment_name).Slide_Directory.Text;
else
    slide_directory = uigetdir(pwd,'Select folder containing slides:');
end


structure_list = fieldnames(exp_struct.(experiment_name).Structure);
for st = 1:length(structure_list)
    structure_name = structure_list{st};

    % Loading stain normalization
    if ismember('StainNormalization',fieldnames(exp_struct.(experiment_name).Structure.(structure_name)))
        means_text = exp_struct.(experiment_name).Structure.(structure_name).StainNormalization.Means.Text;
        max_text = exp_struct.(experiment_name).Structure.(structure_name).StainNormalization.Maxs.Text;
    
        means_text = strsplit(means_text,'\n');
        max_text = strsplit(max_text,'\n');
    
        for i = 1:3
            nums_means = str2double(strsplit(means_text{i},' '));
            means_nums(i,:) = nums_means;
    
            nums_maxs = str2double(strsplit(max_text{i},' '));
            max_nums(i,:) = nums_maxs;
        end
    
        structure_info.(structure_name).StainNormalization.Means = means_nums;
        structure_info.(structure_name).StainNormalization.Maxs = max_nums;
    end
    
    structure_info.(structure_name).AnnotationID = str2double(exp_struct.(experiment_name).Structure.(structure_name).AnnotationID.Text);
    
    comp_seg = exp_struct.(experiment_name).Structure.(structure_name).CompartmentSegmentation;
    
    % Placeholder for custom segmentation procedure or CNN whatever
    % segmentation

    comp_fields = fieldnames(comp_seg);
    comp_list = {'PAS','Luminal','Nuclei'};
    if strcmp(comp_fields{1},'Stain')
        structure_info.(structure_name).CompSeg.Stain = comp_seg.Stain.Text;
    end
    if strcmp(comp_fields{1},'Colorspace')
        structure_info.(structure_name).CompSeg.Colorspace = comp_seg.Colorspace.Text;
    end
    for c = comp_list
        comp = c{1};
        
        structure_info.(structure_name).CompSeg.(comp).Channel = str2double(comp_seg.(comp).Channel.Text);
        structure_info.(structure_name).CompSeg.(comp).Threshold = str2double(comp_seg.(comp).Threshold.Text);
        structure_info.(structure_name).CompSeg.(comp).MinSize = str2double(comp_seg.(comp).MinSize.Text);
        structure_info.(structure_name).CompSeg.(comp).Order = str2double(comp_seg.(comp).Order.Text);
    end

    if any(ismember(fieldnames(exp_struct.(experiment_name).Structure.(structure_name)),'FeatureSet'))

        structure_info.(structure_name).FeatureSet = exp_struct.(experiment_name).Structure.(structure_name).FeatureSet.Text;
    else
        [file,path] = uigetfile('*','Select Feature Set file');
        structure_info.(structure_name).FeatureSet = strcat(path,file);
    end


    if ~isempty(exp_struct.(experiment_name).Structure.(structure_name).MPP.Text)
        MPP = str2double(exp_struct.(experiment_name).Structure.(structure_name).MPP.Text);
    else
        MPP = [];
    end
    
    if any(ismember(fieldnames(exp_struct.(experiment_name).Structure.(structure_name)),'FeatureRanks'))
        rank_categories = fieldnames(exp_struct.(experiment_name).Structure.(structure_name).FeatureRanks);
        
        for name = 1:length(rank_categories)
            current_feature = rank_categories{name};
            rank_path = exp_struct.(experiment_name).Structure.(structure_name).FeatureRanks.(current_feature).Text;
            app.Feat_Rank.(current_feature) = readtable(rank_path,'Delimiter',',','ReadVariableNames',true,'VariableNamingRule','preserve');
        end

        structure_info.(structure_name).FeatureRanks = exp_struct.(experiment_name).Structure.(structure_name).FeatureRanks;
    else
        structure_info.(structure_name).FeatureRanks = 'None';
    end

    if any(ismember(fieldnames(exp_struct.(experiment_name).Structure.(structure_name)),'LabelType'))
        structure_info.LabelFile = exp_struct.(experiment_name).Structure.(structure_name).LabelFile.Text;
        structure_info.LabelType = exp_struct.(experiment_name).Structure.(structure_name).LabelType.Text;
        structure_info.FileLabelCol = exp_struct.(experiment_name).Structure.(structure_name).FileLabelCol.Text;
        structure_info.ClassLabelCol = exp_struct.(experiment_name).Structure.(structure_name).ClassLabelCol.Text;
    end

end

app.Slide_Path = slide_directory;
app.MPP = MPP;

