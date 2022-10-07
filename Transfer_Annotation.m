% --- Function for transferring one structure to another annotation layer
function Transfer_Annotation(app)

% Get whether this is in Red Comp Image or Blue Comp Image
available_tabs = {'Red Comp Image','Blue Comp Image'};
current_tab = app.TabGroup3.SelectedTab.Title;

% Index of transfer image
use_image = find(ismember(current_tab,available_tabs));

% Getting name and index of transfer image
if app.Comparing
    current_image = [{app.Red_Comp_Image.Value},{app.Blue_Comp_Image.Value}];
    current_image = current_image{use_image};
else
    current_image = app.Image_Name_Label.Value;
end

current_image = strsplit(current_image,',');
current_image = current_image{1};

name_parts = strsplit(current_image,'_');
img_idx = name_parts{end};
if length(name_parts)>2
    slide_name = strjoin(name_parts(1:end-1),'_');
else
    slide_name = name_parts{1};
end



% Reading in xml
read_xml = xmlread(strcat(app.Slide_Path,filesep,slide_name,'.xml'));

% Getting the name of the transfer structure
drop_downs = [{app.TransferAnnotationsDropDown.Value},{app.TransferAnnotationsDropDown_2.Value}];
new_structure = drop_downs{use_image};

wb = waitbar(0,strcat('Transferring ',current_image,' to ',new_structure));

% Getting original vertices
og_structure_idx = app.structure_idx.(app.Structure);

% Adding annotation to an existing layer
struct_og = xml2struct(strcat(app.Slide_Path,filesep,slide_name,'.xml'));

if iscell(struct_og.Annotations.Annotation)

    og_annotations = struct_og.Annotations.Annotation{og_structure_idx};

    % Deleting old region 
    struct_og.Annotations.Annotation{og_structure_idx}.Regions.Region{str2double(img_idx)} = [];
    struct_og.Annotations.Annotation{og_structure_idx}.Regions.Region = ...
        struct_og.Annotations.Annotation{og_structure_idx}.Regions.Region(~cellfun('isempty',struct_og.Annotations.Annotation{og_structure_idx}.Regions.Region));
else

    og_annotations = struct_og.Annotations.Annotation;

    % Deleting old region
    struct_og.Annotations.Annotation.Regions.Region{str2double(img_idx)} = [];
    struct_og.Annotations.Annotation.Regions.Region = ...
        struct_og.Annotations.Annotation.Regions.Region(~cellfun('isempty',struct_og.Annotations.Annotation.Regions.Region));

end

waitbar(0.25,wb,'Original Vertices Loaded')

region_og = og_annotations.Regions.Region{str2double(img_idx)};

