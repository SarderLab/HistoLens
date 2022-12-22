% --- Function that improves memory requirements of table2struct
function new_tablestruct = Special_Table2Struct(feature_table)

% Pull data from each row of the feature table, convert to strings, convert
% to cellstr, strjoin with ',' delimeter, and store data and original
% column name separately
variable_names = feature_table.Properties.VariableNames;
for i = 1:width(feature_table)
    current_var = variable_names{i};
    col_name_string = strcat('Column_',num2str(i));
    
    % Replace empties first
    pre_col_data = cellstr(string(feature_table.(current_var)));
    pre_col_data(find(cellfun(@isempty,pre_col_data))) = {'NaN'};
    col_data = strjoin(pre_col_data,',');
    new_tablestruct.(col_name_string).Name = current_var;
    new_tablestruct.(col_name_string).Data = col_data;
end


