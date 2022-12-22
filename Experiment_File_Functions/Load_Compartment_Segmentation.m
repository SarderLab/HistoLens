% --- Function to load compartment segmentation procedure
function comp_seg_struct = Load_Compartment_Segmentation(comp_seg)

comp_fields = fieldnames(comp_seg);
comp_list = {'PAS','Luminal','Nuclei'};
if any(ismember(comp_fields,{'Stain','Colorspace'}))
    if strcmp(comp_fields{1},'Stain')
        comp_seg_struct.Stain = comp_seg.Stain;
    end
    if strcmp(comp_fields{1},'Colorspace')
        comp_seg_struct.Colorspace = comp_seg.Colorspace;
    end
    for c = comp_list
        comp = c{1};
        
        comp_seg_struct.(comp).Channel = comp_seg.(comp).Channel;
        comp_seg_struct.(comp).Threshold = comp_seg.(comp).Threshold;
        comp_seg_struct.(comp).MinSize = comp_seg.(comp).MinSize;
        comp_seg_struct.(comp).Order = comp_seg.(comp).Order;
        comp_seg_struct.(comp).Splitting = comp_seg.(comp).Splitting;
        
    end
else
    % For custom path inputting
    comp_seg_struct.Path = comp_seg.Path;
end














