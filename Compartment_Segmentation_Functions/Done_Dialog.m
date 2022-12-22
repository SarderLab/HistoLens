% --- Function containing dialog box for whether or not to continue if
% pressing done before going through each slide in compartment segmentation
% procedure
function go_for_it = Done_Dialog
    go_for_it = false;

    d = dialog("Name","Project Segmentation Parameters",...
        "Icon","Logo.png",...
        'Position',[300 300 250 150]);
    txt = uicontrol('Parent',d,...
        'Style','text',...
        'Position',[20 80 210 40],...
        'String','Are you sure you want to continue?\nSegmentation parameters for remaining slides and structures will be copied from previous slides');

    ok_btn = uicontrol('Parent',d,...
        'Position',[75 70 100 25],...
        'String', 'OK',...
        'Callback',@update_goforit);

    uiwait(d);

    function update_goforit(d,event)
        go_for_it = true;
        delete(d)
    end
end


