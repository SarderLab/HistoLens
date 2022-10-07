% --- Function to enable buttons after images are loaded
%function Enable_Butts(hObject, eventdata, handles)
function Enable_butts(app,event)

app.Comp_List.Enable = 'on';
app.Feat_List.Enable = 'on';
app.Spec_List.Enable = 'on';

app.Prev_Butt.Enable = 'on';
app.Next_Butt.Enable = 'on';
app.View_Comp.Enable = 'on';
app.View_Feat_Type.Enable = 'on';
app.View_Spec_Feat.Enable = 'on';

app.Image_Name_Label.Enable = 'on';

app.SimilarityThresholdSpinner.Enable = 'on';
%app.SimilarityThresholdSpinner.Enable = 'on';
app.TextureWindowSizeEditField.Enable = 'on';

% Keep not-enabled until working
app.AddLabelButton.Enable = 'on';
app.Select_New_Butt.Enable = 'on';
app.SelectSinglePointButton.Enable = 'on';
app.ExamplesEditField.Enable = 'on';
app.SelectPointsAlongLineButton.Enable = 'on';
app.DownloadDistributionDataButton.Enable = 'on';
app.RemoveOutliersCheckBox.Enable = 'on';


app.AddLabelButton.Enable = 'on';
app.RemoveLabelButton.Enable = 'on';
app.SearchNotesFileButton.Enable = 'on';

% Annotation tab
app.AddNewClasstoListEditField.Enable = 'on';
app.UITable5.Enable = 'on';

% Subsetting and labeling tab group
app.SelectLabelDropDown.Enable = 'on';
app.Tree.Enable = 'on';
app.SubsetDataButton.Enable = 'on';

% Classification tab
children = get(app.ClassificationModelsTab,'Children');
set(children(isprop(children,'Enable')),'Enable','on')
models = get(app.ModelsTabGroup,'Children');
for c = 1:length(models)
    grandchildren = get(models(c),'Children');
    set(grandchildren(isprop(grandchildren,'Enable')),'Enable','on')
end

% Add Labels tab
app.AddSlideLabelfromFileButton.Enable = 'on';
app.AddStructureLabelfromFileButton.Enable = 'on';

% Enabling Normalization Labels tab
app.MetadataLabelDropDown.Enable = 'on';
app.SubClassDropDown.Enable = 'on';
app.ViewNormalizedButton.Enable = 'on';

% Enabling compartment segmentation check button
app.GenerateCompartmentSegmentationCheckButton.Enable = 'on';

% Enabling Pause Visualization checkbox
app.PauseVisualizationCheckBox.Enable = 'on';
