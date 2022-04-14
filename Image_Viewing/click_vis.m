% Get coordinates of mouse click on axis1 and then plot/list relative
% influences of each feature in the current map.
function click_vis(app,event,roi)

axes(app.Rel_Ax);
app.min_feat_rank = app.Rank_Slide.Value;

if length(app.map_idx)==1
    plot_idx = find(app.Overlap_Feature_idx==app.map_idx);
else
    plot_idx = find(ismember(app.Overlap_Feature_idx,app.map_idx));
end

if ~app.Comparing || strcmp(app.Image_Name_Label.Visible,'on')
    
    cla(app.Rel_Ax,'reset');
    
    point = roi.Position;
    current_map = app.map;

    % For single feature maps
    if length(app.map_idx)>1
        i_influence = zeros(1,length(app.map_idx));

        % Adjusting for ranked features
        if ~isempty(app.weighted_encodings)

            for i = 1:length(app.map_idx)
                if ~isnan(max(app.sep_feat_map{i}))
                    map_feat = app.feature_encodings.Feature_Names{app.map_idx(i)};
                    map_feat_rank = find(strcmp(map_feat, app.weighted_encodings.Feature_Names));
                    if map_feat_rank>=app.min_feat_rank
                        i_map = rescale(app.sep_feat_map{i});
                        i_region = i_map(floor(point(2))+1:floor(point(2)+point(4)),floor(point(1))+1:floor(point(1)+point(3)));

                        i_influence(1,i) = sum(sum(i_region))/(sum(sum(i_map)));
                    else
                        i_influence(1,i) = NaN;
                    end
                end
            end

        % Now without filtering out lower ranked features
        else
            for i = 1:length(app.map_idx)
                if ~isnan(max(app.sep_feat_map{i},[],'all'))
                    i_map = rescale(app.sep_feat_map{i});
                    i_region = i_map(floor(point(2))+1:floor(point(2)+point(4)),floor(point(1))+1:floor(point(1)+point(3)));

                    i_influence(1,i) = sum(sum(i_region))/(sum(sum(i_map)));
                end

            end
        end

        % Bar plot with feature names as the x-axis labels
        i_influence(isnan(i_influence)) = -Inf;
        bar(app.Rel_Ax, sort(i_influence,'descend'));
        xlabel(app.Rel_Ax,'Feature Index'), ylabel(app.Rel_Ax,'Feature Influence') 
        title(app.Rel_Ax,'Relative Feature Influence')

        i_influence(isinf(i_influence)) = NaN;
        table_info = cell(length(app.map_idx),2);
                
        table_info(:,1) = app.feature_encodings.Feature_Names(app.map_idx);
        i_influence(isnan(i_influence)) = -Inf;
        table_info(:,2) = num2cell(i_influence);

        table_info = cell2table(table_info, 'VariableNames',{'Feature','Value'});
        table_info = sortrows(table_info,'Value','descend');
        table_info.Value(isinf(table_info.Value)) = NaN;
        
        if ~isempty(app.weighted_encodings)
            % This gives "general" rankings, i.e. it is not in the same 
            % order as the input, it will just give the index that any member 
            % of one shows up in the other 
            ranks = find(ismember(app.weighted_encodings.Feature_Names,table_info.Feature));
            ranks_order = app.weighted_encodings.Feature_Names(ranks);
            
            align_table = cell2table([ranks_order,num2cell(ranks)],'VariableNames',{'Feature','Rank'});
            [table_info,rows_in_T] = innerjoin(table_info,align_table);
            [~,sortinds] = sort(rows_in_T);
            table_info = table_info(sortinds,:);

            app.Rel_Feat_Table.Data = table2cell(table_info);
            app.Rel_Feat_Table.ColumnName = {'Feature Name','Relative Area Contained','Feature Rank'};
        else           
            app.Rel_Feat_Table.Data = table2cell(table_info);
            app.Rel_Feat_Table.ColumnName = {'Feature Name','Relative Area Contained'};
        end
    else

        % Region around clicked point
        region = current_map(floor(point(2))+1:floor(point(2)+point(4)), floor(point(1))+1:floor(point(1)+point(3)));
        
        try
            [N, edges] = histcounts(categorical(region(:)),'Normalization','probability'); 
        catch
            [N, edges] = histcounts(unique(region(:)),'Normalization','probability');
        end
            
        %sel_edges = edges(1:end-1);
        sel_edges = edges(N>0);
        
        bar(app.Rel_Ax,linspace(0,1,length(sel_edges)),N(N>0))
        
        xlabel(app.Rel_Ax,'Feature Intensity'), ylabel(app.Rel_Ax,'Frequency')

        % Accounting for the case that the full feature set isn't provided
        if ~isempty(app.Full_Feature_set)
            title(app.Rel_Ax,['Histogram of:',app.Full_Feature_set.Properties.VariableNames(plot_idx),'around clicked region'])
            if ~isempty(app.weighted_encodings)
                feature = app.Full_Feature_set.Properties.VariableNames{plot_idx};
                rank = find(strcmp(app.weighted_encodings.Feature_Names,feature));
                subtitle(app.Rel_Ax,strcat('Feature Rank: ',string(rank)))
            end
        else
            title(app.Rel_Ax,'Histogram of Values in ROI')
            if ~isempty(app.weighted_encodings)
                feature = app.Full_Feature_set.Properties.VariableNames{plot_idx};
                rank = find(strcmp(app.weighted_encodings.Feature_Names,feature));
                subtitle(app.Rel_Ax,strcat('Feature Rank: ',string(rank)))
            end
            
        end
        
        try
            table_info(:,1) = cellfun(@str2num,sel_edges);
        catch
            table_info(:,1) = sel_edges;
        end
        table_info(:,2) = N(N>0)';

        app.Rel_Feat_Table.Data = table_info;
        app.Rel_Feat_Table.ColumnName = {'Feature Intensity Value', 'Frequency'};

    % Closing figure associated with bar plot and histograms
    try
        close(1)
    catch
        findobj('type','figure');
    end
    end
    
