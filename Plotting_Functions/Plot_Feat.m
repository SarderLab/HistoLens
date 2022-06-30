% --- Function to plot distribution of selected features
%function Plot_Feat(hObject, eventdata, app)
function Plot_Feat(app,event)

% Whether to remove outliers or not, performed class-wise
rm_out = app.rem_out;
        
if app.new_Persistent_label
    
    if length(app.map_idx)==1
        plot_idx = find(app.Overlap_Feature_idx.(app.Structure)==app.map_idx);
    else
        plot_idx = find(ismember(app.Overlap_Feature_idx.(app.Structure),app.map_idx));
    end
    
    all_text_handles = findall(app.Dist_Ax,'type','Text');
    all_text = {findall(app.Dist_Ax,'type','Text').String};
    all_labels = find(cellfun(@(x)contains(x,'\leftarrow'),all_text));
     
    % Save the current image labels (im_text, red_text, blue_text)
    current_labels = find(cellfun(@(x)contains(x,'Image'),all_text));
    all_labels = setdiff(all_labels,current_labels);
    
    delete(all_text_handles(all_labels))
    
    
    if length(plot_idx)==1

        all_class = unique(app.Dist_Data.Class);
        if ~isnumeric(all_class)
            for j = 1:length(app.Persistent_Labels.(app.Structure))
                
                label_data = app.Dist_Data(strcmp(app.Dist_Data.ImgLabel,app.Persistent_Labels.(app.Structure){j}),:);
                if ~isempty(label_data)
                    text(app.Dist_Ax,find(strcmp(label_data{1,3},all_class)),...
                        label_data{1,1},strcat('\leftarrow',app.Persistent_Labels.(app.Structure){j}),...
                        'ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app)); 
                end
            end
        else
            for j = 1:length(app.Persistent_Labels.(app.Structure))
                
                label_data = app.Dist_Data(strcmp(app.Dist_Data.ImgLabel,app.Persistent_Labels.(app.Structure){j}),:);
                if ~isempty(label_data)
                    text(app.Dist_Ax,find(label_data{1,3}==all_class),...
                        label_data{1,1},strcat('\leftarrow',app.Persistent_Labels.(app.Structure){j}),...
                        'ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));
                end
            end
        end
    else
        label_vals = app.Dist_Data{ismember(app.Dist_Data.ImgLabel,app.Persistent_Labels.(app.Structure)),1:2};
        for j = 1:height(label_vals)
            text(app.Dist_Ax,label_vals(j,1),label_vals(j,2),strcat('\leftarrow',app.Persistent_Labels.(app.Structure){j}),...
                'ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));
        end
    end
        
end

if app.New_Label
    
    if length(app.map_idx)==1
        plot_idx = find(app.Overlap_Feature_idx.(app.Structure)==app.map_idx);
    else
        plot_idx = find(ismember(app.Overlap_Feature_idx.(app.Structure),app.map_idx));
    end
    
    if length(plot_idx)==1
        
        feat_name = app.Full_Feature_set.(app.Structure).Properties.VariableNames{plot_idx};
        %feat_name = app.feature_encodings.Feature_Names{plot_idx};
        current_val = app.Image_Name_Label.Value;
        app.Image_Name_Label.Items = Combine_Name_Label(app, app.Dist_Data.ImgLabel(:),app.Dist_Data.(feat_name)(:));
        if ~isempty(find(strcmp(app.Image_Name_Label.Items,current_val)))
            app.Image_Name_Label.Value = current_val;
        else
            app.Image_Name_Label.Value = app.Image_Name_Label.Items(1);
        end
                    
        cla(app.Dist_Ax,'reset')

        axes(app.Dist_Ax)

        % Plotting Violinplot of data, labeling by Treatment/Class
        violinplot(app.Dist_Data.(feat_name), app.Dist_Data.Class);
        xlabel('Class')
        ylabel(feat_name)
        title(feat_name)
                    
        % Adding persistent image labels to plot
        if ~isempty(app.Persistent_Labels.(app.Structure))

            all_class = unique(app.Dist_Data.Class);
            if ~isnumeric(all_class)
                for j = 1:length(app.Persistent_Labels.(app.Structure))

                    label_data = app.Dist_Data(strcmp(app.Dist_Data.ImgLabel,app.Persistent_Labels.(app.Structure){j}),:);
                    if ~isempty(label_data)
                        text(app.Dist_Ax,find(strcmp(label_data{1,3},all_class)),...
                            label_vals{1,1},strcat('\leftarrow',app.Persistent_Labels.(app.Structure){j}),...
                            'ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));            
                    end
                end
            else
                for j = 1:length(app.Persistent_Labels.(app.Structure))
                    
                    label_data = app.Dist_Data(strcmp(app.Dist_Data.ImgLabel,app.Persistent_Labels.(app.Structure){j}),:);
                    if ~isempty(label_data)
                        text(app.Dist_Ax,find(label_data{1,3}==all_class),...
                            label_data{1,1},strcat('\leftarrow',app.Persistent_Labels.(app.Structure){j}),...
                            'ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));
                    end
                end
            end
                
        end
    end
    
    if length(plot_idx)==2
        
        feat_names = app.Full_Feature_set.(app.Structure).Properties.VariableNames(plot_idx);
        
        current_val = app.Image_Name_Label.Value;
        app.Image_Name_Label.Items = Combine_Name_Label(app, app.Dist_Data.ImgLabel,[]);
        if ~isempty(find(strcmp(app.Image_Name_Label.Items, current_val)))
            app.Image_Name_Label.Value = current_val;
        else
            app.Image_Name_Label.Value = app.Image_Name_Label.Items(1);
        end
                    
        if isnumeric(app.Dist_Data.Class(:))
            g_scat = gscatter(app.Dist_Ax,app.Dist_Data{:,1},app.Dist_Data{:,2},app.Dist_Data.Class,"*",'off');
            colormap(jet(length(unique(app.Dist_Data.Class(:)))))
            hc = colorbar;
            set(hc,'YTick',linspace(1,length(unique(app.Dist_Data.Class(:))),...
                length(unique(app.Dist_Data.Class(:)))),'YTickLabel',unique(app.Dist_Data.Class(:)))

        else
            g_scat = gscatter(app.Dist_Ax,app.Dist_Data{:,1},app.Dist_Data{:,2},app.Dist_Data.Class);
        end
        xlabel(feat_names{1}), ylabel(feat_names{2}), title('Scatter plot of two features')
        
        % Adding persistent image labels to plot
        if ~isempty(app.Persistent_Labels.(app.Structure))
            label_vals = app.Dist_Data{ismember(app.Dist_Data.ImgLabel,app.Persistent_Labels.(app.Structure)),1:2};

            for j = 1:height(label_vals)
                text(app.Dist_Ax,label_vals(j,1),label_vals(j,2),...
                    strcat('\leftarrow',app.Persistent_Labels.(app.Structure){j}),...
                    'ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));             
            end
        end
        
    end
    
    if length(plot_idx)>2
        
        if isnumeric(app.Dist_Data.Class(1,1))
            g_scat = gscatter(app.Dist_Ax,app.Dist_Data.Score1,...
                app.Dist_Data.Score2,app.Dist_Data.Class,...
                colormap(jet(length(unique(app.Dist_Data.Class)))),[],[],'off');
            colormap(jet(length(unique(app.Dist_Data.Class))))
            hc = colorbar;
            set(hc,'YTick',linspace(0,1,...
                length(unique(app.Dist_Data.Class))),'YTickLabel',...
                cellstr(num2str(unique(app.Dist_Data.Class)))')

        else
            gscatter(app.Dist_Ax,app.Dist_Data.Score1,app.Dist_Data.Score2,...
                app.Dist_Data.Class)

        end

        xlabel('PCA 1'), ylabel('PCA 2'), title('Scatter plot of PC1 and PC2')

        current_val = app.Image_Name_Label.Value;
        app.Image_Name_Label.Items = Combine_Name_Label(app, app.Dist_Data.ImgLabel(:),[]);
        if ~isempty(find(strcmp(app.Image_Name_Label.Items,current_val)))
            app.Image_Name_Label.Value = current_val;
        else
            app.Image_Name_Label.Value = app.Image_Name_Label.Items(1);
        end
        
        % Adding persistent image labels to plot
        if ~isempty(app.Persistent_Labels.(app.Structure))
            label_vals = app.Dist_Data{ismember(app.Dist_Data.ImgLabel,app.Persistent_Labels.(app.Structure)),1:2};

            for j = 1:height(label_vals)
                text(app.Dist_Ax,label_vals(j,1),label_vals(j,2),...
                    strcat('\leftarrow',app.Persistent_Labels.(app.Structure){j}),...
                    'ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));             
            end
        end

    end
    
end

if ~app.new_Persistent_label && ~app.New_Label
    
    Get_Feat(app,event)
    app.Heat_Slide.Enable = 'on';
    
    if length(app.map_idx)==1
        plot_idx = find(app.Overlap_Feature_idx.(app.Structure)==app.map_idx);
    else
        plot_idx = find(ismember(app.Overlap_Feature_idx.(app.Structure),app.map_idx));
    end


    cla(app.Dist_Ax,'reset')
    % For single feature plots (violinplots)
    if length(plot_idx)==1

        % Feature values
        feat_name = app.Full_Feature_set.(app.Structure).Properties.VariableNames{plot_idx};

        try
            data = horzcat(num2cell(app.Full_Feature_set.(app.Structure).(feat_name)),num2cell(app.Full_Feature_set.(app.Structure).ImgLabel),...
                num2cell(app.Full_Feature_set.(app.Structure).Class));
        catch
            data = horzcat(num2cell(app.Full_Feature_set.(app.Structure).(feat_name)),app.Full_Feature_set.(app.Structure).ImgLabel,...
                app.Full_Feature_set.(app.Structure).Class);
        end

        data = cell2table(data,'VariableNames',{feat_name, 'ImgLabel','Class'});

        % Getting labeling class from selection
        data_ind = Subset_Data(app,event);
        % Data only for the classes we are interested in
        sub_data = data(find(data_ind),:);

        if rm_out
            [~,TF] = rmoutliers(sub_data.(feat_name));
            TF = TF+ismissing(sub_data.(feat_name));
            
            % Populating Outlier Table
            app.OutlierTable.Data = sub_data.ImgLabel(find(TF));
            app.OutlierTable.Visible = 'on';

            sub_data = sub_data(~TF,:);
        end

        current_val = app.Image_Name_Label.Value;
        app.Image_Name_Label.Items = Combine_Name_Label(app, sub_data.ImgLabel(:),sub_data.(feat_name)(:));
        if ~isempty(find(strcmp(app.Image_Name_Label.Items,current_val)))
            app.Image_Name_Label.Value = current_val;
        else
            app.Image_Name_Label.Value = app.Image_Name_Label.Items(1);
        end
        
        app.Dist_Data = sub_data;

        axes(app.Dist_Ax)

        % Plotting Violinplot of data, labeling by Treatment/Class
        violinplot(sub_data.(feat_name), sub_data.Class);
        xlabel('Class')
        ylabel(app.feature_encodings.Feature_Names{app.map_idx})
        title(app.feature_encodings.Feature_Names{app.map_idx})
                    
        % Adding persistent image labels to plot
        if ~isempty(app.Persistent_Labels.(app.Structure))

            all_class = unique(sub_data.Class);
            if ~isnumeric(all_class)
                for j = 1:length(app.Persistent_Labels.(app.Structure))
                    
                    label_data = app.Dist_Data(strcmp(app.Dist_Data.ImgLabel,app.Persistent_Labels.(app.Structure){j}),:);
                    if ~isempty(label_data)
                        text(app.Dist_Ax,find(strcmp(label_data{1,3},all_class)),...
                            label_data{1,1},strcat('\leftarrow',app.Persistent_Labels.(app.Structure){j}),...
                            'ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));      
                    end
                end
            else
                for j = 1:length(app.Persistent_Labels.(app.Structure))
                    
                    label_data = app.Dist_Data(strcmp(app.Dist_Data.ImgLabel,app.Persistent_Labels.(app.Structure){j}),:);
                    if ~isempty(label_data)
                        text(app.Dist_Ax,find(label_data{1,3}==all_class),...
                            label_data{1,1},strcat('\leftarrow',app.Persistent_Labels.(app.Structure){j}),...
                            'ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));
                    end
                end
            end
        end

    else

        %% Dimensional reductions for multiple features
        feat_names = app.Full_Feature_set.(app.Structure).Properties.VariableNames(plot_idx);
        axis_titles = app.feature_encodings.Feature_Names(app.map_idx);

        % Combining data for all included feature values
        data = app.Full_Feature_set.(app.Structure)(:,strcmp(app.Full_Feature_set.(app.Structure).Properties.VariableNames,feat_names{1}));
        for j = 2:length(plot_idx)
            data = horzcat(data,app.Full_Feature_set.(app.Structure)(:,strcmp(app.Full_Feature_set.(app.Structure).Properties.VariableNames,feat_names{j})));
        end

        % Combining data with image labels and treatment/class label
        data = horzcat(data,app.Full_Feature_set.(app.Structure)(:,end-1),app.Full_Feature_set.(app.Structure)(:,end));

        data_ind = Subset_Data(app,event);

        % Data only for the classes we are interested in
        sub_data = data(find(data_ind),:);
        
        app.Dist_Data = sub_data;

        axes(app.Dist_Ax)

        if length(plot_idx)==2
            
            if rm_out
                [~,TF] = rmoutliers(sub_data{:,1:end-2});
                TF = TF|any(ismissing(sub_data{:,1:end-2}),2);

                % Populating Outlier Table
                app.OutlierTable.Data = sub_data.ImgLabel(TF);
                app.OutlierTable.Visible = 'on';

                sub_data = sub_data(~TF,:);
                app.Dist_Data = sub_data;

            end

            current_val = app.Image_Name_Label.Value;
            app.Image_Name_Label.Items = Combine_Name_Label(app, sub_data.ImgLabel,[]);
            if ~isempty(find(strcmp(app.Image_Name_Label.Items,current_val)))
                app.Image_Name_Label.Value = current_val;
            else
                app.Image_Name_Label.Value = app.Image_Name_Label.Items(1);
            end
            
            app.Dist_Data = sub_data;
            
            if isnumeric(sub_data.Class(:))
                                    
                g_scat = gscatter(app.Dist_Ax,sub_data{:,1},sub_data{:,2},sub_data.Class);
                colormap(jet(length(unique(sub_data.Class(:)))))
                hc = colorbar;
                set(hc,'YTick',linspace(1,length(unique(sub_data.Class(:))),...
                    length(unique(sub_data.Class(:)))),'YTickLabel',unique(sub_data.Class(:)))

            else
                g_scat = gscatter(app.Dist_Ax,sub_data{:,1},sub_data{:,2},sub_data.Class);
            end

            [sorted,title_inds] = sort(app.map_idx);
            xlabel(axis_titles{title_inds(1)}), ylabel(axis_titles{title_inds(2)}), title('Scatter plot of two features')

        else
            
            if rm_out
                    
                class_data = sub_data(:,1:end-2);

                [row_clean,TF_rows] = rmoutliers(class_data,1);
                row_clean.Class = sub_data.Class(~TF_rows);
                row_clean.ImgLabel = sub_data.ImgLabel(~TF_rows);

                [row_clean,TF_missing] = rmmissing(row_clean,1);

                % Populating Outlier Table
                app.OutlierTable.Data = sub_data.ImgLabel(TF_rows);
                app.OutlierTable.Visible = 'on';

                sub_data = row_clean;
      
            else
                sub_data = rmmissing(sub_data);
                % column check for inf
                t = sub_data{:,1:end-2};
                t(isinf(t)) = 0;
                sub_data{:,1:end-2} = t;
                [sub_data,TF] = rmmissing(sub_data,1);
                
            end
            
            [coeff,score,~,~,explained] = pca(zscore(sub_data{:,1:end-2}));

            app.PCA_Vals = [{explained},{coeff}];
            
            if isnumeric(sub_data.Class(1,1))
                app.Dist_Data = cell2table(horzcat(num2cell(score(:,1:2)),...
                    sub_data.ImgLabel(:),num2cell(sub_data.Class(:))),...
                    'VariableNames',{'Score1','Score2','ImgLabel','Class'});

                g_scat = gscatter(app.Dist_Ax,score(:,1),score(:,2),sub_data.Class,colormap(jet(length(unique(sub_data.Class(:))))),[],[],'off');
                colormap(jet(length(unique(sub_data.Class(:)))))
                hc = colorbar;
                set(hc,'YTick',linspace(0,1,...
                    length(unique(sub_data.Class(:)))),'YTickLabel',cellstr(num2str(unique(sub_data.Class(:))))')

            else
                app.Dist_Data = cell2table(horzcat(num2cell(score(:,1:2)),...
                    sub_data.ImgLabel(:),sub_data.Class(:)),...
                    'VariableNames',{'Score1','Score2','ImgLabel','Class'});

                gscatter(app.Dist_Ax,app.Dist_Data.Score1,app.Dist_Data.Score2,app.Dist_Data.Class)

            end

            xlabel('PCA 1'), ylabel('PCA 2'), title('Scatter plot of PC1 and PC2')
            
            current_val = app.Image_Name_Label.Value;
            app.Image_Name_Label.Items = Combine_Name_Label(app, app.Dist_Data.ImgLabel(:),[]);
            if ~isempty(find(strcmp(app.Image_Name_Label.Items,current_val)))
                app.Image_Name_Label.Value = current_val;
            else
                app.Image_Name_Label.Value = app.Image_Name_Label.Items(1);
            end
            
            
            % Adding persistent image labels to plot
            if ~isempty(app.Persistent_Labels.(app.Structure))
                label_vals = app.Dist_Data{ismember(app.Dist_Data.ImgLabel,app.Persistent_Labels.(app.Structure)),1:2};

                for j = 1:height(label_vals)
                    text(app.Dist_Ax,label_vals(j,1),label_vals(j,2),...
                        strcat('\leftarrow',app.Persistent_Labels.(app.Structure){j}),...
                        'ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));             
                end
            end

        end

    end

end

Feat_Stats(app,event)
Check_Classification(app)



