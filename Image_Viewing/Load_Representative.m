% --- Function to load representative image based on feature value
% selection
function Load_Representative(app,event)

% Getting the image paths in Dist_Ax
dist_data = app.Dist_Data;

% For adding new comparison region
if app.Comparing
        
    if length(app.map_idx)>1

        % When multiple axes are active, change img_paths and
        % Red_Comp_Image list
        if app.Red_Only

            dist_roi_idx = inROI(app.dist_roi,[dist_data{:,1}],[dist_data{:,2}]);
            %include_names = dist_data.ImgLabel(dist_roi_idx);
            %include_idx = find(ismember(app.Full_Feature_set.ImgLabel,include_names));

            % Making new handles.img_paths and handles.mask_paths from ROI
            % selection
            red_image_names = dist_data.ImgLabel(dist_roi_idx);
            
            app.Red_Comp_Image.Items = Combine_Name_Label(app, red_image_names,[]);
            app.Red_Comp_Image.Value = app.Red_Comp_Image.Items(1);
            app.Image_Name_Label.Items = Combine_Name_Label(app,red_image_names,[]);
            app.Image_Name_Label.Value = app.Image_Name_Label.Items(1);
        end
        
        if app.Blue_Only

            comp_roi_idx = inROI(app.comp_roi,[dist_data{:,1}],[dist_data{:,2}]);
            %include_names = dist_data.ImgLabel(comp_roi_idx);
            %include_idx = find(ismember(app.Full_Feature_set.ImageLabel,include_names));

            blue_image_names = dist_data.ImgLabel(comp_roi_idx);
            
            app.Blue_Comp_Image.Items = Combine_Name_Label(app, blue_image_names,[]);
            app.Blue_Comp_Image.Value = app.Blue_Comp_Image.Items(1);
        end
        
        if ~app.Red_Only && ~app.Blue_Only
            
            comp_roi_idx = inROI(app.comp_roi,[dist_data{:,1}],[dist_data{:,2}]);
            %include_names = dist_data.ImgLabel(comp_roi_idx);
            %include_idx = find(ismember(app.Full_Feature_set.ImgLabel,include_names));

            blue_image_names = dist_data.ImgLabel(comp_roi_idx);
            
            app.Blue_Comp_Image.Items = Combine_Name_Label(app, blue_image_names,[]);
            app.Blue_Comp_Image.Value = app.Blue_Comp_Image.Items(1);
            
            dist_roi_idx = inROI(app.dist_roi,[dist_data{:,1}],[dist_data{:,2}]);
            %include_names = dist_data.ImgLabel(dist_roi_idx);
            %include_idx = find(ismember(app.Full_Feature_set.ImgLabel,include_names));

            % Making new handles.img_paths and handles.mask_paths from ROI
            % selection
            red_image_names = dist_data.ImgLabel(dist_roi_idx);
            
            app.Red_Comp_Image.Items = Combine_Name_Label(app, red_image_names,[]);
            app.Red_Comp_Image.Value = app.Red_Comp_Image.Items(1);
        end
        
    else
        
        % Only really need to get the height values which are [xmin ymin width
        % height]
        
        % To get values that are within the ROI
        %dist_data = handles.Dist_Data;
        
        if app.Red_Only
            sel_data_min = app.dist_roi.Position(2);
            sel_data_max = app.dist_roi.Position(2)+app.dist_roi.Position(4);
            
            sel_class_min = app.dist_roi.Position(1);
            sel_class_max = sel_class_min+app.dist_roi.Position(3);
            %n_classes = length(unique(dist_data.Class));
            include_classes = unique(dist_data.Class);
            include_classes = include_classes(round(sel_class_min):round(sel_class_max));
            
            app.dist_roi.Label = ['Min: ',num2str(sel_data_min,'%0.4f'),' to Max: ',num2str(sel_data_max,'%0.4f')];
            
            % Making new handles.img_paths and handles.mask_paths from ROI
            % selection
            red_image_names = dist_data.ImgLabel(sel_data_min<=dist_data{:,1} & dist_data{:,1}<=sel_data_max & ismember(dist_data.Class,include_classes));

            sel_dist_values = dist_data{sel_data_min<=dist_data{:,1} & dist_data{:,1}<=sel_data_max,1};

            app.Red_Comp_Image.Items = Combine_Name_Label(app, red_image_names, sel_dist_values);
            app.Red_Comp_Image.Value = app.Red_Comp_Image.Items(1);
            app.Image_Name_Label.Items = Combine_Name_Label(app, red_image_names,[]);
            app.Image_Name_Label.Value = app.Image_Name_Label.Items(1);
        end
        
        if app.Blue_Only
            comp_data_min = app.comp_roi.Position(2);
            comp_data_max = app.comp_roi.Position(2)+app.comp_roi.Position(4);
            
            comp_class_min = app.comp_roi.Position(1);
            comp_class_max = comp_class_min+app.comp_roi.Position(3);
            %n_classes = length(unique(dist_data.Class));
            include_classes = unique(dist_data.Class);
            include_classes = include_classes(round(comp_class_min):round(comp_class_max));
            
            app.comp_roi.Label = ['Min: ',num2str(comp_data_min,'%0.4f'),' to Max: ',num2str(comp_data_max,'%0.4f')];
            
            % Making new handles.img_paths and handles.mask_paths from ROI
            % selection
            blue_image_names = dist_data.ImgLabel(comp_data_min<=dist_data{:,1} & dist_data{:,1}<=comp_data_max & ismember(dist_data.Class,include_classes));

            comp_dist_values = dist_data{comp_data_min<=dist_data{:,1} & dist_data{:,1}<=comp_data_max,1};
            
            app.Blue_Comp_Image.Items = Combine_Name_Label(app, blue_image_names,comp_dist_values);
            app.Blue_Comp_Image.Value = app.Blue_Comp_Image.Items(1);
            
        end
        
        if ~app.Red_Only && ~app.Blue_Only
            
            comp_data_min = app.comp_roi.Position(2);
            comp_data_max = app.comp_roi.Position(2)+app.comp_roi.Position(4);
            
            comp_class_min = app.comp_roi.Position(1);
            comp_class_max = comp_class_min+app.comp_roi.Position(3);
            %n_classes = length(unique(dist_data.Class));
            include_classes = unique(dist_data.Class);
            if round(comp_class_max)>length(include_classes)
                if round(comp_class_min)<1
                    include_classes = include_classes(1:end);
                else
                    include_classes = include_classes(round(comp_class_min):end);
                end
            else
                if round(comp_class_min)<1
                    include_classes = include_classes(1:round(comp_class_max));
                else
                    include_classes = include_classes(round(comp_class_min):round(comp_class_max));
                end
            end
       
            app.comp_roi.Label = ['Min: ',num2str(comp_data_min,'%0.4f'),' to Max: ',num2str(comp_data_max,'%0.4f')];
            
            % Making new handles.img_paths and handles.mask_paths from ROI
            % selection
            blue_image_names = dist_data.ImgLabel(comp_data_min<=dist_data{:,1} & dist_data{:,1}<=comp_data_max & ismember(dist_data.Class,include_classes));

            comp_dist_values = dist_data{comp_data_min<=dist_data{:,1} & dist_data{:,1}<=comp_data_max,1};
            
            app.Blue_Comp_Image.Items = Combine_Name_Label(app, blue_image_names,comp_dist_values);
            app.Blue_Comp_Image.Value = app.Blue_Comp_Image.Items(1);
            
            sel_data_min = app.dist_roi.Position(2);
            sel_data_max = app.dist_roi.Position(2)+app.dist_roi.Position(4);
            
            sel_class_min = app.dist_roi.Position(1);
            sel_class_max = sel_class_min+app.dist_roi.Position(3);
            %n_classes = length(unique(dist_data.Class));
            include_classes = unique(dist_data.Class);
            if round(sel_class_min)<1
                if round(sel_class_max)>length(include_classes)
                    include_classes = include_classes(1:length(include_classes));
                else
                    include_classes = include_classes(1:round(sel_class_max));
                end
            elseif round(sel_class_max)>length(include_classes)
                include_classes = include_classes(round(sel_class_min):length(include_classes));
            else
                include_classes = include_classes(round(sel_class_min):round(sel_class_max));
            end           
            
            app.dist_roi.Label = ['Min: ',num2str(sel_data_min,'%0.4f'),' to Max: ',num2str(sel_data_max,'%0.4f')];
            
            % Making new handles.img_paths and handles.mask_paths from ROI
            % selection
            red_image_names = dist_data.ImgLabel(sel_data_min<=dist_data{:,1} & dist_data{:,1}<=sel_data_max & ismember(dist_data.Class,include_classes));

            sel_dist_values = dist_data{sel_data_min<=dist_data{:,1} & dist_data{:,1}<=sel_data_max,1};

            app.Red_Comp_Image.Items = Combine_Name_Label(app, red_image_names, sel_dist_values);
            app.Red_Comp_Image.Value = app.Red_Comp_Image.Items(1);
        end
    end
