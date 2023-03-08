% --- Function to prep data for classification models depending on if it is
% based off a single Train/Test split or a k-fold CV
function [train_data,test_data,test_labels,unlabeled_data] = Prep_Classification(app)

include_data = app.Full_Feature_set.(app.Structure_Idx_Name)(find(ismember(app.Full_Feature_set.(app.Structure_Idx_Name).ImgLabel,...
    app.Dist_Data.ImgLabel)),:);

class_data = include_data.Class;
imglabels = include_data.ImgLabel;
include_data.Class = [];
include_data.ImgLabel = [];

% Using the current features
if length(app.map_idx) == 1
    plot_idx = find(app.Overlap_Feature_idx.(app.Structure_Idx_Name)==app.map_idx);
else
    plot_idx = find(ismember(app.Overlap_Feature_idx.(app.Structure_Idx_Name),app.map_idx));
end

include_data = include_data(:,plot_idx);

% Normalizing 
include_data = normalize(include_data);
include_data = fillmissing(include_data,'constant',0);

% Testing for unlabeled samples (labeled "Unlabeled", I know)
unlabeled_idx = strcmp(class_data,'Unlabeled');
if any(unlabeled_idx)
    unlabeled_data = include_data(unlabeled_idx,:);
    include_data = include_data(~unlabeled_idx,:);

    unlabeled_imglabels = imglabels(unlabeled_idx);
    
    unlabeled_data.ImgLabel = unlabeled_imglabels;

    class_data = class_data(~unlabeled_idx);
    imglabels = imglabels(~unlabeled_idx);
else
    unlabeled_data = [];
end
    

include_data.Class = class_data;
include_data.ImgLabel = imglabels;

if app.TrainTestSplitButton.Value

    % One single train test split
   
    % Shuffling and picking training/testing set
    shuffle_idx = randperm(height(include_data));

    train_test_idx = floor(app.TrainTestSplitEditField.Value*height(include_data));
    train_data = include_data(shuffle_idx(1:train_test_idx),:);
    train_data.ImgLabel = [];

    test_data = include_data(shuffle_idx(train_test_idx:end),:);
    test_labels = test_data.ImgLabel;
    test_data.ImgLabel = [];
    
else

    train_data = include_data;
    test_labels = train_data.ImgLabel;
    train_data.ImgLabel = [];
    
    test_data = train_data;
end



