% --- Function to generate feature visualizations, generalizable to the
% inclusion of multiple different structures
%function all_feature_vis = Feature_Vis_Gen(app,event)
function Feature_Vis_Gen(app,event)

    min_object_size = 15;
    nucpixradius = 2;
    w_in_range = app.w_in_range;
    texture_window = app.texture_window;


    vis_params = [min_object_size,nucpixradius,w_in_range,texture_window];
    if ~app.Comparing

        app.Comp_Img = [];
        
        image_name = app.Image_Name_Label.Value;
        image_name = strsplit(image_name,',');
        image_name = image_name{1};
        [raw_I,norm_I,mask,composite] = Extract_Spec_Img(app,event,image_name);

        app.Comp_Img{1} = composite;

        all_feature_vis = cell(length(app.map_idx),1);
        all_feature_vis = Get_Feat_Vis(norm_I,mask,composite,app.map_idx,all_feature_vis,vis_params);
        app.sep_feat_map = all_feature_vis;

        if strcmp(inputname(1),'dummy_app')
            assignin('base','all_feature_vis',all_feature_vis)
            save(strcat(app.output_dir,'all_feature_vis.mat'),all_feature_vis)
        end

    else

        % Setting which compare image is being changed
        replace_map = find([app.Red_Only,app.Blue_Only]);
        if isempty(replace_map)
            replace_map = [1,2];
            app.Comp_Img = cell(1,2);
            all_feature_vis = cell(length(app.map_idx),2);
        else
            all_feature_vis = app.sep_feat_map;
        end

        % Iterating through both images
        for j = 1:length(replace_map)
            im_num = replace_map(j);

            if im_num == 1
                img_idx = app.Red_Comp_Image.Value;
                img_idx = strsplit(img_idx,',');
                img_idx = img_idx{1};
                
                [raw_I,norm_I,mask,composite] = Extract_Spec_Img(app,event,img_idx);
            else
                comp_img_idx = app.Blue_Comp_Image.Value;
                comp_img_idx = strsplit(comp_img_idx,',');
                comp_img_idx = comp_img_idx{1};
                [raw_I,norm_I,mask,composite] = Extract_Spec_Img(app,event,comp_img_idx);
            end

            app.Comp_Img{im_num} = composite;
            
            comp_feature_vis = cell(length(app.map_idx),1);
            all_feature_vis(:,im_num) = Get_Feat_Vis(norm_I,mask,composite,app.map_idx,comp_feature_vis, vis_params);
        end
        app.sep_feat_map = all_feature_vis;
    end
end

