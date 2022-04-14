% --- Function to save registration transform information for each pair of
% slides to the experiment file
function Transforms_to_Experiment_File(app,main_app)

registrations = main_app.Registration_Transforms;
assignin('base','Registration_Transforms',registrations)














