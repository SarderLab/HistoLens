% --- Function to reverse the visibility and enabled status of the image
% name, class list boxes
function Flip_Image_Listbox(app,event)

if app.Comparing
    
    % From selecting Compare_Butt, initializing two sets of axes
    if strcmp(app.Red_Img_Ax.Visible,'off') && strcmp(app.Blue_Img_Ax.Visible,'off')
        app.Red_Img_Ax.Visible = 'on';
        app.Blue_Img_Ax.Visible = 'on';
 
        app.Red_Comp_Image.Enable = 'on';
        app.Red_Comp_Image.Visible = 'on';
        
        app.BlueROIImagesLabel.Visible = 'on';
        app.RedROIImagesLabel.Visible = 'on';
    
        app.Blue_Comp_Image.Enable = 'on';
        app.Blue_Comp_Image.Visible = 'on';
        
        cla(app.Img_Ax)
        app.Image_Name_Label.Enable = 'off';
        app.Image_Name_Label.Visible = 'off';
        app.Img_Ax.Visible = 'off';
        
        app.Red_Only = false;
        app.Blue_Only = false;
        
    end    

else
    
    cla(app.Red_Img_Ax)
    cla(app.Blue_Img_Ax)
    cla(app.Img_Ax)
    
    if ~isempty(app.Full_Feature_set)
        app.Compare_Butt.Enable = 'off';
        app.Select_New_Butt.Enable = 'on';
    end
    
    app.Image_Name_Label.Enable = 'on';
    app.Image_Name_Label.Visible = 'on';
    
    app.Red_Img_Ax.Visible = 'off';
    app.Blue_Img_Ax.Visible = 'off';
    
    app.Red_Only = false;
    app.Blue_Only = false;
        
    app.Red_Comp_Image.Enable = 'off';
    app.Red_Comp_Image.Visible = 'off';
    
    app.Blue_Comp_Image.Enable = 'off';
    app.Blue_Comp_Image.Visible = 'off';
    
    app.BlueROIImagesLabel.Visible = 'off';
    app.RedROIImagesLabel.Visible = 'off';
    
end
