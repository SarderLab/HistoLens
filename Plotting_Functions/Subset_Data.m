% --- Function to subset data based on checked boxes 
function data_ind = Subset_Data(app,event)

data_ind = ones(height(app.Full_Feature_set.(app.Structure)),1);

if ~isempty(app.Subset_Master)
    if ~isempty(app.Subset_Master.(app.Structure))
        % Parent nodes in app.Subset_Master
        parent_nodes = {app.Subset_Master.(app.Structure).Parent};
        parent_nodes = cellfun(@(x) x.Text,parent_nodes,'UniformOutput',false);
        
        for j = 1:length(app.Subset_Master.(app.Structure))
            
            remove_label = app.Subset_Master.(app.Structure)(j).Text;

            % Updating Plot_Options after removing label
            if ~isempty(app.Plot_Options)
                if ismember('LabelOrder',fieldnames(app.Plot_Options))
                    app.Plot_Options.LabelOrder(find(strcmp(remove_label,app.Plot_Options.LabelOrder))) = [];
                end
            end
    
            ind_labels = app.Aligned_Labels.(app.Structure).(parent_nodes{j}).Aligned;
            % Finding overlap with existing ignored labels
            [T,rows_in_T] = innerjoin(ind_labels,app.Ignore_idx.(app.Structure));
            [~,sortinds] = sort(rows_in_T);
            ign_labels = T(sortinds,:);
    
            [T,rows_in_T] = innerjoin(table(app.Full_Feature_set.(app.Structure).ImgLabel,'VariableName',{'ImgLabel'}),...
                ign_labels);
            [~,sortinds] = sort(rows_in_T);
            ign_labels = T(sortinds,:);
            
            % ign_labels contains labels that overlap with those in
            % app.Aligned_Labels.(class_opts{j}).Aligned and those in
            % app.Ignore_idx.  If a sample does not have the same label as
            % the un-checked and it is not in the app.Ignore_idx from a
            % previous subsetting or notes operation then it stays.  
                
            % Check type of label
            if isnumeric(ind_labels.Class)
                
                % Numeric labels are subset according to quartiles
                first_val = strsplit(remove_label,'<');
                first_val = first_val{1};
                first_val = str2num(first_val);
                sec_val = strsplit(remove_label,'=');
                sec_val = sec_val{end};
                sec_val = str2num(sec_val);
    
                data_ind(find(ign_labels.Class>=first_val & ign_labels.Class<=sec_val)) = 0;
                data_ind(find(ign_labels.Ignore)) = 0;
    
            else
                data_ind(find(ismember(ign_labels.Class,remove_label) | ign_labels.Ignore)) = 0;
    
            end            
                
        end
    
    else
    
        data_labels = app.Full_Feature_set.(app.Structure).ImgLabel;
        [data_aligned,rows_in_T] = innerjoin(app.Ignore_idx.(app.Structure),cell2table(data_labels,'VariableNames',{'ImgLabel'}));
        [~,sortinds] = sort(rows_in_T);
        
        class_data_ind = data_aligned(sortinds,:);
        data_ind(find(class_data_ind.Ignore)) = 0;
        
    end
else
    data_labels = app.Full_Feature_set.(app.Structure).ImgLabel;
    
    
    [data_aligned,rows_in_T] = innerjoin(app.Ignore_idx.(app.Structure),cell2table(data_labels,'VariableNames',{'ImgLabel'}));
    [~,sortinds] = sort(rows_in_T);
    
    class_data_ind = data_aligned(sortinds,:);
    data_ind(find(class_data_ind.Ignore)) = 0;

end
