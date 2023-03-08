%--- Function to perform Catch & Release feature extraction
function Catch_N_Release(app,structure_name,feature_indices)

% Getting all the slide names
slide_names = app.Slide_Names;
slide_names = slide_names(~contains(slide_names,{'.xml','json'}));
slide_path = app.Slide_Path;

%structure_idx = app.Structure_Names.(structure_name).Annotation_ID;
structure_names = app.Structure_Names{:,1};
structure_row = find(strcmp(structure_name,structure_names));
structure_idx = app.Structure_Names{structure_row,2};
structure_idx = strsplit(structure_idx{1},',');

structure_idx = str2double(structure_idx);

structure_idx_name = strcat('Structure_',num2str(structure_row));

feat_filename = app.FeatSet_File;
app.FeatureSetFilenameLabel.Text = strcat('Feature Set Filename: ',feat_filename);
ax = app.UIAxes;

% Initializing feature set
feature_set = cell(1,length(feature_indices)+1);
feature_names = app.all_feature_defs.Feature_Names;
feature_names = feature_names(feature_indices);
feature_set(1,:) = [feature_names',{'ImgLabel'}];
    
% Empty patch that will be updated
ph = patch(ax,[0 0 0 0],[0 0 1 1],[0.67578 1 0.18359]);
% Percent-complete text that will be updated
th = text(ax,1,1,'0%','VerticalAlignment','bottom','HorizontalAlignment','right');
% Updating slide progress bar with current slide name
title(ax, 'On Slide: ')

% Iterating through all slides
for s = 1:length(slide_names)
    
    slide = slide_names{s};
    slide_idx_name = strcat('Slide_Idx_',num2str(s));

    if contains(slide,'.')
        slide = strsplit(slide,'.');

        wsi_ext = slide{end};
        slide = strjoin(slide(1:end-1),'_');
    end

    if ~strcmp(wsi_ext,'svs')
        %display('Opening slide pointer')
        slide_pointer = openslide_open(strcat(app.Slide_Path,filesep,slide_names{s}));
    else
        slide_pointer = [];
    end

    app.Slide_NormVals.(slide_idx_name).SlideName = slide;

    title(ax, strcat('On Slide: ',slide))
    % Updating progress bar
    ph.XData = [0 0 0 0];
    th.String = sprintf('%.0f%%',0);
    th.Position = [1 1 0];
    drawnow    
    
    if strcmp(app.Annotation_Format,'XML')
        current_path = strcat(slide_path,filesep,slide,'.xml');
        read_xml = xmlread(current_path);
            
        annotations = read_xml.getElementsByTagName('Annotation');
    
        % Uncomment this try-catch to account for any slides with 0 structures
        % annotated
        mpp = read_xml.getElementsByTagName('Annotations');
        mpp = str2double(mpp.item(0).getAttribute('MicronsPerPixel'));
    
        % When annotations are the result of network predictions, the MPP is
        % not written to the xml file
        if ~isnan(mpp)
            app.MPP = mpp;
        else
            mpp = 0.2253;
            app.MPP = mpp;
        end
    else
        current_path = strcat(slide_path,filesep,slide,'.json');
        if ~isfile(current_path)
            current_path = strrep(current_path,'.json','.geojson');
            annotations = jsondecode(fileread(current_path));
            annotations = annotations.features;
        else
            annotations = jsondecode(fileread(current_path));

        end
    end

    slide_filepath = strcat(slide_path,filesep,slide,'.svs');

    % Unique structure identifier
    slide_id = slide;
    structure_ID = slide_id;
    
    % Fix for multiple structure idxes for a single structure
    %reg_count = 1;
    reg_array = [];
    if strcmp(app.Annotation_Format,'XML')
        for st = 1:length(structure_idx)
            structure_regions = annotations.item(structure_idx(st)-1);
            if ~isempty(structure_regions)
                regions = structure_regions.getElementsByTagName('Region');
        
                % Creating an array of all regions in the slide for more efficient
                % parallel processing
                for p = 0:regions.getLength-1
                    reg_array = [reg_array;regions.item(p)];
                    %reg_count = reg_count+1;
                end
            end
        end
    else
        for st = 1:length(annotations)
            try
                reg_array = [reg_array;annotations(st).coordinates];
            catch
                reg_array = [reg_array;annotations(st).geometry.coordinates];
            end
        end
    end

    reg_count = 0;
    if strcmp(app.Annotation_Format,'XML')
        for st = 1:length(structure_idx)
            structure_regions = annotations.item(structure_idx(st)-1);
            if ~isempty(structure_regions)
                regions = structure_regions.getElementsByTagName('Region');
                reg_count = reg_count+regions.getLength;
            end
        end
    else
        reg_count = reg_count+length(annotations);
    end


    % Slide-level progress bar
    ph.XData = [0 ((s-1)/length(slide_names)) ((s-1)/length(slide_names)) 0];
    th.String = sprintf('%.0f%%',round(100*((s-1)/length(slide_names))));
    th.Position = [1 1 0];
    drawnow

    % Parallel for-loops only really worthwhile if you have >4 cores to
    % work with
    % Need to change up input into Comp_Seg_Gen to facilitate
    % parallelization, it doesn't like being passed 'app' as an argument.
    % So just need to extract the segmentation parameters before that
    seg_params = app.Seg_Params;
    ann_format = app.Annotation_Format;

    try
        parfor r = 1:reg_count
        %for r = 1:length(reg_array)
            if strcmp(ann_format,'XML')
                reg = reg_array(r);
                verts = reg.getElementsByTagName('Vertex');
                xy = zeros(verts.getLength-1,2);
                for vi = 0:verts.getLength-1
                    x = str2double(verts.item(vi).getAttribute('X'));
                    y = str2double(verts.item(vi).getAttribute('Y'));
        
                    xy(vi+1,:) = [x,y];
                end
        
                mask_coords = zeros(size(xy));
                bbox_coords = [min(xy(:,1))-100,max(xy(:,1))+100,min(xy(:,2))-100,max(xy(:,2))+100];
                mask_coords(:,1) = xy(:,1)-bbox_coords(1);
                mask_coords(:,2) = xy(:,2)-bbox_coords(3);
            else
                reg = reg_array(r);
                
                bbox_coords = [min(reg(:,1))-100,max(reg(:,1))+100,min(reg(:,2))-100,max(reg(:,2))+100];
                mask_coords = zeros(size(reg));
                mask_coords(:,1) = reg(:,1)-bbox_coords(1);
                mask_coords(:,2) = reg(:,2)-bbox_coords(3);
            end
            
            
            if strcmp(wsi_ext,'svs')
                raw_img = imread(slide_filepath,'Index',1,'PixelRegion',{bbox_coords(3:4),bbox_coords(1:2)});
            else
                %display('Non SVS File format')
                min_x = bbox_coords(1);
                min_y = bbox_coords(3);
                range_x = bbox_coords(2)-bbox_coords(1);
                range_y = bbox_coords(4)-bbox_coords(3);
    
                raw_img = openslide_read_region(slide_pointer,min_x,min_y,range_x,range_y);
            end
    
            mask = poly2mask(mask_coords(:,1),mask_coords(:,2),size(raw_img,1),size(raw_img,2));
    
            % Stain normalization
            if ismember('StainNormalization',fieldnames(seg_params))
                img = normalizeStaining(raw_img,240,0.15,1,seg_params.StainNormalization.Means,...
                    seg_params.StainNormalization.Maxs);
            else
                img = raw_img;
            end
            
            if ismember('Path',fieldnames(seg_params.(slide_idx_name).CompartmentSegmentation))
                mask = strcat(slide,'_',num2str(r));
            end
            comp_img = Comp_Seg_Gen(seg_params.(slide_idx_name).CompartmentSegmentation,img,mask);
    
            % Extracting feature row (corresponding to specific structure
            feat_row_combined = Features_Extract_General(img,comp_img,feature_indices,mpp);
    
            % Assigning a name to that structure
            new_ID = strcat(structure_ID,'_',num2str(r));
            feat_row_combined = [num2cell(feat_row_combined),new_ID];
    
            feature_set = [feature_set;feat_row_combined];
        end
        
        app.UITable.Data = [app.UITable.Data;{slide_id,num2str(reg_count)}];

        cell2csv(feat_filename,feature_set);
    
        if ~strcmp(wsi_ext,'svs')
            %display('Closing slide pointer')
            openslide_close(slide_pointer)
        end
        
        
        clear reg_array
    end
end

% Slide-level progress bar
ph.XData = [0 1 1 0];
th.String = sprintf('%.0f%%',100);
th.Position = [1 1 0];
drawnow

% Writing the features to the feature set file (get feature names)
cell2csv(feat_filename,feature_set);
app.Full_Feature_set.(structure_idx_name) = readtable(feat_filename,'ReadVariableNames',true,'VariableNamingRule','preserve','Delimiter',',');

