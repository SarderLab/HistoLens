%% --- Function that updates the stain that an uploaded segmentation network will function on
function Update_Sem_Stain(obj,event,app)

% Getting the semantic segmentation model from the current tab
sem_model = app.SemanticOptionsTabGroup.SelectedTab;
sem_model_name = sem_model.Title;

% Finding index of this semantic segmentation model
all_sem_models = cell(1,length(fieldnames(app.Semantic_Sub_Compartment_Details)));
for i = 1:length(fieldnames(app.Semantic_Sub_Compartment_Details))
    all_sem_models(i) = app.Semantic_Sub_Compartment_Details;
end












