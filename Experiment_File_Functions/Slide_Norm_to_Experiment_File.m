% --- Function to write slide-level normalization parameters to HistoLens
% experiment file
function Slide_Norm_to_Experiment_File(app)

% Getting the experiment file name from the main path
experiment_file = app.Experiment_File;
% Reading in xml file as a struct
exp_struct = xml2struct(experiment_file);

% Extracting name of experiment
experiment_name = fieldnames(exp_struct);
experiment_name = experiment_name{1};

% Iterating through Slides and adding slide-level normalization
% parameters as a field
% slide-level normalization values are stored under
% app.Slide_NormVals.(slide_name) -->.Means and .Maxs
slide_names = fieldnames(app.Slide_NormVals);
n_slides = length(slide_names);
for i = 1:n_slides
    
    current_slide = slide_names{i};
    
    exp_struct.(experiment_name).SlideNormalization.(current_slide).SlideName = app.Slide_NormVals.(current_slide).SlideName;
    exp_struct.(experiment_name).SlideNormalization.(current_slide).Means = num2str(app.Slide_NormVals.(current_slide).Means);
    exp_struct.(experiment_name).SlideNormalization.(current_slide).Maxs = num2str(app.Slide_NormVals.(current_slide).Maxs);

end

struct2xml(exp_struct,experiment_file)







