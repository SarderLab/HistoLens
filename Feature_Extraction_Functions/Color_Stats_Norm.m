% --- Function to calculate impact of dynamic stain normalization on color
% statistics in specific sub-compartments
function Color_Stats_Norm(app)

% Color features recorded in app.Full_Feature_set.(app.Structure) are based
% on global normalization values (which are also used in segmentation).

% Compartment mask stored in app.Comp_Img

% This covers whether app.Comparing or not
means_raw_and_norm = zeros(3*3,2*length(app.Current_Img));
stds_raw_and_norm = zeros(3*3,2*length(app.Current_Img));
column_names = [];

for img = 1:length(app.Current_Img)
    
    raw_img = reshape(app.Current_Img{img},[],3);
    comp_img = reshape(app.Comp_Img{img},[],3);
    norm_img = reshape(app.Current_NormImg{img},[],3);

    % Iterating through sub-compartments
    mean_raw_vector = zeros(3,3);
    std_raw_vector = zeros(3,3);

    mean_norm_vector = zeros(3,3);
    std_norm_vector = zeros(3,3);
    for comp = 1:3
        
        % Setting pixels outside of the current compartment = Nan
        masked_raw = raw_img;
        masked_raw = masked_raw(find(comp_img(:,comp)==1),:);

        masked_norm = norm_img;
        masked_norm = masked_norm(find(comp_img(:,comp)==1),:);

        % Calculating mean and standard deviation of RGB values for both
        % raw color and norm
        mean_raw_vector(comp,:) = mean(masked_raw,1,'omitnan');
        std_raw_vector(comp,:) = std(double(masked_raw),1,'omitnan');
        mean_norm_vector(comp,:) = mean(masked_norm,1,'omitnan');
        std_norm_vector(comp,:) = std(double(masked_norm),1,'omitnan');
    end

    means_raw_and_norm(:,2*(img-1)+1) = reshape(mean_raw_vector',[],1);
    stds_raw_and_norm(:,2*(img-1)+1) = reshape(std_raw_vector',[],1);

    means_raw_and_norm(:,2*(img-1)+2) = reshape(mean_norm_vector',[],1);
    stds_raw_and_norm(:,2*(img-1)+2) = reshape(std_norm_vector',[],1);

    if isempty(column_names)
        column_names = {'Image 1 Raw RGB','Image 1 Norm'};
    else
        column_names = [column_names,{'Image 2 Raw RGB','Image 2 Norm'}];
    end
    
end


app.NormColorTable.Data = [means_raw_and_norm;stds_raw_and_norm];
app.NormColorTable.ColumnName = column_names;
removeStyle(app.NormColorTable)

% Adding color if the difference is positive or negative
if length(app.Current_Img)==1
    %diffs = app.NormColorTable.Data(:,1)-app.NormColorTable.Data(:,2);
    
    %[green_row,green_col] = find(diffs>0);
    %[red_row,red_col] = find(diffs<0);
    
    maxes = max(app.NormColorTable.Data(:,1:2),[],2);
    [green_row,green_col] = find(app.NormColorTable.Data==maxes);

    s_green = uistyle('BackgroundColor','green');
    addStyle(app.NormColorTable,s_green,'cell',[green_row,green_col])
    %s_red = uistyle('BackgroundColor','red');
    %addStyle(app.NormColorTable,s_red,'cell',[red_row,red_col])
else

    %diffs(:,1) = app.NormColorTable.Data(:,1)-app.NormColorTable.Data(:,2);
    %diffs(:,3) = app.NormColorTable.Data(:,3)-app.NormColorTable.Data(:,4);

    %[green_row,green_col] = find(diffs>0);
    %[red_row,red_col] = find(diffs<0);

    maxes(:,1) = max(app.NormColorTable.Data(:,1:2),[],2);
    maxes(:,2) = max(app.NormColorTable.Data(:,3:4),[],2);

    [row,col] = find(app.NormColorTable.Data==maxes(:,1));
    green_row = row;
    green_col = col;
    [row,col] = find(app.NormColorTable.Data==maxes(:,2));
    green_row = [green_row;row];
    green_col = [green_col;col];
    s_green = uistyle('BackgroundColor','green');
    addStyle(app.NormColorTable,s_green,'cell',[green_row,green_col])
    %s_red = uistyle('BackgroundColor','red');
    %addStyle(app.NormColorTable,s_red,'cell',[red_row,red_col])
end

% Adding color to the example compartment color tab
Example_Comp_Color(app)


