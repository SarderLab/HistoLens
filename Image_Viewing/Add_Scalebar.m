% --- Function to add scale bar to images
function scaled_img = Add_Scalebar(img, img_axis, mpp, app)

% size and width of scale bar
if ~isnan(mpp)& mpp~=0
    scale_length = round(50/mpp);  
else
    scale_length = 50;
end

% Defining height and width for lower right hand corner
[rows, cols, ~] = size(img);

% Setting image locations to white
scaled_img = img;
scale_width = 5;
scaled_img(rows-10-scale_width:rows-10, cols-10-scale_length:cols-10,:) = 255;



