% --- Function for saving model along with important model information
function Save_Model(app)

% Stuff to save: (1) Model itself (as Matlab object), (2) Performance
% Report, (3) Samples used in training, (4) Class/label classified, (5)
% Model hyperparameters, (6) Features used in model

% Performance report will include model classification/regression
% performance, samples used in testing, class/label, and features used

% Model object will have model and model parameters

%% Getting model path and create folder

model_type = class(app.Current_Model);
slide_dir = app.Slide_Path;

t = now;
d = datetime(t,'ConvertFrom','datenum');
current_time = strrep(strrep(string(d),' ','__'),':','_');

model_dir = strcat(slide_dir,filesep,'HistoLens_Models_Archive',filesep);
if ~exist(model_dir,'dir')
    mkdir(model_dir)
end

model_filename = strcat(model_dir,model_type,'_',current_time,filesep);
if ~exist(model_filename,'file')
    mkdir(model_filename)
end

%% Saving model as Matlab object
model = app.Current_Model;
save(strcat(model_filename,model_type,'.mat'),'model')

%% Saving model report
% Save performance report
writecell(app.Performance_Report.Model_Performance,strcat(model_filename,model_type,'_Info.xlsx'),'Sheet','Model Performance')
writetable(app.Performance_Report.Test_Samples,strcat(model_filename,model_type,'_Info.xlsx'),'Sheet','Test Samples')
writematrix(app.Performance_Report.ClassLabel,strcat(model_filename,model_type,'_Info.xlsx'),'Sheet','Class Label')
writecell(app.Performance_Report.FeaturesUsed,strcat(model_filename,model_type,'_Info.xlsx'),'Sheet','Features Used')








