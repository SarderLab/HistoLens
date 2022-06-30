% --- Function to generate performance report
function Generate_Performance_Report(app,test_samples,test_labels,predictions)

% Generate report containing test samples, model performance metrics,
% class/label used in classification, and features used

% Writing all as different sheets in excel spreadsheet

%% Getting model performance
model_performance = app.Performance_Table.Data;

%% Class/Label used in classification
class_label = app.SelectLabelDropDown.Value;

%% Test samples info
test_data = table(test_samples,test_labels,predictions,'VariableNames',{'ImgLabel','GroundTruth','Predicted'});


%% Features used

% Using the current features
if length(app.map_idx) == 1
    plot_idx = find(app.Overlap_Feature_idx.(app.Structure)==app.map_idx);
else
    plot_idx = find(ismember(app.Overlap_Feature_idx.(app.Structure),app.map_idx));
end

features_used = app.Full_Feature_set.(app.Structure).Properties.VariableNames(plot_idx);

%% Adding to performance report struct
app.Performance_Report.Model_Performance = model_performance;
app.Performance_Report.Test_Samples = test_data;
app.Performance_Report.ClassLabel = class_label;
app.Performance_Report.FeaturesUsed = features_used';


