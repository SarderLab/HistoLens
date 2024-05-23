% --- Function to add the user-defined stain names to the compartment
% segmentation tab group
function Add_Stain_Tabs(app)

stain_names = app.Stain_Names;
delete(get(app.StainsTabGroup,'Children'))

if length(stain_names)~=3
    stain_norm_children = get(app.ColorNormalizationMacenkoetalPanel,'Children');

    set(stain_norm_children(isprop(stain_norm_children,'Enable')),'Enable','off')

elseif length(stain_names)==3
    app.SelectStain1Button.Text = stain_names{1};
    app.SelectStain2Button.Text = stain_names{2};
    
    app.MaxTable.ColumnName = {strcat(stain_names{1}, '_Max'), strcat(stain_names{2}, '_Max')};
    app.MeanTable.ColumnName = {strcat(stain_names{1},'_Mean'),strcat(stain_names{2},'_Mean')};

end

%TODO: This part here is expecting three (or fewer) stains (including background)
stain_color_labels = [[1 0 0];[0 1 0];[0 0 1]];
for i = 1:length(stain_names)

    stain_field = strcat('Stain',num2str(i));
    
    % Adding label
    stain_label = uilabel(app.CompartmentSegmentationUIFigure);
    stain_label.HorizontalAlignment = 'center';
    stain_label.FontSize = 18;
    stain_label.FontWeight = 'bold';
    stain_label.FontColor = stain_color_labels(i,:);
    stain_label.Position = [725+100*(i-1) 570 150 22];
    stain_label.Text = stain_names{i};

    % Adding tab with the right title
    stain_tab = uitab(app.StainsTabGroup,'Title',stain_names{i},'Scrollable','on');
    
    % Every tab will get a channel dropdown, a threshold edit field, a
    % minimum size edit field, and a segmentation hierarchy field.
    % Hematoxylin tabs will get a splitting slider. Order of stain names
    % determines segmentation hierarchy starting value with the last one
    % getting all the other components in that tab disabled.
        
    % This dropdown can actually just be 1/2/3 as all the color
    % transforms are 3 channel
    if strcmp(app.ChannelDropdown.Value,'RGB (Red, Green, Blue)')
        channel_items = {'Red Channel','Green Channel','Blue Channel'};
        channel_itemdata = [1,2,3];

    elseif strcmp(app.ChannelDropdown.Value,'HSV (Hue, Saturation, Value)')
        channel_items = {'Hue Channel','Saturation Channel','Value Channel'};
        channel_itemdata = [1,2,3];

    elseif strcmp(app.ChannelDropdown.Value,'LAB')
        channel_items = {'L* Channel','A* Channel','B* Channel'};
        channel_itemdata = [1,2,3];
    end

    channel_label = uilabel(stain_tab);
    channel_label.HorizontalAlignment = 'right';
    channel_label.Position = [6 112 82 22];
    channel_label.Text = 'Color Channel';


    channel_drop = uidropdown(stain_tab,...
        'Items',channel_items, ...
        'ItemsData',channel_itemdata,...
        'Position',[143 112 285 22],...
        'ValueChangedFcn',{@app.ChannelValueChanged,i});

    % Threshold edit field (setup default value)
    threshold_label = uilabel(stain_tab);
    threshold_label.HorizontalAlignment = 'right';
    threshold_label.Position = [5,78,92,22];
    threshold_label.Text = 'Threshold Value';

    threshold_field = uieditfield(stain_tab,'numeric');
    threshold_field.Limits = [0,255];
    threshold_field.ValueChangedFcn = {@app.ThresholdValueChanged,i};
    threshold_field.Enable = 'on';
    threshold_field.Position = [145,78,285,22];

    threshold_switch = uiswitch(stain_tab,'toggle');
    threshold_switch.Items = {'above','below'};
    threshold_switch.Position = [434 67 20 45];
    threshold_switch.Value = 'above';
    threshold_switch.ValueChangedFcn = {@app.ThresholdDirectionChanged,i};

    % Minimum size edit field
    minsize_label = uilabel(stain_tab);
    minsize_label.HorizontalAlignment = 'right';
    minsize_label.Position = [5,44,81,22];
    minsize_label.Text = 'Minimum Size';

    minsize_field = uieditfield(stain_tab,'numeric');
    minsize_field.ValueChangedFcn = {@app.MinimumSizeValueChanged,i};
    minsize_field.Enable = 'on';
    minsize_field.Position = [145,44,285,22];

    if strcmp(stain_names{i},'Hematoxylin')
        % Adding splitting slider
        slider_label = uilabel(stain_tab);
        slider_label.HorizontalAlignment = 'right';
        slider_label.Position = [378,10,48,22];
        slider_label.Text = 'Splitting';

        slider = uislider(stain_tab);
        slider.Orientation = 'vertical';
        slider.ValueChangedFcn = {@app.SplittingValueChanged,i};
        slider.Position = [447 19 3 107];
        slider.Value = 5;


    end

end

