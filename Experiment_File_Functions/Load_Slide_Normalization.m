% --- Function to load slide normalization values if they are present in
% experiment file
function slide_norm_struct = Load_Slide_Normalization(norm_struct)

for i = 1:3
    row_means = str2double(strsplit(norm_struct.Means.(strcat('Row_',num2str(i))),','));
    row_means = row_means(~isnan(row_means));
    row_maxs = str2double(strsplit(norm_struct.Maxs.(strcat('Row_',num2str(i))),','));
    row_maxs = row_maxs(~isnan(row_maxs));
    means_nums(i,:) = row_means;
    max_nums(i,:) = row_maxs;
end

slide_norm_struct.Means = means_nums;
slide_norm_struct.Maxs = max_nums;


