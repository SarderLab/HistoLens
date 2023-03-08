% --- Function to update subsetting tree with new labels
function Update_Subset_Tree(app)

current_labels = {app.Tree.Children.Text};
features = app.Aligned_Labels.(app.Structure_Idx_Name).AllLabels;
non_overlap_features = features(find(~ismember(features,current_labels)));

for f = 1:length(non_overlap_features)
    this_feature = non_overlap_features{f};
    N = uitreenode(app.Tree);
    N.Text = this_feature;

    label_idx = find(strcmp(this_feature,app.Aligned_Labels.(app.Structure_Idx_Name).AllLabels));

    sub_features = app.Aligned_Labels.(app.Structure_Idx_Name).(strcat('Label_',num2str(label_idx))).Sub_Class;
    for sf = 1:length(sub_features)
        sN = uitreenode(N);
        sN.Text = sub_features{sf};
    end

    app.checked_master.(app.Structure_Idx_Name) = [app.checked_master.(app.Structure_Idx_Name);N];
end

app.Tree.CheckedNodes = app.checked_master.(app.Structure_Idx_Name);


