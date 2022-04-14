%--- Function to perform Catch & Release feature extraction
function Catch_N_Release(app,structure_name,feature_indices)

% Getting all the slide names
slide_names = app.Slide_Names;
slide_names = slide_names(~contains(slide_names,'.xml'));
slide_path = app.Slide_Path;

% Structure_list = 
% Make the feature extraction flexible to multi-compartment as well
structure_idx = app.Structure_Names.(structure_name).Annotation_ID;

feat_filename = app.FeatSet_File;
app.FeatureSetFilenameLabel.Text = strcat('Feature Set Filename: ',feat_filename);
ax = app.UIAxes;

% Compartment extraction
% Writing as a nested function to call compartment segmentation
% seg_script = strcat('function comp_img = Call_Comp_Seg(img,mask); comp_img = Comp_Seg(img,mask);',...
%     strjoin([app.Seg_Script.(structure_name){:}],';'));
% comp_seg = @(varargin)seg_script;

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
    
    slide = slide_names(s);

    title(ax, strcat('On Slide: ',slide))
    % Updating progress bar
    ph.XData = [0 0 0 0];
    th.String = sprintf('%.0f%%',0);
    th.Position = [1 1 0];
    drawnow    
    
    % Getting annotations for that slide
    if contains(slide,'.svs')
        file_name = strrep(slide,'.svs','.xml');
    else
        file_name = strrep(slide,'.ndpi','.xml');
    end
    
    current_path = strcat(slide_path,filesep,file_name);
    current_path = current_path{1};

    read_xml = xmlread(current_path);
    
    % Extract MPP from XML
    
    annotations = read_xml.getElementsByTagName('Annotation');
    %try
        structure_regions = annotations.item(structure_idx-1);
        regions = structure_regions.getElementsByTagName('Region');

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

        slide_filepath = strcat(slide_path,filesep,slide);
        slide_filepath = slide_filepath{1};

        % Unique structure identifier
        slide_id = slide{1};
        structure_ID = strsplit(slide_id,'.');
        structure_ID = structure_ID{1};

        % Creating an array of all regions in the slide for more efficient
        % parallel processing
        for p = 0:regions.getLength-1
            reg_array(p+1) = regions.item(p);
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
        %parfor r = 1:length(reg_array)
        for r = 1:length(reg_array)

            % This progress bar can't be used in a parfor loop, shows progress
            % in terms of number of structures per slide
    %         % Updating progress bar
    %         ph.XData = [0 (r/(regions.getLength-1)) (r/(regions.getLength-1)) 0];
    %         th.String = sprintf('%.0f%%',round(100*(r/(regions.getLength-1))));
    %         th.Position = [1 1 0];
    %         drawnow

            %reg = regions.item(r);
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

            img = imread(slide_filepath,'Index',1,'PixelRegion',{bbox_coords(3:4),bbox_coords(1:2)});
            mask = poly2mask(mask_coords(:,1),mask_coords(:,2),size(img,1),size(img,2));

            % Stain normalization
            img = normalizeStaining(img,240,0.15,1,app.Seg_Params.(structure_name).StainNormalization.Means,...
                app.Seg_Params.(structure_name).StainNormalization.Maxs);

            %comp_img = comp_seg(img,mask);
            %assignin('base','comp_img',comp_img)
            comp_img = Comp_Seg_Gen(app.Seg_Params.(structure_name),img,mask);

            % Extracting feature row (corresponding to specific structure
            feat_row_combined = Features_Extract_General(img,comp_img,feature_indices,mpp);

            % Assigning a name to that structure
            new_ID = strcat(structure_ID,'_',num2str(r));
            feat_row_combined = [num2cell(feat_row_combined),new_ID];

            feature_set = [feature_set;feat_row_combined];
        end
        app.UITable.Data = [app.UITable.Data;{slide_id,num2str(regions.getLength)}];
        cell2csv(feat_filename,feature_set);

        clear reg_array
    
    %catch
%         % Slide-level progress bar
%         ph.XData = [0 ((s-1)/length(slide_names)) ((s-1)/length(slide_names)) 0];
%         th.String = sprintf('%.0f%%',round(100*((s-1)/length(slide_names))));
%         th.Position = [1 1 0];
%         drawnow
    %end

end



% Slide-level progress bar
ph.XData = [0 1 1 0];
th.String = sprintf('%.0f%%',100);
th.Position = [1 1 0];
drawnow

%feature_set = feature_set(2:end,:);
% Writing the features to the feature set file (get feature names)
%feature_table = cell2table(feature_set);
%writetable(feature_table,feat_filename);
cell2csv(feat_filename,feature_set);
app.Full_Feature_set = readtable(feat_filename,'ReadVariableNames',true,'VariableNamingRule','preserve','Delimiter',',');
