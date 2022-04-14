% --- Function to change the minimum rank of features included in
% visualization if feature rankings are provided.
function update_rank(app,event)

% Get value from Rank_Slide
rank_val = 1-app.Rank_Slide.Value;

% Get relative value compared to number of features in current
% handles.sep_feat_map
n_feat = length(app.sep_feat_map);

min_rank = floor(rank_val*n_feat);
if min_rank == 0
    min_rank = 1;
end

final_map = zeros(size(app.sep_feat_map{1}));
new_map_idx = zeros(1);
count = 1;

if iscell(app.map)
    final_map = cell(1,2);
    final_map{1,1} = zeros(size(app.map{1}));
    final_map{1,2} = zeros(size(app.map{2}));
end

for i=1:length(app.Relative_Rank)
    if app.Relative_Rank(i)<=min_rank
        
        map_feat = app.feature_encodings.Feature_Names{app.og_map_idx(i)};
        map_feat_rank = find(strcmp(map_feat, app.weighted_encodings.Feature_Names));

        if iscell(app.map)
            for j = 1:size(app.map,2)
                if ~isnan(max(app.sep_feat_map{i,j}))
                    final_map{1,j} = final_map{1,j}+(1/map_feat_rank).*app.sep_feat_map{i,j};
                end
            end            
        else
            if ~isnan(max(app.sep_feat_map{i}))
                final_map = final_map+(1/map_feat_rank).*app.sep_feat_map{i};
            end
        end
        
        new_map_idx(count) = app.og_map_idx(i);
        count = count+1;
    end
end

if iscell(app.map)
    final_map{1,1} = rescale(final_map{1,1});
    final_map{1,2} = rescale(final_map{1,2});
else
    final_map = rescale(final_map);
end

app.map = final_map;
% Updating handles for histogram visualization to contain correct map
% indices
app.map_idx = new_map_idx;
app.min_feat_rank = min_rank;

View_Image(app,event)
