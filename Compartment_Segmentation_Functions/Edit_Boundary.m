% --- Function to edit boundary mask of current image
function Edit_Boundary(app)

% Getting current image boundary mask and placing it on the image as a
% Freehand ROI
current_tab = app.TabGroup.SelectedTab;
current_axis = app.Stain_Img_Axes(find(strcmp(current_tab.Title,app.Stain_Table.Properties.VariableNames)));

% Adjust this later when adjusting Advanced_Extract_Rand_Img for
% annotations in multiple stains
current_mask = app.Current_Img.BoundaryMask{1};
boundary_points = bwboundaries(current_mask);
boundary_points = boundary_points{1};

% Adding freehand ROI to current axis
app.Editable_Boundary = images.roi.Freehand(current_axis,'Position',[boundary_points(:,2),boundary_points(:,1)]);
%boundary_roi.draw()
drawnow()

