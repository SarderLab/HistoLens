function dist_area_vis = DistAreaVisual(mdt, w_in_range)

dist_area_vis = {zeros(size(mdt)), zeros(size(mdt)), zeros(size(mdt)), zeros(size(mdt)), zeros(size(mdt))};

m_ext1 = mdt>0&mdt<=10;
m_ext2 = mdt>10&mdt<=20;

m_ext1_logic = logical(m_ext1);
m_ext2_logic = logical(m_ext2);

stats1 = regionprops(bwlabel(m_ext1_logic),'area');
stats2 = regionprops(bwlabel(m_ext2_logic),'area');

mean_area1 = mean([stats1.Area]);
mean_area2 = mean([stats2.Area]);
median_area1 = median([stats1.Area]);
median_area2 = median([stats2.Area]);
max_area1 = max([stats1.Area]);

numbers = [mean_area1, mean_area2, median_area1, median_area2, max_area1];
objects = [stats1.Area,stats2.Area,stats1.Area,stats2.Area,stats1.Area];
whole_thing = [m_ext1_logic, m_ext2_logic, m_ext1_logic,m_ext2_logic,m_ext1_logic];
for i = 1:length(numbers)
   
    select_ind = find(objects(i)>=numbers(i)-(w_in_range*numbers(i)) & objects(i)<=numbers(i)+(w_in_range*numbers(i)));
    
    dist_area_vis{i} = dist_area_vis{i}+(ismember(bwlabel(whole_thing(i)),select_ind));
end


