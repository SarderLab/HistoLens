% --- Function to organize Catch n Release experiment file
function Format_Experiment_File(app,main_app)

% Key information:
%   Slide directory
%   Structure Names,Annotation IDs, structure compartment segmentation
%   scripts
%   Path to feature set (structure-level)

experiment_name = strsplit(app.Slide_Path,filesep);
experiment_name = experiment_name{end};
experiment_name = strrep(experiment_name,' ','_');

% Experiment struct with slide directory
Experiment_Struct.(experiment_name).Slide_Directory = app.Slide_Path;

% Adding structure names and annotation IDs
structures = fieldnames(app.Structure_Names);

for i = 1:length(structures)
    structure = structures{i};
    Experiment_Struct.(experiment_name).Structure.(structure).AnnotationID = app.Structure_Names.(structure).Annotation_ID;
    
    if ~isempty(main_app.MPP)
        Experiment_Struct.(experiment_name).Structure.(structure).MPP = app.MPP;
    else
        Experiment_Struct.(experiment_name).Structure.(structure).MPP = [];
    end
    
    slide_names = fieldnames(app.Seg_Params.(structure));
    for slide = 1:length(slide_names)
        current_slide = slide_names{slide};
        if ~strcmp(current_slide,'StainNormalization')
            Experiment_Struct.(experiment_name).Structure.(structure).(current_slide).SlideName = app.Seg_Params.(structure).(current_slide).SlideName;
            Experiment_Struct.(experiment_name).Structure.(structure).(current_slide).CompartmentSegmentation = app.Seg_Params.(structure).(current_slide).CompartmentSegmentation;
        end
        if ismember('StainNormalization',fieldnames(app.Seg_Params.(structure)))
            
            Experiment_Struct.(experiment_name).Structure.(structure).StainNormalization.Means = num2str(app.Seg_Params.(structure).StainNormalization.Means);
            Experiment_Struct.(experiment_name).Structure.(structure).StainNormalization.Maxs = num2str(app.Seg_Params.(structure).StainNormalization.Maxs);
    
        end
    end
         
    Experiment_Struct.(experiment_name).Structure.(structure).FeatureSet = strcat(app.Slide_Path,filesep,structure,'_Features.csv');
end

% Writing Experiment_Struct to an .xml file
%struct2xml(Experiment_Struct,strcat(experiment_name,'_HistoLens_Experiment_File.xml'))
%main_app.Experiment_File = strcat(experiment_name,'_HistoLens_Experiment_File.xml');
display(strcat('Saving experiment file to:',strcat(app.Slide_Path,filesep,app.Experiment_File),'.xml'))
struct2xml(Experiment_Struct,strcat(app.Slide_Path,filesep,app.Experiment_File,'.xml'))
main_app.Experiment_File = strcat(app.Slide_Path,filesep,app.Experiment_File,'.xml');

