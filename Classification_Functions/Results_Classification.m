% --- Function to generate performance plots and reports on trained models
function Results_Classification(app,test_data,test_labels,predictions)

if ~isnumeric(app.Dist_Data.Class)
    % Erase previous confusion matrix
    child = get(app.ClassificationResultsTab,'Children');
    set(child(isprop(child,'Visible')),'Visible','off')
    app.Confusion_Matrix = [];

    try
        app.Confusion_Matrix = confusionchart(app.ClassificationResultsTab,...
            test_data.Class,predictions,"ColumnSummary",'column-normalized','RowSummary','row-normalized');
    catch
        delete(app.Performance_Axes)
        delete(app.Performance_Violinplot)
        app.Confusion_Matrix = confusionchart(app.ClassificationResultsTab,...
            test_data.Class,predictions,"ColumnSummary",'column-normalized','RowSummary','row-normalized');   
    end

else

    % Erase previous confusion matrix
    child = get(app.ClassificationResultsTab,'Children');
    set(child(isprop(child,'Visible')),'Visible','off')
    app.Confusion_Matrix = [];

    pred_diff = predictions-test_data.Class;
    
    % Initializing Performance_Axes
    if ~ishandle(app.Performance_Axes)
        app.Performance_Axes = uiaxes('Parent',app.ClassificationResultsTab);
    else
        app.Performance_Axes.Visible = 'on';
        cla(app.Performance_Axes)
    end
    axes(app.Performance_Axes)
    app.Performance_Violinplot = violinplot(pred_diff);
    title('Difference between Predicted Value and Actual'),ylabel('Difference')
end

% Generating classification performance metrics
if ~isnumeric(app.Dist_Data.Class)
    % categorical classification metrics
    % Accuracy, F1, TPR, FPR, Recall, Precision
    confusion_matrix = confusionmat(test_data.Class,predictions);
    
    TP_class = diag(confusion_matrix);

    Accuracy_class = zeros(size(confusion_matrix,1),1);
    F1_class = zeros(size(confusion_matrix,1),1);
    Precision_class = zeros(size(confusion_matrix,1),1);
    Recall_class = zeros(size(confusion_matrix,1),1);

    for c = 1:size(confusion_matrix,1)
        TP = TP_class(c);
        FP = sum(confusion_matrix(:,c),1)-TP;
        FN = sum(confusion_matrix(c,:),2)-TP;
        TN = sum(confusion_matrix(:))-TP-FP-FN;

        Accuracy_class(c) = (TP+TN)./(TP+FP+TN+FN);
        Precision_class(c) = TP./(TP+FP);
        Recall_class(c) = TP./(TP+FN);
        F1_class(c) = (2*TP)/(2*TP+FP+FN);
    end

    classes = unique(test_data.Class);
    [~,test_class_idx] = ismember(test_data.Class,classes);
    [~,pred_class_idx] = ismember(predictions,classes);

    app.Performance_Metrics.TP = TP_class;
    app.Performance_Metrics.Accuracy = Accuracy_class;
    app.Performance_Metrics.Precision = Precision_class;
    app.Performance_Metrics.Recall = Recall_class;
    app.Performance_Metrics.F1 = F1_class;

else
    % Quantitative classification metrics
    % MSE, MAE, R-squared, Adjusted R-squared
    
    diff = test_data.Class-predictions;
    MSE = mean(diff.^2,'all','omitnan');
    MAE = mean(abs(diff),'all','omitnan');

    if isprop(app.Current_Model,'Rsquared')
        R_squared = app.Current_Model.Rsquared.Ordinary;
    else
        R_squared = 1-(sum(diff.^2)/sum((test_data.Class-mean(predictions)).^2));
    end

    app.Performance_Metrics.MSE = MSE;
    app.Performance_Metrics.MAE = MAE;
    app.Performance_Metrics.R_squared = R_squared;
    
end