function all_feature_vis = Get_Feat_Vis(I,mask,composite,features_needed,all_feature_vis,vis_params)
    
    min_object_size = vis_params(1);
    nucpixradius = vis_params(2);
    w_in_range = vis_params(3);
    texture_window = vis_params(4);
    
    main_fig = gcf;
    % Initializing waitbar
    wb = waitbar(0,'Feature Visualizations completed: 0');
    num_feat = length(features_needed);
    feat_count = 0;
    
    pas_mask = composite(:,:,1);
    lum_mask = composite(:,:,2);
    nuc_mask = composite(:,:,3);
    boundary_mask = pas_mask|lum_mask|nuc_mask;

    % Luminal space solidity, texture
    if any(ismember(features_needed,[1,4:10]))
        
        % Re-orienting for getCompRatios, luminal space
        composite = cat(3,lum_mask,pas_mask,nuc_mask);
        composite(~repmat(boundary_mask,[1,1,3]))=0;
        
        grayIm = rgb2gray(I);
        grayIm(~lum_mask) = NaN;
        
        if any(ismember(features_needed,[1,5,6]))
            [ratiosL,s2,lum_num,lum_comp_vis] = getCompRatiosVis(composite,...
                grayIm,min_object_size,w_in_range);
            
            overlap_num = length(find(ismember(features_needed,[1,5,6])));
            feat_count = feat_count+overlap_num;
            
            all_feature_vis = insert_vis(features_needed,[1,5,6],lum_comp_vis,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end
        
        if any(ismember(features_needed,(7:10)))
            lum_texture_vis = TextureVisual(composite, grayIm, 1,...
                min_object_size, w_in_range,texture_window);
            
            overlap_num = length(find(ismember(features_needed,(7:10))));
            feat_count = feat_count+overlap_num;

            all_feature_vis = insert_vis(features_needed,(7:10),lum_texture_vis,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        else
            overlap_num = 1;
            feat_count = feat_count+overlap_num;

            all_feature_vis = insert_vis(features_needed,4,lum_mask,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end
    end
    
    % Relative visualiztion between compartments
    if any(ismember(features_needed,[2,3,12,13,21,22]))
        relative_feature_vis = RelativeVisual(cat(3,pas_mask,lum_mask,nuc_mask));
        
        overlap_num = length(find(ismember(features_needed,[2,3,12,13,21,22])));
        feat_count = feat_count+overlap_num;

        all_feature_vis = insert_vis(features_needed,[2,3,12,13,21,22],relative_feature_vis,all_feature_vis);
        update_waitbar(wb,feat_count,num_feat);
    end
    
    % PAS+ areas solidity, texture
    if any(ismember(features_needed,[11,14:20]))
        
        grayIm = rgb2gray(I);
        grayIm(~pas_mask) = NaN;
        composite = cat(3,pas_mask,lum_mask,nuc_mask);
        composite(~repmat(boundary_mask,[1,1,3]))=0;
        
        if any(ismember(features_needed,(14:16)))
            [ratiosM,s1,pas_num,pas_comp_vis] = getCompRatiosVis(composite,grayIm,...
                min_object_size,w_in_range);
            
            overlap_num = length(find(ismember(features_needed,(14:16))));
            feat_count = feat_count+overlap_num;

            all_feature_vis = insert_vis(features_needed,(14:16),pas_comp_vis,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end
        
        if any(ismember(features_needed,(17:20)))
            pas_texture_vis = TextureVisual(composite, grayIm, 1,...
                min_object_size,w_in_range,texture_window);
            
            overlap_num = length(find(ismember(features_needed,(17:20))));
            feat_count = feat_count+overlap_num;

            all_feature_vis = insert_vis(features_needed,(17:20),pas_texture_vis,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        else
            overlap_num = 1;
            feat_count = feat_count+overlap_num;

            all_feature_vis = insert_vis(features_needed,11,pas_mask,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end
    end
    
    if any(ismember(features_needed,(23:30)))
        
        composite = cat(3,nuc_mask,lum_mask,pas_mask);
        composite(~repmat(boundary_mask,[1,1,3])) = 0;
        grayIm = rgb2gray(I);
        grayIm(~nuc_mask)=NaN;
        
        if any(ismember(features_needed,[23,25,26]))
            % Get nuclear ratios
            [ratiosN,s3,nuc_num,nuc_comp_vis] = getNucRatiosVis(composite,...
                nucpixradius,grayIm,w_in_range);
            
            overlap_num = length(find(ismember(features_needed,[23,25,26])));
            feat_count = feat_count+overlap_num;

            all_feature_vis = insert_vis(features_needed,[23,25,26],nuc_comp_vis,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end
        
        if any(ismember(features_needed,(27:30)))
            nuc_texture_vis = TextureVisual(composite,grayIm,1,2,w_in_range,texture_window);
            
            overlap_num = length(find(ismember(features_needed,(27:30))));
            feat_count = feat_count+overlap_num;

            all_feature_vis = insert_vis(features_needed,(27:30),nuc_texture_vis,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        else
            overlap_num = 1;
            feat_count = feat_count+overlap_num;

            all_feature_vis = insert_vis(features_needed,24,nuc_mask,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end
    end
    
    if any(ismember(features_needed,(31:51)))
        
        % Structure boundary and distance features between periphery,
        % center, and other compartments
        gOutline = bwperim(boundary_mask);

        [r,c]=find(boundary_mask);
        rMean=round(mean(r));
        cMean=round(mean(c));
        
        if any(ismember(features_needed,(31:37)))
            [distsL, distL_vis] = getCompDistsVis(lum_mask,gOutline,...
                [rMean,cMean],w_in_range);
            
            overlap_num = length(find(ismember(features_needed,(31:37))));
            feat_count = feat_count+overlap_num;

            all_feature_vis = insert_vis(features_needed,(31:37),distL_vis,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end
        
        if any(ismember(features_needed,(38:44)))
            [distsM, distM_vis] = getCompDistsVis(pas_mask,gOutline,...
                [rMean,cMean],w_in_range);
            
            overlap_num = length(find(ismember(features_needed,(38:44))));
            feat_count = feat_count+overlap_num;
            
            all_feature_vis = insert_vis(features_needed,(38:44),distM_vis,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end
        
        if any(ismember(features_needed,(45:51)))
            [distsN, distN_vis] = getCompDistsVis(nuc_mask,gOutline,...
                [rMean,cMean],w_in_range);
            
            overlap_num = length(find(ismember(features_needed,(45:51))));
            feat_count = feat_count+overlap_num;

            all_feature_vis = insert_vis(features_needed,(45:51),distN_vis,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end
    end
    
    if find(features_needed==52)
        % Area vis
        gArea_vis = boundary_mask;
        
        overlap_num = 1;
        feat_count = feat_count+overlap_num;
        
        all_feature_vis = insert_vis(features_needed,52,gArea_vis,all_feature_vis);
        update_waitbar(wb,feat_count,num_feat);
    end
    
    if find(features_needed==53)
        % PAS vis
        pas_vis = pas_mask;
        
        overlap_num = 1;
        feat_count = feat_count+overlap_num;
        
        all_feature_vis = insert_vis(features_needed,53,pas_vis,all_feature_vis);
        update_waitbar(wb,feat_count,num_feat);
    end
    
    if find(features_needed==54)
        % luminal space vis
        lum_vis = lum_mask;
        
        overlap_num = 1;
        feat_count = feat_count+overlap_num;
        
        all_feature_vis = insert_vis(features_needed,54,lum_vis,all_feature_vis);
        update_waitbar(wb,feat_count,num_feat);
    end
    
    if find(features_needed==55)
        % nuc vis
        nuc_vis = nuc_mask;
        
        overlap_num = 1;
        feat_count = feat_count+overlap_num;
        
        all_feature_vis = insert_vis(features_needed,55,nuc_vis,all_feature_vis);
        update_waitbar(wb,feat_count,num_feat);
    end
    
    if any(ismember(features_needed,(56:70)))
        % PAS+ distance transform image
        pdt = bwdist(~pas_mask);
        
        % Manually selected distance transform cuts for PAS+ component
        p_ext1 = pdt>0&pdt<=10;
        sum_PAS_0_10 = p_ext1;
        
        if any(ismember(features_needed,[56,60]))
            
            overlap_num = length(find(ismember(features_needed,[56,60])));
            feat_count = feat_count+overlap_num;
            
            all_feature_vis = insert_vis(features_needed,[56,60],sum_PAS_0_10,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end
        
        if any(ismember(features_needed,[62,64]))
            mean_0_10 = mean(mean(pdt(p_ext1>0)));
            median_0_10 = median(pdt(p_ext1>0));
            mean_0_10_vis = pdt>=mean_0_10-(w_in_range*mean_0_10) & pdt<=mean_0_10+(w_in_range*mean_0_10);
            median_0_10_vis = pdt>=median_0_10-(w_in_range*median_0_10) & pdt<=median_0_10+(w_in_range*median_0_10);
            
            overlap_num = length(find(ismember(features_needed,[62,64])));
            feat_count = feat_count+overlap_num;
            
            all_feature_vis = insert_vis(features_needed,[62,64],{mean_0_10_vis,median_0_10_vis},all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end
        
        if any(ismember(features_needed,[57,59,61,63,65]))
            p_ext2 = pdt>10&pdt<=20;
            sum_PAS_10_20 = p_ext2;
            
            if any(ismember(features_needed,[57,59,61]))
                overlap_num = length(find(ismember(features_needed,[57,59,61])));
                feat_count = feat_count+overlap_num;
                
                all_feature_vis = insert_vis(features_needed,[57,59,61],sum_PAS_10_20,all_feature_vis);
                update_waitbar(wb,feat_count,num_feat);
            end
            
            if any(ismember(features_needed,[63,65]))
                mean_10_20 = mean(mean(pdt(p_ext2>0)));
                median_10_20 = median(pdt(p_ext2>0));
                mean_10_20_vis = pdt>=mean_10_20-(w_in_range*mean_10_20) & pdt<=mean_10_20+(w_in_range*mean_10_20);
                median_10_20_vis = pdt>=median_10_20-(w_in_range*median_10_20) & pdt<=median_10_20+(w_in_range*median_10_20);
                
                overlap_num = length(find(ismember(features_needed,[63,65])));
                feat_count = feat_count+overlap_num;
                
                all_feature_vis = insert_vis(features_needed,[63,65],{mean_10_20_vis,median_10_20_vis},all_feature_vis);
                update_waitbar(wb,feat_count,num_feat);
            end
        end
        
        if any(ismember(features_needed,(66:70)))
            dist_area_vis = DistAreaVisual(pdt,w_in_range);
            
            overlap_num = length(find(ismember(features_needed,(66:70))));
            feat_count = feat_count+overlap_num;
            
            all_feature_vis = insert_vis(features_needed,(66:70),dist_area_vis,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end
        
        if find(features_needed==58)
            p_ext3 = pdt>20&pdt<1000;
            sum_PAS_20_1000 = p_ext3;
            
            overlap_num =1;
            feat_count = feat_count+overlap_num;
            
            all_feature_vis = insert_vis(features_needed,58,sum_PAS_20_1000,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end
    end
    
    if any(ismember(features_needed,(71:110)))
        pdt = bwdist(~pas_mask);
        
        edges = [1:2:80,2000];
        N1 = histcounts(pdt(pdt(:)>0),edges);
        count_PAS_vis = cell(length(N1),1);
        for m = 1:length(N1)
            count_PAS_vis{m} = pdt>edges(m) & pdt<=edges(m+1);
        end
        
        overlap_num = length(find(ismember(features_needed,(71:110))));
        feat_count = feat_count+overlap_num;
        
        all_feature_vis = insert_vis(features_needed,(71:110),count_PAS_vis,all_feature_vis);
        update_waitbar(wb,feat_count,num_feat);
    end
    
    if any(ismember(features_needed,(111:170)))
        ldt = bwdist(~lum_mask);
        edges = [1:1:60,2000];
        N2 = histcounts(ldt(ldt(:)>0),edges);
        count_lum_vis = cell(length(N2),1);
        for m = 1:length(N2)
            count_lum_vis{m} = ldt>edges(m) & ldt<=edges(m+1);
        end
        
        overlap_num = length(find(ismember(features_needed,(111:170))));
        feat_count = feat_count+overlap_num;
        
        all_feature_vis = insert_vis(features_needed,(111:170),count_lum_vis,all_feature_vis);
        update_waitbar(wb,feat_count,num_feat);
    end
    
    if any(ismember(features_needed,(171:190)))
        ndt = bwdist(~nuc_mask);
        edges = [1:1:20,2000];
        N3 = histcounts(ndt(ndt(:)>0),edges);
        count_nuc_vis = cell(length(N3),1);
        for m = 1:length(N3)
            count_nuc_vis{m} = ndt>edges(m) & ndt<=edges(m+1);
        end
        
        overlap_num = length(find(ismember(features_needed,(171:190))));
        feat_count = feat_count+overlap_num;
        
        all_feature_vis = insert_vis(features_needed,(171:190),count_nuc_vis,all_feature_vis);
        update_waitbar(wb,feat_count,num_feat);
    end
    
    if any(ismember(features_needed,(191:214)))
        gdist = bwdist(~boundary_mask);
        edges = [2:25:600,20000];
        N4 = histcounts(gdist(gdist(:)>0),edges);
        count_glom_vis = cell(length(N4),1);
        for m = 1:length(N4)
            count_glom_vis{m} = gdist>edges(m) & gdist<=edges(m+1);
        end
        
        overlap_num = length(find(ismember(features_needed,(191:214))));
        feat_count = feat_count+overlap_num;
        
        all_feature_vis = insert_vis(features_needed,(191:214),count_glom_vis,all_feature_vis);
        update_waitbar(wb,feat_count,num_feat);
    end
    
    if any(ismember(features_needed,(215:232)))
        color_stats_vis = ColorStatsVis(I,cat(3,pas_mask,lum_mask,nuc_mask),w_in_range);
        
        overlap_num = length(find(ismember(features_needed,(215:232))));
        feat_count = feat_count+overlap_num;
        
        all_feature_vis = insert_vis(features_needed,(215:232),color_stats_vis,all_feature_vis);
        update_waitbar(wb,feat_count,num_feat);
    end
    
    if any(ismember(features_needed,(233:285)))
        gOutline = bwperim(boundary_mask);
        [r,c]=find(boundary_mask);
        rMean=round(mean(r));
        cMean=round(mean(c));
        [y,x] = find(nuc_mask);
        [theta,rho] = cart2pol(x-rMean,y-cMean);
        
        N_n = histcounts(rho,[0,100:1000,1300]);
        T_n = histcounts(theta,[-pi:(2*pi/20):pi]);
        
        if any(ismember(features_needed,(233:243)))
            [nuc_num_rho_vis, nuc_num_theta_vis] = NumberPixVis(x,y,theta,rho,...
                nuc_mask,N_n,T_n);
            
            overlap_num = length(find(ismember(features_needed,(233:243))));
            feat_count = feat_count+overlap_num;
            
            all_feature_vis = insert_vis(features_needed,(233:243),nuc_num_rho_vis,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);           
            
        end
        
        if any(ismember(features_needed,(266:285)))
            [nuc_num_rho_vis, nuc_num_theta_vis] = NumberPixVis(x,y,theta,rho,...
                nuc_mask,N_n,T_n);
            
            overlap_num = length(find(ismember(features_needed,(266:285))));
            feat_count = feat_count+overlap_num;
            
            all_feature_vis = insert_vis(features_needed,(266:285),nuc_num_theta_vis,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end
        
        [y,x] = find(lum_mask);
        [theta,rho] = cart2pol(x-rMean,y-cMean);
        N_l = histcounts(rho,[0:100:1000,1300]);
        
        if any(ismember(features_needed,(244:254)))
            [lum_num_rho_vis,nunya] = NumberPixVis(x,y,theta,rho,lum_mask,N_l,0);
            
            overlap_num = length(find(ismember(features_needed,(244:254))));
            feat_count = feat_count+overlap_num;
            
            all_feature_vis = insert_vis(features_needed,(244:254),lum_num_rho_vis,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end
        
        [y,x] = find(pas_mask);
        [theta,rho] = cart2pol(x-rMean,y-cMean);
        N_p = histcounts(rho,[0:100:1000,1300]);
        
        if any(ismember(features_needed,(255:265)))
            [pas_num_rho_vis,nunya] = NumberPixVis(x,y,theta,rho,pas_mask,N_p,0);
            
            overlap_num = length(find(ismember(features_needed,(255:265))));
            feat_count = feat_count+overlap_num;
            
            all_feature_vis = insert_vis(features_needed,(255:265),pas_num_rho_vis,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end
    end
    
    if any(ismember(features_needed,(286:315)))
        gdist2 = zeros(size(boundary_mask));
        gdist2(~boundary_mask) = 1;
        gdist2 = bwdist(gdist2);
        gdist2 = (gdist2-max(max(gdist2)))*-1;
        gdist2(~boundary_mask) = 0;
        
        if any(ismember(features_needed,(286:295)))
            nuc_dist_bound = double(gdist2.*double(nuc_mask));
            
            nv = quantile(nonzeros(nuc_dist_bound(:)),[.1:.1:1]);
            nv_vis = cell(10,1);
            old_nv = 0;
            for i = 1:length(nv)
                nv_vis{i} = (old_nv<nuc_dist_bound & nuc_dist_bound<=nv(i));
                old_nv = nv(i);
            end
            
            overlap_num = length(find(ismember(features_needed,(286:295))));
            feat_count = feat_count+overlap_num;
            
            all_feature_vis = insert_vis(features_needed,(286:295),nv_vis,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end
        
        if any(ismember(features_needed,(296:305)))
            pas_dist_bound = double(gdist2.*double(pas_mask));
            
            pv = quantile(nonzeros(pas_dist_bound(:)),[.1:.1:1]);
            pv_vis = cell(length(pv),1);
            old_pv = 0;
            for i = 1:length(pv)
                pv_vis{i} = (old_pv<pas_dist_bound & pas_dist_bound<=pv(i));
                old_pv = pv(i);
            end
            
            overlap_num = length(find(ismember(features_needed,(296:305))));
            feat_count = feat_count+overlap_num;
            
            all_feature_vis = insert_vis(features_needed,(296:305),pv_vis,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end
        
        if any(ismember(features_needed,(306:315)))
            lum_dist_bound = double(gdist2.*double(lum_mask));
            
            lv = quantile(nonzeros(lum_dist_bound(:)),[.1:.1:1]);
            lv_vis = cell(length(lv),1);
            old_lv = 0;
            for i = length(lv)
                lv_vis{i} = (old_lv<lum_dist_bound & lum_dist_bound<=lv(i));
                old_lv = lv(i);
            end
            
            overlap_num = length(find(ismember(features_needed,(306:315))));
            feat_count = feat_count+overlap_num;
            
            all_feature_vis = insert_vis(features_needed,(306:315),lv_vis,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end
    end
    
    if any(ismember(features_needed,(316:329)))
        cent = regionprops(logical(nuc_mask),'centroid');
        nuc_centroids = struct2cell(cent);
        coordinates = reshape(cell2mat(nuc_centroids),2,length(nuc_centroids));
        
        if any(ismember(features_needed,(316:320)))
            if length(nuc_centroids)>1
                [M,G] = OS_minSpanTreeFromCoordinates(coordinates);
                min_span_vis = MinSpanTreeVis(M, nuc_mask,w_in_range);
                
                overlap_num = length(find(ismember(features_needed,(316:320))));
                feat_count = feat_count+overlap_num;
                
                all_feature_vis = insert_vis(features_needed,(316:320),min_span_vis,all_feature_vis);
                update_waitbar(wb,feat_count,num_feat);
            else
                
                overlap_num = length(find(ismember(features_needed,(316:320))));
                feat_count = feat_count+overlap_num;
                
                all_feature_vis = insert_vis(features_needed,(316:320),nuc_mask,all_feature_vis);
                update_waitbar(wb,feat_count,num_feat);
            end
        end
        
        if any(ismember(features_needed,(321:329)))
            if length(coordinates)>3
                [verts,cells] = voronoin(coordinates');
                voronoi_vis = VoronoiVis(verts,cells,nuc_mask,w_in_range);
                
                overlap_num = length(find(ismember(features_needed,(321:329))));
                feat_count = feat_count+overlap_num;
                
                all_feature_vis = insert_vis(features_needed,(321:329),voronoi_vis,all_feature_vis);
                update_waitbar(wb,feat_count,num_feat);
            else
                
                overlap_num = length(find(ismember(features_needed,(321:329))));
                feat_count = feat_count+overlap_num;
                
                all_feature_vis = insert_vis(features_needed,(321:329),nuc_mask,all_feature_vis);
                update_waitbar(wb,feat_count,num_feat);
            end
        end
    end
    
    if any(ismember(features_needed,(330:334)))
        if any(ismember(features_needed,[330,332]))
            
            overlap_num = length(find(ismember(features_needed,[330,332,334])));
            feat_count = feat_count+overlap_num;
            
            all_feature_vis = insert_vis(features_needed,[330,332],imdilate(bwperim(boundary_mask),1),all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end
        
        if find(features_needed==334)
            overlap_num = 1;
            feat_count = feat_count+overlap_num;
            ecc_vis = TubProps(boundary_mask,91);

            all_feature_vis = insert_vis(features_needed,334,ecc_vis,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end

        if any(ismember(features_needed,[331,333]))
            
            overlap_num = length(find(ismember(features_needed,[331,333])));
            feat_count = feat_count+overlap_num;
            
            all_feature_vis = insert_vis(features_needed,[331,333],bwconvhull(boundary_mask),all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end
    end
    
    % Tubule-specific features
    if any(ismember(features_needed,(335:358)))
        
        [~,sat,~] = colour_deconvolution(I,'H PAS');
        sat = 1-im2double(sat);
        sat = imadjust(sat,[],[],3);
        
        mems = imbinarize(sat,adaptthresh(sat,0.3));
        blim = imdilate(boundary_mask,strel('disk',10));
        indel = imerode(blim,strel('disk',10));
        blim(indel) = 0;
        tbm = imreconstruct(blim&mems,mems);
        tbm = bwareaopen(tbm,50);
        tbm = imclose(tbm,strel('disk',1));
        
        tbm_dist = bwdist(~tbm);
        grayIm = rgb2gray(img);
        grayIm(~tbm) = NaN;
        
        if any(ismember(features_needed,(335:339)))
            if any(ismember(features_needed,[335,338]))
                mean_thick = mean(tbm_dist,'all');
                mean_thick_vis = tbm_dist>=(mean_thick-(w_in_range*mean_thick)) & tbm_dist<=(mean_thick+(w_in_range*mean_thick));
                
                overlap_num = length(find(ismember(features_needed,[335,338])));
                feat_count = feat_count+overlap_num;
                
                all_feature_vis = insert_vis(features_needed,[335,338],mean_thick_vis,all_feature_vis);
                update_waitbar(wb,feat_count,num_feat);
            end
            
            if any(ismember(features_needed,[336,339]))
                max_thick = max(tbm_dist,[],'all');
                max_thick_vis = tbm_dist>=max_thick-(w_in_range*max_thick);
                
                overlap_num = length(find(ismember(features_needed,[336,339])));
                feat_count = feat_count+overlap_num;
                
                all_feature_vis = insert_vis(features_needed,[336,339],max_thick_vis,all_feature_vis);
                update_waitbar(wb,feat_count,num_feat);
            end
            
            if find(features_needed==337)
                tbm_dist(tbm_dist==0) = inf;
                min_thick = min(tbm_dist,[],'all');
                min_thick_vis = tbm_dist<=min_thick+(w_in_range*min_thick);
                
                overlap_num = 1;
                feat_count = feat_count+overlap_num;
                
                all_feature_vis = insert_vis(features_needed,337,min_thick_vis,all_feature_vis);
                update_waitbar(wb,feat_count,num_feat);
            end
        end

        if any(ismember(features_needed,(340:343)))
            % TBM texture features
            composite = cat(3,tbm,lum_mask,pas_mask);
            composite(~repmat(blim,[1,1,3])) = 0;
            grayIm = rgb2gray(I);
            grayIm(~tbm) = NaN;

            tbm_texture_vis = TextureVisual(composite,grayIm,1,min_object_size,...
                w_in_range,texture_window);

            overlap_num = length(find(ismember(features_needed,(340:343))));
            feat_count = feat_count+overlap_num;

            all_feature_vis = insert_vis(features_needed,(340:343),tbm_texture_vis,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end

        if any(ismember(features_needed,(344:349)))
            % TBM color features
            color_stats_vis = ColorStatsVis(I,tbm,w_in_range);

            overlap_num = length(find(ismember(features_needed,(344:349))));
            feat_count = feat_count+overlap_num;

            all_feature_vis = insert_vis(features_needed,(344:349),color_stats_vis,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end
        
        if find(features_needed==350)
            overlap_num = 1;
            feat_count = feat_count+overlap_num;

            all_feature_vis = insert_vis(features_needed,350,tbm,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end

        if find(features_needed==351)
            composite = cat(3,tbm,pas_mask,nuc_mask);
            composite(~repmat(boundary_mask,[1,1,3]))=0;

            grayIm = rgb2gray(I);
            grayIm(~tbm) = NaN;

            [~,~,TBM_comp_vis] = getCompRatiosVis(composite,grayIm,min_object_size,w_in_range);

            overlap_num = 1;
            feat_count = feat_count+overlap_num;

            all_feature_vis = insert_vis(features_needed,351,TBM_comp_vis{1},all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end

        if any(ismember(features_needed,(352:358)))
            % Relative distances with TBM
            gOutline = bwperim(boundary_mask);
            [r,c]=find(boundary_mask);
            rMean=round(mean(r));
            cMean=round(mean(c));

            [~,distTBM_vis] = getCompDistsVis(tbm,gOutline,[rMean,cMean],w_in_range);

            overlap_num = length(find(ismember(features_needed,(351:358))));
            feat_count = feat_count+overlap_num;

            all_feature_vis = insert_vis(features_needed,(352:358),distTBM_vis,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end
    end

    if any(ismember(features_needed,(359:382)))
        % Intra-Tubular Objects

        [~,sat,~] = colour_deconvolution(I,'H PAS');
        sat = 1-im2double(sat);
        sat = imadjust(sat,[],[],3);

        blim = imdilate(boundary_mask,strel('disk',10));
        indel = imerode(blim,strel('disk',10));
        blim(indel) = 0;
        mems = imbinarize(sat,adaptthresh(sat,0.3));
        tbm = imreconstruct(blim&mems,mems);
        tbm(~blim) = 0;
        tbm = bwareaopen(tbm,50);
        tbm = imclose(tbm,strel('disk',1));

        fibers = fibermetric(sat,2:4:20);
        inmem = fibers>0.6;
        inmem(tbm)=0;
        inmem(blim) = 0;
        inmem = bwareaopen(inmem,50);

        if any(ismember(features_needed,(359:363)))
            ito_dist = bwdist(~inmem);

            if any(ismember(features_needed,[359,362]))
                mean_thick = mean(ito_dist,'all');
                mean_thick_vis = ito_dist>=(mean_thick-(w_in_range*mean_thick)) & ito_dist<=(mean_thick+(w_in_range*mean_thick));

                overlap_num = length(find(ismember(features_needed,[359,362])));
                feat_count = feat_count+overlap_num;

                all_feature_vis = insert_vis(features_needed,[359,362],mean_thick_vis,all_feature_vis);
                update_waitbar(wb,feat_count,num_feat);
            end

            if any(ismember(features_needed,[360,363]))
                max_thick = max(ito_dist,[],'all');
                max_thick_vis = ito_dist>=(max_thick-(w_in_range*max_thick));

                overlap_num = length(find(ismember(features_needed,[360,363])));
                feat_count = feat_count+overlap_num;

                all_feature_vis = insert_vis(features_needed,[360,363],max_thick_vis,all_feature_vis);
                update_waitbar(wb,feat_count,num_feat);
            end

            if find(features_needed==361)
                ito_dist(ito_dist==0) = inf;
                min_thick = min(ito_dist,[],'all');
                min_thick_vis = ito_dist<=min_thick+(w_in_range*min_thick);

                overlap_num = 1;
                feat_count = feat_count+overlap_num;

                all_feature_vis = insert_vis(features_needed,361,min_thick_vis,all_feature_vis);
                update_waitbar(wb,feat_count,num_feat);
            end
        end

        if any(ismember(features_needed,(364:373)))
            % ITO texture and RGB color features
            grayIm = rgb2gray(I);
            grayIm(~inmem) = NaN;

            if any(ismember(features_needed,(364:367)))
                % texture features
                texture_vis = TextureVisual(cat(3,inmem,pas_mask,lum_mask),...
                    grayIm,1,min_object_size,w_in_range,texture_window);

                overlap_num = length(find(ismember(features_needed,(364:367))));
                feat_count = feat_count+overlap_num;

                all_feature_vis = insert_vis(features_needed,(364:367),texture_vis,all_feature_vis);
                update_waitbar(wb,feat_count,num_feat);
            end

            if any(ismember(features_needed,(368:373)))
                % Color features
                color_vis = ColorStatsVis(I,inmem,w_in_range);

                overlap_num = length(find(ismember(features_needed,(368:373))));
                feat_count = feat_count+overlap_num;

                all_feature_vis = insert_vis(features_needed,(368:373),color_vis,all_feature_vis);
                update_waitbar(wb,feat_count,num_feat);
            end
        end

        if find(features_needed==374)
            overlap_num = 1;
            feat_count = feat_count+overlap_num;

            all_feature_vis = insert_vis(features_needed,374,inmem,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end

        if find(features_needed==375)
            overlap_num = 1;
            feat_count = feat_count+overlap_num;

            grayIm = rgb2gray(I);
            grayIm(~inmem) = NaN;
            [~,~,ito_comp_vis] = getCompRatiosVis(inmem,grayIm,min_object_size,w_in_range);
            
            all_feature_vis = insert_vis(features_needed,375,ito_comp_vis{1},all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end

        if any(ismember(features_needed,(376:382)))
            % Distance features between tubular periphery,center, and
            % compartments
            gOutline = bwperim(boundary_mask);
            [r,c]=find(boundary_mask);
            rMean=round(mean(r));
            cMean=round(mean(c));

            [~,distITO_vis] = getCompDistsVis(inmem,gOutline,[rMean,cMean],w_in_range);
            
            overlap_num = length(find(ismember(features_needed,(376:382))));
            feat_count = feat_count+overlap_num;

            all_feature_vis = insert_vis(features_needed,(376:382),distITO_vis,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end
    end
    
    if any(ismember(features_needed,[383,386:389]))
        % Tubular shape properties
        % First find overlap and send right indices to TubProps
        % order = [compactness,major al, minor al, fiber l, fiber w,
        % curl]
        overlap = find(ismember(features_needed,[383,385:389]));
        overlapping_idxes = features_needed(overlap)-293;
        tub_prop_vis = cell(length(overlap),1);
        for i = 1:length(overlap)
            feat_idx = overlapping_idxes(i);
            tub_prop_vis{i} = TubProps(boundary_mask,feat_idx);
        end

        overlap_num = length(overlap);
        feat_count = feat_count+overlap_num;

        all_feature_vis = insert_vis(features_needed,[383,386:389],tub_prop_vis,all_feature_vis);
        update_waitbar(wb,feat_count,num_feat);
    end

    if find(features_needed==384)
        overlap_num = 1;
        feat_count = feat_count+overlap_num;

        all_feature_vis = insert_vis(features_needed,385,boundary_mask,all_feature_vis);
        update_waitbar(wb,feat_count,num_feat);
    end
    
    if any(ismember(features_needed,(390:399)))
        % Weighting by distance from tubular boundary features
        gdist2 = zeros(size(boundary_mask));
        gdist2(~boundary_mask) = 1;
        gdist2 = bwdist(gdist2);
        gdist2 = (gdist-max(max(gdist2)))*-1;
        gdist2(~boundary_mask) = 0;

        if any(ismember(features_needed,(390:394)))
            lum_dist_bound = double(gdist2.*double(lum_mask));
            
            if find(features_needed==390)
                min_lum_dist = lum_dist_bound;
                min_lum_dist(lum_dist_bound==0) = inf;
                min_val = min(min_lum_dist,[],'all');
                min_val_vis = lum_dist_bound<=min_val+(w_in_range*min_val);

                overlap_num = 1;
                feat_count = feat_count+overlap_num;

                all_feature_vis = insert_vis(features_needed,390,min_val_vis,all_feature_vis);
                update_waitbar(wb,feat_count,num_feat);
            end
                
            if find(features_needed==391)
                max_val = max(lum_dist_bound(:));
                max_val_vis = lum_dist_bound>=(max_val-w_in_range*max_val);

                overlap_num = 1;
                feat_count = feat_count+overlap_num;

                all_feature_vis = insert_vis(features_needed,391,max_val_vis,all_feature_vis);
                update_waitbar(wb,feat_count,num_feat);
            end

            if find(features_needed==392)
                mean_val = mean(lum_dist_bound(:)>0);
                mean_val_vis = lum_dist_bound>=mean_val-(w_in_range*mean_val)...
                    & lum_dist_bound<=mean_val+(w_in_range*mean_val);

                overlap_num = 1;
                feat_count = feat_count+overlap_num;

                all_feature_vis = insert_vis(features_needed,392,mean_val_vis,all_feature_vis);
                update_waitbar(wb,feat_count,num_feat);
            end

            if find(features_needed==393)
                med_val = median(lum_dist_bound(:)>0);
                med_val_vis = lum_dist_bound>=med_val-(w_in_range*med_val)...
                    & lum_dist_bound<=med_val+(w_in_range*med_val);

                overlap_num = 1;
                feat_count = feat_count+overlap_num;

                all_feature_vis = insert_vis(features_needed,393,med_val_vis,all_feature_vis);
                update_waitbar(wb,feat_count,num_feat);
            end
            
            if find(features_needed==394)
                img_vec = reshape(lum_dist_bound,[],1);
                scores = (img_vec-mean(img_vec,'omitnan'))/(std(img_vec,'omitnan'));
                scores = 255*rescale(abs(scores));
                mask = reshape(scores,size(lum_dist_bound));
                mask(isnan(lum_dist_bound)) = 0;

                overlap_num = 1;
                feat_count = feat_count+overlap_num;

                all_feature_vis = insert_vis(features_needed,394,mask,all_feature_vis);
                update_waitbar(wb,feat_count,num_feat);
            end
        end

        if any(ismember(features_needed,(395:399)))
            pas_dist_bound = double(gdist2.*double(pas_mask));

            if find(features_needed==395)
                min_pas_dist = pas_dist_bound;
                min_pas_dist(min_pas_dist==0) = inf;
                min_val = min(min_pas_dist,[],'all');
                min_val_vis = pas_dist_bound<=min_val+(w_in_range*min_val);

                overlap_num = 1;
                feat_count = feat_count+overlap_num;

                all_feature_vis = insert_vis(features_needed,395,min_val_vis,all_feature_vis);
                update_waitbar(wb,feat_count,num_feat);
            end

            if find(features_needed==396)
                max_val = max(pas_dist_bound(:));
                max_val_vis = pas_dist_bound>=max_val-(w_in_range*max_val);

                overlap_num = 1;
                feat_count = feat_count+overlap_num;

                all_feature_vis = insert_vis(features_needed,396,max_val_vis,all_feature_vis);
                update_waitbar(wb,feat_count,num_feat);
            end

            if find(features_needed==397)
                mean_val = mean(pas_dist_bound(:)>0);
                mean_val_vis = pas_dist_bound>=mean_val-(w_in_range*mean_val)...
                    & pas_dist_bound<=mean_val+(w_in_range*mean_val);

                overlap_num = 1;
                feat_count = feat_count+overlap_num;

                all_feature_vis = insert_vis(features_needed,397,mean_val_vis,all_feature_vis);
                update_waitbar(wb,feat_count,num_feat);
            end

            if find(features_needed==398)
                med_val = median(pas_dist_bound(:)>0);
                med_val_vis = pas_dist_bound>=med_val-(w_in_range*med_val)...
                    & pas_dist_bound<=med_val+(w_in_range*med_val);

                overlap_num = 1;
                feat_count = feat_count+overlap_num;

                all_feature_vis = insert_vis(features_needed,398,med_val_vis,all_feature_vis);
                update_waitbar(wb,feat_count,num_feat);
            end

            if find(features_needed==399)
                img_vec = reshape(pas_dist_bound,[],1);
                scores = (img_vec-mean(img_vec,'omitnan'))/(std(img_vec,'omitnan'));
                scores = 255*rescale(abs(scores));
                mask = reshape(scores,size(pas_dist_bound));
                mask(isnan(pas_dist_bound)) = 0;

                overlap_num = 1;
                feat_count = feat_count+overlap_num;

                all_feature_vis = insert_vis(features_needed,399,mask,all_feature_vis);
                update_waitbar(wb,feat_count,num_feat);
            end
        end
    end
    
    if find(features_needed==400)
        pas_dist = bwdist(~pas_mask);
        max_pas = max(max(pas_dist));
        max_pas_vis = pas_dist>=max_pas-(w_in_range*max_pas);

        overlap_num = 1;
        feat_count = feat_count+overlap_num;

        all_feature_vis = insert_vis(features_needed,400,max_pas_vis,all_feature_vis);
        update_waitbar(wb,feat_count,num_feat);
    end
    
    if find(features_needed==401)
        lum_dist = bwdist(~lum_mask);
        max_lum = max(max(lum_dist));
        max_lum_vis = lum_dist>=max_lum-(w_in_range*max_lum);

        overlap_num = 1;
        feat_count = feat_count+overlap_num;

        all_feature_vis = insert_vis(features_needed,401,max_lum_vis,all_feature_vis);
        update_waitbar(wb,feat_count,num_feat);
    end

    if find(features_needed==402)
        nuc_dist = bwdist(~nuc_mask);
        max_nuc = max(max(nuc_dist));
        max_nuc_vis = nuc_dist>=max_nuc-(w_in_range*max_nuc);

        overlap_num = 1;
        feat_count = feat_count+overlap_num;

        all_feature_vis = insert_vis(features_needed,402,max_nuc_vis,all_feature_vis);
        update_waitbar(wb,feat_count,num_feat);
    end

    if find(features_needed==403)
        struc_dist = bwdist(~boundary_mask);
        max_struc = max(max(struc_dist));
        max_struc_vis = struc_dist>=max_struc-(w_in_range*max_struc);

        overlap_num = 1;
        feat_count = feat_count+overlap_num;

        all_feature_vis = insert_vis(features_needed,403,max_struc_vis,all_feature_vis);
        update_waitbar(wb,feat_count,num_feat);
    end

    if any(ismember(features_needed,(404:448)))
        gdist2 = zeros(size(boundary_mask));
        gdist2(~boundary_mask) = 1;
        gdist2 = bwdist(gdist2);
        gdist2 = (gdist2-max(max(gdist2)))*-1;
        gdist2(~boundary_mask) = 0;

        if any(ismember(features_needed,(404:418)))
            % Nuclei
            nuc_dist_bound = double(gdist2.*double(nuc_mask));
            feat_vis = ObjectDistVis(nuc_mask,nuc_dist_bound,w_in_range);

            overlap_num = length(find(ismember(features_needed,(404:418))));
            feat_count = feat_count+overlap_num;

            all_feature_vis = insert_vis(features_needed,(404:418),feat_vis,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end

        if any(ismember(features_needed,(419:433)))
            % Tubular Basement Membrane
            [~,sat,~] = colour_deconvolution(I,'H PAS');
            sat = 1-im2double(sat);
            sat = imadjust(sat,[],[],3);

            blim = imdilate(boundary_mask,strel('disk',10));
            indel = imerode(blim,strel('disk',10));
            blim(indel) = 0;
            mems = imbinarize(sat,adaptthresh(sat,0.3));
            tbm = imreconstruct(blim&mems,mems);
            tbm(~blim) = 0;
            tbm = bwareaopen(tbm,50);
            tbm = imclose(tbm,strel('disk',1));

            gdist = bwdist(~boundary_mask);
            tbmdist = gdist;
            tbmdist(~tbm) = 0;
            feat_vis = ObjectDistVis(tbm,tbmdist,w_in_range);

            overlap_num = length(find(ismember(features_needed,(419:433))));
            feat_count = feat_count+overlap_num;

            all_feature_vis = insert_vis(features_needed,(419:433),feat_vis,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end

        if any(ismember(features_needed,(434:448)))
            % Intra-Tubular Objects
            
            [~,sat,~] = colour_deconvolution(I,'H PAS');
            sat = 1-im2double(sat);
            sat = imadjust(sat,[],[],3);

            blim = imdilate(boundary_mask,strel('disk',10));
            indel = imerode(blim,strel('disk',10));
            blim(indel) = 0;
            mems = imbinarize(sat,adaptthresh(sat,0.3));
            tbm = imreconstruct(blim&mems,mems);
            tbm(~blim) = 0;
            tbm = bwareaopen(tbm,50);
            tbm = imclose(tbm,strel('disk',1));

            fibers = fibermetric(sat,2:4:20);
            inmem = fibers>0.6;
            inmem(tbm)=0;
            inmem(blim) = 0;
            inmem = bwareaopen(inmem,50);

            gdist = bwdist(~boundary_mask);
            inmemdist = gdist;
            inmemdist(~inmem) = 0;
            feat_vis = ObjectDistVis(inmem,inmemdist,w_in_range);

            overlap_num = length(find(ismember(features_needed,(434:448))));
            feat_count = feat_count+overlap_num;

            all_feature_vis = insert_vis(features_needed,(434:448),feat_vis,all_feature_vis);
            update_waitbar(wb,feat_count,num_feat);
        end
    end
    
    waitbar(1,wb,strcat('Feature Visualizations completed:',string(num_feat)))
    close(wb)
end

function update_waitbar(wb,idx,full)
    waitbar((idx-1)/full,wb,strcat('Feature Visualizations completed:',string(idx)))
end

function all_feature_vis = insert_vis(feat_idxes, select_range, feat_subgroup, all_feature_vis)
    [~,int_idx,~] = intersect(feat_idxes,select_range);
    
    % finding index in feat_subgroup that is in feat_idxes
    overlap = find(ismember(select_range,feat_idxes));
    
    if length(feat_subgroup)>1 && strcmp(class(feat_subgroup),'cell')
        for i = 1:length(int_idx)
            inter = int_idx(i);
            over = overlap(i);
            all_feature_vis{inter} = double(feat_subgroup{over});
        end
        
    else
        for i = 1:length(int_idx) 
            inter = int_idx(i);
            all_feature_vis{inter} = double(feat_subgroup);
        end
    end
end


