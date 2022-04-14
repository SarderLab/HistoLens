function [ratios,s,compNum, comp_vis]=getCompRatiosVis(compOb,inte,min_object_size, w_in_range)
%Compartment of interest is stored in channel 1, other compartments in 2
%and 3
L=bwlabel(bwpropfilt(logical(compOb(:,:,1)),'Area',[min_object_size+1,Inf]));
ratios=zeros(max(L(:)),4);
%Get textural features of compartment segmentation
g=graycomatrix(inte);
s=graycoprops(g,'all');
s=struct2table(s);
stats=regionprops(L,'area','convexarea','solidity');

avg_solid = mean([stats.Solidity]);
avg_area = mean([stats.Area]);
med_area = median([stats.Area]);

avg_solid_vis = zeros(size(compOb,1),size(compOb,2));
avg_area_vis = zeros(size(compOb,1),size(compOb,2));
med_area_vis = zeros(size(compOb,1),size(compOb,2));

compNum=max(L(:));
%For all objects
for i=1:compNum
    %Object of interest
    comp=logical(L==i);
    %Other compartments
    CCO=compOb(:,:,2:3);

    %Convex hull of object
    ch=bwconvhull(comp);
    CCO(~repmat(ch,[1,1,2]))=0;

    CCOsum=squeeze(sum(sum(CCO)));

    %Convexity of compartment
    ratios(i,1)=stats(i).Solidity;
    %Ratio of compartment 2 to compartment 1
    ratios(i,2)=CCOsum(1)/stats(i).Area;
    %Ratio of compartment 3 to compartment 1
    ratios(i,3)=CCOsum(2)/stats(i).Area;
    %Area of compartment of interest
    ratios(i,4)=stats(i).Area;
    
    if avg_solid-(w_in_range*avg_solid)<=stats(i).Solidity && stats(i).Solidity<=avg_solid+(w_in_range*avg_solid) 
        avg_solid_vis = avg_solid_vis+comp;
    end
        
    if avg_area-(w_in_range*avg_area)<=stats(i).Area && stats(i).Area <= avg_area+(w_in_range*avg_area)
        avg_area_vis = avg_area_vis+comp;
    end
    
    if med_area-(w_in_range*med_area)<=stats(i).Area && stats(i).Area <= med_area+(w_in_range*med_area)
        med_area_vis = med_area_vis+comp;
    end
    
end

comp_vis = {avg_solid_vis, avg_area_vis, med_area_vis};







