% --- Function where you can add visualizations for custom features
% See documentation for definitions of different types of feature
% visualizations for consistency
function [all_feature_vis, feat_count] = Vis_Custom_Features(I,mask,composite,features_needed,all_feature_vis,vis_params,feat_count)
    % Example features quantification silver stain content
    if any(ismember(features_needed,(449:460)))
        
        % stain stored as first channel in sub-compartment segmentation
        silver_mask = composite(:,:,1);
    
        % silver deposits greater than certain areas (pixel-wise)
        area_breaks = (10:10:100);
        silver_dist = bwdist(~silver_mask);
        silver_area_threshold_masks = cell(1,length(area_breaks));
        for a=1:length(area_breaks)
            
            intermediate_mask = silver_dist > area_breaks(a);
            silver_area_threshold_masks{a} = intermediate_mask;
        
        end
        
        feat_vis = {silver_mask, silver_mask};
        feat_vis = [feat_vis,silver_area_threshold_masks];
    
        overlap_num = length(find(ismember(features_needed,(449:460))));
        feat_count = feat_count+overlap_num;
    
        all_feature_vis = insert_vis(features_needed,(449:460),feat_vis,all_feature_vis);
    
    end
end


function all_feature_vis = insert_vis(feat_idxes, select_range, feat_subgroup, all_feature_vis)
    [~,int_idx,~] = intersect(feat_idxes,select_range);
    
    % finding index in feat_subgroup that is in feat_idxes
    overlap = find(ismember(select_range,feat_idxes));
    
    if length(feat_subgroup)>1 && strcmp(class(feat_subgroup),'cell')
        for i = 1:length(int_idx)
            inter = int_idx(i);
            over = overlap(i);
            all_feature_vis{inter} = double(feat_subgroup{over});
        end
        
    else
        for i = 1:length(int_idx) 
            inter = int_idx(i);
            all_feature_vis{inter} = double(feat_subgroup);
        end
    end
end




