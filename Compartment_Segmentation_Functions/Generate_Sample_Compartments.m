% --- Function to save sample compartment segmentations to a selected
% folder
function Generate_Sample_Compartments(app,save_folder,save_number)

% Getting contents of slide path
dir_contents = dir(app.Slide_Path);
dir_contents = dir_contents(contains({dir_contents.name},{'.svs'}));
dir_contents = {dir_contents.name};

if any(contains(dir_contents,'.'))
    dir_contents = cellfun(@(x) strsplit(x,'.'),dir_contents,'UniformOutput',false);
    dir_contents = cellfun(@(x) x{1}, dir_contents,'UniformOutput',false);
end

slide_wb = waitbar(0,'Saving Example Compartment segmentations',...
    'CreateCancelBtn','setappdata(gcbf,"canceling",1)');

% Iterate through WSIs and pull sample images (up to save_number per slide)
for slide = 1:length(dir_contents)

    % Adding cancel button
    if getappdata(slide_wb,'canceling')
        break
    end

    slide_name = dir_contents{slide};
    slide_idx_name = strcat('Slide_Idx_',num2str(slide));

    slide_path = strcat(app.Slide_Path,filesep,slide_name,'.svs');
    xml_path = strrep(slide_path,'.svs','.xml');

    read_xml = xmlread(xml_path);
    annotations = read_xml.getElementsByTagName('Annotation');
    structure_regions = annotations.item(app.structure_idx.(app.Structure)-1);
    regions = structure_regions.getElementsByTagName('Region');

    region_num = regions.getLength;
    img_ids = randperm(region_num);

    if region_num>=save_number
        img_ids = img_ids(1:save_number);
    end
    
    for img = 1:length(img_ids)
        reg = regions.item(img_ids(img)-1);
        verts = reg.getElementsByTagName('Vertex');
        xy = zeros(verts.getLength-1,2);
        for vi = 0:verts.getLength-1
            x = str2double(verts.item(vi).getAttribute('X'));
            y = str2double(verts.item(vi).getAttribute('Y'));

            xy(vi+1,:) = [x,y];

        end

        bbox_coords = [min(xy(:,1))-100,max(xy(:,1))+100,min(xy(:,2))-100,max(xy(:,2))+100];
        mask_coords = zeros(size(xy));
        mask_coords(:,1) = xy(:,1)-bbox_coords(1);
        mask_coords(:,2) = xy(:,2)-bbox_coords(3);

        raw_I = imread(slide_path,'Index',1,'PixelRegion',{bbox_coords(3:4),bbox_coords(1:2)});
        mask = poly2mask(mask_coords(:,1),mask_coords(:,2),size(raw_I,1),size(raw_I,2));

        if ismember('StainNormalization',fieldnames(app.Seg_Params.(app.Structure)))
            norm_I = normalizeStaining(raw_I,240,0.15,1,app.Seg_Params.(app.Structure).StainNormalization.Means,...
                app.Seg_Params.(app.Structure).StainNormalization.Maxs);
        else
            norm_I = raw_I;
        end

        composite = Comp_Seg_Gen(app.Seg_Params.(app.Structure).(slide_idx_name).CompartmentSegmentation,norm_I,mask);

        save_name = strcat(save_folder,filesep,slide_name,num2str(img_ids(img)));
        comp_save_name = strcat(save_name,'_comp.png');
        raw_save_name = strcat(save_name,'_raw.png');

        imwrite(composite,comp_save_name)
        imwrite(raw_I,raw_save_name)
    end

    waitbar(slide/length(dir_contents),slide_wb,strcat('On slide:',num2str(slide),'of:',num2str(length(dir_contents))))
end
waitbar(1,slide_wb,'Done!')
pause(0.2)
delete(slide_wb)





