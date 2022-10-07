% --- Function to extract all images from ROI 
function Extract_ROI_Images(app,save_folder,roi)

event = [];

if strcmp(roi,'red')
    if ~app.Comparing
        image_list = app.Image_Name_Label.Items;
    else
        image_list = app.Red_Comp_Image.Items; 
    end

    % Getting the image names only
    image_list = cellfun(@(x)strsplit(x,','),image_list,'UniformOutput',false);
    image_list = cellfun(@(x) x{1}, image_list, 'UniformOutput',false);

elseif strcmp(roi,'blue')
    image_list = app.Blue_Comp_Image.Items;

    % Getting the image names only
    image_list = cellfun(@(x)strsplit(x,','),image_list,'UniformOutput',false);
    image_list = cellfun(@(x) x{1}, image_list, 'UniformOutput',false);

elseif strcmp(roi,'persistent')
    image_list = app.PersistentImageLabelsListBox.Items;
end


image_wb = waitbar(0,'Saving Images from ROI',...
    'CreateCancelBtn','setappdata(gcbf,"canceling",1)');

% Iterate through image list
mkdir(strcat(save_folder,filesep,'Images'))
mkdir(strcat(save_folder,filesep,'CompartmentSegmentations'))

for i = 1:length(image_list)

    if getappdata(image_wb,'canceling')
        break
    end

    [raw_image,norm_image,mask,comp_mask] = Extract_Spec_Img(app,event,image_list{i});

    imwrite(raw_image,strcat(save_folder,filesep,'Images',filesep,image_list{i},'.png'))
    imwrite(uint8(255.*comp_mask),strcat(save_folder,filesep,'CompartmentSegmentations',filesep,image_list{i},'_comp.png'))

    waitbar(i/length(image_list),image_wb,strcat('On Image:',num2str(i),'of:',num2str(length(image_list))))

end
waitbar(1,image_wb,'Done!')
pause(0.2)
delete(image_wb)

































