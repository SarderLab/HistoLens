% --- Function for plotting Violinplot
function Plot_Violin(app)

plot_idx = find(app.Overlap_Feature_idx.(app.Structure)==app.map_idx);
rm_out = app.rem_out;

event = [];
cla(app.Dist_Ax,'reset')

% Feature values
feat_name = app.Full_Feature_set.(app.Structure).Properties.VariableNames{plot_idx};

if ~app.Combine_Label
    try
        data = horzcat(num2cell(app.Full_Feature_set.(app.Structure).(feat_name)),num2cell(app.Full_Feature_set.(app.Structure).ImgLabel),...
            num2cell(app.Full_Feature_set.(app.Structure).Class));
    catch
        data = horzcat(num2cell(app.Full_Feature_set.(app.Structure).(feat_name)),app.Full_Feature_set.(app.Structure).ImgLabel,...
            app.Full_Feature_set.(app.Structure).Class);
    end
    
    data = cell2table(data,'VariableNames',{feat_name, 'ImgLabel','Class'});
    
    % Getting labeling class from selection
    data_ind = Subset_Data(app,event);
    % Data only for the classes we are interested in
    sub_data = data(find(data_ind),:);
    
    if rm_out
        [~,TF] = rmoutliers(sub_data.(feat_name));
        TF = TF+ismissing(sub_data.(feat_name));
        
        % Populating Outlier Table
        app.OutlierTable.Data = sub_data.ImgLabel(find(TF));
        app.OutlierTable.Visible = 'on';
    
        sub_data = sub_data(~TF,:);
    end
    
    current_val = app.Image_Name_Label.Value;
    app.Image_Name_Label.Items = Combine_Name_Label(app, sub_data.ImgLabel(:),sub_data.(feat_name)(:));
    if ~isempty(find(strcmp(app.Image_Name_Label.Items,current_val)))
        app.Image_Name_Label.Value = current_val;
    else
        app.Image_Name_Label.Value = app.Image_Name_Label.Items(1);
    end
    
    app.Dist_Data = sub_data;
else
    sub_data = app.Dist_Data;
end

axes(app.Dist_Ax)

% For if switching to a new label or initializing application
if isempty(app.Plot_Options) || ~ismember('LabelOrder',fieldnames(app.Plot_Options))
    Initialize_Plot_Options(app,'violin')
end


% Plotting Violinplot of data, labeling by Treatment/Class
if ~isnumeric(app.Dist_Data.Class)
    violinplot(sub_data.(feat_name), sub_data.Class, 'GroupOrder',app.Plot_Options.LabelOrder);
else
    violinplot(sub_data.(feat_name),sub_data.Class);
end
xlabel('Class')
ylabel(app.feature_encodings.Feature_Names{app.map_idx})
title(app.feature_encodings.Feature_Names{app.map_idx})



