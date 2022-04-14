% --- Function to add labels information to experiment file
function Labels_to_Experiment_File(app)

if ~isempty(app.Experiment_File)
    filename = app.Experiment_File;

    exp_struct = xml2struct(filename);

    experiment_name = fieldnames(exp_struct);
    experiment_name = experiment_name{1};

    structure_names = fieldnames(exp_struct.(experiment_name).Structure);
    
    % Something for multi-structure
    for j = 1:length(structure_names)

        structure_name = structure_names{j};
        exp_struct.(experiment_name).Structure.(structure_name).LabelFile = ...
            app.label_file;
        exp_struct.(experiment_name).Structure.(structure_name).LabelType = ...
            app.file_type;
        exp_struct.(experiment_name).Structure.(structure_name).FileLabelCol = ...
            app.file_label_col;
        exp_struct.(experiment_name).Structure.(structure_name).ClassLabelCol = ...
            app.class_label_col;

    end
    struct2xml(exp_struct,filename)
end







