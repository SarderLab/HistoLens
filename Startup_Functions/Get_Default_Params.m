%--- Function to generate default segmentation parameters for initializing
%compartment segmentation
function Get_Default_Params(app)

selectedButton = app.SegmentationMethodButtonGroup.SelectedObject;
string_vals = {app.SegmentationMethodButtonGroup.Buttons.Text};
butt_idx = find(strcmp(selectedButton.Text,string_vals));

structure = app.SelectStructureDropDown.Value;
if butt_idx==1
    
    app.Seg_Params.(structure).Colorspace = app.ColorSpaceDropDown.Value;
    channel = app.ColorChannelDropDown.Value;
    channel = strsplit(channel,' ');
    channel = channel{end};
    channel = str2num(channel);
    app.Seg_Params.(structure).Luminal.Channel = channel;
    app.Seg_Params.(structure).Luminal.Threshold = app.ThresholdValueEditField.Value;
    app.Seg_Params.(structure).Luminal.MinSize = app.MinimumSizeEditField.Value;
    app.Seg_Params.(structure).Luminal.Order = app.SegmentationHierarchyLevelEditField.Value;
    
    channel = app.ColorChannelDropDown_2.Value;
    channel = strsplit(channel,' ');
    channel = channel{end};
    channel = str2num(channel);
    app.Seg_Params.(structure).PAS.Channel = channel;
    app.Seg_Params.(structure).PAS.Threshold = app.ThresholdValueEditField_2.Value;
    app.Seg_Params.(structure).PAS.MinSize = app.MinimumSizeEditField_2.Value;
    app.Seg_Params.(structure).PAS.Order = app.SegmentationHierarchyLevelEditField_2.Value;
    
    channel = app.ColorChannelDropDown_3.Value;
    channel = strsplit(channel,' ');
    channel = channel{end};
    channel = str2num(channel);
    
    app.Seg_Params.(structure).Nuclei.Channel = channel;
    app.Seg_Params.(structure).Nuclei.Threshold = app.ThresholdValueEditField_3.Value;
    app.Seg_Params.(structure).Nuclei.MinSize = app.MinimumSizeEditField_3.Value;
    app.Seg_Params.(structure).Nuclei.Order = app.SegmentationHierarchyLevelEditField_3.Value;
    
end

if butt_idx == 2
    
    stain_code = app.StainTypeDropDown.Value;
    stain_code = strsplit(stain_code,'(');
    stain_code = stain_code{end};
    stain_code = strrep(stain_code,')','');
    
    app.Seg_Params.(structure).Stain = stain_code;
    
    channel_code = app.StainChannelDropDown.Value;
    channel_code = strsplit(channel_code,' ');
    channel_code = channel_code{end};
    channel_code = str2num(channel_code);
    
    app.Seg_Params.(structure).Luminal.Channel = channel_code;
    app.Seg_Params.(structure).Luminal.Threshold = app.ThresholdValueEditField_4.Value;
    app.Seg_Params.(structure).Luminal.MinSize = app.MinimumSizeEditField_4.Value;
    app.Seg_Params.(structure).Luminal.Order = app.SegmentationHierarchyLevelEditField_4.Value;
    
    channel_code = app.StainChannelDropDown_2.Value;
    channel_code = strsplit(channel_code,' ');
    channel_code = channel_code{end};
    channel_code = str2num(channel_code);
    
    app.Seg_Params.(structure).PAS.Channel = channel_code;
    app.Seg_Params.(structure).PAS.Threshold = app.ThresholdValueEditField_5.Value;
    app.Seg_Params.(structure).PAS.MinSize = app.MinimumSizeEditField_5.Value;
    app.Seg_Params.(structure).PAS.Order = app.SegmentationHierarchyLevelEditField_5.Value;
    
    channel_code = app.StainChannelDropDown_3.Value;
    channel_code = strsplit(channel_code,' ');
    channel_code = channel_code{end};
    channel_code = str2num(channel_code);
    
    app.Seg_Params.(structure).Nuclei.Channel = channel_code;
    app.Seg_Params.(structure).Nuclei.Threshold = app.ThresholdValueEditField_6.Value;
    app.Seg_Params.(structure).Nuclei.MinSize = app.MinimumSizeEditField_6.Value;
    app.Seg_Params.(structure).Nuclei.Order = app.SegmentationHierarchyLevelEditField_6.Value;
    
end


