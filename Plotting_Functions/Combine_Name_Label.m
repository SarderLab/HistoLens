% --- Function to combine image names and labels together for list box
function combined = Combine_Name_Label(app, image_paths, dist_values)
    
img_names = image_paths;
    
combined = cell(length(img_names),1);
for i = 1:length(img_names)
    name = img_names{i};
    label = app.Full_Feature_set.(app.Structure).Class(strcmp(app.Full_Feature_set.(app.Structure).ImgLabel,name));
    if iscell(label)
        label = label{1};
    end
    
    if ~isempty(dist_values)
        value = string(dist_values(i));
        if isnumeric(label)
            if ~any(isempty([name,label,value]))&&~any(ismissing([name,label,value]))
                comb = strcat(name,',',num2str(label),',',value);
            else
                miss_idx = ~ismissing([name,label,value]);
                data_array = [name,label,value];
                comb = strjoin(data_array(find(miss_idx)),',');
            end
            
        else

            if ~any(isempty([name,label,value]))&&~any(ismissing([name,label,value]))
                comb = strcat(name,',',label,',',value);
            else
                miss_idx = ~ismissing([name,label,value]);
                data_array = [name,label,value];
                comb = strjoin(data_array(find(miss_idx)),',');
                
            end
        end
        
        combined{i} = comb{1};
    else
        if isnumeric(label)
            comb = strcat(name,',',num2str(label));
        else
            comb = strcat(name,',',label);
        end
        combined{i} = comb;
    end
end

