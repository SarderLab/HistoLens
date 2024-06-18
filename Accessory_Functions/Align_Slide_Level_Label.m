% --- Function to align new slide-level label
function Align_Slide_Level_Label(app,new_label_table)

all_structures = fieldnames(app.Full_Feature_set);
for s = 1:length(all_structures)
    current_structure = all_structures{s};

    % Getting all slide labels into a table
    all_img_labels = app.base_Feature_set.(current_structure).ImgLabel;
    all_img_slide_labels = cellfun(@(x) strsplit(x,'_'),all_img_labels,'UniformOutput',false);

    lengths = cellfun('length',all_img_slide_labels);
    if any(lengths>2)
        all_img_slide_labels = cellfun(@(x) strjoin(x(1:end-1),'_'),all_img_slide_labels,'UniformOutput',false);
    else
        all_img_slide_labels = cellfun(@(x) x{1},all_img_slide_labels,'UniformOutput',false);
    end

    align_table = cell2table([all_img_labels,all_img_slide_labels],'VariableNames',{'ImgLabel','SlideLabel'});

    % Fixing new_label_table variable names
    new_label_table.Properties.VariableNames(1) = {'SlideLabel'};

    if any(contains(new_label_table.SlideLabel,'.'))
        fixed_labels = cellfun(@(x) strsplit(x,'.'), new_label_table.SlideLabel,'UniformOutput',false);
        fixed_labels = cellfun(@(x) x{1}, fixed_labels,'UniformOutput',false);
        new_label_table.SlideLabel = fixed_labels;
    end

    % Checking if there are any missing slides
    non_overlap_names = align_table{~ismember(align_table.SlideLabel,new_label_table.SlideLabel),:};
    if ~isempty(non_overlap_names)
        % Adding missing slides to the bottom
        non_overlap_names = unique(non_overlap_names(:,2));
        missing_slides = cell2table([non_overlap_names,repmat({'Unlabeled'},length(non_overlap_names),width(new_label_table)-1)],'VariableNames',new_label_table.Properties.VariableNames);
        new_label_table = [new_label_table;missing_slides];
    end
    
    % Iterating through each column of the uploaded file
    labels = new_label_table.Properties.VariableNames;
    for l = 1:length(labels)
        current_col = labels{l};
        if ~strcmp(current_col,'SlideLabel')

            label_idx_name = strcat('Label_',num2str(length(fieldnames(app.Aligned_Labels.(current_structure)))));
            if ~isnumeric(new_label_table.(current_col))

                % Replacing empty elements with 'Unlabeled'
                new_label_table.(current_col)(cell2mat(cellfun(@(x) isempty(x),new_label_table.(current_col),'UniformOutput',false))) = {'Unlabeled'};
                new_label_align = cell2table([new_label_table.SlideLabel,new_label_table.(current_col)],'VariableNames',{'SlideLabel','Class'});
           
            else
                new_label_align = [new_label_table(:,1),array2table(new_label_table.(current_col),'VariableNames',{'Class'})];

            end
                
            % Aligning with innerjoin (new column names should be
            % ImgLabel, SlideLabel, and Class)
            aligned_labels = innerjoin(align_table,new_label_align);
            
            aligned_labels.SlideLabel = [];
            
            % Preventing duplicate label names
            if ismember(current_col,app.Aligned_Labels.(current_structure).AllLabels)
                if ~ismember(strcat(current_col,'_1'),app.Aligned_Labels.(current_structure).AllLabels)
                    current_col = strcat(current_col,'_1');
                else
                    current_labels = app.Aligned_Labels.(current_structure).AllLabels;
                    user_input_labels = current_labels(contains(current_labels,current_col));
                    current_col = strcat(current_col,'_',num2str(length(user_input_labels)+1));
                end
            end

            sub_class = unique(aligned_labels.Class);
            if isnumeric(sub_class)
                sub_class = strsplit(num2str(sub_class'));
            end

            % Adding properties to
            % app.Aligned_Labels.(current_structure)
            app.Aligned_Labels.(current_structure).(label_idx_name).Aligned = aligned_labels;
            app.Aligned_Labels.(current_structure).(label_idx_name).Sub_Class = sub_class;
            app.Aligned_Labels.(current_structure).(label_idx_name).Name = current_col;
            app.Aligned_Labels.(current_structure).AllLabels = [app.Aligned_Labels.(current_structure).AllLabels;{current_col}];
        
        end
    end
end

app.SelectLabelDropDown.Items = app.Aligned_Labels.(app.Structure_Idx_Name).AllLabels;

% Adding new labels to app.Tree
Update_Subset_Tree(app)

% Adding new feature rankings
Update_Feature_Ranks(app,labels(2:end))

% Adding to Experiment_Struct
Update_Experiment_Labels(app)


