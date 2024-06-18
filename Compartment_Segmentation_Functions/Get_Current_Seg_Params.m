% --- Function to get structure segmentation parameters and display in
% compartment segmentation window
function Get_Current_Seg_Params(app,current_slide)

slide_idx_name = strcat('Slide_Idx_',num2str(current_slide));

if ismember(slide_idx_name,fieldnames(app.Final_Seg_Params))
    display('Loading segmentation parameters from previous run-through')
    seg_params = app.Final_Seg_Params.(slide_idx_name).CompartmentSegmentation;
    
    app.Seg_Params = seg_params;
    
    if ismember('Colorspace',fieldnames(seg_params))
        app.SegmentationMethodButtonGroup.SelectedObject = app.ColorspaceThresholdingButton;
    
        colorspace_opts = {'RGB (Red, Green, Blue)','HSV (Hue, Saturation, Value)','LAB'};
        app.ChannelDropdown.Value = app.ColorSpaceDropDown.Items(find(ismember(colorspace_opts,seg_params.Colorspace)));
        

    elseif ismember('Stain',fieldnames(seg_params))

        app.SegmentationMethodButtonGroup.SelectedObject = app.ColorDeconvolutionButton;

        stain_types = {'H&E','H&E 2','H DAB','H AEC','FastRed FastBlue DAB',...
            'Methyl Green DAB','Azan-Mallory','Alcian blue & H',...
            'H PAS','RGB','CMY'};


    elseif ismember('Path',fieldnames(seg_params))

        app.SegmentationMethodButtonGroup.SelectedObject = app.CustomSegmentationButton;

        app.FoldernameLabel.Text = seg_params.Path;
    
    end

else
    display('Using current segmentation parameters from previous slide')
    if ismember('Path',fieldnames(app.Seg_Params))
        display('Just kidding using Colorspace')
        app.FoldernameLabel.Text = 'Folder name';
        
        app.SegmentationMethodButtonGroup.SelectedObject = app.ColorspaceThresholdingButton;

        % Just defaulting to colorspace thresholding if a path hasn't been
        % specified yet
        app.SegmentationMethodButtonGroup.SelectedObject = app.ColorspaceThresholdingButton;
        Get_Default_Params(app)
    end
end

