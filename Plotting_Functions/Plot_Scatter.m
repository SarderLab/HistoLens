% --- Function for plotting Scatter plot
function Plot_Scatter(app)

rm_out = app.rem_out;
plot_idx = find(ismember(app.Overlap_Feature_idx.(app.Structure),app.map_idx));
event = [];

cla(app.Dist_Ax,'reset')

if ~app.Combine_Label
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
else
    sub_data = app.Dist_Data;
end
        
if length(plot_idx)==2
    
    if ~app.Combine_Label
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
    end
    
    axes(app.Dist_Ax)
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
    
    if ~app.Combine_Label
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
        
        axes(app.Dist_Ax)
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
    
    else
        axes(app.Dist_Ax)
        if isnumeric(app.Dist_Data.Class(1,1))
        
            g_scat = gscatter(app.Dist_Ax,app.Dist_Data.Score1,app.Dist_Data.Score2,app.Dist_Data.Class,colormap(jet(length(unique(sub_data.Class(:))))),[],[],'off');
            colormap(jet(length(unique(app.Dist_Data.Class(:)))))
            hc = colorbar;
            set(hc,'YTick',linspace(0,1,...
                length(unique(app.Dist_Data.Class(:)))),'YTickLabel',cellstr(num2str(unique(app.Dist_Data.Class(:))))')
    
        else
            gscatter(app.Dist_Ax,app.Dist_Data.Score1,app.Dist_Data.Score2,app.Dist_Data.Class)
        end
    
        xlabel('PCA 1'), ylabel('PCA 2'), title('Scatter plot of PC1 and PC2')
    end
end

% If changing to a new label
if isempty(app.Plot_Options) || ismember('LabelOrder',fieldnames(app.Plot_Options))
    Initialize_Plot_Options(app,'scatter')
else
    Update_Plot_Options(app)
end