else
    % For comparisons of multiple images, generating blue and red plots
    % separately
    
    cla(app.Rel_Ax,'reset')
    point_red = app.red_roi.Position;
    point_blue = app.blue_roi.Position;
    
    if length(app.map_idx)>1
        
        i_influence_red = zeros(1,length(app.map_idx));
        i_influence_blue = zeros(1,length(app.map_idx));

        % Adjusting for ranked features
        if ~isempty(app.weighted_encodings)

            for i = 1:length(app.map_idx)
                map_feat = app.feature_encodings.Feature_Names{plot_idx(i)};
                map_feat_rank = find(strcmp(map_feat, app.weighted_encodings.Feature_Names));

                % Normalized here but could change to un-normalized to
                % compare them?
                if map_feat_rank>=app.min_feat_rank
                    if ~isnan(max(app.sep_feat_map{i,1},[],'all'))
                        i_map = rescale(app.sep_feat_map{i,1});
                    
                        i_region = i_map(floor(point_red(2))+1:floor(point_red(2)+point_red(4)),floor(point_red(1))+1:floor(point_red(1)+point_red(3)));

                        i_influence_red(1,i) = sum(sum(i_region))/(sum(sum(i_map)));
                    else
                        i_influence_red(1,i) = NaN;
                    end
                    if ~isnan(max(app.sep_feat_map{i,2},[],'all'))
                        i_map = rescale(app.sep_feat_map{i,2});
                        i_region = i_map(floor(point_blue(2))+1:floor(point_blue(2)+point_blue(4)),floor(point_blue(1))+1:floor(point_blue(1)+point_blue(3)));
                    
                        i_influence_blue(1,i) = sum(sum(i_region))/(sum(sum(i_map)));
                    else
                        i_influence_blue(1,i) = NaN;
                    end
                    
                end
            end

        % Now without filtering out lower ranked features
        else
            for i = 1:length(app.map_idx)
                if ~isnan(max(app.sep_feat_map{i},[],'all'))
                    i_map = rescale(app.sep_feat_map{i,1});
                    i_region = i_map(floor(point_red(2))+1:floor(point_red(2)+point_red(4)),floor(point_red(1))+1:floor(point_red(1)+point_red(3)));

                    i_influence_red(1,i) = sum(sum(i_region))/(sum(sum(i_map)));
                    
                    i_map = rescale(app.sep_feat_map{i,2});
                    i_region = i_map(floor(point_blue(2))+1:floor(point_blue(2)+point_blue(4)),floor(point_blue(1))+1:floor(point_blue(1)+point_blue(3)));

                    i_influence_blue(1,i) = sum(sum(i_region))/(sum(sum(i_map)));
                end

            end
        end

        % Bar plot with feature names as the x-axis labels
        i_influence_red(isnan(i_influence_red)) = -Inf;
        red_sorted = sort(i_influence_red,'descend');
        
        i_influence_blue(isnan(i_influence_blue)) = -Inf;
        blue_sorted = sort(i_influence_blue,'descend');
        
        combined_bar = bar(app.Rel_Ax,[blue_sorted',red_sorted']);
        
        xlabel(app.Rel_Ax,'Feature Index'), ylabel(app.Rel_Ax,'Feature Influence'), title(app.Rel_Ax,'Relative Feature Influence')

        i_influence_red(isinf(i_influence_red)) = NaN;
        table_info_red = cell(length(app.map_idx),2);
        
        i_influence_blue(isinf(i_influence_blue)) = NaN;
        table_info_blue = cell(length(app.map_idx),2);
                
        table_info_red(:,1) = app.feature_encodings.Feature_Names(plot_idx);
        i_influence_red(isnan(i_influence_red)) = -Inf;
        table_info_red(:,2) = num2cell(i_influence_red);
        table_info_blue(:,1) = app.feature_encodings.Feature_Names(plot_idx);
        i_influence_blue(isnan(i_influence_blue)) = -Inf;
        table_info_blue(:,2) = num2cell(i_influence_blue);

        table_info_red = cell2table(table_info_red, 'VariableNames',{'Feature','Value'});
        table_info_red = sortrows(table_info_red,'Value','descend');
        table_info_red.Value(isinf(table_info_red.Value)) = NaN;
        
        table_info_blue = cell2table(table_info_blue, 'VariableNames',{'Feature','Value'});
        table_info_blue = sortrows(table_info_blue,'Value','descend');
        table_info_blue.Value(isinf(table_info_blue.Value)) = NaN;

        if ~isempty(app.weighted_encodings)

            red_ranks = find(ismember(app.weighted_encodings.Feature_Names,table_info_red.Feature));
            blue_ranks = find(ismember(app.weighted_encodings.Feature_Names,table_info_blue.Feature));
        
            red_ranks_order = app.weighted_encodings.Feature_Names(red_ranks);
            align_table_red = cell2table([red_ranks_order,num2cell(red_ranks)],'VariableNames',{'Feature','Rank'});
            blue_ranks_order = app.weighted_encodings.Feature_Names(blue_ranks);
            align_table_blue = cell2table([blue_ranks_order,num2cell(blue_ranks)],'VariableNames',{'Feature','Rank'});

            [table_info_red,rows_in_red] = innerjoin(table_info_red,align_table_red);
            [table_info_blue,rows_in_blue] = innerjoin(table_info_blue,align_table_blue);
            [~,sort_red] = sort(rows_in_red);
            [~,sort_blue] = sort(rows_in_blue);

            table_info_red = table_info_red(sort_red,:);
            table_info_blue = table_info_blue(sort_blue,:);

            app.Rel_Feat_Table.Data = [table2cell(table_info_red),table2cell(table_info_blue)];
            app.Rel_Feat_Table.ColumnName = {'Red: Feature Name','Red: Relative Area Contained','Red: Ranks',...
                'Blue: Feature Name','Blue: Relative Area Contained','Blue: Ranks'};
        else
               
            app.Rel_Feat_Table.Data = [table2cell(table_info_red),table2cell(table_info_blue)];
            app.Rel_Feat_Table.ColumnName = {'Red: Feature Name','Red: Relative Area Contained', 'Blue: Feature_Name','Blue: Relative Area Contained'};
        end
    else

        % Region around clicked point
        red_map = app.map{1};
        blue_map = app.map{2};
        
        red_region = red_map(floor(point_red(2))+1:floor(point_red(2)+point_red(4)), floor(point_red(1))+1:floor(point_red(1)+point_red(3)));
        blue_region = blue_map(floor(point_blue(2))+1:floor(point_blue(2)+point_blue(4)), floor(point_blue(1))+1:floor(point_blue(1)+point_blue(3)));
        
        [red_N, red_edges] = histcounts(red_region(:),'Normalization','probability');
        red_edges = red_edges(1:end-1);
        red_edges = red_edges(red_N>0);
        
        red_N = red_N(red_N>0);
        
        [blue_N, blue_edges] = histcounts(blue_region(:),'Normalization','probability');
        blue_edges = blue_edges(1:end-1);
        blue_edges = blue_edges(blue_N>0);
        
        blue_N = blue_N(blue_N>0);
        
        % combined_edges = values that are in red_edges or blue_edges
        % i_red = indices of red_edges values in combined_edges
        % i_blue = indices of blue_edges values in combined_edges
        [combined_edges, i_red, i_blue] = union(single(red_edges),single(blue_edges)); 
        red_comb_edge = zeros(length(combined_edges),1);
        for r = 1:length(combined_edges)
            if ismembertol(combined_edges(r),single(red_edges),eps(combined_edges(r)))
                red_comb_edge(r) = red_N(find(single(red_edges)==single(combined_edges(r))));
            end
        end
        blue_comb_edge = zeros(length(combined_edges),1);
        for b = 1:length(combined_edges)
            if ismembertol(combined_edges(b),single(blue_edges), eps(combined_edges(b)))
                blue_comb_edge(b) = blue_N(find(single(blue_edges)==single(combined_edges(b))));
            end
        end
        
        combined_bar = bar(app.Rel_Ax,rescale(combined_edges),[red_comb_edge,blue_comb_edge],'LineWidth',1.5);
        combined_bar(1).FaceColor = 'r';
        combined_bar(2).FaceColor = 'b'; 
        
        legend(app.Rel_Ax,'Red ROI','Blue ROI')
        xlabel(app.Rel_Ax,'Feature Intensity'), ylabel(app.Rel_Ax,'Frequency')

        % Accounting for the case that the full feature set isn't provided
        if ~isempty(app.Full_Feature_set)
            title(app.Rel_Ax,strcat('Histogram of ', app.Full_Feature_set.Properties.VariableNames(plot_idx),' around clicked region'))
            
            if ~isempty(app.weighted_encodings)
                feature = app.Full_Feature_set.Properties.VariableNames{plot_idx};
                rank = find(strcmp(app.weighted_encodings.Feature_Names,feature));
                subtitle(app.Rel_Ax,strcat('Feature Rank: ',string(rank)))
            end
            
        else
            title(app.Rel_Ax,'Histogram of Values in ROI')
            if ~isempty(app.weighted_encodings)
                feature = app.Full_Feature_set.Properties.VariableNames{plot_idx};
                rank = find(strcmp(app.weighted_encodings.Feature_Names,feature));
                subtitle(app.Rel_Ax,strcat('Feature Rank: ',string(rank)))
            end
        end
        
        table_info(:,1) = rescale(combined_edges);
        table_info(:,2) = red_comb_edge;
        table_info(:,3) = rescale(combined_edges);
        table_info(:,4) = blue_comb_edge;
        
        
        app.Rel_Feat_Table.Data = table_info;
        app.Rel_Feat_Table.ColumnName = {'Red: Feature Intensity Value', 'Red: Frequency', 'Blue: Feature Intensity Value', 'Blue: Frequency'};
        
        % Closing figure associated with bar plot and histograms        
        try
            close(1)
        catch
            findobj('type','figure');
        end
    end
 
end


