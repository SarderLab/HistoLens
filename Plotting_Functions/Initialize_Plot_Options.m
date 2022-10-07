% --- Function to initialize plot options with defaults
function Initialize_Plot_Options(app,plot_type)

app.Plot_Options = [];

if strcmp(plot_type,'violin')
    % Getting labels 
    labels = unique(app.Dist_Data.Class);

    app.Plot_Options.LabelOrder = labels;

elseif strcmp(plot_type,'scatter')

    labels = unique(app.Dist_Data.Class);

    if isnumeric(labels)
        labels = flip(cellstr(string(labels)),2);
    end
    app.Plot_Options.Labels = labels;

    % gscatter properties are nested in the Children property of the Axis
    group_properties = app.Dist_Ax.Children;
    n_groups = length(group_properties);
    for g = 1:n_groups
        if isnumeric(unique(app.Dist_Data.Class))
            label_name = strcat('Label_',string(n_groups-g+1));
        else
            label_name = strcat('Label_',string(g));
        end
        if ismember(group_properties(g).DisplayName,app.Plot_Options.Labels)
            app.Plot_Options.(label_name).Name = labels{g};
            app.Plot_Options.(label_name).Color = group_properties(g).Color;
            app.Plot_Options.(label_name).Marker = group_properties(g).Marker;
            app.Plot_Options.(label_name).MarkerSize = group_properties(g).MarkerSize;
        end
    end

end















