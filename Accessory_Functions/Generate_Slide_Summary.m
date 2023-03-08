% Function for generating slide-level feature summaries
function Generate_Slide_Summary(app)

% Feature summaries for each structure and each slide
structures = app.Structure_Names(:,1);
progress = 0;
slide_wb = waitbar(progress,'Saving Slide-level Feature Summaries',...
    'CreateCancelBtn','setappdata(gcbf,"canceling",1)');

% Getting whether it's one file per structure or one file per slide per
% structure
if app.OnefileperslideButton.Value
    one_file = false;
else
    one_file = true;

    % Making new directory to store slide-summaries
    summary_folder = strcat(app.Slide_Path,filesep,'Slide Level Summaries',filesep);
    mkdir(summary_folder)
end


for st = 1:length(structures)
    % Adding cancel button
    if getappdata(slide_wb,'canceling')
        break
    end

    current_structure = structures{st};
    structure_idx_name = strcat('Structure_',num2str(st));
    % Slide labels stored as 'Label_1' in
    % app.Aligned_Labels.(current_structure)
    slides = app.Aligned_Labels.(structure_idx_name).Label_1.Sub_Class;
    for t = 1:length(slides)
        current_slide = slides{t};

        % Updating waitbar
        waitbar(progress,slide_wb,strcat(['On: ',current_structure,', Slide: ',current_slide]))

        slide_img_labels = app.Aligned_Labels.(structure_idx_name).Label_1.Aligned.ImgLabel(find(strcmp(current_slide,app.Aligned_Labels.(structure_idx_name).Label_1.Aligned.Class)));
        slide_structure_features = app.base_Feature_set.(structure_idx_name)(find(ismember(app.base_Feature_set.(structure_idx_name).ImgLabel,slide_img_labels)),:);

        slide_summary_table = table();
        
        features = slide_structure_features.Properties.VariableNames;
        for f = 1:length(features)
            current_feature = features{f};
            if ~strcmp(current_feature,'ImgLabel')
                feature_data = slide_structure_features.(current_feature);

                Min = min(feature_data);
                Median = median(feature_data);
                Average = mean(feature_data);
                StandardDeviation = std(feature_data);
                Max = max(feature_data);
                Sum = sum(feature_data);
                N_Structures = length(feature_data);

                feature_table = table(Min,Median,Average,StandardDeviation,Max,Sum,N_Structures);
                feature_table.Properties.RowNames = {current_feature};

                slide_summary_table = [slide_summary_table;feature_table];
            end
        end

        % Whether to write a new sheet or a new file 
        if one_file
            file_name = strcat(app.Slide_Path,filesep,current_structure,'_Feature_Summary.xlsx');
            writetable(slide_summary_table,file_name,'Sheet',current_slide,'WriteRowNames',true)
        else
            file_name = strcat(summary_folder,current_slide,'_',current_structure,'_Feature_Summary.xlsx');
            writetable(slide_summary_table,file_name,'Sheet',current_slide,'WriteRowNames',true)

        end
        progress = (st/length(structures))*(t/length(slides));
    end
end

progress = 1;
% Updating waitbar
waitbar(progress,slide_wb,'All Done!')
pause(0.2)
delete(slide_wb)



