% --- Function to check for checked nodes and organize included classes and
% quantitative features
function Check_The_Checked(app)

checkedNodes = app.Tree.CheckedNodes;
selectedNodes = app.Tree.SelectedNodes;

quant_statuses = {'Quantitative Continuous','Quantitative Categorical'};

checked_text = cell(length(checkedNodes),1);
for i = 1:length(checked_text)
    checked_text{i} = checkedNodes(i).Text;
end

selected_text = selectedNodes.Text;

% Checking for overlap with column values of labels
checked_columns = intersect(checked_text,app.Labels.Properties.VariableNames);
selected_columns = intersect(selected_text,app.Labels.Properties.VariableNames);
if ~isempty(selected_columns)
    selected_columns = selected_columns{1};
end

% Check if the selected value was a whole column
if ~isempty(selected_columns)
    % Check if the selected column is checked
    if ismember(selected_columns,checked_columns)
        if ~app.Tree_Labels.(selected_columns).IsNumeric
            app.Include_Class.(selected_columns).Sub_Classes = app.Tree_Labels.(selected_columns).Sub_Class;
        else
            % Default initial check of numeric feature is just to use it as
            % a quantitative continuous
            app.Include_Class.(selected_columns).Quantitative = 'Quantitative Continuous';
        end
                
    else
        % This is when the selected column is unchecked and therefore
        % deselected
        app.Include_Class.(selected_columns) = [];
    end
else
    % This is if the selected box is not a column, so it must be a
    % sub-class
    parent_node = selectedNodes.Parent;
    if ~app.Tree_Labels.(parent_node.Text).IsNumeric
        old_sub_classes = app.Include_Class.(parent_node.Text).Sub_Classes;

        selected_idx = find(strcmp(selected_text,old_sub_classes));

        % Checking vs. un-Checking
        if ~ismember(selected_text,checked_text)
            app.Include_Class.(parent_node.Text).Sub_Classes(selected_idx) = [];

        else
            app.Include_Class.(parent_node.Text).Sub_Classes = [old_sub_classes;{selected_text}];

        end
    else
        old_quant_status = app.Include_Class.(parent_node.Text).Quantitative;
        
        % Only worrying about un-Checking since automatically checking
        % other
        if ~ismember(selected_text,checked_text)
            % Assigning new quantitative status
            app.Include_Class.(parent_node.Text).Quantitative = quant_statuses(find(~strcmp(quant_statuses,old_quant_status)));
            % Checking other node
            app.Tree.CheckedNodes(find(strcmp(old_quant_status,checked_text))) = [];
        end
    end
end

