% --- Function to get feature statistics and summaries
function Feat_Stats(app,event)

% Only running when multiple classes are included in distribution
if length(unique(app.Dist_Data.Class))>1

    % For single feature comparisons, shown using violinplots
    if length(app.map_idx)==1
        if length(unique(app.Dist_Data.Class))==2
            
            if isnumeric(app.Dist_Data.Class)
                classes = num2cell(unique(app.Dist_Data.Class));
                
                class_1 = app.Dist_Data{app.Dist_Data.Class == classes{1},1};
                class_2 = app.Dist_Data{app.Dist_Data.Class == classes{2},1};
            else
                classes = unique(app.Dist_Data.Class);

                class_1 = app.Dist_Data{find(strcmp(app.Dist_Data.Class,classes{1})),1};
                class_2 = app.Dist_Data{find(strcmp(app.Dist_Data.Class,classes{2})),1};
            end
            % Using two-sample t-test to determine significance,
            % p-value, confidence interval, t-statistic, degrees of
            % freedom, and standard deviation
            [h,p,ci,stats] = ttest2(class_1,class_2);
            
            % Initializing table
            descrip = cell(1);
            values = cell(1);    
            
            count = 0;
            for i = 1:length(classes)
                % Summary values of data
                data_summary = summary(app.Dist_Data(find(strcmp(app.Dist_Data.Class,classes{i})),1));
                feature_name = fieldnames(data_summary);
                feature_name = feature_name{1};
                
                % Populating table
                descrip{count+1,1} = strcat('Feature:',feature_name);
                values{count+1,1} = '-';

                % Class-specific summaries
                descrip{count+2,1} = classes{i};
                values{count+2,1} = '-';
                descrip{count+3,1} = 'Number of Samples:';
                values{count+3,1} = string(height(app.Dist_Data(find(strcmp(app.Dist_Data.Class,classes{i})),1)));
                descrip{count+4,1} = 'Minimum';
                values{count+4,1} = string(data_summary.(feature_name).Min);
                descrip{count+5,1} = 'Median';
                values{count+5,1} = string(data_summary.(feature_name).Median);
                descrip{count+6,1} = 'Max';
                values{count+6,1} = string(data_summary.(feature_name).Max);
                descrip{count+7,1} = 'Mean';
                values{count+7,1} = string(mean(app.Dist_Data{find(strcmp(app.Dist_Data.Class,classes{i})),1},'omitnan'));
                descrip{count+8,1} = 'Standard Deviation';
                values{count+8,1} = string(std(app.Dist_Data{find(strcmp(app.Dist_Data.Class,classes{i})),1},'omitnan'));
                
                count = size(descrip,1);
            end
            
            % Results of statistical test
            descrip{count+1,1} = 'Two-Sample t-test results:';
            values{count+1,1} = '-';
            descrip{count+2,1} = 'Significant?';
            if h==0
                values{count+2,1} = 'No';
            else
                values{count+2,1} = 'Yes';
            end
            descrip{count+3,1} = 'P-Value';
            values{count+3,1} = string(p);
            descrip{count+4,1} = 'Confidence Interval';
            values{count+4,1} = strcat(string(ci(1)),'-->',string(ci(2)));
            descrip{count+5,1} = 't-Stat';
            values{count+5,1} = string(stats.tstat);
            descrip{count+6,1} = 'Degrees of Freedom';
            values{count+6,1} = string(stats.df);
            descrip{count+7,1} = 'Population Standard Deviation';
            values{count+7,1} = string(stats.sd);
            
        else
                        
            % Performing 1-way ANOVA on distribution data
            [p,tbl,stats] = anova1(app.Dist_Data{:,1},app.Dist_Data.Class,'off');
                        
            % Getting sub-classes for current feature
            current_feature = app.SelectLabelDropDown.Value;
            current_label_idx = find(strcmp(current_feature,app.Aligned_Labels.(app.Structure_Idx_Name).AllLabels));
            
            
            % Breaking up classes into quantile ranges
            if isnumeric(app.Dist_Data.Class)
                number_range = true;
                %sub_classes = app.Aligned_Labels.(app.Structure_Idx_Name).(strcat('Label_',num2str(current_label_idx))).Sub_Class;
                sub_classes = quantile(app.Dist_Data.Class,[0.25,0.5,0.75]);
            else
                number_range = false;
                sub_classes = unique(app.Dist_Data.Class);
            end      

            % Initializing table   
            count = 0;
            for i = 1:length(sub_classes)
                % Summary values of data
                if number_range
                    if i==1
                        first_val = min(app.Dist_Data.Class,[],'all');
                        sec_val = sub_classes(i);
                    elseif i==length(sub_classes)
                        first_val = sub_classes(i);
                        sec_val = max(app.Dist_Data.Class,[],'all');
                    else
                        first_val = sub_classes(i-1);
                        sec_val = sub_classes(i);
                    end
                    string_sub_class = strcat(num2str(first_val),'<=X<=',num2str(sec_val));
                    class_data = app.Dist_Data(find(app.Dist_Data.Class>=first_val & app.Dist_Data.Class<=sec_val),1);
                   
                else
                    class_data = app.Dist_Data(find(strcmp(app.Dist_Data.Class,sub_classes{i})),1);
                end
                
                if height(class_data)>0
                    data_summary = summary(class_data);
                    feature_name = fieldnames(data_summary);
                    feature_name = feature_name{1};
    
                    % Populating table
                    descrip{count+1,1} = feature_name;
                    values{count+1,1} = '-';
    
                    % Class-specific summaries
                    if ~number_range
                        descrip{count+2,1} = sub_classes{i};
                    else
                        descrip{count+2,1} = string_sub_class;
                    end
                    values{count+2,1} = '-';
                    descrip{count+3,1} = 'Number of Samples:';
                    values{count+3,1} = string(height(class_data));
                    descrip{count+4,1} = 'Minimum';
                    values{count+4,1} = string(data_summary.(feature_name).Min);
                    descrip{count+5,1} = 'Median';
                    values{count+5,1} = string(data_summary.(feature_name).Median);
                    descrip{count+6,1} = 'Max';
                    values{count+6,1} = string(data_summary.(feature_name).Max);
                    descrip{count+7,1} = 'Mean';
                    values{count+7,1} = string(mean(table2array(class_data(:,1),'omitnan')));
                    descrip{count+8,1} = 'Standard Deviation';
                    values{count+8,1} = string(std(table2array(class_data(:,1),'omitnan')));
                    
                    count = size(descrip,1);
                end
            end
            
            descrip{count+1,1} = 'One-Way ANOVA results';
            values{count+1,1} = '-';
            descrip{count+2,1} = 'Significant?';
            if p>=0.05
                values{count+2,1} = 'No';
            else
                values{count+2,1} = 'Yes';
            end
            descrip{count+3,1} = 'P-Value';
            values{count+3,1} = string(p);
            
            %[results,means] = multcompare(stats,'CType','bonferroni');
            
        
        end

        app.CurrentFeaturesListBox.Enable = 'off';
        app.CurrentFeaturesListBox.Items(:) = [];
        app.ViewBiplotButton.Enable = 'off';
        app.ViewBiplotButton.Text = 'View Biplot';
        app.BiplotTable.Data = [];
        app.BiplotTable.Enable = 'off';

    else
        
        % For multi-feature plots, get clustering stats %
        
        classes = unique(app.Dist_Data.Class);
        number_range = false;
        current_feature = app.SelectLabelDropDown.Value;

        % Breaking up classes into quantile ranges
        if isnumeric(classes)
            number_range = true;
            %sub_classes = app.Aligned_Labels.(app.Structure_Idx_Name).(current_feature).Sub_Class;
            sub_classes = quantile(app.Dist_Data.Class,[0.25,0.5,0.75]);
        else
            number_range = false;
            sub_classes = classes;
        end    
        
        % Initializing table
        descrip = cell(1);
        values = cell(1);    
        count = 0;

        % Calculating silhouette scores for clustering results using first
        % two principal components
        if number_range
            range_class = zeros(height(app.Dist_Data),1);
            for t = 1:length(sub_classes)
