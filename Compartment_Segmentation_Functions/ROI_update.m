% --- Function for handling Compartment segmentation region selection ROI
% updates
function ROI_update(src,event,app)
event_type = event.EventName;

roi_label = src.Label;
stain = strsplit(roi_label,' ');
stain = stain{1};

roi_idx = strsplit(roi_label,'_');
roi_idx = str2num(roi_idx{end});
switch(event_type)

    case{'ROIMoved'}
        app.Current_ROIs.(strcat(stain,'_ROIs'))(roi_idx,:) = src.Position;
    
    case{'DeletingROI'}
        app.Current_ROIs.(strcat(stain,'_ROIs'))(roi_idx,:) = [];

    case{'DrawingFinished'}
        app.Current_ROIs.(strcat(stain,'_ROIs'))(roi_idx,:) = src.Position;

end

