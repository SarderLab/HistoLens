% --- Extract mean and max OD values from the current image according to
% the compartment segmentation (that uses global normalization parameters).
% Update the slide-level normalization parameters and save for each slide
function Get_OD_vals(img,comp_img,slide_idx,app)

% OD transformation
od_img = reshape(double(img),[],3);
od_img = -log((od_img+1)/240);

% reshaping comp_img
comp_img_res = reshape(comp_img,[],3);

% compartment specific od value extraction
nuc_vals = od_img(comp_img_res(:,3)>0,:);
mean_nuc_od = mean(nuc_vals,1,'omitnan');
max_nuc_od = max(nuc_vals,[],1,'omitnan');

pas_vals = od_img(comp_img_res(:,1)>0,:);
mean_pas_od = mean(pas_vals,1,'omitnan');
max_pas_od = max(pas_vals,[],1,'omitnan');

% Below aggregation is not structure-specific.  This should be fine as the
% same stains are present in different structures? As long as the
% segmentation parameters are different. 

% Concatenating to slide normalization parameters
if ismember('Means',fieldnames(app.Slide_NormVals.(strcat('Slide_Idx_',num2str(slide_idx)))))
    %display('concatenated')
    if size([mean_nuc_od',mean_pas_od'],2)==2
        app.Slide_NormVals.(strcat('Slide_Idx_',num2str(slide_idx))).Means = cat(3,app.Slide_NormVals.(strcat('Slide_Idx_',num2str(slide_idx))).Means,[mean_nuc_od',mean_pas_od']);
    end
    if size([max_nuc_od',max_pas_od'],2)==2
        app.Slide_NormVals.(strcat('Slide_Idx_',num2str(slide_idx))).Maxs = cat(3,app.Slide_NormVals.(strcat('Slide_Idx_',num2str(slide_idx))).Maxs,[max_nuc_od',max_pas_od']);
    end
else
    %display('initialized')
    app.Slide_NormVals.(strcat('Slide_Idx_',num2str(slide_idx))).Means = [mean_nuc_od',mean_pas_od'];
    app.Slide_NormVals.(strcat('Slide_Idx_',num2str(slide_idx))).Maxs = [max_nuc_od',max_pas_od'];
end

