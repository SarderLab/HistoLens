% --- Function to control labeling feature and feature statistics
function Organize_Labels(app,event)

% Get type of current labeling feature
label_type = app.LabelType.Text;
label_type = strsplit(label_type,': ');
label_type = label_type{end};

% For numeric features:
if strcmp(label_type,'Numeric')
    app.NumericLabelOptionsButtonGroup.Enable = 'on';
    
    % Getting selected button
    sel_butt = app.NumericLabelOptionsButtonGroup.SelectedObject;
    string_values = {app.NumericLabelOptionsButtonGroup.Buttons.Text};
    butt_idx = find(strcmp(sel_butt.Text,string_values));
    
    % For the "Use all/reset" option
    if butt_idx==1
        
        app.CutoffValueEditField.Value = 0;
        app.CutoffValueEditField.Enable = 'off';
        
        % Aligning full feature set and Dist_Data along 'Class'
        app.Dist_Data.Class = [];
        
        app.Dist_Data = innerjoin(app.Dist_Data,...
            app.Full_Feature_set.(app.Structure_Idx_Name)(:,ismember(app.Full_Feature_set.(app.Structure_Idx_Name).Properties.VariableNames,...
            {'ImgLabel','Class'})));
        
        app.New_Label = true;
        app.Combine_Label = true;
        Plot_Feat(app,event)
        View_Image(app,event)
        app.New_Label = false;
        app.Combine_Label = false;
        
    end
    
    % For the "Use Quartiles" option
    if butt_idx==2
        
        app.CutoffValueEditField.Value = 0;
        app.CutoffValueEditField.Enable = 'off';
        
        quant_vals = quantile(app.Dist_Data.Class,[0,0.25,0.5,0.75,1]);
        label_sub_in = cell(height(app.Dist_Data),1);
        label_sub_in(find(app.Dist_Data.Class>=quant_vals(1) & ...
            app.Dist_Data.Class<=quant_vals(2))) = {strcat(num2str(quant_vals(1)),...
            '<=X<=',num2str(quant_vals(2)))};
        label_sub_in(find(app.Dist_Data.Class>=quant_vals(2) & ...
            app.Dist_Data.Class<=quant_vals(3))) = {strcat(num2str(quant_vals(2)),...
            '<=X<=',num2str(quant_vals(3)))};
        label_sub_in(find(app.Dist_Data.Class>=quant_vals(3) & ...
            app.Dist_Data.Class<=quant_vals(4))) = {strcat(num2str(quant_vals(3)),...
            '<=X<=',num2str(quant_vals(4)))};
        label_sub_in(find(app.Dist_Data.Class>=quant_vals(4) & ...
            app.Dist_Data.Class<=quant_vals(5))) = {strcat(num2str(quant_vals(4)),...
            '<=X<=',num2str(quant_vals(5)))};
        
        app.Dist_Data.Class = [];
        app.Dist_Data.Class = label_sub_in;
        
        app.New_Label = true;
        app.Combine_Label = true;
        Plot_Feat(app,event)
        View_Image(app,event)
        app.New_Label = false;
        app.Combine_Label = false;
        
    end
    
    % For the "Set Binary Levels" option
    if butt_idx==3
        
        app.CutoffValueEditField.Enable = 'on';
        
    end
end

% For Categorical Features
if strcmp(label_type,'Categorical')
    app.CategoricalLabelOptionsButtonGroup.Enable = 'on';
    
    % Getting selected button
    sel_butt = app.CategoricalLabelOptionsButtonGroup.SelectedObject;
    string_values = {app.CategoricalLabelOptionsButtonGroup.Buttons.Text};
    butt_idx = find(strcmp(sel_butt.Text,string_values));
    
    % For the "Use all/reset" option
    if butt_idx==1
        
        app.CombinedClassNameEditField.Value = '';
        app.Combine1DropDown.Items = {'Select One'};
        app.Combine2DropDown.Items = {'Select One'};
        % Aligning full feature set and Dist_Data along 'Class'
        % Aligning full feature set and Dist_Data along 'Class'
        
        % Disabling all combo widgets
        app.Combine1DropDown.Enable = 'off';
        app.Combine2DropDown.Enable = 'off';
        app.CombinedClassNameEditField.Value = '';
        app.CombinedClassNameEditField.Enable = 'off';
        
        
        app.Dist_Data.Class = [];
        
        app.Dist_Data = innerjoin(app.Dist_Data,...
            app.Full_Feature_set(:,ismember(app.Full_Feature_set.(app.Structure_Idx_Name).Properties.VariableNames,...
            {'ImgLabel','Class'})));
        
        app.New_Label = true;
        app.Combine_Label = true;
        Plot_Feat(app,event)
        View_Image(app,event)
        app.New_Label = false;
        app.Combine_Label = false;
    end
    
    % For the "Combine Classes" option
    if butt_idx==2
        classes = unique(app.Full_Feature_set.(app.Structure_Idx_Name).Class);
    
        % Enabling combine drop down menus, separate callback to disallow
        % combining the same feature with itself 
        app.Combine1DropDown.Enable = 'on';
        app.CombinedClassNameEditField.Enable = 'on';
        app.Combine1DropDown.Items = [{'Select One'};classes];
        app.Combine2DropDown.Items = [{'Select One'};classes];
        
    end
    
end
        


