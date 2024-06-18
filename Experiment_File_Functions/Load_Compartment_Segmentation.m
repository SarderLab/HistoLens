% --- Function to load compartment segmentation procedure
function comp_seg_struct = Load_Compartment_Segmentation(comp_seg)

comp_fields = fieldnames(comp_seg);
comp_list = comp_fields(contains(comp_fields,'Stain'));
if any(ismember(comp_fields,{'ColorDeconvolution','Colorspace'}))
    if any(ismember(comp_fields,'ColorDeconvolution'))
        comp_seg_struct.ColorDeconvolution = comp_seg.ColorDeconvolution;
    end
    if any(ismember(comp_fields,'Colorspace'))
        comp_seg_struct.Colorspace = comp_seg.Colorspace;
    end
    for c = 1:length(comp_list)
        comp = comp_list{c};
        
        comp_seg_struct.(comp).name = comp_seg.(comp).name;
        comp_seg_struct.(comp).Channel = comp_seg.(comp).Channel;
        comp_seg_struct.(comp).Threshold = comp_seg.(comp).Threshold;
        comp_seg_struct.(comp).ThresholdDir = comp_seg.(comp).ThresholdDir;
        comp_seg_struct.(comp).MinSize = comp_seg.(comp).MinSize;
        comp_seg_struct.(comp).Splitting = comp_seg.(comp).Splitting;
        
    end
else
    % For custom path inputting
    comp_seg_struct.Path = comp_seg.Path;
end


