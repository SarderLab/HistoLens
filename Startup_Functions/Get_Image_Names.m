% --- Function to get the names of each of the images from image paths
function img_names = Get_Image_Names(img_paths)

img_names = cellfun(@(x)strsplit(x,filesep),img_paths,'UniformOutput',false);
img_names = cellfun(@(x)x{end},img_names,'UniformOutput',false);