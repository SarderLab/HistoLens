% --- Function to organize ranked features so they can be displayed in the
% listbox
function weighted_encodings = Organize_Feat_Ranks(app,event)

if ~strcmp(app.FeatureRankingsUsedDropDown.Value,'None')
    
    current_file = app.Feat_Rank.(strrep(app.FeatureRankingsUsedDropDown.Value,' ',''));

    total_rank = cell2table([current_file.Properties.VariableNames',...
        table2cell(current_file(1,:))'],'VariableNames',{'Feature_Names','Total'});
    
    % Compartment Column
    comp_cell = cell(height(total_rank),1);
    comp_cell(:) = {'Weighted Visualization'};
    aligned = app.feature_encodings(app.Overlap_Feature_idx,:);
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




