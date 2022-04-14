%% --- Function to load up new registration pair
function Load_Registration(app)

% Getting the slide names in specific column index of Stain Table
slide_names = app.Stain_Table{app.Slide_Count,:};

% Loading up two images
if ~any(contains(slide_names,'.svs'))
    img_paths = cellfun(@(x,y) strcat(x,y,'.svs'),app.Slide_Path,slide_names,'UniformOutput',false);
else
    img_paths = cellfun(@(x,y) strcat(x,y),app.Slide_Path,'UniformOutput',false);
end

app.Current_Thumbnails.Image1 = imread(img_paths{1},'Index',2);
app.Current_Thumbnails.Image2 = imread(img_paths{2},'Index',2);

app.Current_Thumbnails.Image1_Info = imfinfo(img_paths{1});
app.Current_Thumbnails.Image2_Info = imfinfo(img_paths{2});

% Displaying images together side by side
%axes(app.ImageAxis)
app.Current_Thumbnails.Image1_Axis = app.ImageAxis;
axes(app.ImageAxis)
imshow(app.Current_Thumbnails.Image1,'Parent',app.ImageAxis)

app.Current_Thumbnails.Image2_Axis = app.ImageAxis_2;
axes(app.ImageAxis_2)
imshow(app.Current_Thumbnails.Image2,'Parent',app.ImageAxis_2)

% Making initial annotation panel visible
app.Step1Panel.Visible = 'on';
app.Step2Panel.Visible = 'off';
app.Step3Panel.Visible = 'off';
app.Step4Panel.Visible = 'off';

