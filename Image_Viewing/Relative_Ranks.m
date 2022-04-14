% --- Function to get relative rankings for features in a given
% visualization
function Relative_Ranks(app,event)

ranks = zeros(1);
for f = 1:length(app.map_idx)
    
    map_feat = app.feature_encodings.Feature_Names{app.map_idx(f)};
    map_feat_rank = find(strcmp(map_feat, app.weighted_encodings.Feature_Names));
    
    if isempty(map_feat_rank)
        map_feat = map_feat(1:namelengthmax);
        map_feat_rank = find(strcmp(map_feat, app.weighted_encodings.Feature_Names));
    end
    
    ranks(f) = map_feat_rank;
end


% Setting Major Ticks of Rank_Slide to ranks
if length(ranks)<=10
    app.Rank_Slide.MajorTicks = linspace(0,1,length(ranks));
    app.Rank_Slide.MajorTickLabels = strsplit(num2str(flip(sort(ranks))));
    
else
    %if ~round(length(ranks)/10)>10
    app.Rank_Slide.MajorTicks = linspace(0,10,length(ranks));
    ordered_list = strsplit(num2str(flip(sort(ranks))));
    app.Rank_Slide.MajorTickLabels = ordered_list(1:10:end);
%     else
%         app.Rank_Slide.MajorTicks = linspace(0,50,length(ranks));
%         ordered_list = strsplit(num2str(flip(sort(ranks))));
%         app.Rank_Slide.MajorTickLabels = ordered_list(1:50:end);
%     end
end
% Outputting only the rank index for each feature (1--> # features)
[sorted, ~] = sort(ranks,'ascend');

% Rank idx here is just an index of where each member of "ranks" should be
% ordered, it isn't really a relative ranking
[~,rank_idx] = ismember(ranks,sorted);

app.Relative_Rank = rank_idx;


