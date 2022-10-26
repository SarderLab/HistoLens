% --- Function to load/save notes for observations on each image
%function Load_Notes(hObject, eventdata, handles)
function Load_Notes(app, event)

if app.Comparing && ~strcmp(app.Image_Name_Label.Visible,'on')
    
    if strcmp(app.Img_one_txt.Visible,'off')
        app.Img_one_txt.Visible = 'on';
        app.Img_one_Edit.Visible = 'on';
        app.Img_one_Edit.Enable = 'on';
        
        app.Img_two_txt.Visible = 'on';
        app.Img_two_Edit.Visible = 'on';
        app.Img_two_Edit.Enable = 'on';
        
        app.Notes_edit.Visible = 'off';
        app.Notes_edit.Enable = 'off';
    end

    selected1 = app.Current_Name{1};
    
    notes_contents = app.Notes.(app.Structure).Notes(strcmp(app.Notes.(app.Structure).ImgLabel,selected1),:);
    notes_contents = notes_contents{1};
    
    app.Img_one_txt.Text = selected1;
    if ~isempty(notes_contents)
        app.Img_one_Edit.Value = notes_contents;
    else
        app.Img_one_Edit.Value = '';
    end
    
    selected2 = app.Current_Name{2};
    
    notes_contents = app.Notes.(app.Structure).Notes(strcmp(app.Notes.(app.Structure).ImgLabel,selected2),:);
    notes_contents = notes_contents{1};
    
    app.Img_two_txt.Text = selected2;
    if ~isempty(notes_contents)
        app.Img_two_Edit.Value = notes_contents;
    else
        app.Img_two_Edit.Value = '';
    end
    
else
        
    if strcmp(app.Img_one_txt.Visible,'on')
        app.Img_one_txt.Visible = 'off';
        app.Img_one_Edit.Visible = 'off';
        app.Img_one_Edit.Enable = 'off';
        
        app.Img_two_txt.Visible = 'off';
        app.Img_two_Edit.Visible = 'off';
        app.Img_two_Edit.Enable = 'off';
        
        app.Notes_edit.Visible = 'on';
        app.Notes_edit.Enable = 'on';
    end

    % handles.Notes should be a table with one column corresponding to image
    % name and the other with any notes the user makes.
    selected = app.Current_Name;
    
    notes_contents = app.Notes.(app.Structure).Notes(strcmp(app.Notes.(app.Structure).ImgLabel,selected),:);
    notes_contents = notes_contents{1};

    if ~isempty(notes_contents)
        app.Notes_edit.Value = notes_contents;
    else
        app.Notes_edit.Value = '';
    end
end

