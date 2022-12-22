% --- Function to align Structure-level label
function Align_Structure_Level_Label(app,new_label_table)

% Only adding structure_level_labels to the current structure
current_structure = app.Structure;

% Table with one column, 'ImgLabel'
align_table = app.base_Feature_set.(current_structure)(:,end);

% Fixing new_label_table variable names
new_label_table.Properties.VariableNames(1) = {'ImgLabel'};
if any(contains(new_label_table.ImgLabel,'.'))
    fixed_labels = cellfun(@(x) strsplit(x,'.'),new_label_table.ImgLabel,'UniformOutput',false);
    fixed_labels = cellfun(@(x) x{1}, fixed_labels,'UniformOutput',false);
    new_label_table.ImgLabel = fixed_labels;
end

% Checking for missing structures
non_overlap_names = align_table{~ismember(align_table.ImgLabel,new_label_table.ImgLabel),:};
if ~isempty(non_overlap_names)
    % Adding missing structures to the bottom
    missing_structures = cell2table([non_overlap_names,repmat({'Unlabeled'},length(non_overlap_names),width(new_label_table)-1)],'VariableNames',new_label_table.Properties.VariableNames);
    new_label_table = [new_label_table;missing_structures];
end

% Iterating through each column of the uploaded file
labels = new_label_table.Properties.VariableNames;
for l = 1:length(labels)
    current_col = labels{l};
    if ~strcmp(current_col,'ImgLabel')

        label_idx_name = strcat('Label_',num2str(length(fieldnames(app.Aligned_Labels.(current_structure)))));
        if ~isnumeric(new_label_table.(current_col))

            % Replacing empty elements with 'Unlabeled'
            new_label_table.(current_col)(cell2mat(cellfun(@(x) isempty(x),new_label_table.(current_col),'UniformOutput',false))) = {'Unlabeled'};
        end

        new_label_align = cell2table([new_label_table.ImgLabel,new_label_table.(current_col)],'VariableNames',{'ImgLabel','Class'});

        % Aligning with innerjoin (new column names should be ImgLabel,
        % Class)
        aligned_labels = innerjoin(align_table,new_label_align);

        % Preventing duplicate label names
        if ismember(current_col, app.Aligned_Labels.(current_structure).AllLabels)
            if ~ismember(strcat(current_col,'_1'),app.Aligned_Labels.(current_structure).AllLabels)
                current_col = strcat(current_col,'_1');
            else
                current_labels = app.Aligned_Labels.(current_structure).AllLabels;
                user_input_labels = current_labels(contains(current_labels,current_col));
                current_col = strcat(current_col,'_',num2str(length(user_input_labels)+1));
            end
        end

        sub_class = unique(aligned_labels.Class);

        % Adding properties to app.Aligned_Labels.(current_structure)
        app.Aligned_Labels.(current_structure).(label_idx_name).Aligned = aligned_labels;
        app.Aligned_Labels.(current_structure).(label_idx_name).Sub_Class = sub_class;
        app.Aligned_Labels.(current_structure).(label_idx_name).Name = current_col;
        app.Aligned_Labels.(current_structure).AllLabels = [app.Aligned_Labels.(current_structure).AllLabels;{current_col}];

        % Adding label to SelectLabelDropDown Items
        app.SelectLabelDropDown.Items = [app.SelectLabelDropDown.Items,current_col];
    end
end

% Adding new labels to app.Tree
Update_Subset_Tree(app)

% Adding new feature rankings
Update_Feature_Ranks(app,labels(2:end))

% Adding to Experiment Struct
Update_Experiment_Labels(app)
