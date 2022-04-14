% --- Function to generate feature visualizations 
function Feature_Vis(app,event)

% Take single map_idx or list of map_idx and generate visualizations
min_object_size = 25;
nucpixradius = 2;
w_in_range = app.w_in_range;

if ~app.Comparing

    f = waitbar(0,'Feature Visualizations completed:0');

    image_name = app.Image_Name_Label.Value;
    image_name = strsplit(image_name,',');
    image_name = image_name{1};
    [I,mask,composite] = Extract_Spec_Img(app,event,image_name);
    
    app.Comp_Img = composite;

    mes_mask=composite(:,:,1);
    white_mask=composite(:,:,2);
    nuc_mask=composite(:,:,3);

    boundary_mask=mes_mask|white_mask|nuc_mask;

    features_needed = app.map_idx;
    
    all_feature_vis = cell(length(features_needed),1);
    for feat = 1:length(features_needed)

        waitbar((feat-1)/length(features_needed),f,strcat('Feature Visualizations completed:',string(feat)))

        feature_index = features_needed(feat);

        % Generate inverted glomerular distance transform for glomerular distance
        % transform feature generation
        gdist=bwdist(~boundary_mask);
        gdist=(-1*(gdist))+max(gdist(:));
        gdist(~boundary_mask)=0;

        % Determine glomerular centroid
        [r,c]=find(boundary_mask);
        rMean=round(mean(r));
        cMean=round(mean(c));

        if feature_index == 52
            % Determine glomerular area
            gArea_vis = boundary_mask;               
                
            all_feature_vis{feat} = double(gArea_vis);
            continue
        end

        if ismember(feature_index,(31:51))
            % Determine glomerular boundary
            gOutline=bwperim(boundary_mask);

            % Get distance features between the glomerular periphery, center, and
            % between compartments

            if feature_index<=37
                [distsL, distL_vis]=getCompDistsVis(white_mask,gOutline,[rMean,cMean], w_in_range);

                all_feature_vis{feat} = double(distL_vis{feature_index-30});
                continue
            end
            if 38<=feature_index && feature_index<=44
                [distsM, distM_vis]=getCompDistsVis(mes_mask,gOutline,[rMean,cMean], w_in_range);

                all_feature_vis{feat} = double(distM_vis{feature_index-37});
                continue
            end
            if 45<=feature_index && feature_index<=51
                [distsN, distN_vis]=getCompDistsVis(nuc_mask,gOutline,[rMean,cMean], w_in_range);

                all_feature_vis{feat} = double(distN_vis{feature_index-44});
                continue
            end
        end

        if ismember(feature_index,(286:315))
            gdist2=zeros(size(boundary_mask));

            gdist2(~boundary_mask)=1;
            gdist2=bwdist(gdist2);
            gdist2=(gdist2-max(max(gdist2)))*-1;
            gdist2(~boundary_mask)=0;

            if feature_index<=295
                nuc_dist_bound=double(gdist2.*double(nuc_mask));

                nv=quantile(nonzeros(nuc_dist_bound(:)),[.1:.1:1]);
                nv_vis = cell(10,1);
                old_nv = 0;
                for i=1:length(nv)
                   nv_vis{i} = (old_nv<nuc_dist_bound & nuc_dist_bound<=nv(i)); 
                   old_nv = nv(i);
                end
                all_feature_vis{feat} = double(nv_vis{feature_index-285});
                continue
            end

            if 296<=feature_index && feature_index<=305
                mes_dist_bound=double(gdist2.*double(mes_mask));

                mv=quantile(nonzeros(mes_dist_bound(:)),[.1:.1:1]);
                mv_vis = cell(length(mv),1);
                old_mv = 0;
                for i = 1:length(mv)
                    mv_vis{i} = (old_mv<mes_dist_bound & mes_dist_bound<=mv(i));
                    old_mv = mv(i);
                end
                all_feature_vis{feat} = double(mv_vis{feature_index-295});
                continue
            end

            if 306<=feature_index && feature_index<=315

                lum_dist_bound=double(gdist2.*double(white_mask));


                %%%% Quantile of pixels from boundary line %%%%%%%% 
                lv=quantile(nonzeros(lum_dist_bound(:)),[.1:.1:1]);
                lv_vis = cell(length(lv),1);
                old_lv = 0;
                for i=1:length(lv)
                   lv_vis{i} = (old_lv<lum_dist_bound & lum_dist_bound<=lv(i)); 
                   old_lv = lv(i);
                end
                %[all_feature_vis{306:315}] = lv_vis{:};
                all_feature_vis{feat} = double(lv_vis{feature_index-305});
                continue
            end

        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

        if ismember(feature_index,(233:285))

            [y,x]=find(nuc_mask);

            [theta,rho]=cart2pol(x-rMean,y-cMean);

            N_n=histcounts(rho,[0:100:1000,1300]);

            T_n=histcounts(theta,[-pi:(2*pi/20):pi]);

            if 233<=feature_index && feature_index<=243

                [nuc_num_rho_vis, nuc_num_theta_vis] = NumberPixVis(x,y,theta,rho,nuc_mask,N_n,T_n);    
                all_feature_vis{feat} = double(nuc_num_rho_vis{feature_index-232});
                continue
            end

            if 266<=feature_index && feature_index<=285
                [nuc_num_rho_vis, nuc_num_theta_vis] = NumberPixVis(x,y,theta,rho,nuc_mask,N_n,T_n);    

                all_feature_vis{feat} = double(nuc_num_theta_vis{feature_index-265});
                continue
            end

            [y,x]=find(white_mask);

            [theta,rho]=cart2pol(x-rMean,y-cMean);

            N_l=histcounts(rho,[0:100:1000,1300]);

            if 244<=feature_index && feature_index<=254

                [lum_num_rho_vis, nunya] = NumberPixVis(x,y,theta,rho,white_mask,N_l,0);
                all_feature_vis{feat} = double(lum_num_rho_vis{feature_index-243});
                continue
            end

            [y,x]=find(mes_mask);

            [theta,rho]=cart2pol(x-rMean,y-cMean);

            N_m=histcounts(rho,[0:100:1000,1300]);

            if 255<=feature_index && feature_index<=265

                [mes_num_rho_vis, nunya] = NumberPixVis(x,y,theta,rho,mes_mask, N_m,0);
                all_feature_vis{feat} = double(mes_num_rho_vis{feature_index-254});
                continue
            end
        end

        mes=mes_mask;
        mes=bwareaopen(mes,min_object_size);

        if ismember(feature_index,(56:70))
            %PAS+ distance transform image
            mdt=bwdist(~mes);


            %Manually selected distance transform cuts for PAS+ component
            m_ext1=mdt>0&mdt<=10;
            sum_PAS_0_10 = m_ext1;

            if feature_index == 56 || feature_index ==60
                all_feature_vis{feat} = double(sum_PAS_0_10);
                continue
            end

            if feature_index == 62 || feature_index == 64
                mean_0_10 = mean(mean(mdt(m_ext1>0)));
                median_0_10 = median(mdt(m_ext1>0));
                mean_0_10_vis = mdt>=mean_0_10-(w_in_range*mean_0_10) & mdt<=mean_0_10+(w_in_range*mean_0_10);
                median_0_10_vis = mdt>=median_0_10-(w_in_range*median_0_10) & mdt<=median_0_10+(w_in_range*median_0_10);

                if feature_index == 62
                    all_feature_vis{feat} = double(mean_0_10_vis);
                    continue
                else
                    all_feature_vis{feat} = double(median_0_10_vis);
                    continue
                end
            end


            if ismember(feature_index,[57,59,61,63,65])
                m_ext2=mdt>10&mdt<=20;
                sum_PAS_10_20 = m_ext2;

                if feature_index==57 || feature_index==59 || feature_index ==61
                    all_feature_vis{feat} = double(sum_PAS_10_20);
                    continue
                end

                mean_10_20 = mean(mean(mdt(m_ext2>0)));
                median_10_20 = median(mdt(m_ext2>0));
                mean_10_20_vis = mdt>=mean_10_20-(w_in_range*mean_10_20) & mdt<=mean_10_20+(w_in_range*mean_10_20);
                median_10_20_vis = mdt>=median_10_20-(w_in_range*median_10_20) & mdt<=median_10_20+(w_in_range*median_10_20);

                if feature_index==63
                    all_feature_vis{feat} = double(mean_10_20_vis);
                    continue
                end
                if feature_index==65
                    all_feature_vis{feat} = double(median_10_20_vis);
                    continue
                end
            end
            if 66<=feature_index && feature_index<=70
                dist_area_vis = DistAreaVisual(mdt, w_in_range);
                all_feature_vis{feat} = double(dist_area_vis{feature_index-65});
                continue
            end

            if feature_index==58
                m_ext3=mdt>20&mdt<1000;
                sum_PAS_20_1000 = m_ext3;
                all_feature_vis{feat} = double(sum_PAS_20_1000);
                continue
            end

        end

        % Get histogram data from each various glomerular component distance
        % transform
        if 71<=feature_index && feature_index<=110
            mdt=bwdist(~mes);

            edges=[1:2:80,2000];
            N1=histcounts(mdt(mdt(:)>0),edges);
            count_PAS_vis = cell(length(N1),1);
            for m = 1:length(N1)
                count_PAS_vis{m} = mdt>edges(m) & mdt<=edges(m+1);
            end
            all_feature_vis{feat} = double(count_PAS_vis{feature_index-70});
            continue
        end

        if 111<=feature_index && feature_index<=170
            ldt=bwdist(~white_mask);
            edges=[1:1:60,2000];
            N2=histcounts(ldt(ldt(:)>0),edges);
            count_lum_vis = cell(length(N2),1);
            for m = 1:length(N2)
                count_lum_vis{m} = ldt>edges(m) & ldt<=edges(m+1);
            end
            all_feature_vis{feat} = double(count_lum_vis{feature_index-110});
            continue
        end

        if 171<=feature_index && feature_index<=190
            ndt=bwdist(~nuc_mask);
            edges=[1:1:20,2000];
            N3=histcounts(ndt(ndt(:)>0),edges);
            count_nuc_vis = cell(length(N3),1);
            for m = 1:length(N3)
                count_nuc_vis{m} = ndt>edges(m) & ndt<=edges(m+1);
            end
            all_feature_vis{feat} = double(count_nuc_vis{feature_index-170});
            continue
        end

        if 191<=feature_index && feature_index<=214
            edges=[2:25:600,20000];
            N4=histcounts(gdist(gdist(:)>0),edges);
            count_glom_vis = cell(length(N4),1);
            for m = 1:length(N4)
                count_glom_vis{m} = gdist>edges(m) & gdist<=edges(m+1);
            end
            all_feature_vis{feat} = double(count_glom_vis{feature_index-190});
            continue
        end


        if ismember(feature_index, [11,14:16,17:20])
            % Create grayscale representation of image to determine textural features
            grayIm=rgb2gray(I);
            grayIm(~mes_mask)=NaN;

            % Determine textural and compartment containment features
            [ratiosM,s1,mes_num, mes_comp_vis]=getCompRatiosVis(composite,grayIm,min_object_size, w_in_range);

            mes_texture_vis = TextureVisual(composite, grayIm, 1, min_object_size, w_in_range);

            if 17<=feature_index && feature_index<=20
                all_feature_vis{feat} = double(mes_texture_vis{feature_index-16});
                continue
            end
            if feature_index == 14
                all_feature_vis{feat} = double(mes_mask);
                continue
            end
            if 15<=feature_index && feature_index<=16
                all_feature_vis{feat} = double(mes_comp_vis{feature_index-13});
                continue
            end
            if feature_index == 11
                all_feature_vis{feat} = double(mes_comp_vis{1});
                continue
            end
        end

        if ismember(feature_index,[1,4:10])

            % Re-orient the segmentation channels so that the function 'getCompRatios'
            % knows which segmentation is the primary compartment to be examined
            composite=cat(3,white_mask,mes_mask,nuc_mask);
            composite(~repmat(boundary_mask,[1,1,3]))=0;

            % Repeat the steps above for luminal compartments
            grayIm=rgb2gray(I);
            grayIm(~white_mask)=NaN;

            if ismember(feature_index,[1,5,6])
                [ratiosL,s2,lum_num, lum_comp_vis]=getCompRatiosVis(composite,grayIm,min_object_size, w_in_range);
                if feature_index==1
                    all_feature_vis{feat} = double(lum_comp_vis{1});
                    continue
                end
                if 5<=feature_index && feature_index<=6
                    all_feature_vis{feat} = double(lum_comp_vis{feature_index-3});
                    continue
                end
            end

            if ismember(feature_index,(7:10))   
                lum_texture_vis = TextureVisual(composite, grayIm, 1, min_object_size, w_in_range);
                all_feature_vis{feat} = double(lum_texture_vis{feature_index-6});
                continue
            else
                all_feature_vis{feat} = double(white_mask);
                continue
            end
        end

        if ismember(feature_index,(23:30))
            % Re-orient the segmentation channels so that the function 'getNucRatios'
            % knows which segmentation is the primary compartment to be examined
            composite=cat(3,nuc_mask,white_mask,mes_mask);
            composite(~repmat(boundary_mask,[1,1,3]))=0;
            grayIm=rgb2gray(I);
            grayIm(~nuc_mask)=NaN;

            if ismember(feature_index,[23,25,26])
                % Get nuclear ratios
                [ratiosN,s3,nuc_num, nuc_comp_vis]=getNucRatiosVis(composite,nucpixradius,grayIm, w_in_range);

                if feature_index==23
                    all_feature_vis{feat} = double(nuc_comp_vis{1});
                    continue
                else
                    all_feature_vis{feat} = double(nuc_comp_vis{feature_index-23});
                    continue
                end
            end

            if ismember(feature_index,(27:30))    
                nuc_texture_vis = TextureVisual(composite, grayIm, 1, 2, w_in_range);
                all_feature_vis{feat} = double(nuc_texture_vis{feature_index-26});
                continue
            else
                all_feature_vis{feat} = double(nuc_mask);
                continue
            end
        end

        if ismember(feature_index,[2,3,12,13,21,22])
            % Features relative to other compartments
            relative_feature_vis = RelativeVisual(cat(3,mes_mask,white_mask,nuc_mask));

            if ismember(feature_index,[2,3])

                all_feature_vis{feat} = double(relative_feature_vis{feature_index+1});
                continue
            end
            if ismember(feature_index, [12,13])

                all_feature_vis{feat} = double(relative_feature_vis{feature_index-11});
                continue
            end
            if ismember(feature_index, [21,22])

                all_feature_vis{feat} = double(relative_feature_vis{feature_index-16});
                continue
            end
        end

        % Number of objects per compartment
        if feature_index == 53
            all_feature_vis{feat} = double(mes_mask);
            continue
        end
        if feature_index == 54
            all_feature_vis{feat} = double(white_mask);
            continue
        end
        if feature_index == 55
            all_feature_vis{feat} = double(nuc_mask);
            continue
        end

        if ismember(feature_index,(215:232))
            color_stats_vis= ColorStatsVis(I,cat(3,mes,white_mask,nuc_mask),w_in_range);

            all_feature_vis{feat} = double(color_stats_vis{feature_index-214});
            continue
        end

        if ismember(feature_index,(316:329))
            cent = regionprops(logical(nuc_mask),'centroid');
            nuc_centroids = struct2cell(cent);
            coordinates = reshape(cell2mat(nuc_centroids),2,length(nuc_centroids));

            if ismember(feature_index, (316:320))
                if length(nuc_centroids)>1
                    [M,G] = OS_minSpanTreeFromCoordinates(coordinates);
                    min_span_vis = MinSpanTreeVis(M, nuc_mask, w_in_range);

                    all_feature_vis{feat} = double(min_span_vis{feature_index-315});
                    continue                    
                else
                    % Sclerotic glomeruli with too few nuclei
                    all_feature_vis{feat} = double(nuc_mask);
                    continue
                end
            end

             if ismember(feature_index,(321:329))
                if length(coordinates)>3
                    [verts, cells] = voronoin(coordinates');
                    voronoi_vis = VoronoiVis(verts, cells, nuc_mask, w_in_range);

                    all_feature_vis{feat} = double(voronoi_vis{feature_index-320});
                    continue
                else
                    all_feature_vis{feat} = double(nuc_mask);
                    continue
                end
             end
        end

        if ismember(feature_index,(330:334))

            if feature_index == 330
                all_feature_vis{feat} = double(boundary_mask);
                continue
            end
            if feature_index == 332 || feature_index == 334
                all_feature_vis{feat} = double(imdilate(bwperim(boundary_mask),1));
                continue
            end
            if feature_index == 331 || feature_index == 333
                all_feature_vis{feat} = double(bwconvhull(boundary_mask));
                continue
            end
        end
    end

    waitbar(1,f,'Feature Visualizations Completed');
    pause(1);
    close(f)
    
else
    % Indices of feature maps to generate
    features_needed = app.map_idx;
    % Added variables for replacing individual image feature maps
    if app.Red_Only
        replace_map = 1;
        
        all_feature_vis = app.sep_feat_map;
    end
    if app.Blue_Only
        replace_map = 2;
        
        all_feature_vis = app.sep_feat_map;
    end
    if ~app.Red_Only && ~app.Blue_Only
        replace_map = [1,2];
        
        app.Comp_Img = cell(1,2);
        all_feature_vis = cell(length(features_needed),2);
    end
        
    for j = 1:length(replace_map)
        im_num = replace_map(j);
        
        f = waitbar(0,'Feature Visualizations completed:0');
        
        if ~app.CatchNRelease
            if im_num == 1
                I = imread(app.img_paths{app.img_count});
                mask = imread(app.mask_paths{app.img_count});
                
                %img_name = app.img_paths{app.img_count};
            else
                I = imread(app.comp_img_paths{app.comp_img_count});
                mask = imread(app.comp_mask_paths{app.comp_img_count});
                
                %img_name = app.comp_img_paths{app.comp_img_count};
            end
        
            composite = Seg_Img(I, mask, im_num, app);

        else
            if im_num==1
                img_idx = find(strcmp(app.Full_Feature_set.ImgLabel,app.img_paths{app.img_count}));
                [I,mask,composite] = Extract_Spec_Img(app,event,img_idx);
            else
                comp_img_idx = find(strcmp(app.Full_Feature_set.ImgLabel,app.comp_img_paths{app.comp_img_count}));
                [I,mask,composite] = Extract_Spec_Img(app,event,comp_img_idx);
            end
        end
        
        mes_mask=composite(:,:,1);
        white_mask=composite(:,:,2);
        nuc_mask=composite(:,:,3);

        boundary_mask=mes_mask|white_mask|nuc_mask;

        for feat = 1:length(features_needed)

            waitbar((feat-1)/length(features_needed),f,strcat('Feature Visualizations completed:',string(feat)))

            feature_index = features_needed(feat);

            % Generate inverted glomerular distance transform for glomerular distance
            % transform feature generation
            gdist=bwdist(~boundary_mask);
            gdist=(-1*(gdist))+max(gdist(:));
            gdist(~boundary_mask)=0;

            % Determine glomerular centroid
            [r,c]=find(boundary_mask);
            rMean=round(mean(r));
            cMean=round(mean(c));

            if feature_index == 52
                % Determine glomerular area
                %gArea=sum(boundary_mask(:));
                gArea_vis = boundary_mask;
                %all_feature_vis{52} = gArea_vis;
                all_feature_vis{feat,im_num} = double(gArea_vis);
                continue
            end

            if ismember(feature_index,(31:51))
                % Determine glomerular boundary
                gOutline=bwperim(boundary_mask);

                % Get distance features between the glomerular periphery, center, and
                % between compartments

                if feature_index<=37
                    [distsL, distL_vis]=getCompDistsVis(white_mask,gOutline,[rMean,cMean], w_in_range);

                    all_feature_vis{feat,im_num} = double(distL_vis{feature_index-30});
                    continue
                end
                if 38<=feature_index && feature_index<=44
                    [distsM, distM_vis]=getCompDistsVis(mes_mask,gOutline,[rMean,cMean], w_in_range);

                    all_feature_vis{feat,im_num} = double(distM_vis{feature_index-37});
                    continue
                end
                if 45<=feature_index && feature_index<=51
                    [distsN, distN_vis]=getCompDistsVis(nuc_mask,gOutline,[rMean,cMean], w_in_range);

                    all_feature_vis{feat,im_num} = double(distN_vis{feature_index-44});
                    continue
                end
            end

            if ismember(feature_index,(286:315))
                gdist2=zeros(size(boundary_mask));

                gdist2(~boundary_mask)=1;
                gdist2=bwdist(gdist2);
                gdist2=(gdist2-max(max(gdist2)))*-1;
                gdist2(~boundary_mask)=0;

                if feature_index<=295
                    nuc_dist_bound=double(gdist2.*double(nuc_mask));

                    nv=quantile(nonzeros(nuc_dist_bound(:)),[.1:.1:1]);
                    nv_vis = cell(10,1);
                    old_nv = 0;
                    for i=1:length(nv)
                       nv_vis{i} = (old_nv<nuc_dist_bound & nuc_dist_bound<=nv(i)); 
                       old_nv = nv(i);
                    end
                    all_feature_vis{feat,im_num} = double(nv_vis{feature_index-285});
                    continue
                end

                if 296<=feature_index && feature_index<=305
                    mes_dist_bound=double(gdist2.*double(mes_mask));

                    mv=quantile(nonzeros(mes_dist_bound(:)),[.1:.1:1]);
                    mv_vis = cell(length(mv),1);
                    old_mv = 0;
                    for i = 1:length(mv)
                        mv_vis{i} = (old_mv<mes_dist_bound & mes_dist_bound<=mv(i));
                        old_mv = mv(i);
                    end
                    all_feature_vis{feat,im_num} = double(mv_vis{feature_index-295});
                    continue
                end

                if 306<=feature_index && feature_index<=315

                    lum_dist_bound=double(gdist2.*double(white_mask));
                    %%%% Quantile of pixels from boundary line %%%%%%%% 
                    lv=quantile(nonzeros(lum_dist_bound(:)),[.1:.1:1]);
                    lv_vis = cell(length(lv),1);
                    old_lv = 0;
                    for i=1:length(lv)
                       lv_vis{i} = (old_lv<lum_dist_bound & lum_dist_bound<=lv(i)); 
                       old_lv = lv(i);
                    end
                    %[all_feature_vis{306:315}] = lv_vis{:};
                    all_feature_vis{feat,im_num} = double(lv_vis{feature_index-305});
                    continue
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

            if ismember(feature_index,(233:285))

                [y,x]=find(nuc_mask);
                [theta,rho]=cart2pol(x-rMean,y-cMean);
                N_n=histcounts(rho,[0:100:1000,1300]);
                T_n=histcounts(theta,[-pi:(2*pi/20):pi]);

                if 233<=feature_index && feature_index<=243
                    [nuc_num_rho_vis, nuc_num_theta_vis] = NumberPixVis(x,y,theta,rho,nuc_mask,N_n,T_n);    
                    all_feature_vis{feat,im_num} = double(nuc_num_rho_vis{feature_index-232});
                    continue
                end

                if 266<=feature_index && feature_index<=285
                    [nuc_num_rho_vis, nuc_num_theta_vis] = NumberPixVis(x,y,theta,rho,nuc_mask,N_n,T_n);    
                    all_feature_vis{feat,im_num} = double(nuc_num_theta_vis{feature_index-265});
                    continue
                end

                [y,x]=find(white_mask);
                [theta,rho]=cart2pol(x-rMean,y-cMean);
                N_l=histcounts(rho,[0:100:1000,1300]);

                if 244<=feature_index && feature_index<=254
                    [lum_num_rho_vis, nunya] = NumberPixVis(x,y,theta,rho,white_mask,N_l,0);
                    all_feature_vis{feat,im_num} = double(lum_num_rho_vis{feature_index-243});
                    continue
                end

                [y,x]=find(mes_mask);
                [theta,rho]=cart2pol(x-rMean,y-cMean);
                N_m=histcounts(rho,[0:100:1000,1300]);
                
                if 255<=feature_index && feature_index<=265
                    [mes_num_rho_vis, nunya] = NumberPixVis(x,y,theta,rho,mes_mask, N_m,0);
                    all_feature_vis{feat,im_num} = double(mes_num_rho_vis{feature_index-254});
                    continue
                end
            end

            mes=mes_mask;
            mes=bwareaopen(mes,min_object_size);

            if ismember(feature_index,(56:70))
                %PAS+ distance transform image
                mdt=bwdist(~mes);

                %Manually selected distance transform cuts for PAS+ component
                m_ext1=mdt>0&mdt<=10;
                sum_PAS_0_10 = m_ext1;

                if feature_index == 56 || feature_index ==60
                    all_feature_vis{feat,im_num} = double(sum_PAS_0_10);
                    continue
                end

                if feature_index == 62 || feature_index == 64
                    mean_0_10 = mean(mean(mdt(m_ext1>0)));
                    median_0_10 = median(mdt(m_ext1>0));
                    mean_0_10_vis = mdt>=mean_0_10-(w_in_range*mean_0_10) & mdt<=mean_0_10+(w_in_range*mean_0_10);
                    median_0_10_vis = mdt>=median_0_10-(w_in_range*median_0_10) & mdt<=median_0_10+(w_in_range*median_0_10);

                    if feature_index == 62
                        all_feature_vis{feat,im_num} = double(mean_0_10_vis);
                        continue
                    else
                        all_feature_vis{feat,im_num} = double(median_0_10_vis);
                        continue
                    end
                end

                if ismember(feature_index,[57,59,61,63,65])
                    m_ext2=mdt>10&mdt<=20;
                    sum_PAS_10_20 = m_ext2;

                    if feature_index==57 || feature_index==59 || feature_index ==61
                        all_feature_vis{feat,im_num} = double(sum_PAS_10_20);
                        continue
                    end

                    mean_10_20 = mean(mean(mdt(m_ext2>0)));
                    median_10_20 = median(mdt(m_ext2>0));
                    mean_10_20_vis = mdt>=mean_10_20-(w_in_range*mean_10_20) & mdt<=mean_10_20+(w_in_range*mean_10_20);
                    median_10_20_vis = mdt>=median_10_20-(w_in_range*median_10_20) & mdt<=median_10_20+(w_in_range*median_10_20);

                    if feature_index==63
                        all_feature_vis{feat,im_num} = double(mean_10_20_vis);
                        continue
                    end
                    if feature_index==65
                        all_feature_vis{feat,im_num} = double(median_10_20_vis);
                        continue
                    end
                end
                if 66<=feature_index && feature_index<=70
                    dist_area_vis = DistAreaVisual(mdt, w_in_range);
                    all_feature_vis{feat,im_num} = double(dist_area_vis{feature_index-65});
                    continue
                end

                if feature_index==58
                    m_ext3=mdt>20&mdt<1000;
                    sum_PAS_20_1000 = m_ext3;
                    all_feature_vis{feat,im_num} = double(sum_PAS_20_1000);
                    continue
                end
            end

            % Get histogram data from each various glomerular component distance
            % transform
            if 71<=feature_index && feature_index<=110
                mdt=bwdist(~mes);

                edges=[1:2:80,2000];
                N1=histcounts(mdt(mdt(:)>0),edges);
                count_PAS_vis = cell(length(N1),1);
                for m = 1:length(N1)
                    count_PAS_vis{m} = mdt>edges(m) & mdt<=edges(m+1);
                end
                all_feature_vis{feat,im_num} = double(count_PAS_vis{feature_index-70});
                continue
            end

            if 111<=feature_index && feature_index<=170
                ldt=bwdist(~white_mask);
                edges=[1:1:60,2000];
                N2=histcounts(ldt(ldt(:)>0),edges);
                count_lum_vis = cell(length(N2),1);
                for m = 1:length(N2)
                    count_lum_vis{m} = ldt>edges(m) & ldt<=edges(m+1);
                end
                all_feature_vis{feat,im_num} = double(count_lum_vis{feature_index-110});
                continue
            end

            if 171<=feature_index && feature_index<=190
                ndt=bwdist(~nuc_mask);
                edges=[1:1:20,2000];
                N3=histcounts(ndt(ndt(:)>0),edges);
                count_nuc_vis = cell(length(N3),1);
                for m = 1:length(N3)
                    count_nuc_vis{m} = ndt>edges(m) & ndt<=edges(m+1);
                end
                all_feature_vis{feat,im_num} = double(count_nuc_vis{feature_index-170});
                continue
            end

            if 191<=feature_index && feature_index<=214
                edges=[2:25:600,20000];
                N4=histcounts(gdist(gdist(:)>0),edges);
                count_glom_vis = cell(length(N4),1);
                for m = 1:length(N4)
                    count_glom_vis{m} = gdist>edges(m) & gdist<=edges(m+1);
                end
                all_feature_vis{feat,im_num} = double(count_glom_vis{feature_index-190});
                continue
            end

            if ismember(feature_index, [11,14:16,17:20])
                % Create grayscale representation of image to determine textural features
                grayIm=rgb2gray(I);
                grayIm(~mes_mask)=NaN;

                % Determine textural and compartment containment features
                [ratiosM,s1,mes_num, mes_comp_vis]=getCompRatiosVis(composite,grayIm,min_object_size, w_in_range);

                mes_texture_vis = TextureVisual(composite, grayIm, 1, min_object_size, w_in_range);

                if 17<=feature_index && feature_index<=20
                    all_feature_vis{feat,im_num} = double(mes_texture_vis{feature_index-16});
                    continue
                end
                if feature_index == 14
                    all_feature_vis{feat,im_num} = double(mes_mask);
                    continue
                end
                if 15<=feature_index && feature_index<=16
                    all_feature_vis{feat,im_num} = double(mes_comp_vis{feature_index-13});
                    continue
                end
                if feature_index == 11
                    all_feature_vis{feat,im_num} = double(mes_comp_vis{1});
                    continue
                end
            end

            if ismember(feature_index,[1,4:10])
                % Re-orient the segmentation channels so that the function 'getCompRatios'
                % knows which segmentation is the primary compartment to be examined
                composite=cat(3,white_mask,mes_mask,nuc_mask);
                composite(~repmat(boundary_mask,[1,1,3]))=0;

                % Repeat the steps above for luminal compartments
                grayIm=rgb2gray(I);
                grayIm(~white_mask)=NaN;
                if ismember(feature_index,[1,5,6])
                    [ratiosL,s2,lum_num, lum_comp_vis]=getCompRatiosVis(composite,grayIm,min_object_size, w_in_range);
                    if feature_index==1
                        all_feature_vis{feat,im_num} = double(lum_comp_vis{1});
                        continue
                    end
                    if 5<=feature_index && feature_index<=6
                        all_feature_vis{feat,im_num} = double(lum_comp_vis{feature_index-3});
                        continue
                    end
                end
                if ismember(feature_index,(7:10))   
                    lum_texture_vis = TextureVisual(composite, grayIm, 1, min_object_size, w_in_range);
                    all_feature_vis{feat,im_num} = double(lum_texture_vis{feature_index-6});
                    continue
                else
                    all_feature_vis{feat,im_num} = double(white_mask);
                    continue
                end
            end

            if ismember(feature_index,(23:30))
                % Re-orient the segmentation channels so that the function 'getNucRatios'
                % knows which segmentation is the primary compartment to be examined
                composite=cat(3,nuc_mask,white_mask,mes_mask);
                composite(~repmat(boundary_mask,[1,1,3]))=0;
                grayIm=rgb2gray(I);
                grayIm(~nuc_mask)=NaN;
                if ismember(feature_index,[23,25,26])
                    % Get nuclear ratios
                    [ratiosN,s3,nuc_num, nuc_comp_vis]=getNucRatiosVis(composite,nucpixradius,grayIm, w_in_range);
                    if feature_index==23
                        all_feature_vis{feat,im_num} = double(nuc_comp_vis{1});
                        continue
                    else
                        all_feature_vis{feat,im_num} = double(nuc_comp_vis{feature_index-23});
                        continue
                    end
                end

                if ismember(feature_index,(27:30))    
                    nuc_texture_vis = TextureVisual(composite, grayIm, 1, 2, w_in_range);
                    all_feature_vis{feat,im_num} = double(nuc_texture_vis{feature_index-26});
                    continue
                else
                    all_feature_vis{feat,im_num} = double(nuc_mask);
                    continue
                end
            end

            if ismember(feature_index,[2,3,12,13,21,22])
                % Features relative to other compartments
                relative_feature_vis = RelativeVisual(cat(3,mes_mask,white_mask,nuc_mask));
                if ismember(feature_index,[2,3])
                    all_feature_vis{feat,im_num} = double(relative_feature_vis{feature_index+1});
                    continue
                end
                if ismember(feature_index, [12,13])

                    all_feature_vis{feat,im_num} = double(relative_feature_vis{feature_index-11});
                    continue
                end
                if ismember(feature_index, [21,22])

                    all_feature_vis{feat,im_num} = double(relative_feature_vis{feature_index-16});
                    continue
                end
            end

            % Number of objects per compartment
            if feature_index == 53
                all_feature_vis{feat,im_num} = double(mes_mask);
                continue
            end
            if feature_index == 54
                all_feature_vis{feat,im_num} = double(white_mask);
                continue
            end
            if feature_index == 55
                all_feature_vis{feat,im_num} = double(nuc_mask);
                continue
            end

            if ismember(feature_index,(215:232))
                color_stats_vis= ColorStatsVis(I,cat(3,mes,white_mask,nuc_mask),w_in_range);
                all_feature_vis{feat,im_num} = double(color_stats_vis{feature_index-214});
                continue
            end

            if ismember(feature_index,(316:329))
                cent = regionprops(nuc_mask>0,'centroid');
                nuc_centroids = struct2cell(cent);
                coordinates = reshape(cell2mat(nuc_centroids),2,length(nuc_centroids));

                if ismember(feature_index, (316:320))
                    if length(nuc_centroids)>1
                        [M,G] = OS_minSpanTreeFromCoordinates(coordinates);
                        min_span_vis = MinSpanTreeVis(M, nuc_mask, w_in_range);

                        all_feature_vis{feat,im_num} = double(min_span_vis{feature_index-315});
                        continue                    
                    else
                        % Sclerotic glomeruli with too few nuclei
                        all_feature_vis{feat,im_num} = double(nuc_mask);
                        continue
                    end
                end

                if ismember(feature_index,(321:329))
                    if length(coordinates)>3
                        [verts, cells] = voronoin(coordinates');
                        voronoi_vis = VoronoiVis(verts, cells, nuc_mask, w_in_range);

                        all_feature_vis{feat,im_num} = double(voronoi_vis{feature_index-320});
                        continue
                    else
                        all_feature_vis{feat,im_num} = double(nuc_mask);
                        continue
                    end
                 end
            end
            if ismember(feature_index,(330:334))
                if feature_index == 330
                    all_feature_vis{feat,im_num} = double(boundary_mask);
                    continue
                end
                if feature_index == 332 || feature_index == 334
                    all_feature_vis{feat,im_num} = double(bwperim(boundary_mask));
                    continue
                end
                if feature_index == 331 || feature_index == 333
                    all_feature_vis{feat,im_num} = double(bwconvhull(boundary_mask));
                    continue
                end
            end
        end 
        
        waitbar(1,f,'Feature Visualizations Completed');
        pause(1);
        close(f)

    end
    
end
    
app.sep_feat_map = all_feature_vis;


