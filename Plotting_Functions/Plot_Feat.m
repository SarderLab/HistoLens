% --- Function to plot distribution of selected features
%function Plot_Feat(hObject, eventdata, app)
function Plot_Feat(app,event)

% Whether to remove outliers or not, performed class-wise
%rm_out = app.rem_out;
        
if app.new_Persistent_label
    
    all_text_handles = findall(app.Dist_Ax,'type','Text');
    all_text = {findall(app.Dist_Ax,'type','Text').String};
    all_labels = find(cellfun(@(x)contains(x,'\leftarrow'),all_text));
     
    % Save the current image labels (im_text, red_text, blue_text)
    current_labels = find(cellfun(@(x)contains(x,'Image'),all_text));
    all_labels = setdiff(all_labels,current_labels);
    
    delete(all_text_handles(all_labels))
    
    if length(app.map_idx)==1

        all_class = app.Plot_Options.LabelOrder;
        if ~isnumeric(all_class)
            for j = 1:length(app.Persistent_Labels.(app.Structure_Idx_Name))
                
                label_data = app.Dist_Data(strcmp(app.Dist_Data.ImgLabel,app.Persistent_Labels.(app.Structure_Idx_Name){j}),:);
                if ~isempty(label_data)
                    text(app.Dist_Ax,find(strcmp(label_data{1,3},all_class)),...
                        label_data{1,1},strcat('\leftarrow',app.Persistent_Labels.(app.Structure_Idx_Name){j}),...
                        'ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app)); 
                end
            end
        else
            for j = 1:length(app.Persistent_Labels.(app.Structure_Idx_Name))
                
                label_data = app.Dist_Data(strcmp(app.Dist_Data.ImgLabel,app.Persistent_Labels.(app.Structure_Idx_Name){j}),:);
                if ~isempty(label_data)
                    text(app.Dist_Ax,find(label_data{1,3}==all_class),...
                        label_data{1,1},strcat('\leftarrow',app.Persistent_Labels.(app.Structure_Idx_Name){j}),...
                        'ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));
                end
            end
        end
    else
        label_vals = app.Dist_Data{ismember(app.Dist_Data.ImgLabel,app.Persistent_Labels.(app.Structure_Idx_Name)),1:2};
        for j = 1:height(label_vals)
            text(app.Dist_Ax,label_vals(j,1),label_vals(j,2),strcat('\leftarrow',app.Persistent_Labels.(app.Structure_Idx_Name){j}),...
                'ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));
        end
    end
        
end

if app.New_Label

    app.Plot_Options = [];
    
     if length(app.map_idx)==1
        
        Plot_Violin(app)
        % Adding persistent image labels to plot
        if ~isempty(app.Persistent_Labels.(app.Structure_Idx_Name))

            all_class = app.Plot_Options.LabelOrder;
            if ~isnumeric(all_class)
                for j = 1:length(app.Persistent_Labels.(app.Structure_Idx_Name))

                    label_data = app.Dist_Data(strcmp(app.Dist_Data.ImgLabel,app.Persistent_Labels.(app.Structure_Idx_Name){j}),:);
                    if ~isempty(label_data)
                        text(app.Dist_Ax,find(strcmp(label_data{1,3},all_class)),...
                            label_data{1,1},strcat('\leftarrow',app.Persistent_Labels.(app.Structure_Idx_Name){j}),...
                            'ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));            
                    end
                end
            else
                for j = 1:length(app.Persistent_Labels.(app.Structure_Idx_Name))
                    
                    label_data = app.Dist_Data(strcmp(app.Dist_Data.ImgLabel,app.Persistent_Labels.(app.Structure_Idx_Name){j}),:);
                    if ~isempty(label_data)
                        text(app.Dist_Ax,find(label_data{1,3}==all_class),...
                            label_data{1,1},strcat('\leftarrow',app.Persistent_Labels.(app.Structure_Idx_Name){j}),...
                            'ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));
                    end
                end
            end
                
        end
     else

        Plot_Scatter(app)
        % Adding persistent image labels to plot
        if ~isempty(app.Persistent_Labels.(app.Structure_Idx_Name))
            label_vals = app.Dist_Data{ismember(app.Dist_Data.ImgLabel,app.Persistent_Labels.(app.Structure_Idx_Name)),1:2};

            for j = 1:height(label_vals)
                text(app.Dist_Ax,label_vals(j,1),label_vals(j,2),...
                    strcat('\leftarrow',app.Persistent_Labels.(app.Structure_Idx_Name){j}),...
                    'ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));             
            end
        end

    end
    
end

if ~app.new_Persistent_label && ~app.New_Label
    
    Get_Feat(app,event)
    app.Heat_Slide.Enable = 'on';
             
    if length(app.map_idx)==1
        Plot_Violin(app)
        % Adding persistent image labels to plot
        if ~isempty(app.Persistent_Labels.(app.Structure_Idx_Name))

            all_class = app.Plot_Options.LabelOrder;
            if ~isnumeric(all_class)
                for j = 1:length(app.Persistent_Labels.(app.Structure_Idx_Name))
                    
                    label_data = app.Dist_Data(strcmp(app.Dist_Data.ImgLabel,app.Persistent_Labels.(app.Structure_Idx_Name){j}),:);
                    if ~isempty(label_data)
                        text(app.Dist_Ax,find(strcmp(label_data{1,3},all_class)),...
                            label_data{1,1},strcat('\leftarrow',app.Persistent_Labels.(app.Structure_Idx_Name){j}),...
                            'ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));      
                    end
                end
            else
                for j = 1:length(app.Persistent_Labels.(app.Structure_Idx_Name))
                    
                    label_data = app.Dist_Data(strcmp(app.Dist_Data.ImgLabel,app.Persistent_Labels.(app.Structure_Idx_Name){j}),:);
                    if ~isempty(label_data)
                        text(app.Dist_Ax,find(label_data{1,3}==all_class),...
                            label_data{1,1},strcat('\leftarrow',app.Persistent_Labels.(app.Structure_Idx_Name){j}),...
                            'ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));
                    end
                end
            end
        end

    else
            
        Plot_Scatter(app)
        
        % Adding persistent image labels to plot
        if ~isempty(app.Persistent_Labels.(app.Structure_Idx_Name))
            label_vals = app.Dist_Data{ismember(app.Dist_Data.ImgLabel,app.Persistent_Labels.(app.Structure_Idx_Name)),1:2};

            for j = 1:height(label_vals)
                text(app.Dist_Ax,label_vals(j,1),label_vals(j,2),...
                    strcat('\leftarrow',app.Persistent_Labels.(app.Structure_Idx_Name){j}),...
                    'ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));             
            end
        end
    end
end


Feat_Stats(app,event)
Check_Classification(app)

