% --- Function to extract image filepaths in HistoLens_File_Input
function Get_Image_Paths(app)

dir_contents = dir(app.Slide_Path);
dir_contents = dir_contents(~ismember({dir_contents.name},{'.','..'}));
dir_contents = dir_contents(contains({dir_contents.name},{'.svs','.ndpi'}));
app.Slide_Num = length(dir_contents);

% Checking to see if the provided path is a path containing
% slides or a path of a single slide
% This is for a single slide
if ismember({dir_contents.name},{'Images','CompartmentSegmentations'})
    app.og_img_paths = dir(fullfile(app.Slide_Path,filesep,'Images',filesep));
    app.og_img_paths = app.og_img_paths(~ismember({app.og_img_paths.name},{'.','..'}));
    
    app.base_img_paths = app.og_img_paths;
    
    app.og_mask_paths = dir(fullfile(app.Slide_Path,filesep,'CompartmentSegmentations',filesep));
    app.og_mask_paths = apps.og_mask_paths(~ismember({app.og_mask_paths.name},{'.','..'}));
    
    app.NumberofSlidesLabel.Text = 'Number of Slides: 1';
    app.Slide_Num = 1;
    app.NumberofStructuresLabel.Text = strcat('Number of Structures: ',string(length(app.og_img_paths)));
end

% If a structure isn't specified
if isempty(app.Structure)
    % For a single slide:
    % If in file format of Slide/Structure/Images+Compartments+etc.
    if ismember({dir_contents.name},{'Glomeruli','Tubules'})
        structure_list = {'Glomeruli','Tubules'};
        
        struct_idx = {structure_list{find(strcmp(structure_list,{dir_contents.name}))}};
        
        % When there is only one structure present in the
        % single slide
        if length(struct_idx)==1
            app.og_img_paths = dir(fullfile(app.Slide_Path,filesep,struct_idx{1},filesep,'Images',filesep));
            app.og_img_paths = app.og_img_paths(~ismember({app.og_img_paths.name},{'.','..'}));
                
            app.base_img_paths = app.og_img_paths;
            
            app.og_mask_paths = dir(fullfile(app.Slide_Path,filesep,struct_idx{1},filesep,'CompartmentSegmentations',filesep));
            app.og_mask_paths = app.og_mask_paths(~ismember({app.og_mask_paths.name},{'.','..'}));
            
            app.NumberofSlidesLabel.Text = 'Number of Slides: 1';
            app.Slide_Num = 1;
            app.StructureTypeDropDown.Value = struct_idx{1};
        else
            
            % In the case that the structure hasn't been
            % specified yet and there are more than one present
            app.wait_for_structure = true;
            app.multi_slide = false;
            
        end
    end
    
else
    % For single slides where the structure folder is present
    % in the directory
    if ismember({dir_contents.name},app.Structure)
        app.og_img_paths = dir(fullfile(app.Slide_Path,filesep,app.Structure,filesep,'Images',filesep));
        app.og_img_paths = app.og_img_paths(~ismember({app.og_img_paths.name},{'.','..'}));
            
        app.base_img_paths = app.og_img_paths;
        
        app.og_mask_paths = dir(fullfile(app.Slide_Path,filesep,app.Structure,filesep,'CompartmentSegmentations',filesep));
        app.og_mask_paths = app.og_mask_paths(~ismember({app.og_mask_paths.name},{'.','..'}));
        
        app.NumberofSlidesLabel.Text = 'Number of Slides: 1';
        app.Slide_Num = 1;
        app.NumberofStructuresLabel.Text = strcat('Number of Structures: ',string(length(app.og_img_paths)));
        
    end
    
end

% Contains multiple slides
if ~ismember({dir_contents.name},{'Images','CompartmentSegmentations','Glomeruli','Tubules'})
    app.og_img_paths = cell(1);
    app.og_mask_paths = cell(1);
    
    folders = [dir_contents.isdir];
    
    app.NumberofSlidesLabel.Text = strcat('Number of Slides: ',string(length(folders)));
    app.Slide_Num = length(folders);
    
    img_wait = waitbar(0,'Reading in Image and Compartment Segmentations');
    for f = 1:length(folders)
        waitbar(f/length(folders),img_wait,'Reading in Image and Compartment Segmentations');
        
        slide_contents = dir(fullfile(dir_contents(f).folder,filesep,dir_contents(f).name));
        slide_contents = slide_contents(~ismember({slide_contents.name},{'.','..'}));
        
        current_path = fullfile(dir_contents(f).folder,dir_contents(f).name);
        
        % When structure is in the sub-directory
        if isempty(app.Structure)
            if ismember({slide_contents.name},{'Glomeruli','Tubules'})
                structure_list = {'Glomeruli','Tubules'};
                struct_idx = {structure_list{find(strcmp(structure_list,{slide_contents.name}))}};
                
                % When only one structure is present
                if length(struct_idx)==1
                    current_path = fullfile(current_path,filesep,struct_idx{1});
                    
                    app.StructureTypeDropDown.Value = struct_idx{1};
                    app.Structure = struct_idx{1};
                    
                else
                    
                    % In the case that the structure hasn't
                    % been specified yet but there are more
                    % than one in the directory
                    app.wait_for_structure = true;
                    app.multi_slide = true;
                    break
                    
                end
            end
        else
            % Modifying current path to include structure
            current_path = fullfile(current_path,filesep,app.Structure);
        end
        
        current_image_dir = dir(fullfile(current_path,'Images',filesep));
        current_image_dir = current_image_dir(~ismember({current_image_dir.name},{'.','..'}));
        current_images = cell(1);
        for i = 1:length(current_image_dir)
            current_images{i,1} = strcat(current_image_dir(i).folder,filesep,current_image_dir(i).name);
        end
        current_masks = cellfun(@(x)strrep(x,'Images','CompartmentSegmentations'),current_images,'UniformOutput',false);
        
        app.og_img_paths = [app.og_img_paths;current_images];
        app.og_mask_paths = [app.og_mask_paths;current_masks];
        
        
    end
    
    app.og_img_paths = app.og_img_paths(~cellfun(@isempty,app.og_img_paths));
    app.og_mask_paths = app.og_mask_paths(~cellfun(@isempty,app.og_mask_paths));
    
    app.base_img_paths = app.og_img_paths;
    
    waitbar(1,img_wait,'Finished!')
    pause(0.2)
    close(img_wait)
    
end
end


















