% --- Function to check Dist_Data to modify options available in
% Classification Models tab
function Check_Classification(app)

app.SaveModelButton.Enable = 'off';
app.GeneratePerformanceReportButton.Enable = 'off';
app.AddCurrentModelPredictedLabelsButton.Enable = 'off';

% Classification tab
children = get(app.ClassificationModelsTab,'Children');
set(children(isprop(children,'Enable')),'Enable','on')
models = get(app.ModelsTabGroup,'Children');
for c = 1:length(models)
    grandchildren = get(models(c),'Children');
    set(grandchildren(isprop(grandchildren,'Enable')),'Enable','on')
end

% Enable train/test split and 5-fold CV buttons
app.TrainTestSplitButton.Enable = 'on';
app.TrainTestSplitEditField.Enable = 'on';
app.kfoldCrossValidationButton.Enable = 'on';

% Erase previous confusion matrix
child = get(app.ClassificationResultsTab,'Children');
set(child(isprop(child,'Visible')),'Visible','off')
app.Confusion_Matrix = [];
app.Performance_Metrics = [];
app.Performance_Table.Data = [];
if ishandle(app.Performance_Axes)
    cla(app.Performance_Axes)
end


% Check data type of classes (0 for non-numeric, 1 for numeric)
label_isnumeric = isnumeric(app.Full_Feature_set.Class);

% Numeric properties
if label_isnumeric    
    % Decision tree parameters
    app.MaxNumberofCategoriesEditField.Enable = 'on';

    app.FitNeuralNetworkButton.Enable = 'off';

else
    % Decision tree parameters
    app.MaxNumberofCategoriesEditField.Enable = 'off';

    app.FitNeuralNetworkButton.Enable = 'on';


end


% Other model-specific parameters

% Decision Trees
app.MaxNumberofSplitsEditField.Limits = [0,height(app.Dist_Data)];
app.OpenClassificationTreeViewerButton.Enable = 'off';

% Neural Networks
app.NN_Layer_Dims = 10;
app.LayerNameDropDown.Items = {'Layer 1'};
app.LayerNameDropDown.Value = app.LayerNameDropDown.Items(1);
app.LayerSizeEditField.Value = app.NN_Layer_Dims(1);

