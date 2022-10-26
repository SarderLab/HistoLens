% --- Function to grab labeled image point from feature distribution plot
function Grab_Image(clicked,event,app)

% Resetting color and font weights of all other labels
all_text_handles = findall(app.Dist_Ax,'type','Text');
all_text = {findall(app.Dist_Ax,'type','Text').String};
all_labels = find(cellfun(@(x)contains(x,'\leftarrow'),all_text));

sub_labels = all_text_handles(all_labels);
for j = 1:length(sub_labels)
    sub_labels(j).Color = [0 0 0];
    sub_labels(j).FontWeight = 'normal';
end

clicked.Color = 'r';
clicked.FontWeight = 'bold';
selected_image = clicked.String;
selected_image = strrep(selected_image,'\leftarrow','');

if strcmp(app.Image_Name_Label.Visible,'on')
    
    image_names = cellfun(@(x)strsplit(x,','),app.Image_Name_Label.Items,'UniformOutput',false);
    image_names = cellfun(@(x)x{1},image_names,'UniformOutput',false);
    
    % Finding where the selected image is in the current list box
    new_image_count = find(strcmp(selected_image, image_names));
    if ~isempty(new_image_count)
        app.Image_Name_Label.Value = app.Image_Name_Label.Items(new_image_count);
        %app.img_count = new_image_count;
    end
    
end

if strcmp(app.Blue_Comp_Image.Visible,'on') || strcmp(app.Red_Comp_Image.Visible,'on')
    image_names = cellfun(@(x)strsplit(x,','),app.Blue_Comp_Image.Items,'UniformOutput',false);
    image_names = cellfun(@(x)x{1},image_names,'UniformOutput',false);
    
    new_image_count = find(strcmp(selected_image, image_names));
    
    % if in the blue_comp_image 
    if ~isempty(new_image_count)
        app.Blue_Comp_Image.Value = app.Blue_Comp_Image.Items(new_image_count);
    
        %app.comp_img_count = new_image_count;
        app.Blue_Only = true;
    else
        image_names = cellfun(@(x)strsplit(x,','),app.Red_Comp_Image.Items,'UniformOutput',false);
        image_names = cellfun(@(x)x{1},image_names,'UniformOutput',false);
    
        new_image_count = find(strcmp(selected_image,image_names));
        % if in the red_comp_image
        if ~isempty(new_image_count)
            app.Red_Comp_Image.Value = app.Red_Comp_Image.Items(new_image_count);
            
            %app.img_count = new_image_count;
            app.Red_Only = true;
        else
            app.Comparing = false;
            
            Flip_Image_Listbox(app,event)
            Plot_Feat(app,event)
            
            image_names = cellfun(@(x)strsplit(x,','),app.Image_Name_Label.Items,'UniformOutput',false);
            image_names = cellfun(@(x)x{1},image_names,'UniformOutput',false);
            %app.img_count = find(strcmp(image_names,selected_name));
            app.Image_Name_Label.Value = app.Image_Name_Label.Items(find(strcmp(image_names,selected_name)));
            % Changing visibility of load representative buttons
            if ~strcmp(app.Compare_Butt.Enable,'on')
                app.Compare_Butt.Visible = 'off';
                app.Compare_Butt.Enable = 'off';
            end
        end

    end
end

if ~isempty(new_image_count)
    Gen_Map(app,event)
    View_Image(app,event)
    Load_Notes(app,event)

    app.Red_Only = false;
    app.Blue_Only = false;
end