else  

    if length(app.map_idx)>1

        roi_idx = inROI(app.dist_roi,[dist_data{:,1}],[dist_data{:,2}]);
        %include_names = dist_data.ImgLabel(roi_idx);
        
        %include_idx = find(ismember(app.Full_Feature_set.ImgLabel,include_names));
        
        % Making new handles.img_paths and handles.mask_paths from ROI
        % selection
        image_names = dist_data.ImgLabel(roi_idx);
                    
        app.Image_Name_Label.Items = Combine_Name_Label(app,image_names,[]);
        app.Image_Name_Label.Value = app.Image_Name_Label.Items(1);
            
    else

        % handles.dist_roi.Position = not relative to position in axes but the
        % actual values so the range changes depending on the range of the
        % data.

        % Only really need to get the height values which are [xmin ymin width
        % height]
        data_min = app.dist_roi.Position(2);
        data_max = app.dist_roi.Position(2)+app.dist_roi.Position(4);
        
        class_min = app.dist_roi.Position(1);
        class_max = class_min+app.dist_roi.Position(3);
        %n_classes = length(unique(dist_data.Class));
        include_classes = unique(dist_data.Class);
        if round(class_max)<=length(include_classes)
            include_classes = include_classes(round(class_min):round(class_max));
        else
            include_classes = include_classes(round(class_min):length(include_classes));
        end
        
        app.dist_roi.Label = ['Min: ',num2str(data_min,'%0.4f'),' to Max: ',num2str(data_max,'%0.4f')];
             
        image_names = dist_data.ImgLabel(data_min<=dist_data{:,1} & dist_data{:,1}<=data_max & ismember(dist_data.Class,include_classes));
        
        dist_values = dist_data{data_min<=dist_data{:,1} & dist_data{:,1}<=data_max,1};
                            
        app.Image_Name_Label.Items = Combine_Name_Label(app,image_names,dist_values);
        app.Image_Name_Label.Value = app.Image_Name_Label.Items(1);

    end
end

Gen_Map(app,event)
% Saving image notes
% If going from a bulk labeling instance to a new selection, need to avoid
% saving notes that are not relevant
Save_Notes(app,event)
View_Image(app,event)
% Loading current image notes
Load_Notes(app,event)

