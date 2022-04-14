% --- Updating transparency callback
function update_trans(app,event)

if app.Image_Name_Label.Visible == 1
    app.im.AlphaData = app.Heat_Slide.Value;
else
    app.im_red.AlphaData = app.Heat_Slide.Value;
    app.im_blue.AlphaData = app.Heat_Slide.Value;
end
