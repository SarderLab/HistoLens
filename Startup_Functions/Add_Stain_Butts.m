% --- Function to add sub-compartment peeking buttons to main_app
function Add_Stain_Butts(app)

stain_names = app.Stain_Names;
delete(get(app.Stain_Peek,'Children'))

grid_layouter = uigridlayout(app.Stain_Peek);
grid_layouter.RowHeight = {'fit'};
for i = 1:length(stain_names)

    %stain_field = strcat('Stain',num2str(i));
    %butt_position = [20+100*(i-1) 17 100 40];

    stain_butt = uibutton(grid_layouter,'push');
    stain_butt.Enable = 'off';
    %stain_butt.Position = butt_position;
    stain_butt.Layout.Row = 1;
    stain_butt.Layout.Column = i;
    stain_butt.Text = stain_names{i};
    stain_butt.FontWeight = 'bold';
    stain_butt.ButtonPushedFcn = {@Comp_Peeking, i, app};
    

end


