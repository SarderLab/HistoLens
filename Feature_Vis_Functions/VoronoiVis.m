function voronoi_vis = VoronoiVis(verts, cells, nuc_mask, w_in_range)

% Inter-Vertex Distance
distances = zeros(size(verts,1));
for v = 2:size(verts,1)
    for w = 2:size(verts,1)
        distances(v,w) = sqrt((verts(v,1)-verts(w,1))^2+(verts(v,2)-verts(w,2))^2);
    end
end

% Vertex-wise mean distance
vert_means = mean(distances);
vert_std = abs(zscore(vert_means));
% total mean
total_mean = mean(vert_means);

mean_vert_vis = zeros(size(nuc_mask));
median_vert_vis = zeros(size(nuc_mask));
std_vert_vis = zeros(size(nuc_mask));

% Ridge Lengths averaged per cell/island containing nucleus
ridge_lengths = zeros(length(cells),1);
std_ridge_lengths = zeros(length(cells),1);
med_ridge_lengths = zeros(length(cells),1);
for c = 1:length(cells)
    cell_ridge_dist = zeros(length(cells{c}),1);
   for d = 2:length(cells{c})
       cell_d = cells{c};
       cell_ridge_dist(d-1) = distances(cell_d(d),cell_d(d-1));
   end
   ridge_lengths(c) = mean(cell_ridge_dist);
   std_ridge_lengths(c) = std(cell_ridge_dist);
   med_ridge_lengths(c) = median(cell_ridge_dist);
end

mean_ridge = mean(ridge_lengths);
median_ridge = median(ridge_lengths);
std_ridge = abs((ridge_lengths-mean_ridge)/nanstd(ridge_lengths));

mean_ridge_vis = zeros(size(nuc_mask));
median_ridge_vis = zeros(size(nuc_mask));
std_ridge_vis = zeros(size(nuc_mask));

% Area of each region
cell_areas = zeros(length(cells),1);
for ca = 1:length(cells)
    v1 = verts(cells{ca},1);
    v2 = verts(cells{ca},2);
    cell_areas(ca) = polyarea(v1,v2);
end

mean_area = nanmean(cell_areas);
median_area = nanmedian(cell_areas);
std_area = abs((cell_areas-mean_area)/nanstd(cell_areas));

mean_area_vis = zeros(size(nuc_mask));
median_area_vis = zeros(size(nuc_mask));
std_area_vis = zeros(size(nuc_mask));

nuc_L = bwlabel(nuc_mask);

for nuc = 1:length(cells)
    % Mean inter-vertex distance
    if ridge_lengths(nuc)>= total_mean-(w_in_range*total_mean) && ridge_lengths(nuc)<= total_mean+(w_in_range*total_mean)
        mean_vert_vis = mean_vert_vis+(nuc_L==nuc);
    end
    % StdDev inter-vertex distance
    std_vert_vis = std_vert_vis+std_ridge(nuc).*(nuc_L==nuc);
    % Median inter-vertex distance
    if ridge_lengths(nuc)>=median_ridge-(w_in_range*median_ridge) && ridge_lengths(nuc)<= median_ridge+(w_in_range*median_ridge)
        median_vert_vis = median_vert_vis+(nuc_L==nuc);
    end
    
    % Mean ridge length
    if ridge_lengths(nuc)>= mean_ridge-(w_in_range*mean_ridge) && ridge_lengths(nuc)<= mean_ridge+(w_in_range*mean_ridge)
        mean_ridge_vis = mean_ridge_vis+(nuc_L==nuc);
    end
    % StdDev ridge length
    std_ridge_vis = std_ridge_vis+std_ridge(nuc).*(nuc_L==nuc);
    % Median ridge length
    if ridge_lengths(nuc)>= median_ridge-(w_in_range*median_ridge) && ridge_lengths(nuc)<= median_ridge+(w_in_range*median_ridge)
        median_ridge_vis = median_ridge_vis+(nuc_L==nuc);
    end
    
    % Cell areas (not Inf)
    if ~isnan(cell_areas(nuc)) 
        % Mean area
        if cell_areas(nuc)>= mean_area-(w_in_range*mean_area) && cell_areas(nuc)<=mean_area+(w_in_range*mean_area)
            mean_area_vis = mean_area_vis+(nuc_L==nuc);
        end
        % Median area
        if cell_areas(nuc)>= median_area-(w_in_range*median_area) && cell_areas(nuc)<=median_area+(w_in_range*median_area)
            median_area_vis = median_area_vis+(nuc_L==nuc);
        end 
        % StdDev area
        std_area_vis = std_area_vis+std_area(nuc).*(nuc_L==nuc);
    end
end

voronoi_vis = {mean_vert_vis, rescale(std_vert_vis), median_vert_vis, mean_ridge_vis, rescale(std_ridge_vis), median_ridge_vis, mean_area_vis, rescale(std_area_vis), median_area_vis}; 








