% --- Function to perform feature ranking, relative to specific label
function rank_table = Feature_Ranking(label_table,rank_method,save_path)

% label_table = table with features and label column
label_table.ImgLabel = [];
%rank_cutoff = floor(0.5*width(label_table));

feature_rank = zeros(1,length(label_table.Properties.VariableNames)-1);
% Output of each feature ranking method is "idx" that is organized
% according to DECREASING PREDICTOR IMPORTANCE.  That means that the MOST
% predictive feature is: feature_list(idx(1)) and the LEAST predictive
% feature is feature_list(idx(end)). :/

%% Minimum Redundancy Maximum Relevance (MRMR)
if strcmp(rank_method,'MRMR')
    mrmr_ranks = fscmrmr(label_table,'Class');
    
    [~,ordered_rank] = intersect(mrmr_ranks,(1:length(feature_rank)));
    feature_rank = feature_rank+ordered_rank';
end

%assignin('base','mrmr_ranks',feature_rank)

%% Univariate feature ranking with Chi-Square Tests
if strcmp(rank_method,'Chi-Square')
    chi_ranks = fscchi2(label_table,'Class');

    [~,ordered_rank] = intersect(chi_ranks,(1:length(feature_rank)));
    feature_rank = feature_rank + ordered_rank';
end
%assignin('base','chi_ranks',chi_ranks)

%% Ranking importance of predictors using ReliefF algorithm
if strcmp(rank_method,'ReliefF')
    relief_ranks = relieff(table2array(label_table(:,1:end-1)),label_table.Class,10);
    
    [~,ordered_rank] = intersect(relief_ranks,(1:length(feature_rank)));
    feature_rank = feature_rank + ordered_rank';
end
%assignin('base','relief_ranks',relief_ranks)

%% Formatting feature rankings
feature_names = label_table.Properties.VariableNames';
feature_names = feature_names(1:end-1)';
rank_table = rows2vars(table(1./feature_rank'));
rank_table = rank_table(:,2:end);
rank_table.Properties.RowNames = {'Total'};
rank_table.Properties.VariableNames = feature_names;

rank_table{'Total',isinf(rank_table{:,:})} = 0;

% Converting to .csv to write to file

writetable(rank_table,save_path)