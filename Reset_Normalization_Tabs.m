% --- Function to transition from one image (or images) to another and
% clear out all the normalization information
function Reset_Normalization_Tabs(app)

% Clearing the Impact of Normalization table
app.NormColorTable.Data = [];

% Clearing Example Color Patches
cla(app.PASExample_Axes)
cla(app.LumExample_Axes)
cla(app.NucExample_Axes)

% Enabling View Normalized
app.ViewNormalizedButton.Enable = 'on';
app.ViewRawRGBButton.Enable = 'off';

