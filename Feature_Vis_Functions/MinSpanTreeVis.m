function min_span_tree_vis = MinSpanTreeVis(M, nuc_mask, w_in_range)

L = bwlabel(nuc_mask);


% Degrees per node
degrees = degree(M);
degree_mask = zeros(size(nuc_mask));
for d = 1:length(degrees)
    degree_mask = degree_mask+(L==d)*degrees(d);
end

% Leaf Fraction
leafs = find(degrees==1);
leaf_mask = zeros(size(nuc_mask));
for l = 1:length(leafs)
    leaf_mask = leaf_mask+(L==leafs(l));
end

% Edge Length stats
edge_lengths = M.Edges;

mean_edge = mean(edge_lengths.Weight);
median_edge = median(edge_lengths.Weight);
z_score_edge = abs(zscore(edge_lengths.Weight));

% Iterating through individual nuclei and weighting according to similarity
% to global mean and median and by magnitude of z-score
edge_mean_vis = zeros(size(nuc_mask));
edge_median_vis = zeros(size(nuc_mask));
edge_std_vis = zeros(size(nuc_mask));
for e = 1:max(max(L))

    % finding all the edges that start and end with that nucleus
    [nuc_edges,~] = find(edge_lengths.EndNodes==e);
    
    for ne = 1:length(nuc_edges)
        if mean_edge-(w_in_range*mean_edge)<=edge_lengths.Weight(nuc_edges(ne)) && edge_lengths.Weight(nuc_edges(ne))<=mean_edge+(w_in_range*mean_edge)
            edge_mean_vis = edge_mean_vis+(L==e);
        end
        if median_edge-(w_in_range*median_edge)<=edge_lengths.Weight(nuc_edges(ne)) && edge_lengths.Weight(nuc_edges(ne))<=median_edge+(w_in_range*median_edge)
            edge_median_vis = edge_median_vis+(L==e);
        end
        
        edge_std_vis = edge_std_vis+z_score_edge(nuc_edges(ne))*(L==e);
    end 
          
end    

edge_mean_vis = rescale(edge_mean_vis);
edge_median_vis = rescale(edge_median_vis);
edge_std_vis = rescale(edge_std_vis);
    
min_span_tree_vis = {degree_mask,leaf_mask,edge_mean_vis,edge_median_vis,edge_std_vis};




