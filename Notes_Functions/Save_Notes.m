% --- Function to save notes input by user to new filename set up when the
% Go-Button is pressed
function Save_Notes(app,event)

% If a notes file is not already loaded
if isempty(app.Notes_File)
    
    % Getting date-time
    t = now;
    d = datetime(t,'ConvertFrom','datenum','Format','dd-MMM-uuuu HH:mm:ss');
    
    current_time = strrep(strrep(string(d),' ','__'),':','_');
    
    notes_dir = strcat(app.Slide_Path,filesep,'HistoLens_Notes_Archive',filesep);
    if ~exist(notes_dir,'dir')
        mkdir(notes_dir)
    end
    
    % Getting name of slides directory
    slide_dir = app.Slide_Path;
    slide_dir = strsplit(slide_dir,filesep);
    slide_dir = slide_dir{end};

    notes_filename = strcat(notes_dir,slide_dir,'_',current_time,'_',app.Structure,'.csv');

    app.Notes_File.(app.Structure) = notes_filename;
    
    % Getting notes format
    all_img_names = app.Full_Feature_set.(app.Structure).ImgLabel;
    blank_notes = cell(length(all_img_names),1);

    notes_table = cell2table([all_img_names,blank_notes],'VariableNames',...
        {'ImgLabel','Notes'});
    
    app.Notes.(app.Structure) = notes_table;
    writetable(app.Notes.(app.Structure), app.Notes_File.(app.Structure));
    app.Notes_edit.Enable = 'on';
    app.Notes_edit.Value = '';

else
    %display('Notes not empty')
    if ~ismember(app.Structure,fieldnames(app.Notes_File))
        % Getting date-time
        t = now;
        d = datetime(t,'ConvertFrom','datenum','Format','dd-MMM-uuuu HH:mm:ss');
        
        current_time = strrep(strrep(string(d),' ','__'),':','_');
        
        notes_dir = strcat(app.Slide_Path,filesep,'HistoLens_Notes_Archive',filesep);
        if ~exist(notes_dir,'dir')
            mkdir(notes_dir)
        end
        
        % Getting name of slides directory
        slide_dir = app.Slide_Path;
        slide_dir = strsplit(slide_dir,filesep);
        slide_dir = slide_dir{end};
    
        notes_filename = strcat(notes_dir,slide_dir,'_',current_time,'_',app.Structure,'.csv');
    
        app.Notes_File.(app.Structure) = notes_filename;
        
        % Getting notes format
        all_img_names = app.Full_Feature_set.(app.Structure).ImgLabel;
        blank_notes = cell(length(all_img_names),1);
    
        notes_table = cell2table([all_img_names,blank_notes],'VariableNames',...
            {'ImgLabel','Notes'});
        
        app.Notes.(app.Structure) = notes_table;
        writetable(app.Notes.(app.Structure), app.Notes_File.(app.Structure));
        app.Notes_edit.Enable = 'on';
        app.Notes_edit.Value = '';
    end
    
end

if ~app.Comparing
    
    if ~isempty(app.Notes_edit.Value{1})
        %display('Note edit field not empty')
        selected = app.Image_Name_Label.Value;

        selected = strsplit(selected,',');
        selected = selected{1};

        app.Notes.(app.Structure).Notes{strcmp(app.Notes.(app.Structure).ImgLabel,selected)} = app.Notes_edit.Value{1};

        % Saving notes table to the pre-specified notes filename
        writetable(app.Notes.(app.Structure),app.Notes_File.(app.Structure));
    end
else
    
    if ~isempty(app.Img_one_Edit.Value)
        selected1 = app.Red_Comp_Image.Value;

        selected1 = strsplit(selected1,',');
        selected1 = selected1{1};

        app.Notes.(app.Structure).Notes{strcmp(app.Notes.(app.Structure).ImgLabel,selected1)} = app.Img_one_Edit.Value{1};
   
    end
    
    if ~isempty(app.Img_two_Edit.Value)
        selected2 = app.Blue_Comp_Image.Value;

        selected2 = strsplit(selected2,',');
        selected2 = selected2{1};

        app.Notes.(app.Structure).Notes{strcmp(app.Notes.(app.Structure).ImgLabel,selected2)} = app.Img_two_Edit.Value{1};

    end
    
    if ~isempty(app.Img_one_Edit.Value) || ~isempty(app.Img_two_Edit.Value)
        % Saving notes table to the pre-specified notes filename
        writetable(app.Notes.(app.Structure),app.Notes_File.(app.Structure));
    end
    
end


