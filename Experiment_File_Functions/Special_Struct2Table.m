% --- Function for loading specially prepared table from experiment struct
function feature_table = Special_Struct2Table(feature_struct)

column_ids = fieldnames(feature_struct);
feature_table = table();
for col = 1:length(column_ids)
    current_column = column_ids{col};
    feature_name = char(feature_struct.(current_column).Name);
    col_data = strsplit(feature_struct.(current_column).Data,',')';
    
    if ~all(isnan(str2double(col_data)),'all')
        col_data = num2cell(str2double(col_data));
    else
        col_data = cellstr(col_data);
    end
    sub_table = cell2table(col_data,"VariableNames",{feature_name});

    feature_table = [feature_table,sub_table];

end

