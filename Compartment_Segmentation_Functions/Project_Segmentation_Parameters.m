% --- Function to copy over segmentation parameters for non-checked slides
% and structures
function Project_Segmentation_Parameters(app)

% Copying over segmentation parameters (using current seg_params) to all remaining slides unless
% segmentation parameters are specified for a different structure for that slide
for s = 1:length(app.Slide_Names)
    slide_idx_name = strcat('Slide_Idx_',num2str(s));
    if ~ismember(slide_idx_name,fieldnames(app.Final_Seg_Params))
        app.Final_Seg_Params.(slide_idx_name).CompartmentSegmentation = app.Seg_Params;
        app.Final_Seg_Params.(slide_idx_name).SlideName = app.Slide_Names{s};
    end
end


