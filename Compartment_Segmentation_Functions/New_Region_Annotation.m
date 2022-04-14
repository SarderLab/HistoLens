% --- Function to add new region annotation for Sub-Compartment
% Segmentation
function New_Region_Annotation(app)

% Get the current slide-stain tab
current_tab = app.TabGroup.SelectedTab;
current_axis = app.Stain_Img_Axes(find(strcmp(current_tab.Title,app.Stain_Table.Properties.VariableNames)));

% Creating and drawing the ROI
roi = images.roi.Freehand(current_axis,'Smoothing',0,'FaceAlpha',0);
roi.draw()

% Getting regions within that image
new_mask = roi.createMask;
current_img = app.Current_Img.(strcat('Image',num2str(find(strcmp(current_tab.Title,...
    app.Stain_Table.Properties.VariableNames)))));

% Adding transformed values to values_matrix
current_sub_compartment = app.SubCompartmentNameDropDown.Value;

% All the sub-compartment display names
display_names = cell(length(fieldnames(app.Sub_Compartment_Details)),1);
for i = 1:length(fieldnames(app.Sub_Compartment_Details))
    display_names{i} = app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(i))).DisplayName;
end

sub_comp_idx = find(strcmp(display_names,current_sub_compartment));
current_details = app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx)));

% Getting color transform for sub-compartment
% switch current_details.Type
%     case 'HSV'
%         transformed_img = rgb2hsv(current_img);
% 
%         masked_img = transformed_img.*double(cat(3,new_mask,new_mask,new_mask));
%     case 'H PAS'
%         [transformed_1,transformed_2,transformed_3] = colour_deconvolution(current_img,'H PAS');
%         transformed_img = cat(3,transformed_1,transformed_2,transformed_3);
% 
%         masked_img = transformed_img.*uint8(cat(3,new_mask,new_mask,new_mask));
% 
%     case 'RGB'
%         transformed_img = current_img;
% 
%         masked_img = transformed_img.*uint8(cat(3,new_mask,new_mask,new_mask));
% end

% Switching to all HSV
transformed_img = rgb2hsv(current_img);
masked_img = transformed_img.*double(cat(3,new_mask,new_mask,new_mask));

% Getting HSV values within annotated regions
masked_img = reshape(masked_img,[],3);
masked_img(all(masked_img==0,2),:) = NaN;
ign_pix_idx = isnan(masked_img);

% Removing NaNs (non-annotated areas)
masked_1 = masked_img(:,1);
masked_1 = masked_1(~ign_pix_idx(:,1));
masked_2 = masked_img(:,2);
masked_2 = masked_2(~ign_pix_idx(:,2));
masked_3 = masked_img(:,3);
masked_3 = masked_3(~ign_pix_idx(:,3));

% Current Vals matrix 
current_Vals = app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).Values_Matrix;

if size(current_Vals,1)==1 
    if all(current_Vals==0)
        app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).Values_Matrix = [masked_1,masked_2,masked_3];
    else
        app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).Values_Matrix = [current_Vals;masked_1,masked_2,masked_3];
    end
else
    app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).Values_Matrix = [current_Vals;masked_1,masked_2,masked_3];
end


% Adding image underneath sub-compartment name in tree
if isprop(app.SubCompartmentTree.Children(sub_comp_idx).Children,'Text')
    if ~ismember(app.Current_Img.ImgLabel,{app.SubCompartmentTree.Children(sub_comp_idx).Children.Text})
        sN = uitreenode(app.SubCompartmentTree.Children(sub_comp_idx));
        sN.Text = app.Current_Img.ImgLabel;
    
        if isfield(app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))),'Rep_Images')
            current_reps = app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).Rep_Images;
            app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).Rep_Images = [current_reps,{current_img}];
        else
            app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).Rep_Images = {current_img};
        end
    end

else
    sN = uitreenode(app.SubCompartmentTree.Children(sub_comp_idx));
    sN.Text = app.Current_Img.ImgLabel;

    if isfield(app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))),'Rep_Images')
        current_reps = app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).Rep_Images;
        app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).Rep_Images = [current_reps,{current_img}];
    else
        app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).Rep_Images = {current_img};
    end

end

% Adding image name and ROI location to struct
if isfield(app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))),'ImgLabels')  
    current_labels = app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).ImgLabels;
    current_rois = app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).ROIs;

    app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).ImgLabels = [current_labels,{app.Current_Img.ImgLabel}];
    app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).ROIs = [current_rois,{roi.Position}];

else
    app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).ImgLabels = {app.Current_Img.ImgLabel};
    app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).ROIs = {roi.Position};
end


% Establishing normal probability distribution
current_Vals = app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).Values_Matrix;
if strcmp(class(current_Vals),'double')
    app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).Distribution.First = [mean(current_Vals(:,1),'omitnan'),std(current_Vals(:,1),'omitnan')];
    app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).Distribution.Second = [mean(current_Vals(:,2),'omitnan'),std(current_Vals(:,2),'omitnan')];
    app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).Distribution.Third = [mean(current_Vals(:,3),'omitnan'),std(current_Vals(:,3),'omitnan')];
else
    current_Vals = double(current_Vals);
    app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).Distribution.First = [mean(current_Vals(:,1),'omitnan'),std(current_Vals(:,1),'omitnan')];
    app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).Distribution.Second = [mean(current_Vals(:,2),'omitnan'),std(current_Vals(:,2),'omitnan')];
    app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).Distribution.Third = [mean(current_Vals(:,3),'omitnan'),std(current_Vals(:,3),'omitnan')];
end

% Modifying Segmentation_Methods
%app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).Type = 'HSV';
%app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).Distribution = app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).Distribution;

% Activating switch
if app.Switch.Visible && ~app.Switch.Enable 
    app.Switch.Enable = 'on';
elseif app.Knob.Visible && ~app.Knob.Enable
    app.Knob.Enable = 'on';
end

display('New_Region_Annotation 134')
assignin('base',"app",app)


New_Sub_Segmentation(app)

