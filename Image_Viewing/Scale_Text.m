% --- Function to add scale bar text
function Scale_Text(img, img_axis, mpp)

% size and width of scale bar
if ~isnan(mpp) & mpp~=0
    scale_length = round(50/mpp);  
    text_text = strcat('50', '\mu','m');
else
    scale_length = 50;
    text_text = '50 px';
end
scale_width = 5;

% Defining height and width for lower right hand corner
[rows, cols, ~] = size(img);

% Text location
text_loc = [rows-15-scale_width,cols-15-(scale_length/2)];
scale_text = text(img_axis, text_loc(2), text_loc(1), text_text,'FontSize',10,...
    'FontWeight','bold','Color',[1,1,1], 'HorizontalAlignment','center');




