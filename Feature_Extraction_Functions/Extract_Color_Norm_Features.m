% --- Function to extract color and texture features using updated color
% normalization values
function Extract_Color_Norm_Features(app)


% Getting slide_names
slide_names = dir(app.Slide_Path);
slide_names = {slide_names.name};
slide_names = slide_names(contains(slide_names,'.svs'));

slide_path = app.Slide_Path;

structure_idx = app.structure_idx.(app.Structure);

% Replacement features = 6x(n compartments)+4*(n compartments)
n_rep_feats = 30;
feature_set = cell(1,n_rep_feats+1);

% Geting all the feature names for the current feature set
feature_names = app.feature_encodings(app.Overlap_Feature_idx.(app.Structure),:);

% Getting all the color feature names and their indexes (indices?)
color_feature_idx = ismember(feature_names.Type,{'Color','Texture'});
color_feature_names = feature_names(color_feature_idx,:);

feature_extract_idx = ismember(app.feature_encodings.Feature_Names,color_feature_names.Feature_Names);

wb = waitbar(0,'Running Color Feature Extraction');

% iterate over slides
for s = 1:length(slide_names)
    
    slide = slide_names{s};
    if contains(slide,'.svs')
        xml_file = strrep(slide,'.svs','.xml');
    else
        slide = strcat(slide,'.svs');
        xml_file = strcat(slide,'.xml');
    end

    read_xml = xmlread(strcat(app.Slide_Path,filesep,xml_file));
    annotations = read_xml.getElementsByTagName('Annotation');

    structure_regions = annotations.item(structure_idx-1);
    if ~isempty(structure_regions)
        regions = structure_regions.getElementsByTagName('Region');
        
        slide_filepath = strcat(app.Slide_Path,filesep,slide);
        
        for p = 0:regions.getLength-1
            reg_array(p+1) = regions.item(p);
        end

        colornorm_means = app.ColorNormParams.Means;
        colornorm_maxs = app.ColorNormParams.Maxs;
        stainnorm_means = app.Seg_Params.(app.Structure).StainNormalization.Means;
        stainnorm_maxs = app.Seg_Params.(app.Structure).StainNormalization.Maxs;
        seg_params = app.Seg_Params.(app.Structure);

        parfor r = 1:length(reg_array)
            reg = reg_array(r);
            verts = reg.getElementsByTagName('Vertex');
            xy = zeros(verts.getLength-1,2);
            for vi = 0:verts.getLength-1
                x = str2double(verts.item(vi).getAttribute('X'));
                y = str2double(verts.item(vi).getAttribute('Y'));
    
                xy(vi+1,:) = [x,y];
            end
    
            mask_coords = zeros(size(xy));
            bbox_coords = [min(xy(:,1))-100,max(xy(:,1))+100,min(xy(:,2))-100,max(xy(:,2))+100];
            mask_coords(:,1) = xy(:,1)-bbox_coords(1);
            mask_coords(:,2) = xy(:,2)-bbox_coords(3);
    
            raw_img = imread(slide_filepath,'Index',1,'PixelRegion',{bbox_coords(3:4),bbox_coords(1:2)});
            mask = poly2mask(mask_coords(:,1),mask_coords(:,2),size(raw_img,1),size(raw_img,2));
    
            % Stain normalization
            img = normalizeStaining(raw_img,240,0.15,1,stainnorm_means,...
                stainnorm_maxs);
    
            comp_img = Comp_Seg_Gen(seg_params,img,mask);
            
            color_norm_img = normalizeStaining(raw_img,240,0.15,1,colornorm_means,...
                colornorm_maxs);

            % Color+Texture feat row
            feat_row_combined = Features_Extract_General(color_norm_img,comp_img,find(feature_extract_idx),[]);
            
            img_name = strsplit(slide,'.');
            img_name = img_name{1};
            new_ID = strcat(img_name,'_',num2str(r));
            feat_row_combined = [num2cell(feat_row_combined),new_ID];

            feature_set = [feature_set;feat_row_combined];

            %waitbar((s-1)/length(slide_names),wb,strcat('Running Color Feature Extraction:',num2str(r)))

        end
        clear reg_array
    end

    waitbar(s/length(slide_names),wb,'Running Color Feature Extraction')

end
feature_set(1,:) = [color_feature_names.Feature_Names',{'ImgLabel'}];
delete(wb)
app.Replace_Features = cell2table(feature_set(2:end,:),'VariableNames',feature_set(1,:));