if ~strcmp(new_structure,'New Layer')
    
    % Replacement idx 
    if iscell(struct_og.Annotations.Annotation)

        rep_annotations = struct_og.Annotations.Annotation{app.structure_idx.(new_structure)};

        n_regions = length(rep_annotations.Regions.Region);
        rep_idx = n_regions+1;

    else
        rep_annotations = struct_og.Annotations.Annotation;
        rep_annotations.Regions = [];
        rep_annotations.Attributes.Id = app.structure_idx.(new_structure);
        rep_annotations.Attributes.LineColor = num2str(str2double(rep_annotations.Attributes.LineColor)+300);

        rep_idx = 1;
        
    end

    % Replacing some information in the xml file
    rep_region = region_og;
    rep_region.Attributes.DisplayId = num2str(rep_idx);
    rep_region.Attributes.Id = num2str(rep_idx);

    % Saving modified xml file
    if iscell(struct_og.Annotations.Annotation)
        struct_og.Annotations.Annotation{app.structure_idx.(new_structure)}.Regions.Region =...
            [struct_og.Annotations.Annotation{app.structure_idx.(new_structure)}.Regions.Region,rep_region];
    else
        rep_annotations.Regions.Region = rep_region;
        struct_og.Annotations.Annotation = [{struct_og.Annotations.Annotation},{rep_annotations}];

    end

    waitbar(0.5,wb,'Saving modified XML file')

    struct2xml(struct_og,strcat(app.Slide_Path,filesep,slide_name,'.xml'))

    % Making new feature set file
    feat_idx = find(ismember(current_image,app.Full_Feature_set.(app.Structure).ImgLabel));
    transfer_features = app.Full_Feature_set.(app.Structure)(feat_idx,:);

    base_feat_idx = find(ismember(current_image,app.base_Feature_set.(app.Structure).ImgLabel));
    transfer_base_features = app.base_Feature_set.(app.Structure)(base_feat_idx,:);

    ign_idx = find(ismember(current_image,app.Ignore_idx.(app.Structure).ImgLabel));
    transfer_ignore = app.Ignore_idx.(app.Structure)(ign_idx,:);

    notes_idx = find(ismember(current_image,app.Notes.(app.Structure).ImgLabel));
    transfer_notes = app.Notes.(app.Structure)(notes_idx,:);
    
    if ismember(new_structure,fieldnames(app.Notes))
        app.Notes.(new_structure) = [app.Notes.(new_structure);transfer_notes];
    end

    display(strcat('Height pre transfer ',new_structure,num2str(height(app.Full_Feature_set.(new_structure)))))
    display(strcat('Height pre transfer ',app.Structure,num2str(height(app.Full_Feature_set.(app.Structure)))))
    
    app.Full_Feature_set.(new_structure) = [app.Full_Feature_set.(new_structure);transfer_features];
    app.base_Feature_set.(new_structure) = [app.base_Feature_set.(new_structure);transfer_base_features];
    app.Ignore_idx.(new_structure) = [app.Ignore_idx.(new_structure);transfer_ignore];


    app.Full_Feature_set.(app.Structure)(feat_idx,:) = [];
    app.base_Feature_set.(app.Structure)(base_feat_idx,:) = [];
    app.Ignore_idx.(app.Structure)(ign_idx,:) = [];
    app.Notes.(app.Structure)(notes_idx,:) = [];

    % Editing image labels for other images in that slide
    in_slide_images = app.Full_Feature_set.(app.Structure).ImgLabel(find(contains(app.Full_Feature_set.(app.Structure).ImgLabel,slide_name)));
    all_name_parts = cellfun(@(x) strsplit(x,'_'),in_slide_images,'UniformOutput',false);
    all_idxes = cellfun(@(x) x{end},all_name_parts,'UniformOutput',false);
    for i = 1:length(all_idxes)
        if ~str2double(all_idxes(i))<str2double(img_idx)
            name_parts = all_name_parts{i};
            name_parts{end} = num2str(str2double(all_idxes(i))-1);
            all_name_parts{i} = strjoin(name_parts,'_');
        else
            all_name_parts{i} = strjoin(all_name_parts{i},'_');
        end
    end

    app.Full_Feature_set.(app.Structure).ImgLabel(find(contains(app.Full_Feature_set.(app.Structure).ImgLabel,slide_name))) = all_name_parts;

    in_slide_images = app.base_Feature_set.(app.Structure).ImgLabel(find(contains(app.base_Feature_set.(app.Structure).ImgLabel,slide_name)));
    all_name_parts = cellfun(@(x) strsplit(x,'_'),in_slide_images,'UniformOutput',false);
    all_idxes = cellfun(@(x) x{end},all_name_parts,'UniformOutput',false);
    for i = 1:length(all_idxes)
        if ~str2double(all_idxes(i))<str2double(img_idx)
            name_parts = all_name_parts{i};
            name_parts{end} = num2str(str2double(all_idxes(i))-1);
            all_name_parts{i} = strjoin(name_parts,'_');
        else
            all_name_parts{i} = strjoin(all_name_parts{i},'_');
        end
    end
    app.base_Feature_set.(app.Structure).ImgLabel(find(contains(app.base_Feature_set.(app.Structure).ImgLabel,slide_name))) = all_name_parts;

    in_slide_images = app.Notes.(app.Structure).ImgLabel(find(contains(app.Notes.(app.Structure).ImgLabel,slide_name)));
    all_name_parts = cellfun(@(x) strsplit(x,'_'), in_slide_images,'UniformOutput',false);
    all_idxes = cellfun(@(x) x{end}, all_name_parts,'UniformOutput',false);
    for i = 1:length(all_idxes)
        if ~str2double(all_idxes(i))<str2double(img_idx)
            name_parts = all_name_parts{i};
            name_parts{end} = num2str(str2double(all_idxes(i))-1);
            all_name_parts{i} = strjoin(name_parts,'_');
        else
            all_name_parts{i} = strjoin(all_name_parts{i},'_');
        end
    end
    app.Notes.(app.Structure).ImgLabel(find(contains(app.Notes.(app.Structure).ImgLabel,slide_name))) = all_name_parts;


    display(strcat('Height post transfer ',new_structure,num2str(height(app.Full_Feature_set.(new_structure)))))
    display(strcat('Height post transfer ',app.Structure,num2str(height(app.Full_Feature_set.(app.Structure)))))


    waitbar(0.75,wb,'Updating Feature Set and Notes')

