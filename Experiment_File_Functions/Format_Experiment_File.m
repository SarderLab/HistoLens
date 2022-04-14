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
for i = fieldnames(app.Structure_Names)
    structure = i{1};
    Experiment_Struct.(experiment_name).Structure.(structure).AnnotationID = app.Structure_Names.(structure).Annotation_ID;
    
    if ~isempty(main_app.MPP)
        Experiment_Struct.(experiment_name).Structure.(structure).MPP = app.MPP;
    else
        Experiment_Struct.(experiment_name).Structure.(structure).MPP = [];
    end
    
    %Experiment_Struct.(experiment_name).Structure.(structure).CompartmentSegmentation = strcat(structure,'_Comp_Seg.m');
    if ismember('Stain',fieldnames(app.Seg_Params.(structure)))
        Experiment_Struct.(experiment_name).Structure.(structure).CompartmentSegmentation.Stain = app.Seg_Params.(structure).Stain;
        Experiment_Struct.(experiment_name).Structure.(structure).CompartmentSegmentation.PAS = app.Seg_Params.(structure).PAS;
        Experiment_Struct.(experiment_name).Structure.(structure).CompartmentSegmentation.Luminal = app.Seg_Params.(structure).Luminal;
        Experiment_Struct.(experiment_name).Structure.(structure).CompartmentSegmentation.Nuclei = app.Seg_Params.(structure).Nuclei;
    end
    if ismember('Colorspace',fieldnames(app.Seg_Params.(structure)))
        Experiment_Struct.(experiment_name).Structure.(structure).CompartmentSegmentation.Colorspace = app.Seg_Params.(structure).Colorspace;
        Experiment_Struct.(experiment_name).Structure.(structure).CompartmentSegmentation.PAS = app.Seg_Params.(structure).PAS;
        Experiment_Struct.(experiment_name).Structure.(structure).CompartmentSegmentation.Luminal = app.Seg_Params.(structure).Luminal;
        Experiment_Struct.(experiment_name).Structure.(structure).CompartmentSegmentation.Nuclei = app.Seg_Params.(structure).Nuclei;
    end
    
    for j = fieldnames(app.Seg_Params.(structure))
        seg_field = j{1};
        Experiment_Struct.(experiment_name).Structure.(structure).CompartmentSegmentation.(seg_field) = app.Seg_Params.(structure).(seg_field);
    end

    if ismember('StainNormalization',fieldnames(app.Seg_Params.(structure)))
        
        Experiment_Struct.(experiment_name).Structure.(structure).StainNormalization.Means = num2str(app.Seg_Params.(structure).StainNormalization.Means);
        Experiment_Struct.(experiment_name).Structure.(structure).StainNormalization.Maxs = num2str(app.Seg_Params.(structure).StainNormalization.Maxs);

    end
         
    Experiment_Struct.(experiment_name).Structure.(structure).FeatureSet = strcat(app.Slide_Path,filesep,structure,'_Features.csv');
end

% Writing Experiment_Struct to an .xml file
struct2xml(Experiment_Struct,strcat(experiment_name,'_HistoLens_Experiment_File.xml'))
main_app.Experiment_File = strcat(experiment_name,'_HistoLens_Experiment_File.xml');


