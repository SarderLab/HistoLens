% --- Function to view image on axis
function View_Image(app,event)

if ~app.Comparing
    app.Current_Img = [];
    app.Current_NormImg = [];
    
    % Reading in image
    image_name = app.Image_Name_Label.Value;
    image_name = strsplit(image_name,',');
    image_name = image_name{1};

    if ~isempty(app.Current_Name)
        app.Previous_Name = app.Current_Name;
    end
    app.Current_Name = {image_name};
    
    [raw_img,norm_img,~,~] = Extract_Spec_Img(app,event,image_name);
    
    axes(app.Img_Ax);

    scaled_norm_img = Add_Scalebar(norm_img,app.Img_Ax,app.Baseline_MPP,app);
    scaled_img = Add_Scalebar(raw_img,app.Img_Ax,app.Baseline_MPP,app);

    app.Current_NormImg{1} = scaled_norm_img;
    app.Current_Img{1} = scaled_img;
    
    imshow(scaled_img), axis image  
    Scale_Text(scaled_img, app.Img_Ax, app.Baseline_MPP,app)
    hold on

    app.Heat_Slide.Enable = 'on';

    if ~isempty(app.map)
        % Get map(s)
        colormap jet
        % Switching to un-scaled viewing
        app.im = imagesc(app.Img_Ax,app.map);
        %app.im = imshow(app.map);
        app.im.AlphaData = app.Heat_Slide.Value;
        hold off
        
        if ~app.Pause_Visualization
            % Moving rectangular ROI to contain all map data
            bin_roi = struct2cell(regionprops(bwconvhull(imbinarize(app.map,0)),'BoundingBox'));
    
            % For maps that are all zeros clear out histogram and table
            if ~isempty(bin_roi)
                app.red_roi = images.roi.Rectangle(app.Img_Ax,'Position',cell2mat(bin_roi),...
                    'FaceAlpha',0);
    
                app.red_rect_position = app.red_roi.Position;
    
                click_vis(app,event,app.red_roi);
                addlistener(app.red_roi, 'ROIMoved',@(varargin)click_vis(app,event,app.red_roi));
    
            else
                cla(app.Rel_Ax)
                app.Rel_Feat_Table.Data = {};
            end
        else
            cla(app.Rel_Ax)
            app.Rel_Feat_Table.Data = {};
        end
        
        % Annotating image position in feature space for PCA plots and
        % scatter plots
        if length(app.map_idx)>1
            try
                delete(app.img_text)
            end
            
            coords = app.Dist_Data(find(strcmp(app.Dist_Data.ImgLabel,image_name)),1:2);
            app.img_text = text(app.Dist_Ax,coords{1,1},coords{1,2},...
                '\leftarrow Current Image','ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));
        else
            try
                delete(app.img_text)
            end
            
            label_vals = app.Dist_Data{find(strcmp(app.Dist_Data.ImgLabel,image_name)),1};
            class_vals = app.Dist_Data{find(strcmp(app.Dist_Data.ImgLabel,image_name)),3};
            all_class = app.Plot_Options.LabelOrder;
            if isnumeric(all_class)
                app.img_text = text(app.Dist_Ax,find(class_vals(1,1)==all_class),...
                    label_vals(1,1),'\leftarrow Current Image','ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));
            else
                app.img_text = text(app.Dist_Ax,find(strcmp(class_vals(1,1),all_class)),...
                    label_vals(1,1),'\leftarrow Current Image','ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));
            end
        end
            
    end
        
else
    
    if app.Red_Only
        cla(app.Red_Img_Ax)
        hold off
        % Reading in image
        image_name = app.Red_Comp_Image.Value;
        image_name = strsplit(image_name,',');
        image_name = image_name{1};

        if ~isempty(app.Current_Name)
            if iscell(app.Current_Name{1})
                app.Previous_Name{1} = app.Current_Name{1};
            else
                app.Previous_Name{1} = app.Current_Name;
            end
        end
        app.Current_Name{1} = {image_name};
        
        [raw_img,norm_img,~,~] = Extract_Spec_Img(app,event,image_name);
        
        if ~iscell(app.map)
            app.map = {app.map};
        end

        axes(app.Red_Img_Ax);
        
        scaled_img = Add_Scalebar(raw_img, app.Red_Img_Ax, app.Baseline_MPP,app);
        scaled_norm_img = Add_Scalebar(norm_img,app.Red_Img_Ax,app.Baseline_MPP,app);

        app.Current_Img{1} = scaled_img;
        app.Current_NormImg{1} = scaled_norm_img;

        imshow(scaled_img), axis image%, title('Red ROI Image')
        Scale_Text(scaled_img, app.Red_Img_Ax, app.Baseline_MPP,app)

        hold on

        if ~isempty(app.map)
            % Get map(s)
            colormap jet
            % Removing scaled map viewing
            app.im_red = imagesc(app.Red_Img_Ax,app.map{1});
            %handles.im_red = imshow(handles.map{1});
            app.im_red.AlphaData = app.Heat_Slide.Value;
            hold off
            
            if ~app.Pause_Visualization
                % Moving rectangular ROI to contain all map data
                bin_roi = struct2cell(regionprops(bwconvhull(imbinarize(app.map{1},0)),'BoundingBox'));
    
                % For maps that are all zeros clear out histogram and table
                if ~isempty(bin_roi)
                    app.red_roi = images.roi.Rectangle(app.Red_Img_Ax,'Position',cell2mat(bin_roi),'Color','r',...
                        'FaceAlpha',0);
                    
                    app.red_rect_position = app.red_roi.Position;
                    
                    if ~isempty(app.red_roi)
                        click_vis(app,event,app.red_roi);
                    end
                    addlistener(app.red_roi, 'ROIMoved',@(varargin)click_vis(app,event,app.red_roi));
    
                else
                    % Only clear red columns
    
                    prev_data = app.Rel_Feat_Table.Data;
                    prev_columns = app.Rel_Feat_Table.ColumnName;
                    red_cols = find(contains(prev_columns,'Red'));
    
                    new_data = prev_data;
                    for k = 1:length(red_cols)
                        new_data(:,red_cols(k)) = zeros(size(prev_data,1),1);
                    end
                    app.Rel_Feat_Table.Data = new_data;                   
                        
                end
            else
                cla(app.Rel_Ax)
                app.Rel_Feat_Table.Data = {};
            end
            
            %if ~isempty(app.Full_Feature_set)
            % Annotating image position in feature space for PCA plots
            if length(app.map_idx)>1
                try
                    delete(app.red_text)
                end
                try
                    delete(app.img_text)
                end

                coords = app.Dist_Data(find(strcmp(app.Dist_Data.ImgLabel,image_name)),1:2);
                app.red_text = text(app.Dist_Ax,coords{1,1},coords{1,2},...
                    '\leftarrow Red Image','ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));
            
            else
                try
                    delete(app.red_text)
                end
                try
                    delete(app.img_text)
                end

                label_vals = app.Dist_Data{find(strcmp(app.Dist_Data.ImgLabel,image_name)),1};
                class_vals = app.Dist_Data{find(strcmp(app.Dist_Data.ImgLabel,image_name)),3};
                all_class = app.Plot_Options.LabelOrder;

                if isnumeric(all_class)
                    app.red_text = text(app.Dist_Ax,find(class_vals(1,1)==all_class),...
                        label_vals(1,1),'\leftarrow Red Image','ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));
                else
                    app.red_text = text(app.Dist_Ax,find(strcmp(class_vals(1,1),all_class)),...
                        label_vals(1,1),'\leftarrow Red Image','ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));
                end
            
            end
            %end
            
        end
    end
    if app.Blue_Only
        cla(app.Blue_Img_Ax)
        hold off
        % Reading in image
        image_name = app.Blue_Comp_Image.Value;
        image_name = strsplit(image_name,',');
        image_name = image_name{1};

        if ~isempty(app.Current_Name)
            try
                app.Previous_Name{2} = app.Current_Name{2};
            catch
                app.Previous_Name{2} = app.Current_Name;
            end
        end
        app.Current_Name{2} = {image_name};
        
        [raw_img,norm_img,~,~] = Extract_Spec_Img(app,event,image_name);
        app.Current_Img{2} = raw_img;

        axes(app.Blue_Img_Ax);
        
        scaled_img = Add_Scalebar(raw_img, app.Blue_Img_Ax, app.Baseline_MPP, app);
        scaled_norm_img = Add_Scalebar(norm_img,app.Blue_Img_Ax,app.Baseline_MPP,app);

        app.Current_Img{2} = scaled_img;
        app.Current_NormImg{2} = scaled_norm_img;   

        imshow(scaled_img), axis image%, title('Blue ROI Image')
        Scale_Text(scaled_img, app.Blue_Img_Ax, app.Baseline_MPP,app)

        hold on   

        if ~isempty(app.map)
            % Get map(s)
            colormap jet
            % Removing re-scaling of feature maps
            app.im_blue = imagesc(app.Blue_Img_Ax,app.map{2});
            %handles.im_blue = imshow(handles.map{2});
            app.im_blue.AlphaData = get(app.Heat_Slide,'Value');
            hold off

            if ~app.Pause_Visualization
                % Moving rectangular ROI to contain all map data
                bin_roi = struct2cell(regionprops(bwconvhull(imbinarize(app.map{2},0)),'BoundingBox'));
    
                % For maps that are all zeros clear out histogram and table
                if ~isempty(bin_roi)
                    app.blue_roi = images.roi.Rectangle(app.Blue_Img_Ax,'Position',cell2mat(bin_roi),'Color','b',...
                        'FaceAlpha',0);
    
                    app.blue_rect_position = app.blue_roi.Position;
    
                    click_vis(app,event,app.blue_roi);
                    addlistener(app.blue_roi, 'ROIMoved',@(varargin)click_vis(app,event,app.blue_roi));
    
                else
                    % Only clear blue axis columns
                    prev_data = app.Rel_Feat_Table.Data;
                    prev_columns = app.Rel_Feat_Table.ColumnName;
                    blue_cols = find(contains(prev_columns,'Blue'));
    
                    new_data = prev_data;
                    for k = 1:length(blue_cols)
                        new_data(:,blue_cols(k)) = zeros(size(prev_data,1),1);
                    end
                    app.Rel_Feat_Table.Data = new_data;
                end
            else
                cla(app.Rel_Ax)
                app.Rel_Feat_Table.Data = {};
            end
            %if ~isempty(app.Full_Feature_set)
            % Annotating image position in feature space for PCA plots
            if length(app.map_idx)>1
                try
                    delete(app.blue_text)
                end
                try
                    delete(app.img_text)
                end

                coords = app.Dist_Data(find(strcmp(app.Dist_Data.ImgLabel,image_name)),1:2);
                app.blue_text = text(app.Dist_Ax,coords{1,1},coords{1,2},'\leftarrow Blue Image',...
                    'ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));
            else
                try
                    delete(app.blue_text)
                end
                try
                    delete(app.img_text)
                end

                label_vals = app.Dist_Data{find(strcmp(app.Dist_Data.ImgLabel,image_name)),1};
                class_vals = app.Dist_Data{find(strcmp(app.Dist_Data.ImgLabel,image_name)),3};
                all_class = app.Plot_Options.LabelOrder;
                
                if isnumeric(all_class)
                    app.blue_text = text(app.Dist_Ax, find(class_vals(1,1)==all_class),...
                        label_vals(1,1),'\leftarrow Blue Image','ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));
                else
                    app.blue_text = text(app.Dist_Ax,find(strcmp(class_vals(1,1),all_class)),...
                        label_vals(1,1),'\leftarrow Blue Image','ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));
                end
            end
            %end
            
        end
    end
        
    if ~app.Red_Only && ~app.Blue_Only
        cla(app.Red_Img_Ax)
        cla(app.Blue_Img_Ax)
        
        % Reading in both images
        red_image_name = app.Red_Comp_Image.Value;
        red_image_name = strsplit(red_image_name,',');
        red_image_name = red_image_name{1};

        [raw_img,norm_img,~,~] = Extract_Spec_Img(app,event,red_image_name);
        
        blue_image_name = app.Blue_Comp_Image.Value;
        blue_image_name = strsplit(blue_image_name,',');
        blue_image_name = blue_image_name{1};
        [raw_comp_img,norm_comp_img,~,~] = Extract_Spec_Img(app,event,blue_image_name);
        
        app.Previous_Name = app.Current_Name;
        app.Current_Name = {{red_image_name},{blue_image_name}};

        app.Heat_Slide.Enable = 'on';

        if ~isempty(app.map)
            % Get map(s)
            axes(app.Red_Img_Ax)
            
            scaled_img = Add_Scalebar(raw_img, app.Red_Img_Ax, app.Baseline_MPP, app);
            scaled_norm_img = Add_Scalebar(norm_img,app.Red_Img_Ax,app.Baseline_MPP, app);

            app.Current_Img{1} = scaled_img;
            app.Current_NormImg{1} = scaled_norm_img;

            imshow(scaled_img), axis image%, title('Red ROI Image')   
            Scale_Text(scaled_img, app.Red_Img_Ax, app.Baseline_MPP, app)

            hold on

            colormap jet
            app.im_red = imagesc(app.Red_Img_Ax,app.map{1});
            %handles.im_red = imshow(handles.map{1});
            app.im_red.AlphaData = app.Heat_Slide.Value;
            hold off

            axes(app.Blue_Img_Ax)
            
            scaled_img = Add_Scalebar(raw_comp_img, app.Blue_Img_Ax, app.Baseline_MPP, app);
            scaled_norm_img = Add_Scalebar(norm_comp_img, app.Blue_Img_Ax,app.Baseline_MPP, app);

            app.Current_Img{2} = scaled_img;
            app.Current_NormImg{2} = scaled_norm_img;

            imshow(scaled_img), axis image%, title('Blue ROI Image')
            Scale_Text(scaled_img, app.Blue_Img_Ax, app.Baseline_MPP, app)

            hold on

            colormap jet
            app.im_blue = imagesc(app.Blue_Img_Ax, app.map{2});
            %handles.im_blue = imshow(handles.map{2});
            app.im_blue.AlphaData = app.Heat_Slide.Value;
            hold off
            
            if ~app.Pause_Visualization
                % Moving rectangular ROI to contain all map data
                red_bin_roi = struct2cell(regionprops(bwconvhull(imbinarize(app.map{1},0)),'BoundingBox'));
    
                % For maps that are all zeros clear out histogram and table
                if ~isempty(red_bin_roi)
                    app.red_roi = images.roi.Rectangle(app.Red_Img_Ax,'Position',cell2mat(red_bin_roi),'Color','r',...
                        'FaceAlpha',0);
    
                    app.red_rect_position = app.red_roi.Position;
    
                else
                    % Only clear red columns
                    prev_data = app.Rel_Feat_Table.Data;
                    prev_columns = app.Rel_Feat_Table.ColumnName;
                    red_col = find(contains(prev_columns,'Red: Relative Area Contained'));
    
                    new_data = prev_data;
                    
                    new_data{:,red_col} = 0*new_data(:,red_col);
    
                    app.Rel_Feat_Table.Data = new_data;
    
                end
    
                % Moving rectangular ROI to contain all map data
                blue_bin_roi = struct2cell(regionprops(bwconvhull(imbinarize(app.map{2},0)),'BoundingBox'));
    
                % For maps that are all zeros clear out histogram and table
                if ~isempty(blue_bin_roi)
                    app.blue_roi = images.roi.Rectangle(app.Blue_Img_Ax,'Position',cell2mat(blue_bin_roi),'Color','b',...
                        'FaceAlpha',0);
                    app.blue_rect_position = app.blue_roi.Position;
                    
                else
                    % Only clear blue columns
                    prev_data = app.Rel_Feat_Table.Data;
                    prev_columns = app.Rel_Feat_Table.ColumnName;
                    blue_cols = find(contains(prev_columns,'Blue'));
    
                    new_data = prev_data;
                    for k = 1:length(blue_cols)
                        new_data(:,blue_cols(k)) = zeros(size(prev_data,1),1);
                    end
                    app.Rel_Feat_Table.Data = new_data;
    
                end
                
                % Only adding the listener to ROIs that aren't empty
                if ~isempty(red_bin_roi) && ~isempty(blue_bin_roi)
                    
                    % Might work with only specifying the one initially since
                    % handles.Comparing is true
                    click_vis(app,event,app.red_roi);
                    addlistener(app.red_roi, 'ROIMoved',@(varargin)click_vis(app,event,app.red_roi));
                    addlistener(app.blue_roi, 'ROIMoved',@(varargin)click_vis(app,event,app.blue_roi));
                else
                    if ~isempty(red_bin_roi)
                        click_vis(app,event,app.red_roi);
                        addlistener(app.red_roi, 'ROIMoved',@(varargin)click_vis(app,event,app.red_roi));
                    end
                    if ~isempty(blue_bin_roi)
                        click_vis(app,event,app.blue_roi);
                        addlistener(app.blue_roi, 'ROIMoved',@(varargin)click_vis(app,event,app.blue_roi));
                    end
                end
            else
                cla(app.Rel_Ax)
                app.Rel_Feat_Table.Data = {};
            end
               
            %if ~isempty(app.Full_Feature_set)
            % Annotating image position in feature space for PCA plots
            if length(app.map_idx)>1
                try
                    delete(app.red_text)
                end
                try
                    delete(app.blue_text)
                end
                try
                    delete(app.img_text)
                end

                coords = app.Dist_Data(find(strcmp(app.Dist_Data.ImgLabel,red_image_name)),1:2);
                app.red_text = text(app.Dist_Ax,coords{1,1},coords{1,2},...
                    '\leftarrow Red Image','ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));

                coords = app.Dist_Data(find(strcmp(app.Dist_Data.ImgLabel,blue_image_name)),1:2);
                app.blue_text = text(app.Dist_Ax,coords{1,1},coords{1,2},'\leftarrow Blue Image',...
                    'ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));
           
            else
                try
                    delete(app.red_text)
                end
                try
                    delete(app.blue_text)
                end
                try
                    delete(app.img_text)
                end

                label_vals = app.Dist_Data{find(strcmp(app.Dist_Data.ImgLabel,red_image_name)),1};
                class_vals = app.Dist_Data{find(strcmp(app.Dist_Data.ImgLabel,red_image_name)),3};
                all_class = app.Plot_Options.LabelOrder;

                if isnumeric(all_class)
                    app.red_text = text(app.Dist_Ax,find(class_vals(1,1)==all_class),...
                        label_vals(1,1),'\leftarrow Red Image','ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));
                else
                    app.red_text = text(app.Dist_Ax,find(strcmp(class_vals(1,1),all_class)),...
                        label_vals(1,1),'\leftarrow Red Image','ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app)); 
                end
                
                label_vals = app.Dist_Data{find(strcmp(app.Dist_Data.ImgLabel,blue_image_name)),1};
                class_vals = app.Dist_Data{find(strcmp(app.Dist_Data.ImgLabel,blue_image_name)),3};
                all_class = app.Plot_Options.LabelOrder;
                
                if isnumeric(all_class)
                    app.blue_text = text(app.Dist_Ax,find(class_vals(1,1)==all_class),...
                        label_vals(1,1),'\leftarrow Blue Image','ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));
                else
                    app.blue_text = text(app.Dist_Ax,find(strcmp(class_vals(1,1),all_class)),...
                        label_vals(1,1),'\leftarrow Blue Image','ButtonDownFcn',@(clicked,event)Grab_Image(clicked,event,app));
                end
            end
            %end
        end
    end
end

% Adding image to annotation axes
if length(app.Current_Img)==1
    cla(app.UIAxes)
    axes(app.UIAxes)
    imshow(app.Current_Img{1})
    Scale_Text(app.Current_Img{1}, app.UIAxes, app.Baseline_MPP, app)
     
    if height(app.UITable5.Data)>0
        app.UITable5.Data(:,2) = num2cell(cell2mat(app.UITable5.Data(:,2))+sum(app.new_annot,2));
        % Keeping track of number of annotated objects per class
        app.new_annot = zeros(height(app.UITable5.Data),1);
    end
    
    app.UIAxes2.Visible = 'off';

else
    cla(app.UIAxes)
    axes(app.UIAxes)
    imshow(app.Current_Img{1})
    Scale_Text(app.Current_Img{1}, app.UIAxes, app.Baseline_MPP, app)
    
    app.UIAxes.Visible = 'on';
    cla(app.UIAxes2)
    axes(app.UIAxes2)
    imshow(app.Current_Img{2})
    Scale_Text(app.Current_Img{2},app.UIAxes2,app.Baseline_MPP, app)
    
    % Keeping track of number of annotated objects per class
    if height(app.UITable5.Data)>0
        app.UITable5.Data(:,2) = num2cell(cell2mat(app.UITable5.Data(:,2))+sum(app.new_annot,2));
        app.new_annot = zeros(height(app.UITable5.Data),2);
    end
end


