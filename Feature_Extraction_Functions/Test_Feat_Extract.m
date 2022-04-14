% Testing out feature extraction
clc
close all
clear all

nuc_img = imread('Diabetic nephropathy_0_1_nuc.png');
%nuc_img = nuc_img(:,:,1);
%nuc_img = imbinarize(nuc_img);


nuc_coords = regionprops(nuc_img,'centroid');
nuc_coords = struct2cell(nuc_coords);
nuc_coords = cell2mat(nuc_coords');

if length(nuc_coords)>1
    
    D = zeros(length(nuc_coords));
    for a = 1:length(nuc_coords)
        D(a,:) = sqrt((nuc_coords(:,1)-nuc_coords(a,1)).^2+(nuc_coords(:,2)-nuc_coords(a,2)).^2);
    end
    
    G = graph(D);
    M = minspantree(G);
    
    deg_per_node = sum(degree(M))/length(nuc_coords);
    leaf_fraction = sum(degree(M)==1)/(length(nuc_coords)-1);
    avg_edge = mean(M.Edges.Weight);
    std_edge = std(M.Edges.Weight);
    med_edge = median(M.Edges.Weight);
end

if length(nuc_coords)>2
    
    [verts, cells] = voronoin(nuc_coords);
    
    D = zeros(length(verts)-1);
    for a = 2:length(verts)
        D(a,:) = sqrt((verts(2:end,1)-verts(a,1)).^2+(verts(2:end,2)-verts(a,2)).^2);
    end
    
    mean_iv_dist = mean(D,'all');
    
    A = zeros(length(cells),1);
    for b = 1:length(cells)
        v1 = verts(cells{b},1);
        v2 = verts(cells{b},2);
        A(b) = polyarea(v1,v2);
    end
    
    mean_reg_area = mean(A,'omitnan');
    std_reg_area = std(A,'omitnan');
    med_reg_area = median(A,'omitnan');
end

    
    
    




