% --- Function to organize ranked features so they can be displayed in the
% listbox
function weighted_encodings = Organize_Feat_Ranks(app,event)

selected_structure = app.Structure;

if ~strcmp(app.FeatureRankingsUsedDropDown.Value,'None')
    
    feat_rank_idx = find(strcmp(app.FeatureRankingsUsedDropDown.Value,app.Feat_Rank.(selected_structure).AllRanks));
    current_file = app.Feat_Rank.(selected_structure).Table(:,feat_rank_idx);
    
    total_rank = cell2table([app.base_Feature_set.(selected_structure).Properties.VariableNames(1:end-1)',...
        table2cell(current_file(:,1))],'VariableNames',{'Feature_Names','Total'});
    
    % Compartment Column
    comp_cell = cell(height(total_rank),1);
    comp_cell(:) = {'Weighted Visualization'};
    aligned = app.feature_encodings(app.Overlap_Feature_idx.(selected_structure),:);
    aligned.Total = total_rank.Total;
    aligned = sortrows(aligned,'Total','descend');

    weighted_encodings = [aligned.Feature_Names, comp_cell, aligned.Type,...
        aligned.Specific];
    weighted_encodings = cell2table(weighted_encodings,'VariableNames',{'Feature_Names','Compartment','Type','Specific'});

else
    weighted_encodings = [];
    app.Rank_Slide.Enable = 'off';
    app.Rank_Slide.MajorTicks = [];
end


