% --- Function to generate the Color Normalization values used for Macenko
% color normalization
function Generate_Norm_Params(app)

% This function will pull out slide-normalization values according to
% sub-class labels and average those together to create a more specific
% normalization.  Maybe this will be interesting.

current_structure = app.Structure;
normalization_values = app.SlideNormalization;
    
% Conditional statement if there are any selected sub-classes
if ~isempty(app.ColorNormParams)

    % Get slide-labels from normalization_values
    slide_idxes = fieldnames(normalization_values);
    slide_names = cell(length(slide_idxes),1);
    for i = 1:length(slide_idxes)
        slide_idx = slide_idxes{i};
    
        slide_names{i,1} = normalization_values.(slide_idx).SlideName;
    end
    % Find overlap between the slide_names and IncludeSlides property of
    % ColorNormParams
    [~,intersecting_idx,~] = intersect(slide_names,app.ColorNormParams.IncludeSlides);

    means = zeros(3,2,length(intersecting_idx));
    maxs = zeros(3,2,length(intersecting_idx));
    for j = 1:length(intersecting_idx)
        intersect_slide = intersecting_idx(j);
        current_slide = normalization_values.(slide_idxes{intersect_slide});
        means(:,:,j) = current_slide.Means;
        maxs(:,:,j) = current_slide.Maxs;
    end

    app.ColorNormParams.Means = mean(means,3,'omitnan');
    app.ColorNormParams.Maxs = max(mean(maxs,3,'omitnan'),[],1)';

end



