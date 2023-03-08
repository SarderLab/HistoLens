% --- Function to adjust enable status of edit fields depending on
% segmentation hierarchy
function Enable_Fields(app,event)

structure = app.SelectStructureDropDown.Value;
structure_idx_name = find(strcmp(structure,app.Structure_Names(:,1)));
structure_idx_name = strcat('Structure_',num2str(structure_idx_name));

if ismember('Colorspace',fieldnames(app.Seg_Params.(structure_idx_name)))
    
    % all items in each tab
    tab_1 = [app.ColorChannelDropDown,app.MinimumSizeEditField,...
        app.ThresholdValueEditField,app.SegmentationHierarchyLevelEditField];
    tab_2 = [app.ColorChannelDropDown_2,app.MinimumSizeEditField_2,...
        app.ThresholdValueEditField_2,app.SegmentationHierarchyLevelEditField_2];
    tab_3 = [app.ColorChannelDropDown_3,app.MinimumSizeEditField_3,...
        app.ThresholdValueEditField_3,app.SegmentationHierarchyLevelEditField_3];
    all_tabs = [tab_1,tab_2,tab_3];
    
    orders = [app.Seg_Params.(structure_idx_name).PAS.Order,...
        app.Seg_Params.(structure_idx_name).Luminal.Order,...
        app.Seg_Params.(structure_idx_name).Nuclei.Order];
    
    bottom_tab = all_tabs(find(orders==3));
    bottom_tab(1).Enable = 'off';
    bottom_tab(2).Enable = 'off';
    bottom_tab(3).Enable = 'off';
    bottom_tab(4).Value = 3;
    bottom_tab(4).Enable = 'off';
    
    other_tabs = all_tabs(find(orders~=3));
    other_orders = orders(orders~=3);
    for tab = 1:length(other_tabs) 
        current_tab = other_tabs(tab);
        current_tab(4).Value = other_orders(tab);
    end
end

if ismember('Stain',fieldnames(app.Seg_Params.(structure_idx_name)))
    
    tab_1 = ['StainChannelDropDown','ThresholdValueEditField_4',...
        'MinimumSizeEditField_4','SegmentationHierarchyLevelEditField_4'];
    tab_2 = ['StainChannelDropDown_2','ThresholdValueEditField_5',...
        'MinimumSizeEditField_5','SegmentationHierarchyLevelEditField_5'];
    tab_3 = ['StainChannelDropDown_3','ThresholdValueEditField_6',...
        'MinimumSizeEditField_6','SegmentationHierarchyLevelEditField_6'];
        
    all_tabs = [tab_1;tab_2;tab_3];
    
    orders = [app.Seg_Params.(structure_idx_name).PAS.Order,...
        app.Seg_Params.(structure_idx_name).Luminal.Order,...
        app.Seg_Params.(structure_idx_name).Nuclei.Order];

    
    bottom_tab = all_tabs(find(orders==3),:);
    app.bottom_tab(1).Enable = 'off';
    app.bottom_tab(2).Enable = 'off';
    app.bottom_tab(3).Enable = 'off';
    app.bottom_tab(4).Value = 3;
    app.bottom_tab(4).Enable = 'off';
    
    other_tabs = all_tabs(find(orders~=3),:);
    other_orders = orders(orders~=3);
    for tab = 1:length(other_tabs) 
        current_tab = other_tabs(tab);
        app.current_tab(4).Value = other_orders(tab);
    end

end

