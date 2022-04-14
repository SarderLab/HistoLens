function feat_vis = ObjectDistVis(comp_mask, dist_bound, w_in_range)

% This function will take care of all the max-mean/min/max,
% mean-mean/min/max, etc. features

comp_areas = regionprops(comp_mask,'SubarrayIdx');
obs_areas = bwlabel(comp_mask);

% Iterating through each object in the compartment mask, generating initial
% statistics for mean, min, and max
stats = [];
for lab = 1:numel(comp_areas)
    
    loc = comp_areas(lab).SubarrayIdx;
    smallmask = obs_areas(loc{:});
    
    % All distance transform values within that object
    dtvals = dist_bound(loc{:}).*double(smallmask==lab);
    if sum(dtvals(:))==0
        ovals = [0,0,0];
    else
        % mean, min, and max values for that object
        ovals = [mean(dtvals(:)),min(dtvals(dtvals>0)),max(dtvals(:))];
    end
    
    stats = [stats;ovals];
end
    
% Now generating visual masks containing objects containing pixels within
% range of the target value.
% max, mean, min, variance, and median along the row dimension, for total
% image
% stats = mean, min, max
max_vals = max(stats,[],1);
mean_vals = mean(stats,1);
min_vals = min(stats,[],1);

med_vals = median(stats,1);

% Max features vis
if length(max_vals>0)
    max_mean = max_vals(1);
    obj_idx = find(stats(:,1)>=max_mean-(w_in_range*max_mean));
    max_mean_vis = ismember(obs_areas,obj_idx);

    max_min = max_vals(2);
    obj_idx = find(stats(:,2)>=max_min-(w_in_range*max_min));
    max_min_vis = ismember(obs_areas,obj_idx);

    max_max = max_vals(3);
    obj_idx = find(stats(:,3)>=max_max-(w_in_range*max_max));
    max_max_vis = ismember(obs_areas,obj_idx);
else
    max_mean_vis = zeros(size(obs_areas));
    max_min_vis = max_mean_vis;
    max_max_vis = max_mean_vis;
end

% Mean features vis
if length(mean_vals)>0
    mean_mean = mean_vals(1);
    obj_idx = find(stats(:,1)>=mean_mean-(w_in_range*mean_mean) & stats(:,1)<=mean_mean+(w_in_range*mean_mean));
    mean_mean_vis = ismember(obs_areas,obj_idx);

    mean_min = mean_vals(2);
    obj_idx = find(stats(:,2)>=mean_min-(w_in_range*mean_min) & stats(:,2)<=mean_min+(w_in_range*mean_min));
    mean_min_vis = ismember(obs_areas,obj_idx);

    mean_max = mean_vals(3);
    obj_idx = find(stats(:,3)>= mean_max-(w_in_range*mean_max) & stats(:,3)<=mean_max+(w_in_range*mean_max));
    mean_max_vis = ismember(obs_areas,obj_idx);
else
    mean_mean_vis = zeros(size(obs_areas));
    mean_min_vis = mean_mean_vis;
    mean_max_vis = mean_mean_vis;
end


% Min features vis
if length(min_vals)>0
    min_mean = min_vals(1);
    obj_idx = find(stats(:,1)<=min_mean+(w_in_range*min_mean));
    min_mean_vis = ismember(obs_areas,obj_idx);

    min_min = min_vals(2);
    obj_idx = find(stats(:,2)<= min_min+(w_in_range*min_min));
    min_min_vis = ismember(obs_areas,obj_idx);

    min_max = min_vals(3);
    obj_idx = find(stats(:,3)<= min_max+(w_in_range*min_max));
    min_max_vis = ismember(obs_areas,obj_idx);
else
    min_mean_vis = zeros(size(obs_areas));
    min_min_vis = min_mean_vis;
    min_max_vis = min_mean_vis;
end

% Var features_vis
score_row = reshape(dist_bound.*mean_mean_vis,[],1);
scores = (score_row(:,1)-nanmean(score_row(:,1)))/(nanstd(score_row(:,1)));
scores = 255*rescale(abs(scores));
var_mean_vis = reshape(scores,size(dist_bound));
var_mean_vis(isnan(dist_bound))=0;

score_row = reshape(dist_bound.*mean_min_vis,[],1);
scores = (score_row(:,1)-nanmean(score_row(:,1)))/(nanstd(score_row(:,1)));
scores = 255*rescale(abs(scores));
var_min_vis = reshape(scores,size(dist_bound));
var_min_vis(isnan(dist_bound))=0;

score_row = reshape(dist_bound.*mean_max_vis,[],1);
scores = (score_row(:,1)-nanmean(score_row(:,1)))/(nanstd(score_row(:,1)));
scores = 255*rescale(abs(scores));
var_max_vis = reshape(scores,size(dist_bound));
var_max_vis(isnan(dist_bound))=0;

% Median features vis
if length(med_vals)>0
    med_mean = med_vals(1);
    obj_idx = find(stats(:,1)>=med_mean-(w_in_range*med_mean) & stats(:,1)<=med_mean+(w_in_range*med_mean));
    med_mean_vis = ismember(obs_areas,obj_idx);

    med_min = med_vals(2);
    obj_idx = find(stats(:,2)>=med_min-(w_in_range*med_min) & stats(:,2)<=med_min+(w_in_range*med_min));
    med_min_vis = ismember(obs_areas,obj_idx);

    med_max = med_vals(3);
    obj_idx = find(stats(:,3)>= med_max-(w_in_range*med_max) & stats(:,3)<=med_max+(w_in_range*med_max));
    med_max_vis = ismember(obs_areas,obj_idx);
else
    med_mean_vis = zeros(size(obs_areas));
    med_min_vis = med_mean_vis;
    med_max_vis = med_mean_vis;
end
    
%% Assembling full feature visualization cell
feat_vis = {max_mean_vis, max_min_vis, max_max_vis, mean_mean_vis, mean_min_vis,...
    mean_max_vis, min_mean_vis, min_min_vis, min_max_vis, var_mean_vis, var_min_vis,...
    var_max_vis, med_mean_vis, med_min_vis, med_max_vis};