% Populating the Performance_Table
performance_data = [{cell(1),'Metric Value Per Class'},cell(1,length(unique(test_data.Class))-1)];
if ~isnumeric(test_data.Class)
    performance_data = [{'Metric Name'},unique(test_data.Class)'];
else
    performance_data = [{'Metric Name'},{'Value'}];
end
metrics = fieldnames(app.Performance_Metrics);
for m = 1:length(metrics)
    current_name = metrics{m};
    current_val = app.Performance_Metrics.(current_name)';

    performance_data = [performance_data;[current_name,strsplit(num2str(current_val),' ')]];
end


% Getting the current slide-names
current_slides = cellfun(@(x)strsplit(x,'_'),test_labels,'UniformOutput',false);
if length(current_slides(1))>2
    current_slides = cellfun(@(x)strjoin(x{1:end-1},'_'),current_slides,'UniformOutput',false);
else
    current_slides = cellfun(@(x)x{1},current_slides,'UniformOutput',false);
end

if ~isnumeric(test_data.Class)
    unique_slides = unique(current_slides);
    %all_slide_preds = cell(length(unique_slides)+1,length(unique(test_data.Class))+1);

    all_slide_preds(1,:) = [{'Slide Name'},unique(test_data.Class)',{'Ground Truth'}];
    for j = 1:length(unique_slides)

        this_slide = unique_slides(j);
        slide_idx = find(strcmp(current_slides,this_slide));

        slide_class = test_data.Class(slide_idx);

        slide_confusionmat = confusionmat(slide_class,predictions(slide_idx),'Order',unique(test_data.Class)');
        if size(slide_confusionmat,1)==1
            slide_predictions = zeros(1,length(unique(test_data.Class)));
            slide_predictions(find(ismember(slide_class{1},unique(test_data.Class)))) = slide_confusionmat;
        else
            slide_predictions = sum(slide_confusionmat,1);
        end
        
        all_slide_preds(j+1,:) = [this_slide,strsplit(num2str(slide_predictions),' '),slide_class(1)];

    end

    if size(all_slide_preds,2)>size(performance_data,2)
        n_metrics = length(fieldnames(app.Performance_Metrics));
        col_diff = size(all_slide_preds,2)-size(performance_data,2);

        performance_data = [performance_data,cell(n_metrics+1,col_diff);all_slide_preds];
    else
        performance_data = [performance_data;all_slide_preds];
    end
else
    % For quantitative class values, report the distribution of predictions
    % and actuals
    % Recording min, mean, standard deviation, median, max
    unique_slides = unique(current_slides);
    %all_slide_preds = cell(length(unique_slides)+1,7);
    all_slide_preds(1,:) = [{'Slide Name'},{'Min'},{'Mean'},{'Std Dev'},{'Med'},{'Max'},{'Ground Truth'}];
    for j = 1:length(unique_slides)

        this_slide = unique_slides(j);
        slide_idx = find(strcmp(current_slides,this_slide));
        true_label = test_data.Class(slide_idx);

        slide_vals = predictions(slide_idx);
        slide_min = min(slide_vals,[],'all','omitnan');
        slide_mean = mean(slide_vals,'all','omitnan');
        slide_stddev = std(slide_vals,'omitnan');
        slide_med = median(slide_vals,'all','omitnan');
        slide_max = max(slide_vals,[],'all','omitnan');
        
        all_slide_preds(j+1,:) = [this_slide,strsplit(num2str([slide_min,slide_mean,slide_stddev,slide_med,slide_max]),' '),num2str(true_label(1))];

    end
    
    if size(all_slide_preds,2)>size(performance_data,2)
        n_metrics = length(fieldnames(app.Performance_Metrics));
        col_diff = size(all_slide_preds,2)-size(performance_data,2);

        performance_data = [performance_data,cell(n_metrics+1,col_diff);all_slide_preds];
    else
        performance_data = [performance_data;all_slide_preds];
    end
    
end

% Saving training/testing prediction labels to use as labels
full_imglabels = app.Dist_Data.ImgLabel;
full_class = app.Dist_Data.Class;
% Getting the training samples and their labels
train_idx = find(~ismember(full_imglabels,test_labels));
train_imglabels = full_imglabels(train_idx);
train_class = full_class(train_idx);

test_imglabels = test_labels;

if ~isnumeric(full_class)
    train_sample_labels = cellfun(@(x) strjoin([{'Train'},x],' '),train_class,'UniformOutput',false);
    test_sample_labels = cellfun(@(x) strjoin([{'Predicted'},x],' '),predictions,'UniformOutput',false);
else
    train_sample_labels = cellfun(@(x) strjoin([{'Train'},x],' '),cellstr(num2str(train_class)),'UniformOutput',false);
    test_sample_labels = cellfun(@(x) strjoin([{'Predicted'},x],' '),cellstr(num2str(predictions)),'UniformOutput',false);
end

app.Current_Model_Labels = table([train_imglabels;test_imglabels],[train_sample_labels;test_sample_labels],...
    'VariableNames',{'ImgLabel','Class'});

app.AddCurrentModelPredictedLabelsButton.Enable = 'on';
    
app.Performance_Table.Data = performance_data;
Generate_Performance_Report(app,test_labels,test_data.Class,predictions)

