function [thin_values]=get_thinness(I)
bwl=bwlabel(I);
bwd=bwdist(~I);
perims=regionprops(I,'Perimeter');
thin_values=[];
for i=1:length(perims)
    ob=bwl==i;
    dist=bwd.*double(ob);
    thin_values(i)=(max(max(dist))/perims(i).Perimeter)*100;
    
end

