% --- Function to update feature rankings for new labels or for new Method
function Update_Feature_Ranks(app,labels)

% labels is a cell array of all the label names to grab from
% app.Aligned_Labels. Looks through all structures in the event a new
% slide-level label is added which would impact all structures. Ignores
% "Unlabeled"

structures = fieldnames(app.Full_Feature_set);
for st = 1:length(structures)
    current_structure = structures{st};

    for l = 1:length(labels)
        current_label = labels{l};

        if ismember(current_label,app.Aligned_Labels.(current_structure).AllLabels)
            label_idx = find(strcmp(current_label,app.Aligned_Labels.(current_structure).AllLabels));
            % Grab labels and sub-classes (removing unlabeled samples)
            aligned_labels = app.Aligned_Labels.(current_structure).(strcat('Label_',num2str(label_idx))).Aligned;
            aligned_labels = aligned_labels(find(~strcmp(aligned_labels.Class,'Unlabeled')),:);
            
            % Getting features for ranking
            feature_table = innerjoin(app.base_Feature_set.(current_structure),aligned_labels);
            feature_table.ImgLabel = [];

            if ~isnumeric(aligned_labels.Class)
                sub_classes = app.Aligned_Labels.(current_structure).(strcat('Label_',num2str(label_idx))).Sub_Class;
                % Iterating through sub_classes
                for sc = 1:length(sub_classes)
                    current_sub = sub_classes{sc};
                    if ~strcmp(current_sub,'Unlabeled')
                        
                        rankings_features = feature_table;
                        rankings_features(find(~strcmp(feature_table.Class,current_sub)),end) = {'Not'};

                        if strcmp(app.Feat_Rank.(current_structure).Method,'chi-square')
                            feature_ranks = fscchi2(rankings_features,'Class');
                        elseif strcmp(app.Feat_Rank.(current_structure).Method,'MRMR')
                            feature_ranks = fscmrmr(rankings_features,'Class');
                        elseif strcmp(app.Feat_Rank.(current_structure).Method,'ReliefF')
                            feature_ranks = relieff(table2array(rankings_features(:,1:end-1)),feature_rankings.Class,10);
                        end

                        [~,ordered_ranks] = intersect(feature_ranks,(1:width(rankings_features)-1));

                        % Making new sub-class label
                        sub_label = strcat('SubClass_',num2str(width(app.Feat_Rank.(current_structure).Table)+1));
                        cat_table = table(ordered_ranks,'VariableNames',{sub_label});

                        app.Feat_Rank.(current_structure).Table = [app.Feat_Rank.(current_structure).Table,cat_table];
                        app.Feat_Rank.(current_structure).AllRanks = [app.Feat_Rank.(current_structure).AllRanks;{current_sub}];
                    end
                end
            else
                % For numeric labels, don't have to go through sub-classes
                if strcmp(app.Feat_Rank.(current_structure).Method,'chi-square')
                    feature_ranks = fscchi2(feature_table,'Class');
                elseif strcmp(app.Feat_Rank.(current_structure).Method,'MRMR')
                    feature_ranks = fscmrmr(feature_table,'Class');
                elseif strcmp(app.Feat_Rank.(current_structure).Method,'ReliefF')
                    feature_ranks = relieff(table2array(feature_table(:,1:end-1)),feature_table.Class,10);
                end

                [~,ordered_ranks] = intersect(feature_ranks,(1:width(feature_table)-1));

                sub_label = strcat('SubClass_',num2str(width(app.Feat_Rank.(current_structure).Table)+1));
                cat_table = table(ordered_ranks,'VariableNames',{sub_label});

                app.Feat_Rank.(current_structure).Table = [app.Feat_Rank.(current_structure).Table,cat_table];
                app.Feat_Rank.(current_structure).AllRanks = [app.Feat_Rank.(current_structure).AllRanks;{current_label}];
            end
        end
    end
end
                    
% Updating Feature Ranks dropdown
app.FeatureRankingsUsedDropDown.Items = app.Feat_Rank.(app.Structure).AllRanks;




