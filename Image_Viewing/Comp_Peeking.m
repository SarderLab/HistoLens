% --- Function to view compartment in addition to feature map
function Comp_Peeking(app,event)

comp_list = {'Pas','Lum','Nuc'};

this_comp = find(strcmp(app.Comp_Peek,comp_list));
if strcmp(app.Image_Name_Label.Visible,'on')
    img = app.Current_Img;

    compartment = app.Comp_Img;
    img_ax = app.Img_Ax;
    map = app.map;
    comp_idx = this_comp;
    color = '';

    Peek(img_ax, color, img, map, compartment, comp_idx, app, event);
else
    
    % Making comparisons on two different axes
    img = app.Current_Img;
    compartment = app.Comp_Img;
    img_ax = {app.Red_Img_Ax, app.Blue_Img_Ax};
    map = app.map;
    comp_idx = this_comp;
    color = {'red','blue'};

    Peek(img_ax, color, img, map, compartment, comp_idx, app, event);

end


function Peek(img_ax, color, img, map, compartment, comp_idx, app, event)

% Getting the buttons to say the right thing
if comp_idx==1
    if strcmp(app.PAS_Butt.Text,'PAS+')
        app.PAS_Butt.Text = 'Un-See PAS+';
        unsee = false;
    else
        app.PAS_Butt.Text = 'PAS+';
        unsee = true;
    end
    vis_color = 'magenta';
end
if comp_idx==2
    if strcmp(app.Lum_Butt.Text,'Luminal Space')
        app.Lum_Butt.Text = 'Un-See Lumen';
        unsee = false;
    else
        app.Lum_Butt.Text = 'Luminal Space';
        unsee = true;
    end
    vis_color = 'yellow';
end
if comp_idx==3
    if strcmp(app.Nuc_Butt.Text,'Nuclei')
        app.Nuc_Butt.Text = 'Un-See Nuclei';
        unsee = false;
    else
        app.Nuc_Butt.Text = 'Nuclei';
        unsee = true;
    end
    vis_color = 'cyan';
end

% Something that allows iteration between the two colors and images
if iscell(map)
    img_it = img;
    map_it = map;
    comp_it = compartment;
    color_it = color;
    axis_it = img_ax;
else
    img_it = img;
    map_it = {map};
    comp_it = compartment;
    color_it = {color};
    axis_it = {img_ax};
end
    

for i = 1:length(axis_it)
    if ~unsee
        axes(axis_it{i})
        overlaid = imoverlay(img_it{i},comp_it{i}(:,:,comp_idx),vis_color);
        scaled_img = Add_Scalebar(overlaid, axis_it{i},app.MPP);
        imshow(scaled_img), axis image
        Scale_Text(scaled_img, axis_it{i}, app.MPP)

        hold on
        
        if ~strcmp(color_it{i},'')
            app.(strcat('im_',color_it{i})) = imagesc(axis_it{i}, map_it{i});
            app.(strcat('im_',color_it{i})).AlphaData = app.Heat_Slide.Value;
        else
            app.im = imagesc(axis_it{i}, map_it{i});
            app.im.AlphaData = app.Heat_Slide.Value;
        end
        hold off

        % Moving rectangular ROI to contain all map data
        bin_roi = struct2cell(regionprops(bwconvhull(imbinarize(map_it{i},0)),'BoundingBox'));

        % For maps that are all zeros clear out histogram and table
        if ~isempty(bin_roi)
            
            if ~strcmp(color_it{i},'')
                roi = images.roi.Rectangle(axis_it{i},'Position',cell2mat(bin_roi),'Color',color_it{i},'FaceAlpha',0);
                app.(strcat(color_it{i},'_roi')) = roi;
                
                click_vis(app,event,app.(strcat(color_it{i},'_roi')));
                addlistener(app.(strcat(color_it{i},'_roi')), 'ROIMoved',@(varargin)click_vis(app,event,app.(strcat(color_it{i},'_roi'))));

            else
                roi = images.roi.Rectangle(axis_it{i},'Position',cell2mat(bin_roi),'FaceAlpha',0);
                
                click_vis(app,event,roi);
                addlistener(roi, 'ROIMoved',@(varargin)click_vis(app,event,roi));
            end
            
            if ~strcmp(color_it{i},'')
                app.([color_it{i},'_rect_position']) = roi.Position;
            else
                app.rect_position = roi.Position;
            end

        else
            if ~strcmp(color_it,'')
                prev_data = app.Rel_Feat_Table.Data;
                prev_columns = app.Rel_Feat_Table.ColumnName;

                color_cols = find(contains(prev_columns,color_it{i}));

                app.Rel_Feat_Table.Data = prev_data(:,~color_cols);


            else
                cla(app.Rel_Ax)
                app.Rel_Feat_Table.Data = {};
            end

        end
    else

        axes(axis_it{i})
        scaled_img = Add_Scalebar(img_it{i},axis_it{i},app.MPP);
        imshow(scaled_img), axis image   
        Scale_Text(scaled_img, axis_it{i}, app.MPP)

        hold on

        if ~strcmp(color,'')
            app.(strcat('im_',color_it{i})) = imagesc(axis_it{i}, map_it{i});
            app.(strcat('im_',color_it{i})).AlphaData = app.Heat_Slide.Value;
        else
            app.im = imagesc(axis_it{i}, map_it{i});
            app.im.AlphaData = app.Heat_Slide.Value;
        end
        hold off

        % Moving rectangular ROI to contain all map data
        bin_roi = struct2cell(regionprops(bwconvhull(imbinarize(map_it{i},0)),'BoundingBox'));

        % For maps that are all zeros clear out histogram and table
        if ~isempty(bin_roi)
            if ~strcmp(color_it{i},'')
                roi = images.roi.Rectangle(axis_it{i},'Position',cell2mat(bin_roi),'Color',color_it{i},...
                    'FaceAlpha',0);
                app.(strcat(color_it{i},'_roi')) = roi;
                
                click_vis(app, event, app.(strcat(color_it{i},'_roi')));
                addlistener(app.(strcat(color_it{i},'_roi')), 'ROIMoved',@(varargin)click_vis(app,event,app.(strcat(color_it{i},'_roi'))));

            else
                roi = images.roi.Rectangle(axis_it{i},'Position',cell2mat(bin_roi),...
                    'FaceAlpha',0);
                click_vis(app, event, roi);
                addlistener(roi, 'ROIMoved',@(varargin)click_vis(app,event,roi));
                
            end
            
            if ~strcmp(color_it{i},'')
                app.(strcat(color_it{i},'_rect_position')) = roi.Position;
            else
                app.rect_position = roi.Position;
            end         

        else
            if ~strcmp(color_it{i},'')
                prev_data = app.Rel_Feat_Table.Data;
                prev_columns = app.Rel_Feat_Table.ColumnName;

                color_cols = find(contains(prev_columns,color_it{i}));

                new_data = prev_data;
                new_data(:,color_cols) = zeros(size(prev_data,1),length(color_cols));

                app.Rel_Feat_Table.Data = new_data;

            else
                cla(app.Rel_Ax)
                app.Rel_Feat_Table.Data = {};
            end
        end

    end
end