%                 first_val = strsplit(sub_classes{t},'<');
%                 first_val = first_val{1};
%                 first_val = str2num(first_val);
%                 sec_val = strsplit(sub_classes{t},'=');
%                 sec_val = sec_val{end};
%                 sec_val = str2num(sec_val);
                if t == 1
                    first_val = min(app.Dist_Data.Class,[],'all');
                    sec_val = sub_classes(t);
                elseif t==length(sub_classes)
                    first_val = sub_classes(t);
                    sec_val = max(app.Dist_Data.Class,[],'all');
                else
                    first_val = sub_classes(t-1);
                    sec_val = sub_classes(t);
                end
                string_sub_class = strcat(num2str(first_val),'<=X<=',num2str(sec_val));

                range_class(find(app.Dist_Data.Class>=first_val & app.Dist_Data.Class<=sec_val)) = t;
            end
            
            sil_scores = silhouette(app.Dist_Data{:,1:2},range_class);
            class_sil_scores = cell(length(sub_classes),2);
            for j = 1:length(sub_classes)
                class_sil = sil_scores(j);

                class_sil_scores{j,1} = sub_classes{j};
                class_sil_scores{j,2} = string(mean(class_sil,'omitnan'));
            end


        else

            sil_scores = silhouette(app.Dist_Data{:,1:2},app.Dist_Data.Class);
            class_sil_scores = cell(length(sub_classes),2);

            for j = 1:length(sub_classes)
                class_sil = sil_scores(find(strcmp(app.Dist_Data.Class,sub_classes{j})));

                class_sil_scores{j,1} = sub_classes{j};
                class_sil_scores{j,2} = string(mean(class_sil,'omitnan'));
            end

        end
        
        descrip{count+1,1} = 'Silhouette Scores by Class';
        values{count+1,1} = '-';
                
        descrip = [descrip;class_sil_scores(:,1)];
        values = [values;class_sil_scores(:,2)];
        
        count = size(descrip,1);
        if length(app.map_idx)>2
            descrip{count+1,1} = 'Percentage Variance Explained by PC';
            values{count+1,1} = '-';
            
            explain_vals = app.PCA_Vals{1};
            descrip{count+2,1} = 'PC 1';
            values{count+2,1} = string(explain_vals(1));
            descrip{count+3,1} = 'PC 2';
            values{count+3,1} = string(explain_vals(2));

            descrip{count+4,1} = 'Coefficients of each Feature';
            values{count+4,1} = '-';
            coeffs = app.PCA_Vals{2};
            coeffs = coeffs(:,1:2);
            
            sub_feature_encodings = app.feature_encodings(app.Overlap_Feature_idx.(app.Structure_Idx_Name),:);
            plot_idx = find(ismember(app.Overlap_Feature_idx.(app.Structure_Idx_Name),app.map_idx));
            all_feature_names = sub_feature_encodings.Feature_Names(plot_idx);
            
            app.CurrentFeaturesListBox.Items = all_feature_names;

            for co = 1:length(app.map_idx)
                descrip{count+4+co,1} = all_feature_names{co};

                cur_row = coeffs(co,:);
                cur_row = strjoin([{num2str(cur_row(1))},{num2str(cur_row(2))}],',');

                values{count+4+co,1} = cur_row;
            end

            app.CurrentFeaturesListBox.Enable = 'on';
            app.BiplotTable.Data = [];
            app.ViewBiplotButton.Enable = 'off';
            app.ViewBiplotButton.Text = 'View Biplot';

        else

            app.CurrentFeaturesListBox.Enable = 'off';
            app.CurrentFeaturesListBox.Items = {''};
            app.ViewBiplotButton.Enable = 'off';
            app.ViewBiplotButton.Text = 'View Biplot';
            app.BiplotTable.Data = [];
            app.BiplotTable.Enable = 'off';
        end

    end
    
    
    app.UITable4.Data = cell2table([descrip,values]);
    
else
    % Not bothering with unsupervised/intra-class statistics for now
    app.UITable4.Data = [];
end
