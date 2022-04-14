% --- Function to update the values contained in Values matrix after
% adjusting "Type"
function Update_Stored_Values(app)

current_sub_compartment = app.SubCompartmentNameDropDown.Value;

% All the sub-compartment display names
display_names = cell(length(fieldnames(app.Sub_Compartment_Details)),1);
for i = 1:length(fieldnames(app.Sub_Compartment_Details))
    display_names{i} = app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(i))).DisplayName;
end

sub_comp_idx = find(strcmp(display_names,current_sub_compartment));
current_details = app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx)));

% Getting the image names and ROIs in each 
img_labels = unique(current_details.ImgLabels);

for i = 1:length(img_labels)
    current_label = img_labels(i);
    img_rois = current_details.ROIs(find(strcmp(current_label,current_details.ImgLabels)));

    for j = 1:length(img_rois)
        if j == 1
            combined_roi_coords = img_rois{j};
        else
            combined_roi_coords = [combined_roi_coords;img_rois{j}];
        end
    end
    combined_roi_coords = combined_roi_coords(2:end,:);

    new_mask = poly2mask(combined_roi_coords(:,1),combined_roi_coords(:,2),size(current_details.Rep_Images{i},1),size(current_details.Rep_Images{i},2));

    switch current_details.Type
        case 'HSV'
            transformed_img = rgb2hsv(current_details.Rep_Images{i});

            masked_img = transformed_img.*double(cat(3,new_mask,new_mask,new_mask));

        case 'RGB'
            transformed_img = current_details.Rep_Images{i};

            masked_img = transformed_img.*uint8(cat(3,new_mask,new_mask,new_mask));

        case 'H PAS'
            transformed_img = colour_deconvolution(current_details.Rep_Images{i},'H PAS');

            masked_img = transformed_img.*uint8(cat(3,new_mask,new_mask,new_mask));
    end
    
    masked_img = reshape(masked_img,[],3);
    masked_img(all(masked_img==0,2),:) = NaN;
    ign_pix_idx = isnan(masked_img);

    masked_1 = masked_img(:,1);
    masked_1 = masked_1(~ign_pix_idx(:,1));
    masked_2 = masked_img(:,2);
    masked_2 = masked_2(~ign_pix_idx(:,2));
    masked_3 = masked_img(:,3);
    masked_3 = masked_3(~ign_pix_idx(:,3));

    if i==1
        app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).Values_Matrix = [masked_1,masked_2,masked_3];
    else
        current_vals = app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).Values_Matrix;
        app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub_comp_idx))).Values_Matrix = [current_vals;masked_1,masked_2,masked_3];
    end
end

