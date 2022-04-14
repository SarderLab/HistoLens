% --- Function to run sub-compartment segmentation on new images
function New_Sub_Segmentation(app)

% Get current tab
current_tab = app.TabGroup.SelectedTab;
img_idx = find(strcmp(current_tab.Title,app.Stain_Table.Properties.VariableNames));
current_axis = app.Stain_Img_Axes(img_idx);

bg_idx = 0;

% Only running if a segmentation method is defined
if ~isempty(app.Sub_Compartment_Details)

    n_sub_compartments = length(fieldnames(app.Sub_Compartment_Details));
    
    % Initializing sub-compartment mask (2D)
    combined = zeros(size(app.Current_Img.(strcat('Image',num2str(img_idx))),1),...
        size(app.Current_Img.(strcat('Image',num2str(img_idx))),2));

    current_img = app.Current_Img.(strcat('Image',num2str(img_idx)));
    % Iterating through each sub-compartment
    for sub = 1:n_sub_compartments
        current_details = app.Sub_Compartment_Details.(strcat('Sub_Comp_',num2str(sub)));
        
        if ~current_details.Background
            % Using saved fitted distribution
            if ismember('Distribution',fieldnames(current_details))
                
                % selecting color transform 
    %             switch current_details.Type
    %                 case 'HSV'
    %                     transformed_img = rgb2hsv(current_img);
    %                 case 'RGB'
    %                     transformed_img = current_img;
    %                 case 'H PAS'
    %                     %stain_code = current_details.Stain;
    %                     [transformed_1,transformed_2,transformed_3] = colour_deconvolution(current_img,'H PAS');
    %                     transformed_img = cat(3,transformed_1,transformed_2,transformed_3);
    %             end
                
                % Switching to all HSV
                transformed_img = rgb2hsv(current_img);
                
                display('New_Sub_Segmentation 40')
                assignin('base','transformed_img',transformed_img)
    
                display('New_Sub_Segmentation 43')
                assignin('base','current_img',current_img)
    
                % Fitting pdf to current transformed image data
                sub_pdf_1 = normpdf(double(reshape(transformed_img(:,:,1),1,[])),...
                    current_details.Distribution.First(1),...
                    current_details.Distribution.First(2));
                sub_pdf_2 = normpdf(double(reshape(transformed_img(:,:,2),1,[])),...
                    current_details.Distribution.Second(1),...
                    current_details.Distribution.Second(2));
                sub_pdf_3 = normpdf(double(reshape(transformed_img(:,:,3),1,[])),...
                    current_details.Distribution.Third(1),...
                    current_details.Distribution.Third(2));
    
                sub_pdf_1 = reshape(sub_pdf_1,size(transformed_img(:,:,1),1),size(transformed_img(:,:,1),2));
                sub_pdf_2 = reshape(sub_pdf_2,size(transformed_img(:,:,1),1),size(transformed_img(:,:,1),2));
                sub_pdf_3 = reshape(sub_pdf_3,size(transformed_img(:,:,1),1),size(transformed_img(:,:,1),2));
                
                display('New_Sub_Segmentation 48')
                assignin('base','sub_pdf_combined',cat(3,sub_pdf_1,sub_pdf_2,sub_pdf_3))
    
                combined_pdf = ones(size(sub_pdf_1));
                if ~all(all(isnan(sub_pdf_1))) && ~all(all(sub_pdf_1==0))
                    combined_pdf = rescale(sub_pdf_1);
                end
    
                if ~all(all(isnan(sub_pdf_2))) && ~all(all(sub_pdf_2==0))
                    combined_pdf = combined_pdf.*rescale(sub_pdf_2);
                end
    
                if ~all(all(isnan(sub_pdf_3))) && ~all(all(sub_pdf_3==0))
                    combined_pdf = combined_pdf.*rescale(sub_pdf_3);
                end
    
                % Using user-defined threshold
                thresheld = rescale(combined_pdf)>current_details.Tolerance;
                
                % Applying smoothing based on user-defined Sigma value
                if ~current_details.Smoothing==0
                    smoothed = imgaussfilt(uint8(thresheld),current_details.Smoothing);
                    smoothed = imbinarize(smoothed);
                else
                    smoothed = thresheld;
                end
                
                if current_details.Split
                    smoothed = split_nuclei_functional(smoothed);
                end
    
    
    
                % Removing small objects based on user-defined minimum size
                de_noised = bwareaopen(smoothed,current_details.MinSize);

            end
        
            % Assigning new label to pixels not already claimed by a previous
            % class
    
            %figure, imagesc(de_noised)
            combined(de_noised & ~combined) = sub;
            assignin('base','combined',combined)
        else
            bg_idx = sub;
        end

        combined(combined==0) = bg_idx;

    end

    if ismember('Network',fieldnames(current_details))
        


    end

    app.Current_Combined = combined;
end


