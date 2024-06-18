%--- Function to generate default segmentation parameters for initializing
%compartment segmentation
function Get_Default_Params(app)

selectedButton = app.SegmentationMethodButtonGroup.SelectedObject;
string_vals = {app.SegmentationMethodButtonGroup.Buttons.Text};
butt_idx = find(strcmp(selectedButton.Text,string_vals));

% Initializing stains for segmentation
app.Channels = ones(length(app.Stain_Names));
app.Thresholds = ones(length(app.Stain_Names));
app.ThresholdDirs = ones(length(app.Stain_Names));
app.MinSizes = ones(length(app.Stain_Names));
app.Splittings = zeros(length(app.Stain_Names));

% Updating app.ParametersPanel
if butt_idx==1

    app.ParametersPanel.Title = 'Colorspace Parameters';
    app.ColorSelectLabel.Text = 'Colorspace';
    
    app.ChannelDropdown.Items = {'RGB (Red, Green, Blue)',...
        'HSV (Hue, Saturation, Value)',...
        'LAB'};
    app.ChannelDropdown.ItemsData = [1,2,3];

    app.ChannelDropdown.Value = app.ChannelDropdown.ItemsData(2);
    app.Seg_Params.Colorspace = app.ChannelDropdown.Value;

elseif butt_idx==2
    app.ParametersPanel.Title = 'Color Deconvolution';
    app.ColorSelectLabel.Text = 'Stain Type';

    app.ChannelDropdown.Items = {'Hematoxylin and Eosin determined by G. Landini',...
        'Hematoxylin and Eosin determined by A.C. Ruifrok',...
        'Hematoxylin and DAB',...
        'Hematoxylin, Eosin and DAB',...
        'Hematoxylin and AEC',...
        'Fast Red, Fast Blue and DAB',...
        'Methyl green and DAB',...
        'Azan-Mallory',...
        'Alcian blue & Hematoxylin',...
        'Hematoxylin and Periodic Acid Schiff',...
        'RGB subtractive',...
        'CMY subtractive'};

    app.ChannelDropdown.ItemsData = [1,2,3,4,5,6,7,8,9,10,11,12,13];
    
    app.ChannelDropdown.Value = app.ChannelDropdown.ItemsData(1);
    app.Seg_Params.ColorDeconvolution = app.ChannelDropdown.Value;

elseif butt_idx==3
    % Custom segmentation:
    app.Seg_Params.Path = uigetdir(pwd,"Select directory containing custom subcompartment segmentations");

end


if ismember(butt_idx,[1,2])
    % Grabbing default values for segmentation parameters
    for st = 1:length(app.Stain_Names)
        stain_field = strcat('Stain',num2str(st));
    
        app.Seg_Params.(stain_field).Channel = app.Channels(st);
        app.Seg_Params.(stain_field).Threshold = app.Thresholds(st);
        app.Seg_Params.(stain_field).ThresholdDir = app.ThresholdDirs(st);
        app.Seg_Params.(stain_field).MinSize = app.MinSizes(st);
        app.Seg_Params.(stain_field).Splitting = app.Splittings(st);
    
    end
end