else
    HistoLens_NewAnnotationLayer(app)

    new_name = fieldnames(app.structure_idx);
    new_name = new_name{end};
    new_idx = app.structure_idx.(new_name);

    % Adding new annotation layer to xml file
    % Adding annotation to an existing layer
    struct_og = xml2struct(strcat(app.Slide_Path,filesep,slide_name,'.xml'));
    og_annotations = struct_og.Annotations.Annotation;
    
    % If there is already more than 1 structure
    if iscell(og_annotations)
        struct_mod = struct_og;

        rep_annotations = og_annotations{1};
        rep_annotations.Regions = [];
        rep_annotations.Attributes.Id = num2str(new_idx);
        
        rep_region = region_og;
        rep_region.Attributes.DisplayId = '1';
        rep_region.Attributes.Id = '1';
        rep_annotations.Regions.Region = rep_region;
        struct_mod.Annotations.Annotation = [struct_mod.Annotations.Annotation,rep_annotations];

    else
        struct_mod = struct_og;

        rep_annotations = og_annotations;
        rep_annotations.Regions = [];
        rep_annotations.Attributes.Id = num2str(new_idx);
        rep_region = region_og;
        rep_region.Attributes.DisplayId = '1';
        rep_region.Attributes.Id = '1';
        rep_annotations.Regions.Region = rep_region;

        struct_mod.Annotations.Annotation = [{struct_mod.Annotations.Annotation},rep_annotations];
    end

    waitbar(0.5,wb,'Saving modified XML file')


    struct2xml(struct_mod,strcat(app.Slide_Path,filesep,slide_name,'.xml'))

    % Making new feature set file
    feat_idx = find(ismember(current_image,app.Full_Feature_set.(app.Structure).ImgLabel));
    transfer_features = app.Full_Feature_set.(app.Structure)(feat_idx,:);

    base_feat_idx = find(ismember(current_image,app.base_Feature_set.(app.Structure).ImgLabel));
    transfer_base_features = app.base_Feature_set.(app.Structure)(base_feat_idx,:);

    ign_idx = find(ismember(current_image,app.Ignore_idx.ImgLabel));
    transfer_ignore = app.Ignore_idx.(app.Structure)(ign_idx,:);

    notes_idx = find(ismember(current_image,app.Notes.(app.Structure).ImgLabel));
    transfer_notes = app.Notes.(app.Structure)(notes_idx,:);
    app.Notes.(new_name) = transfer_notes;
    app.Notes_File.(new_name) = strrep(app.Notes_File.(app.Structure),app.Structure,new_name);

    app.Full_Feature_set.(new_name) = transfer_features;
    app.base_Feature_set.(new_name) = transfer_base_features;
    app.Ignore_idx.(new_name) = transfer_ignore;

    app.Full_Feature_set.(app.Structure)(feat_idx,:) = [];
    app.base_Feature_set.(app.Structure)(base_feat_idx,:) = [];
    app.Ignore_idx.(app.Structure)(ign_idx,:) = [];
    app.Notes.(app.Structure)(notes_idx,:) = [];

    app.Overlap_Feature_idx.(new_name) = app.Overlap_Feature_idx.(app.Structure);
    app.Feat_Rank.(new_name) = app.Feat_Rank.(app.Structure);
    app.PersistentLabels.(new_name) = '';
    app.StructureDropDown.Items = fieldnames(app.Full_Feature_set);
    app.StructureDropDown.Value = app.Structure;
    
    aligned_labels = fieldnames(app.Aligned_Labels.(app.Structure));
    for a = 1:length(aligned_labels)
        current_feature = aligned_labels{a};
        aligned = app.Aligned_Labels.(app.Structure).(current_feature).Aligned;
        app.Aligned_Labels.(new_name) = aligned(find(ismember(current_image,aligned.ImgLabel)),:);
    end

    waitbar(0.75,wb,'Updating Feature Set and Notes')


end

waitbar(1,wb,'Reloading main window')
pause(1)
delete(wb)

% Refreshing analysis after transferring annotation
app.PAS_Butt.Text = 'PAS+';
app.Lum_Butt.Text = 'Luminal Space';
app.Nuc_Butt.Text = 'Nuclei';
event = [];

app.New_Label = false;
app.new_Persistent_label = false;

Reset_Normalization_Tabs(app)

app.Comparing = false;

Flip_Image_Listbox(app,event)

Plot_Feat(app,event)
Gen_Map(app,event)
View_Image(app,event)
Load_Notes(app,event)

if ~strcmp(app.Compare_Butt.Enable,'on')
    app.Compare_Butt.Visible = 'off';
    app.Compare_Butt.Enable = 'off';
end


