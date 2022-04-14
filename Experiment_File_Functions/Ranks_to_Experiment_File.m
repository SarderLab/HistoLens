% Function to add feature ranks information to existing experiment file
function Ranks_to_Experiment_File(app,main_app)

if ~isempty(main_app.Experiment_File)
    filename = main_app.Experiment_File;
    
    exp_struct = xml2struct(filename);
    
    experiment_name = fieldnames(exp_struct);
    experiment_name = experiment_name{1};

    structure_names = fieldnames(exp_struct.(experiment_name).Structure);
    
    % Something here for multi-structure %
    for j = 1:length(structure_names)
    
        % Need to add a structure-label component to feature ranking for
        % multiple structure usage

        structure_name = structure_names{j};

        % Feature ranks files to include
        rank_cats = fieldnames(app.Feat_Rank);
        for i = 1:length(rank_cats)
            save_file = strcat(app.Feat_Rank_File,filesep,rank_cats{i},'.csv');
        
            % Currently only for glomeruli
            exp_struct.(experiment_name).Structure.(structure_name).FeatureRanks.(rank_cats{i}) = save_file;
        end
    
        struct2xml(exp_struct,filename)
    end
    
end









