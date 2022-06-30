% --- Function to use the current ROIs to update stain normalization
% parameters when generating a new example
function Update_Normalization_Params(app)
    
% OD transformation
od_img = reshape(double(app.Current_Img),[],3);
od_img = -log((od_img+1)/240);

% Current structure StainNorm_Params
current_structure = app.SelectStructureDropDown.Value;

if ~isempty(app.StainNorm_Params) && ismember(current_structure,fieldnames(app.StainNorm_Params))
    norm_params = app.StainNorm_Params.(current_structure);
else
    norm_params = [];
end


if ~isempty(app.Current_ROIs.H_ROIs)
    for m = 1:size(app.Current_ROIs.H_ROIs,1)

        vertex_coords = app.Current_ROIs.H_ROIs(m,:);
        vertex_coords = [vertex_coords(1),vertex_coords(1),...
            vertex_coords(1)+vertex_coords(3),...
            vertex_coords(1)+vertex_coords(3);...
            vertex_coords(2),vertex_coords(2)+vertex_coords(4),...
            vertex_coords(2),vertex_coords(2)+vertex_coords(4)];

        h_mask = poly2mask(vertex_coords(1,:),vertex_coords(2,:),...
            size(app.Current_Img,1),size(app.Current_Img,2));
        
        % masking OD image according to annotated areas
        od_mask = od_img.*reshape(h_mask,[],1);
        
        % Finding non-zero values
        od_values = od_mask(~all(od_mask==0,2),:);
        
        % Column means and max
        mean_od = mean(od_values,1);
        max_od = max(od_values,[],1);
        
        if isempty(norm_params)
            norm_params.Means = zeros(3,2);
            norm_params.Maxs = zeros(3,2);
        
            norm_params.Means(:,1) = mean_od';
            norm_params.Maxs(:,1) = max_od';
        
        else
            current_means = norm_params.Means;
            current_maxs = norm_params.Maxs;
        
            norm_params.Means(:,1) = mean([current_means,mean_od'],2);
            norm_params.Maxs(:,1) = mean([current_maxs,max_od'],2);
        
        end
    end
end

if ~isempty(app.Current_ROIs.P_ROIs)
    for n = 1:size(app.Current_ROIs.P_ROIs,1)

        vertex_coords = app.Current_ROIs.P_ROIs(n,:);
        vertex_coords = [vertex_coords(1),vertex_coords(1),...
            vertex_coords(1)+vertex_coords(3),...
            vertex_coords(1)+vertex_coords(3);...
            vertex_coords(2),vertex_coords(2)+vertex_coords(4),...
            vertex_coords(2),vertex_coords(2)+vertex_coords(4)];

        p_mask = poly2mask(vertex_coords(1,:),vertex_coords(2,:),...
            size(app.Current_Img,1),size(app.Current_Img,2));
    
        % masking OD image according to annotated areas
        od_mask = od_img.*reshape(p_mask,[],1);
        
        % Finding non-zero values
        od_values = od_mask(~all(od_mask==0,2),:);
        
        % Column means and max
        mean_od = mean(od_values,1);
        max_od = max(od_values,[],1);
        
        if isempty(norm_params)
            norm_params.Means = zeros(3,2);
            norm_params.Maxs = zeros(3,2);
        
            norm_params.Means(:,2) = mean_od';
            norm_params.Maxs(:,2) = max_od';
            
        else
            current_means = norm_params.Means;
            current_maxs = norm_params.Maxs;
        
            norm_params.Means(:,2) = mean([current_means,mean_od'],2);
            norm_params.Maxs(:,2) = mean([current_maxs,max_od'],2);
            
        end
    end
end

app.MeanTable.Data = norm_params.Means;
app.MaxTable.Data = norm_params.Maxs;

app.StainNorm_Params.(current_structure).Means = norm_params.Means;
app.StainNorm_Params.(current_structure).Maxs = norm_params.Maxs;

app.Current_ROIs.H_ROIs = [];
app.Current_ROIs.P_ROIs = [];

