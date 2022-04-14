function [compDists, dist_vis]=getCompDistsVis(mask,gOutline,gCenter, w_in_range)
L=logical(mask);
labeled = bwlabel(mask);
dist_vis = {zeros(size(L)),zeros(size(L)),zeros(size(L)),zeros(size(L)),zeros(size(L)),zeros(size(L)),zeros(size(L))}; 

%If compartment doesn't exist (e.g. no nuclei in a sclerotic glomerulus),
%skip it
if sum(sum(mask(:)))==0
    GCeCoDistance=0;
    GBCDistance=0;
    GCoCoDistance=0;
    compDists=['CenterDist',GCeCoDistance','MeanBoundaryDist',mean(GBCDistance,2), ...
    'MaxBoundaryDist',max(GBCDistance,[],2),'MinBoundaryDist', ...
    min(GBCDistance,[],2),'MeanNNDistance',mean(GCoCoDistance,2),'MaxNNDistance', ...
    max(GCoCoDistance,[],2),'MinNNDistance',min(GCoCoDistance,[],2)];
else


%Indices of glomerular boundary
[rPerim,cPerim]=find(gOutline);
%Centroids of compartment
s=regionprops(L,'Centroid');
compCenters=struct2table(s);
compCenters=[compCenters.Centroid];
%Pairwise distance between glomerular center and compartment centers
GCeCoDistance=pdist2(gCenter,compCenters);
%Pairwise distance between glomerular boundary and compartment centers
GBCDistance=pdist2(compCenters,[rPerim,cPerim]);
%Pairwise distance between compartment centers and themselves
GCoCoDistance=pdist2(compCenters,compCenters);

%Sort the data so we can extract the SECOND smallest distance (the actual 
%smallest distance is always 0 since we are taking the distance between a list of objects and itself)
GCoCoDistance=sort(GCoCoDistance);
if length(GCoCoDistance)==1
    GCoCoOut=GCeCoDistance;
else
   GCoCoOut= GCoCoDistance(2,:)';
end

compDists=[GCeCoDistance',mean(GBCDistance,2),max(GBCDistance,[],2), ...
    min(GBCDistance,[],2),mean(GCoCoDistance,2),max(GCoCoDistance,[],2), ...
    GCoCoOut];

meancompDists = mean(compDists);

for i = 1:length(meancompDists)
   select_ind = find(compDists(:,i)>=meancompDists(i)-(w_in_range*meancompDists(i)) & compDists(:,i)<=meancompDists(i)+(w_in_range*meancompDists(i)));
   
   dist_vis{i} = dist_vis{i}+(ismember(labeled,select_ind));
    
end


end