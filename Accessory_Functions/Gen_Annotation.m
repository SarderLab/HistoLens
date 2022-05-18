% --- Function for generating annotations
function Gen_Annotation(app, event)

current_tab = app.TabGroup3.SelectedTab;
% If more colors are needed then bro idk
ann_colors = {'blue','red','green','yellow','cyan','pink', 'blueviolet','brown',...
    'orange','white','magenta'};

% For the Red Comp Image tab
if strcmp(current_tab.Title,'Red Comp Image')
    
    if ~app.Comparing
        img_name = app.Full_Feature_set.(app.Structure).ImgLabel{find(strcmp(app.Image_Name_Label.Items,app.Image_Name_Label.Value))};
    else
        img_name = app.Full_Feature_set.(app.Structure).ImgLabel{find(strcmp(app.Red_Comp_Image.Items,app.Red_Comp_Image.Value))};
    end
    ann_dir = [app.Slide_Path,filesep,img_name,filesep,'Annotated_Images',filesep];
    img_filename = [ann_dir,img_name,'_ann.png'];
    if exist(img_filename,'file')
        app.Red_Mask = imread(img_filename);
        app.ResetAnnotationButton.Enable = 'on';
    else
        app.Red_Mask = zeros(size(app.Current_Img{1},1),size(app.Current_Img{1},2));
        app.ResetAnnotationButton.Enable = 'off';
    end
    
    axes(app.UIAxes)
    roi = images.roi.Freehand(app.UIAxes,'Color',ann_colors{app.ann_value},'FaceAlpha',0.2);
    roi.draw
    
    % Need to change this up to prevent overlapping labels of the same
    % class getting overwritten
    app.Red_Mask = app.Red_Mask+(roi.createMask);
    app.ResetAnnotationButton.Enable = 'on';
    
else
    img_name = app.Full_Feature_set.(app.Structure).ImgLabel{find(strcmp(app.Blue_Comp_Image.Items,app.Blue_Comp_Image.Value))};
    
    ann_dir = [app.Slide_Path,filesep,img_name,filesep,'Annotated_Images',filesep];
    img_filename = [ann_dir,img_name,'_ann.png'];
    if exist(img_filename,'file')
        app.Blue_Mask = imread(img_filename);
        app.ResetAnnotationButton_2.Enable = 'on';
    else
        app.Blue_Mask = zeros(size(app.Current_Img{2},1),size(app.Current_Img{2},2));
        app.ResetAnnotationButton_2.Enable = 'off';
    end

    axes(app.UIAxes2)
    roi = images.roi.Freehand(app.UIAxes2,'Color',ann_colors{app.ann_value},'FaceAlpha',0.2);
    roi.draw
    
    % Need to change this up to prevent overlapping labels of the same
    % class getting overwritten
    app.Blue_Mask = app.Blue_Mask+(roi.createMask);
    app.ResetAnnotationButton_2.Enable = 'on';
end


% Saving annotations to directory
if any(app.Red_Mask,'all')
    if ~app.Comparing
        img_name = app.Full_Feature_set.(app.Structure).ImgLabel{find(strcmp(app.Image_Name_Label.Items,app.Image_Name_Label.Value))};
    else
        img_name = app.Full_Feature_set.(app.Structure).ImgLabel{find(strcmp(app.Red_Comp_Image.Items,app.Red_Comp_Image.Value))};
    end
    
    % Checking if annotation directory exists 
    ann_dir = [app.Slide_Path,filesep,img_name,filesep,'Annotated_Images',filesep,...
        app.AvailableClassesDropDown.Value,filesep];    
    if ~exist(ann_dir,'dir')
        mkdir(ann_dir)
    end
    
    imwrite(uint8(255.*app.Red_Mask),[ann_dir,img_name,'_ann.png'])

    % Keeping track of number of new annotated objects per class
    app.new_annot(:,1) = app.new_annot(:,1) | strcmp(app.AvailableClassesDropDown.Items,...
        app.AvailableClassesDropDown.Value)';

end

if any(app.Blue_Mask,'all')
    img_name = app.Full_Feature_set.(app.Structure).ImgLabel{find(strcmp(app.Blue_Comp_Image.Items,app.Blue_Comp_Image.Value))};
    
    % Checking if annotation directory exists 
    ann_dir = [app.Slide_Path,filesep,img_name,filesep,'Annotated_Images',filesep,...
        app.AvailableClassesDropDown.Value,filesep];    
    if ~exist(ann_dir)
        mkdir(ann_dir)
    end
        
    imwrite(uint8(255.*app.Blue_Mask),[ann_dir,img_name,'_ann.png'])

    % Keeping track of number of new annotated objects per class
    app.new_annot(:,2) = app.new_annot(:,2) | strcmp(app.AvailableClassesDropDown.Items,...
        app.AvailableClassesDropDown.Value);
    
end

