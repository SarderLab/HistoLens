% --- Function to update experiment file when new labels are added
function Update_Experiment_Labels(app)

% Update across structures
structures = fieldnames(app.Aligned_Labels);
for st = 1:length(structures)
    current_structure = structures{st};

    % Getting all labels in aligned_labels
    labels = fieldnames(app.Aligned_Labels.(current_structure));
    for l = 1:length(labels)
        current_label = labels{l};
        if ~strcmp(current_label,'AllLabels')
            app.Experiment_Struct.Structure.(current_structure).Aligned_Labels.(current_label).Aligned = Special_Table2Struct(app.Aligned_Labels.(current_structure).(current_label).Aligned);
            app.Experiment_Struct.Structure.(current_structure).Aligned_Labels.(current_label).Sub_Class = app.Aligned_Labels.(current_structure).(current_label).Sub_Class;
            app.Experiment_Struct.Structure.(current_structure).Aligned_Labels.(current_label).Name = app.Aligned_Labels.(current_structure).(current_label).Name;
        end
    end
    app.Experiment_Struct.Structure.(current_structure).Aligned_Labels.AllLabels = app.Aligned_Labels.(current_structure).AllLabels;
    
    % Writing feature ranks
    app.Experiment_Struct.Structure.(current_structure).Feat_Rank.Table = Special_Table2Struct(app.Feat_Rank.(current_structure).Table);
    app.Experiment_Struct.Structure.(current_structure).Feat_Rank.Method = app.Feat_Rank.(current_structure).Method;
    app.Experiment_Struct.Structure.(current_structure).Feat_Rank.Scores = app.Feat_Rank.(current_structure).Scores;
    app.Experiment_Struct.Structure.(current_structure).Feat_Rank.AllRanks = app.Feat_Rank.(current_structure).AllRanks;
end

writestruct(app.Experiment_Struct,app.Experiment_File,'StructNodeName','HistoLensExperimentParameters')


