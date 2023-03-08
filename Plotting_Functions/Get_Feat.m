% --- Function to sort through categories/features to get feature indices
% and names
function Get_Feat(app,event)
% Main handle of interest is handles.feature_encodings

% Step 1) Determine which button was pressed that would lead to Get_Feat
% Step 2) Get feature index relative to original list of features

% Get type of current labeling feature
label_type = app.LabelType.Text;
label_type = strsplit(label_type,': ');
label_type = label_type{end};

if strcmp(label_type,'Numeric')
    app.NumericLabelOptionsButtonGroup.SelectedObject = app.NumericLabelOptionsButtonGroup.Buttons(1);
    app.CutoffValueEditField.Value = 0;
    app.CutoffValueEditField.Enable = 'off';
else
    app.CategoricalLabelOptionsButtonGroup.SelectedObject = app.CategoricalLabelOptionsButtonGroup.Buttons(1);
    app.AddComboButton.Enable = 'off';
    app.Combine1DropDown.Enable = 'off';
    app.Combine1DropDown.Items = {'Select One'};
    app.Combine2DropDown.Enable = 'off';
    app.Combine2DropDown.Items = {'Select One'};
end

if any([app.Spec_View,app.Feat_View,app.Comp_View,app.Custom_View])

    sub_feature_encodings = app.feature_encodings(app.Overlap_Feature_idx.(app.Structure_Idx_Name),:);
    
    % For viewing a specific feature there will only be one feature
    if app.Spec_View

        sel_comp = app.Comp_List.Value;
        sel_feat = app.Feat_List.Value;
        sel_spec = app.Spec_List.Value;
            
        if ~strcmp(sel_comp,'Weighted Visualization')
            row_idx = (strcmp(sub_feature_encodings.Compartment,sel_comp) & ...
                strcmp(sub_feature_encodings.Type, sel_feat) & ...
                strcmp(sub_feature_encodings.Specific,sel_spec));
        else
            row_idx = (strcmp(sub_feature_encodings.Type, sel_feat)&...
                strcmp(sub_feature_encodings.Specific,sel_spec));
        end
        
        app.map_idx = app.Overlap_Feature_idx.(app.Structure_Idx_Name)(find(row_idx));
        app.og_map_idx = app.Overlap_Feature_idx.(app.Structure_Idx_Name)(find(row_idx));
        
    end
    if app.Feat_View
        sel_comp = app.Comp_List.Value;
        sel_feat = app.Feat_List.Value;

        if ~strcmp(sel_comp,'Weighted Visualization')
            row_idx = (strcmp(sub_feature_encodings.Compartment,sel_comp) & ...
                strcmp(sub_feature_encodings.Type, sel_feat));
        else
            row_idx = (strcmp(sub_feature_encodings.Type, sel_feat));
        end
        
        if ~isempty(app.Feat_Rank)
            app.Rank_Slide.Enable = 'on';
        end
        
        app.map_idx = app.Overlap_Feature_idx.(app.Structure_Idx_Name)(find(row_idx));
        app.og_map_idx = app.Overlap_Feature_idx.(app.Structure_Idx_Name)(find(row_idx));

    end
    if app.Comp_View
        sel_comp = app.Comp_List.Value;

        if ~strcmp(sel_comp,'Weighted Visualization')
            row_idx = (strcmp(sub_feature_encodings.Compartment,sel_comp));
        else
            row_idx = ones(height(sub_feature_encodings),1);
        end
        
        if ~isempty(app.Feat_Rank)
            app.Rank_Slide.Enable = 'on';
        end
        
        app.map_idx = app.Overlap_Feature_idx.(app.Structure_Idx_Name)(find(row_idx));
        app.og_map_idx = app.Overlap_Feature_idx.(app.Structure_Idx_Name)(find(row_idx));

    end
    
    
    if app.Custom_View
        app.map_idx = app.Custom_map_idx;
        app.og_map_idx = app.Custom_map_idx;
        
        row_idx = app.Custom_map_idx;
    end
     
    
    % Filling in Feat_Defs and Feat_Meth table
    app.UITable2.Data = [app.feature_encodings.Feature_Names(app.map_idx),...
        app.feature_encodings.Definition(app.map_idx)];
    app.UITable2.ColumnName = {'Feature Names','Definitions'};

    app.UITable.Data = [app.feature_encodings.Feature_Names(app.map_idx),...
        app.feature_encodings.Map_Method(app.map_idx)];
    app.UITable.ColumnName = {'Feature Names','Map Method'};    
    
else
    
    sub_feature_encodings = app.feature_encodings(app.Overlap_Feature_idx.(app.Structure_Idx_Name),:);

    sel_comp = app.Comp_List.Value;
    sel_feat = app.Feat_List.Value;
    sel_spec = app.Spec_List.Value;

    if ~strcmp(sel_comp,'Weighted Visualization')
        row_idx = (strcmp(sub_feature_encodings.Compartment,sel_comp) & ...
            strcmp(sub_feature_encodings.Type, sel_feat) & ...
            strcmp(sub_feature_encodings.Specific,sel_spec));
    else
        row_idx = (strcmp(sub_feature_encodings.Type, sel_feat)&...
            strcmp(sub_feature_encodings.Specific,sel_spec));
    end
    
    app.map_idx = app.Overlap_Feature_idx.(app.Structure_Idx_Name)(find(row_idx));
    app.og_map_idx = app.Overlap_Feature_idx.(app.Structure_Idx_Name)(find(row_idx));
    
    app.UITable2.Data = [sub_feature_encodings.Feature_Names(row_idx),...
        sub_feature_encodings.Definition(row_idx)];
    app.UITable2.ColumnName = {'Feature Names','Definitions'};
    
    app.UITable.Data = [sub_feature_encodings.Feature_Names(row_idx),...
        sub_feature_encodings.Map_Method(row_idx)];
    app.UITable.ColumnName = {'Feature Names','Map Method'};
    
end


