% --- Function to update plot options with user-inputs
function Update_Plot_Options(app)
event = [];

if length(app.map_idx)==1

    % Have to re-run violinplot with updated group order 
    Plot_Feat(app,event)
else
    
    % Can apply changes to current plots without having to re-run plotting

    % Getting current distribution
    dist_properties = findall(app.Dist_Ax,'type','Line');

    % Applying new plot_options to each group scatter object
    for g = 1:length(dist_properties)
    
        group_scatter = dist_properties(g);
        group_name = group_scatter.DisplayName;
        if ~isempty(group_name)
            match_name = find(strcmp(app.Plot_Options.Labels,group_name));
        else
            % Groups are added to gscatter in ascending order 
            match_name = length(dist_properties)-g+1;
        end
        if ~isempty(match_name)
            group_scatter.Color = app.Plot_Options.(strcat('Label_',string(match_name))).Color;
            group_scatter.Marker = app.Plot_Options.(strcat('Label_',string(match_name))).Marker;
            group_scatter.MarkerSize = app.Plot_Options.(strcat('Label_',string(match_name))).MarkerSize;
        end
    end
end

