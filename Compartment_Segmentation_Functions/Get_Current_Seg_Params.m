% --- Function to get structure segmentation parameters and display in
% compartment segmentation window
function Get_Current_Seg_Params(app,current_slide)

slide_idx_name = strcat('Slide_Idx_',num2str(current_slide));

if ismember(slide_idx_name,fieldnames(app.Final_Seg_Params))
    display('Loading segmentation parameters from previous run-through')
    seg_params = app.Final_Seg_Params.(slide_idx_name).CompartmentSegmentation;
    
    app.Seg_Params = seg_params;
    
    if ismember('Colorspace',fieldnames(seg_params))
        app.ColorspaceParametersPanel.Visible = 'on';
        app.ColorspaceParametersPanel.Enable = 'on';
        app.ColorDeconvolutionParametersPanel.Visible = 'off';
        app.ColorDeconvolutionParametersPanel.Enable = 'off';
        app.CustomSegmentationMasksPanel.Visible = 'off';
        app.CustomSegmentationMasksPanel.Enable = 'off';

        app.SegmentationMethodButtonGroup.SelectedObject = app.ColorspaceThresholdingButton;
    
        colorspace_opts = {'RGB (Red, Green, Blue)','HSV (Hue, Saturation, Value)','LAB'};
        colorspace_abbrevs = {'RGB','HSV','LAB'};
        app.ColorSpaceDropDown.Value = app.ColorSpaceDropDown.Items(find(ismember(colorspace_opts,seg_params.Colorspace)));
        
        % Luminal space tab
        app.SegmentationHierarchyLevelEditField.Value = seg_params.Luminal.Order;
        app.ColorChannelDropDown.Value = app.ColorChannelDropDown.Items(seg_params.Luminal.Channel);
        app.MinimumSizeEditField.Value = seg_params.Luminal.MinSize;
        app.ThresholdValueEditField.Value = seg_params.Luminal.Threshold;
    
        % PAS tab
        app.SegmentationHierarchyLevelEditField_2.Value = seg_params.PAS.Order;
        app.ColorChannelDropDown_2.Value = app.ColorChannelDropDown_2.Items(seg_params.PAS.Channel);
        app.MinimumSizeEditField_2.Value = seg_params.PAS.MinSize;
        app.ThresholdValueEditField_2.Value = seg_params.PAS.Threshold;
    
        % Nuclei tab
        app.SegmentationHierarchyLevelEditField_3.Value = seg_params.Nuclei.Order;
        app.ColorChannelDropDown_3.Value = app.ColorChannelDropDown_3.Items(seg_params.Nuclei.Channel);
        app.MinimumSizeEditField_3.Value = seg_params.Nuclei.MinSize;
        app.SplittingSlider.Value = seg_params.Nuclei.Splitting;
        app.ThresholdValueEditField_3.Value = seg_params.Nuclei.Threshold;
    
    elseif ismember('Stain',fieldnames(seg_params))
        app.ColorspaceParametersPanel.Visible = 'off';
        app.ColorspaceParametersPanel.Enable = 'off';
        app.ColorDeconvolutionParametersPanel.Visible = 'on';
        app.ColorDeconvolutionParametersPanel.Enable = 'on';
        app.CustomSegmentationMasksPanel.Visible = 'off';
        app.CustomSegmentationMasksPanel.Enable = 'off';

        app.SegmentationMethodButtonGroup.SelectedObject = app.ColorDeconvolutionButton;

        stain_types = {'H&E','H&E 2','H DAB','H AEC','FastRed FastBlue DAB',...
            'Methyl Green DAB','Azan-Mallory','Alcian blue & H',...
            'H PAS','RGB','CMY'};

        app.StainTypeDropDown.Value = app.StainTypeDropDown.Items(find(ismember(seg_params.stain,stain_types)));
    
        % Luminal space tab
        app.SegmentationHierarchyLevelEditField_4.Value = seg_params.Luminal.Order;
        app.MinimumSizeEditField_4.Value = seg_params.Luminal.MinSize;
        app.ThresholdValueEditField_4.Value = seg_params.Luminal.Threshold;
        app.StainChannelDropDown.Value = app.StainChannelDropDown.Items(seg_params.Luminal.Channel);
    
        % PAS tab
        app.SegmentationHierarchyLevelEditField_5.Value = seg_params.PAS.Order;
        app.MinimumSizeEditField_5.Value = seg_params.PAS.MinSize;
        app.ThresholdValueEditField_5.Value = seg_params.PAS.Threshold;
        app.StainChannelDropDown_2.Value = app.StainChannelDropDown_2.Items(seg_params.PAS.Channel);
    
        % Nuclei tab
        app.SegmentationHierarchyLevelEditField_6.Value = seg_params.Nuclei.Order;
        app.MinimumSizeEditField_6.Value = seg_params.Nuclei.MinSize;
        app.ThresholdValueEditField_6.Value = seg_params.Nuclei.Threshold;
        app.SplittingSlider_2.Value = seg_params.Nuclei.Splitting;
        app.StainChannelDropDown_3.Value = app.StainChannelDropDown_3.Items(seg_params.Nuclei.Channel);
    
    elseif ismember('Path',fieldnames(seg_params))
        app.CustomSegmentationMasksPanel.Visible = 'on';
        app.CustomSegmentationMasksPanel.Enable = 'on';
        app.ColorspaceParametersPanel.Visible = 'off';
        app.ColorspaceParametersPanel.Enable = 'off';
        app.ColorDeconvolutionParametersPanel.Visible = 'off';
        app.ColorDeconvolutionParametersPanel.Enable = 'off';

        app.SegmentationMethodButtonGroup.SelectedObject = app.CustomSegmentationButton;

        app.FoldernameLabel.Text = seg_params.Path;
    
    end

else
    display('Using current segmentation parameters from previous slide')
    if ismember('Path',fieldnames(app.Seg_Params))
        display('Just kidding using Colorspace')
        app.FoldernameLabel.Text = 'Folder name';
        
        app.SegmentationMethodButtonGroup.SelectedObject = app.ColorspaceThresholdingButton;
        app.ColorspaceParametersPanel.Visible = 'on';
        app.ColorspaceParametersPanel.Enable = 'on';
        app.CustomSegmentationMasksPanel.Visible = 'off';
        app.CustomSegmentationMasksPanel.Enable = 'off';
        app.ColorDeconvolutionParametersPanel.Visible = 'off';
        app.ColorDeconvolutionParametersPanel.Enable = 'off';

        % Just defaulting to colorspace thresholding if a path hasn't been
        % specified yet
        app.SegmentationMethodButtonGroup.SelectedObject = app.ColorspaceThresholdingButton;
        Get_Default_Params(app)
    end
end

