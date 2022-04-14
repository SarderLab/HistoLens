function [ratios,s,compNum, comp_vis]=getNucRatiosVis(compOb,nucpixradius,graynuclei, w_in_range)
L=bwlabel(compOb(:,:,1));
ratios=zeros(max(L(:)),4);
g=graycomatrix(graynuclei);
s=graycoprops(g,'all');
s=struct2table(s);

comp_per_pix_count = zeros(size(compOb,1),size(compOb,2));
avg_area_vis = zeros(size(compOb,1),size(compOb,2));
mode_area_vis = zeros(size(compOb,1),size(compOb,2));

stats = regionprops(L, 'perimeter','area');
mean_per = mean([stats.Perimeter]);
mean_area = mean([stats.Area]);
mode_area = mode([stats.Area]);


compNum=max(L(:));
for i=1:compNum
    %Get nuclear compartment
    comp=logical(L==i);
    %Find pixels surrounding each nucleus
    compOutline=bwperim(bwmorph(comp,'dilate',nucpixradius));
    %Eliminate pixels that aren't on the nuclear border
    CCO=compOb;
    CCO(~repmat(compOutline,[1,1,3]))=0;
    
    if mean_per-(w_in_range*mean_per)<=stats(i).Perimeter && stats(i).Perimeter<=mean_per+(w_in_range*mean_per)
        comp_per_pix_count = comp_per_pix_count+comp;
    end
    
    if mean_area-(w_in_range*mean_area)<=stats(i).Area && stats(i).Area<=mean_area+(w_in_range*mean_area)
        avg_area_vis = avg_area_vis+comp;
    end
    
    if mode_area-(w_in_range*mode_area)<= stats(i).Area && stats(i).Area<=mode_area+(w_in_range*mode_area)
        mode_area_vis = mode_area_vis+comp;
    end
    
    
    %Quantify compartment values at the nuclear boundary
    ratios(i,1)=sum(sum(CCO(:,:,2)))/sum(sum(compOutline));
    ratios(i,2)=sum(sum(CCO(:,:,3)))/sum(sum(compOutline));
    %Length of nuclear boundary
    ratios(i,3)=sum(sum(compOutline));
    % Nuclear area
    ratios(i,4)=sum(sum(comp));
end
comp_vis = {comp_per_pix_count, avg_area_vis, mode_area_vis};









