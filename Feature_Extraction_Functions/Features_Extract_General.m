% --- Function for Generalized Feature Extraction based on array of feature
% indices
function feat_row = Features_Extract_General(img,comp_img,feat_idxes,mpp,mpp_scale)

% Resizing images according to mpp_scale
img = imresize(img,mpp_scale,'bilinear');
comp_img = imresize(comp_img,mpp_scale,'bilinear');

comp_img = logical(comp_img);
% Initializing feature row
feat_row = zeros(1,length(feat_idxes));

% Parameters used in feature extraction
nucpixradius = 2;
min_object_size = 15;

% Each compartment mask from compartment image
if size(comp_img,3)==3

    % Updated for hematoxylin-first sub-compartment segmentation
    % Order is hematoxylin-PAS+/eosinophilic (for H&E)-background/luminal
    % space
    pas_mask = comp_img(:,:,2);
    lum_mask = comp_img(:,:,3);
    nuc_mask = comp_img(:,:,1);
    
    pas_mask = ~bwareaopen(~pas_mask,min_object_size);
    pas_mask = bwareaopen(pas_mask,min_object_size);
    
    lum_mask = bwareaopen(lum_mask,min_object_size);
    lum_mask = imfill(lum_mask,'holes');
    
    boundary_mask = pas_mask|lum_mask|nuc_mask;
else
    boundary_mask = squeeze(sum(comp_img,3))>0;
end

boundary_mask = bwpropfilt(boundary_mask,'Area',1);

% Glomerular distance transform (Distance from center of glomerulus)
gdist = bwdist(~boundary_mask);
gdist = (-1*(gdist))+max(gdist(:));
gdist(~boundary_mask) = 0;

% Glomerular boundary
gOutline = bwperim(boundary_mask);

% Glomerular centroid
[r,c] = find(boundary_mask);
rMean = round(mean(r));
cMean = round(mean(c));

% Glomerular distance transform (Distance from glomerular boundary)
gdist2 = zeros(size(boundary_mask));
gdist2(~boundary_mask)=1;
gdist2 = bwdist(gdist2);
gdist2 = (gdist2-max(gdist2(:))*-1);
gdist2(~boundary_mask) = 0;

%% Textural and compartment containment features
if size(comp_img,3)==3
    grayPAS = rgb2gray(img);
    grayPAS(~pas_mask) = NaN;
    grayLum = rgb2gray(img);
    grayLum(~lum_mask) = NaN;
    grayNuc = rgb2gray(img);
    grayNuc(~nuc_mask) = NaN;
    
    % Composite images with each compartment in the first channel
    compLum = cat(3,lum_mask,pas_mask,nuc_mask);
    compPAS = comp_img;
    compNuc = cat(3,nuc_mask,lum_mask,pas_mask);
end


% Going through feature indices and calculating features that are contained
% within the array 

if any(ismember(feat_idxes,(1:10)))
    [ratiosL, s2, lum_num] = getCompRatios(compLum,grayLum,min_object_size);
    
    feat_subgroup = zeros(1,10);
    feat_subgroup(1,1:3) = mean(ratiosL(:,1:3));
    feat_subgroup(1,4) = sum(ratiosL(:,4));
    feat_subgroup(1,5) = mean(ratiosL(:,4));
    feat_subgroup(1,6) = median(ratiosL(:,4));
    feat_subgroup(1,7:10) = [s2(1,1).Contrast,s2(1,2).Correlation,s2(1,3).Energy,s2(1,4).Homogeneity];
    
    [overlap,int_idx,~] = intersect(feat_idxes,(1:10));
    feat_row(1,int_idx) = feat_subgroup(overlap);
    
    if any(ismember(feat_idxes,54))
        feat_row(1,find(feat_idxes==54)) = lum_num;
    end
end

if any(ismember(feat_idxes,(11:20)))
    [ratiosM,s1,PAS_num] = getCompRatios(compPAS,grayPAS,min_object_size);
    
    feat_subgroup = zeros(1,10);
    feat_subgroup(1,1:3) = mean(ratiosM(:,1:3));
    feat_subgroup(1,4) = sum(ratiosM(:,4));
    feat_subgroup(1,5) = mean(ratiosM(:,4));
    feat_subgroup(1,6) = median(ratiosM(:,4));
    feat_subgroup(1,7:10) = [s1(1,1).Contrast,s1(1,2).Correlation,s1(1,3).Energy,s1(1,4).Homogeneity];
    
    [overlap,int_idx,~] = intersect(feat_idxes,(11:20));
    feat_row(1,int_idx) = feat_subgroup(overlap-10);
    
    if any(ismember(feat_idxes,53))
        feat_row(1,find(feat_idxes==53)) = PAS_num;
    end
end

if any(ismember(feat_idxes,(21:30)))
    [ratiosN,s3,nuc_num] = getNucRatios(compNuc,nucpixradius,grayNuc);
    
    feat_subgroup = zeros(1,10);
    feat_subgroup(1,1:3) = mean(ratiosN(:,1:3));
    feat_subgroup(1,4) = sum(ratiosN(:,4));
    feat_subgroup(1,5) = mean(ratiosN(:,4));
    feat_subgroup(1,6) = mode(ratiosN(:,4));
    feat_subgroup(1,7:10) = [s3(1,1).Contrast, s3(1,2).Correlation,s3(1,3).Energy,s3(1,4).Homogeneity];
    
    [overlap,int_idx,~] = intersect(feat_idxes,(21:30));
    feat_row(1,int_idx) = feat_subgroup(overlap-20);
    
    if any(ismember(feat_idxes,55))
        feat_row(1,find(feat_idxes==55)) = nuc_num;
    end
end

if any(ismember(feat_idxes,(31:37)))
   distsL = getCompDists(lum_mask,gOutline,[rMean,cMean]);
   
   [overlap,int_idx,~] = intersect(feat_idxes, (31:37));
   feat_row(1,int_idx) = distsL(overlap-30);
end

if any(ismember(feat_idxes,(38:44)))
    distsM = getCompDists(pas_mask,gOutline,[rMean,cMean]);
    
    [overlap,int_idx,~] = intersect(feat_idxes,(38:44));
    feat_row(1,int_idx) = distsM(overlap-37);
end

if any(ismember(feat_idxes,(45:51)))
    distsN = getCompDists(nuc_mask,gOutline,[rMean,cMean]);
    
    [overlap,int_idx,~] = intersect(feat_idxes,(45:51));
    feat_row(1,int_idx) = distsN(overlap-44);
end

if any(ismember(feat_idxes,52))
    glom_area = sum(boundary_mask(:));
    
    feat_row(1,find(feat_idxes==52)) = glom_area;
end

if any(ismember(feat_idxes,(56:110)))
    PAS = bwareaopen(pas_mask,min_object_size);
    mdt = bwdist(~PAS);
    m_ext1 = mdt>0&mdt<=10;
    m_ext2 = mdt>10&mdt<=20;
    m_ext3 = mdt>20&mdt<1000;
    
    feat_subgroup = zeros(1,55);
    feat_subgroup(1,1) = sum(m_ext1(:));
    feat_subgroup(1,2) = sum(m_ext2(:));
    feat_subgroup(1,3) = sum(m_ext3(:));
    
    if sum(m_ext2(:))~= 0
        feat_subgroup(1,4) = max(max(mdt(m_ext2)));
    end
    
    feat_subgroup(1,5) = max(max(bwlabel(m_ext1)));
    feat_subgroup(1,6) = max(max(bwlabel(m_ext2)));
    feat_subgroup(1,7) = mean(mean(mdt(m_ext1>0)));
    feat_subgroup(1,8) = mean(mean(mdt(m_ext2>0)));
    feat_subgroup(1,9) = median(mdt(m_ext1>0));
    feat_subgroup(1,10) = median(mdt(m_ext2>0));
    
    stats = regionprops(m_ext1,'Area');
    stats2 = regionprops(m_ext2,'Area');
    
    feat_subgroup(1,11) = mean([stats.Area]);
    feat_subgroup(1,12) = median([stats.Area]);
    if ~isempty([stats.Area])
        feat_subgroup(1,13) = max([stats.Area]);
    end
    feat_subgroup(1,14) = mean([stats2.Area]);
    feat_subgroup(1,15) = median([stats2.Area]);
    
    edges = [1:2:80,2000];
    feat_subgroup(1,16:end) = histcounts(mdt(mdt(:)>0),edges);
    
    [overlap,int_idx,~] = intersect(feat_idxes,(56:110));
    feat_row(1,int_idx) = feat_subgroup(overlap-55);
end

if any(ismember(feat_idxes,(111:170)))
    ldt = bwdist(~lum_mask);
    edges = [1:1:60,2000];
    feat_subgroup = histcounts(ldt(ldt(:)>0),edges);
    
    [overlap,int_idx,~] = intersect(feat_idxes,(111:170));
    feat_row(1,int_idx) = feat_subgroup(overlap-110);
end

if any(ismember(feat_idxes,(171:190)))
    ndt = bwdist(~nuc_mask);
    edges = [1:1:20,2000];
    feat_subgroup = histcounts(ndt(ndt(:)>0),edges);
    
    [overlap,int_idx,~] = intersect(feat_idxes,(171:190));
    feat_row(1,int_idx) = feat_subgroup(overlap-170);
end

if any(ismember(feat_idxes,(191:214)))
    edges = [2:25:600,20000];
    feat_subgroup = histcounts(gdist(gdist(:)>0),edges);
    
    [overlap,int_idx,~] = intersect(feat_idxes,(191:214));
    feat_row(1,int_idx) = feat_subgroup(overlap-190);
end

if any(ismember(feat_idxes,(215:220)))
    [d1,d2,z] = size(img);
    
    PAS_int = im2double(img);
    PAS_int(~repmat(pas_mask,[1,1,3])) = NaN;
    PAS_int = reshape(PAS_int,[d1*d2],3);
    
    feat_subgroup = zeros(1,6);
    feat_subgroup(1,1) = mean(PAS_int(:,1),'omitnan');
    feat_subgroup(1,2) = mean(PAS_int(:,2),'omitnan');
    feat_subgroup(1,3) = mean(PAS_int(:,3),'omitnan');
    feat_subgroup(1,4) = std(PAS_int(:,1),[],'omitnan');
    feat_subgroup(1,5) = std(PAS_int(:,2),[],'omitnan');
    feat_subgroup(1,6) = std(PAS_int(:,3),[],'omitnan');
    
    [overlap,int_idx,~] = intersect(feat_idxes,(215:220));
    feat_row(1,int_idx) = feat_subgroup(overlap-214);
end

if any(ismember(feat_idxes,(221:226)))
    [d1,d2,z] = size(img);
    
    lum_int = im2double(img);
    lum_int(~repmat(lum_mask,[1,1,3])) = NaN;
    lum_int = reshape(lum_int,[d1*d2],3);
    
    feat_subgroup = zeros(1,6);
    feat_subgroup(1,1) = mean(lum_int(:,1),'omitnan');
    feat_subgroup(1,2) = mean(lum_int(:,2),'omitnan');
    feat_subgroup(1,3) = mean(lum_int(:,3),'omitnan');
    feat_subgroup(1,4) = std(lum_int(:,1),[],'omitnan');
    feat_subgroup(1,5) = std(lum_int(:,2),[],'omitnan');
    feat_subgroup(1,6) = std(lum_int(:,3),[],'omitnan');
    
    [overlap,int_idx,~] = intersect(feat_idxes,(221:226));
    feat_row(1,int_idx) = feat_subgroup(overlap-220);
end

if any(ismember(feat_idxes,(227:232)))
    [d1,d2,z] = size(img);
    
    nuc_int = im2double(img);
    nuc_int(~repmat(nuc_mask,[1,1,3])) = NaN;
    nuc_int = reshape(nuc_int,[d1*d2],3);
    
    feat_subgroup = zeros(1,6);
    feat_subgroup(1,1) = mean(nuc_int(:,1),'omitnan');
    feat_subgroup(1,2) = mean(nuc_int(:,2),'omitnan');
    feat_subgroup(1,3) = mean(nuc_int(:,3),'omitnan');
    feat_subgroup(1,4) = std(nuc_int(:,1),[],'omitnan');
    feat_subgroup(1,5) = std(nuc_int(:,2),[],'omitnan');
    feat_subgroup(1,6) = std(nuc_int(:,3),[],'omitnan');
    
    [overlap,int_idx,~] = intersect(feat_idxes,(227:232));
    feat_row(1,int_idx) = feat_subgroup(overlap-226);
end

if any(ismember(feat_idxes,(233:243)))
    [y,x] = find(nuc_mask);
    [theta,rho] = cart2pol(x-rMean,y-cMean);
    feat_subgroup = histcounts(rho,[0,100:1000,1300]);
    
    [overlap,int_idx,~] = intersect(feat_idxes,(233:243));
    feat_row(1,int_idx) = feat_subgroup(overlap-232);
    
    if any(ismember(feat_idxes,(266:285)))
        feat_subgroup = histcounts(theta,[-pi:(2*pi/20):pi]);
        
        [overlap,int_idx,~] = intersect(feat_idxes,(266:285));
        feat_row(1,int_idx) = feat_subgroup(overlap-265);
    end
end

if any(ismember(feat_idxes,(244:254)))
    [y,x] = find(lum_mask);
    [~,rho] = cart2pol(x-rMean,y-cMean);
    feat_subgroup = histcounts(rho,[0:100:1000:1300]);
    
    [overlap,int_idx,~] = intersect(feat_idxes,(244:254));
    feat_row(1,int_idx) = feat_subgroup(overlap-243);
end

if any(ismember(feat_idxes,(255:265)))
    [y,x] = find(pas_mask);
    [~,rho] = cart2pol(x-rMean,y-cMean);
    feat_subgroup = histcounts(rho,[0:100:1000,1300]);
    
    [overlap,int_idx,~] = intersect(feat_idxes,(255:265));
    feat_row(1,int_idx) = feat_subgroup(overlap-254);
end

if any(ismember(feat_idxes,(286:295)))
    nuc_dist_bound = double(gdist2.*double(nuc_mask));
    feat_subgroup = quantile(nonzeros(nuc_dist_bound(:)),[.1:.1:1]);
    
    [overlap,int_idx,~] = intersect(feat_idxes,(286:295));
    feat_row(1,int_idx) = feat_subgroup(overlap-285);
end

if any(ismember(feat_idxes,(296:305)))
    PAS_dist_bound = double(gdist2.*double(pas_mask));
    feat_subgroup = quantile(nonzeros(PAS_dist_bound(:)),[.1:.1:1]);
    
    [overlap,int_idx,~] = intersect(feat_idxes,(296:305));
    feat_row(1,int_idx) = feat_subgroup(overlap-295);
end

if any(ismember(feat_idxes,(306:315)))
    lum_dist_bound = double(gdist2.*double(lum_mask));
    feat_subgroup = quantile(nonzeros(lum_dist_bound(:)),[.1:.1:1]);
    
    [overlap,int_idx,~] = intersect(feat_idxes,(306:315));
    feat_row(1,int_idx) = feat_subgroup(overlap-305);
end
    
if any(ismember(feat_idxes,(316:329)))
    nuc_coords = regionprops(nuc_mask,'centroid');
    nuc_coords = struct2cell(nuc_coords);
    nuc_coords = cell2mat(nuc_coords');
   
    if length(nuc_coords)>2

        % MST Features

        % MST Features = [Degrees per Node, Leaf Fraction, Average Edge Length,
        % Standard Deviation Edge Length, Median Edge Length]
        D = zeros(length(nuc_coords));
        for a = 1:length(nuc_coords)
            D(a,:) = sqrt((nuc_coords(:,1)-nuc_coords(a,1)).^2+(nuc_coords(:,2)-nuc_coords(a,2)).^2);
        end

        G = graph(D);
        M = minspantree(G);

        deg_per_node = sum(degree(M))/length(nuc_coords);
        leaf_fraction = sum(degree(M)==1)/(length(nuc_coords)-1);
        avg_edge = mean(M.Edges.Weight);
        std_edge = std(M.Edges.Weight);
        med_edge = median(M.Edges.Weight);
    else
        deg_per_node = 0;
        leaf_fraction = 0;
        avg_edge = 0;
        std_edge = 0;
        med_edge = 0;
    end

    if length(nuc_coords)>2
        % Voronoi Features

        % Voronoi Features = [Mean inter-vertex distance, Mean ridge length,
        % Standard Deviation Ridge Length, Median Ridge Length, Mean Region Area,
        % Standard Deviation Region Area, Median Region Area]
        [verts, cells] = voronoin(nuc_coords);

        D = zeros(length(verts)-1);
        for a = 2:length(verts)
           D(a,:) = sqrt((verts(2:end,1)-verts(a,1)).^2+(verts(2:end,2)-verts(a,2)).^2); 
        end

        mean_iv_dist = mean(D(:),'omitnan');
        med_iv_dist = median(D(:),'omitnan');
        std_iv_dist = std(D(:),'omitnan');

        A = zeros(length(cells),1);
        ridge_coords = cell(length(cells),1);
        for b = 1:length(cells)
            v1 = verts(cells{b},1);
            v2 = verts(cells{b},2);

            ridges = [v1,v2];
            ridges = ridges(~any(isnan(ridges)|isinf(ridges),2),:);
            ridge_coords{b} = ridges;

            A(b) = polyarea(v1,v2);
        end

        ridge_lengths = zeros(1);
        for c = 1:length(ridge_coords)
            current_cell = ridge_coords{c};
            if length(current_cell)>2
                R = zeros(length(current_cell));
                for d = 1:length(current_cell)
                    R(d,:) = sqrt((current_cell(:,1)-current_cell(d,1)).^2+(current_cell(:,2)-current_cell(d,2)).^2);
                end
                unique_lengths = unique(R);
                ridge_lengths = [ridge_lengths;unique_lengths];
            end
        end

        mean_reg_area = mean(A,'omitnan');
        std_reg_area = std(A,'omitnan');
        med_reg_area = median(A,'omitnan');

        mean_ridge_length = mean(ridge_lengths(2:end),'omitnan');
        std_ridge_length = std(ridge_lengths(2:end),'omitnan');
        med_ridge_length = median(ridge_lengths(2:end),'omitnan');

    else
        mean_iv_dist = 0;
        med_iv_dist = 0;
        std_iv_dist = 0;
        mean_reg_area = 0;
        std_reg_area = 0;
        med_reg_area = 0;
        mean_ridge_length = 0;
        std_ridge_length = 0;
        med_ridge_length = 0;

    end
    
    %feat_subgroup = zeros(1,15);
    feat_subgroup = [deg_per_node,leaf_fraction,avg_edge,std_edge,med_edge,...
        mean_iv_dist,med_iv_dist,std_iv_dist,mean_ridge_length,std_ridge_length,...
        med_ridge_length,mean_reg_area,std_reg_area,med_reg_area];
    
    [overlap,int_idx,~] = intersect(feat_idxes,(316:329));
    feat_row(1,int_idx) = feat_subgroup(overlap-315);
    
end

if any(ismember(feat_idxes,(330:334)))
    % General Features = [Area (um^2), Convex Area (um^2), Perimeter (um),
    % Solidity, Eccentricity]
    mask_feats = regionprops(boundary_mask,'Area','ConvexArea','Perimeter','Solidity','Eccentricity');
    
    area = mask_feats.Area*(mpp^2);
    convex_area = mask_feats.ConvexArea*(mpp^2);
    perimeter = mask_feats.Perimeter*(mpp);
    solidity = mask_feats.Solidity;
    eccentricity = mask_feats.Eccentricity;

    feat_subgroup = [area,convex_area,perimeter,solidity,eccentricity];
    
    [overlap,int_idx,~] = intersect(feat_idxes,(330:334));
    feat_row(1,int_idx) = feat_subgroup(overlap-329);
end
    
% Tubular basement membrane (TBM)
if any(ismember(feat_idxes,(335:358)))
    
    [~,sat,~] = colour_deconvolution(img,'H PAS');
    sat = 1-im2double(sat);
    sat = imadjust(sat,[],[],3);
    
    mems = imbinarize(sat,adaptthresh(sat,0.3));
    blim = imdilate(boundary_mask,strel('disk',10));
    indel = imerode(blim,strel('disk',10));
    blim(indel) = 0;
    tbm = imreconstruct(blim&mems,mems);
    tbm = bwareaopen(tbm,50);
    tbm = imclose(tbm,strel('disk',1));
    
    dt = bwdist(~tbm);
    grayIm = rgb2gray(img);
    grayIm(~tbm) = NaN;
    
    if any(ismember(feat_idxes,(335:337)))
        thin_feats = get_thinness(tbm);
        
        feat_subgroup = zeros(1,3);
        feat_subgroup(1,1) = mean(thin_feats);
        feat_subgroup(1,2) = max(thin_feats);
        feat_subgroup(1,3) = min(thin_feats);
        
        [overlap,int_idx,~] = intersect(feat_idxes,(335:337));
        feat_row(1,int_idx) = feat_subgroup(overlap-334);
    end
    
    if any(ismember(feat_idxes,[338,339]))
        
        feat_subgroup = zeros(1,2);
        feat_subgroup(1,1) = mean(mean(dt));
        feat_subgroup(1,2) = max(max(dt));
        
        [overlap,int_idx,~] = intersect(feat_idxes,[338,339]);
        feat_row(1,int_idx) = feat_subgroup(overlap-337);
    end
    
    if any(ismember(feat_idxes,(340:343)))
       
        stats = graycoprops(graycomatrix(grayIm));
        feat_subgroup = zeros(1,4);
        
        feat_subgroup(1,1) = stats.Energy;
        feat_subgroup(1,2) = stats.Correlation;
        feat_subgroup(1,3) = stats.Contrast;
        feat_subgroup(1,4) = stats.Homogeneity;
    end
    
    if any(ismember(feat_idxes,(344:349)))
        
        tbm_int = im2double(img);
        tbm_int(~repmat(tbm,[1,1,3])) = NaN;
        tbm_int = reshape(tbm_int,[],3);
        
        feat_subgroup = zeros(1,6);
        feat_subgroup(1,1) = mean(tbm_int(:,1),'omitnan');
        feat_subgroup(1,2) = mean(tbm_int(:,2),'omitnan');
        feat_subgroup(1,3) = mean(tbm_int(:,3),'omitnan');
        feat_subgroup(1,4) = std(tbm_int(:,1),[],'omitnan');
        feat_subgroup(1,5) = std(tbm_int(:,2),[],'omitnan');
        feat_subgroup(1,6) = std(tbm_int(:,3),[],'omitnan');
        
        [overlap,int_idx,~] = intersect(feat_idxes,(344:349));
        feat_row(1,int_idx) = feat_subgroup(overlap-343);
    end
    
    if any(ismember(feat_idxes,(350:358)))
        
        stats = regionprops(tbm,'Solidity');
        diststbm = getCompDists(tbm,gOutline,[rMean,cMean]);
        
        feat_subgroup = zeros(1,9);
        feat_subgroup(1,1) = sum(sum(tbm));
        feat_subgroup(1,2) = mean([stats.Solidity]);
        
        feat_subgroup(1,3:end) = mean(diststbm);
        
        [overlap,int_idx,~] = intersect(feat_idxes,(350:358));
        feat_row(1,int_idx) = feat_subgroup(overlap-349);
        
    end
        
end

% Intra-Tubular Objects
if any(ismember(feat_idxes,(359:382)))
    
    [~,sat,~] = colour_deconvolution(img,'H PAS');
    sat = 1-im2double(sat);
    sat = imadjust(sat,[],[],3);
    
    boundary_w_mem = imdilate(boundary_mask,strel('disk',10));
    
    fibers = fibermetric(sat,2:4:20);
    inmem = fibers>0.6;
    inmem(tbm) = 0;
    inmem(~boundary_w_mem) = 0;
    inmem = bwareaopen(inmem,50);
    
    inmemdist = gdist;
    inmemdist(~inmem) = 0;
    inmem_areas = regionprops(inmem,'SubarrayIdx');
    
    if any(ismember(feat_idxes,(359:361)))
        
        thin_feats = get_thinness(inmem);
        
        feat_subgroup = zeros(1,3);
        feat_subgroup(1,1) = mean(thin_feats);
        feat_subgroup(1,2) = max(thin_feats);
        feat_subgroup(1,3) = min(thin_feats);
        
        [overlap,int_idx,~] = intersect(feat_idxes,(359:361));
        feat_row(1,int_idx) = feat_subgroup(overlap-358);
    end
    
    if any(ismember(feat_idxes,[362,363]))
        
        dt = bwdist(~inmem);
        
        feat_subgroup = zeros(1,2);
        feat_subgroup(1,1) = mean(mean(dt));
        feat_subgroup(1,2) = max(max(dt));
        
        [overlap,int_idx,~] = intersect(feat_idxes,[362,363]);
        feat_row(1,int_idx) = feat_subgroup(overlap-361);
    end
    
    if any(ismember(feat_idxes,(364:367)))
        
        grayIm = rgb2gray(img);
        grayIm(~inmem) = NaN;
        stats = graycoprops(graycomatrix(grayIm));
        
        feat_subgroup = zeros(1,4);
        feat_subgroup(1,1) = stats.Energy;
        feat_subgroup(1,2) = stats.Correlation;
        feat_subgroup(1,3) = stats.Contrast;
        feat_subgroup(1,4) = stats.Homogeneity;
        
        [overlap,int_idx,~] = intersect(feat_idxes,(364:367));
        feat_row(1,int_idx) = feat_subgroup(overlap-363);
    end
        
    if any(ismember(feat_idxes,(368:373)))
        
        inmem_int = im2double(img);
        inmem_int(~repmat(inmem,[1,1,3])) = NaN;
        inmem_int = reshape(inmem_int,[],3);
        
        feat_subgroup = zeros(1,6);
        feat_subgroup(1,1) = mean(inmem_int(:,1),'omitnan');
        feat_subgroup(1,2) = mean(inmem_int(:,2),'omitnan');
        feat_subgroup(1,3) = mean(inmem_int(:,3),'omitnan');
        feat_subgroup(1,4) = std(inmem_int(:,1),[],'omitnan');
        feat_subgroup(1,5) = std(inmem_int(:,2),[],'omitnan');
        feat_subgroup(1,6) = std(inmem_int(:,3),[],'omitnan');
        
        [overlap,int_idx,~] = intersect(feat_idxes,(368:373));
        feat_row(1,int_idx) = feat_subgroup(overlap-367);
        
    end
    
    if any(ismember(feat_idxes,[374,375]))
        
        stats = regionprops(inmem,'Solidity');
        feat_subgroup = zeros(1,2);
        feat_subgroup(1,1) = sum(sum(inmem));
        feat_subgroup(1,2) = mean([stats.Solidity]);
        
        [overlap,int_idx,~] = intersect(feat_idxes,[374,375]);
        feat_row(1,int_idx) = feat_subgroup(overlap-373);
    end
    
    if any(ismember(feat_idxes,(376:382)))
        
        distsinmem = getCompDists(inmem,gOutline,[rMean,cMean]);
        
        feat_subgroup = mean(distsinmem);
        [overlap,int_idx,~] = intersect(feat_idxes,(376:382));
        feat_row(1,int_idx) = feat_subgroup(overlap-375);
    end 
    
end

if any(ismember(feat_idxes,(383:389)))
    
    tubule_morphology = regionprops(boundary_mask,'Area','Eccentricity',...
        'MajorAxisLength','MinorAxisLength','Perimeter','Solidity');
    
    feat_subgroup = zeros(1,7);
    feat_subgroup(1,1) = (4*pi*tubule_morphology.Area)/(tubule_morphology.Perimeter.^2);
    feat_subgroup(1,2) = sqrt(4*tubule_morphology.Area*pi);
    feat_subgroup(1,3) = tubule_morphology.MajorAxisLength;
    feat_subgroup(1,4) = tubule_morphology.MinorAxisLength;
    feat_subgroup(1,5) = real((tubule_morphology.Perimeter-sqrt(tubule_morphology.Perimeter.^2-(16*tubule_morphology.Area)))/4);
    feat_subgroup(1,6) = tubule_morphology.Area/real((tubule_morphology.Perimeter-sqrt(tubule_morphology.Perimeter.^2-(16*tubule_morphology.Area)))/4);
    feat_subgroup(1,7) = tubular_morphology.MajorAxisLength/real((tubule_morphology.Perimeter-sqrt(tubule_morphology.Perimeter.^2-(16*tubule_morphology.Area)))/4);
    
    
    [overlap,int_idx,~] = intersect(feat_idxes,(383:389));
    feat_row(1,int_idx) = feat_subgroup(overlap-382);
end

if any(ismember(feat_idxes,(390:394)))
    
    lum_dist_bound = double(gdist2.*double(lum_mask));
    
    feat_subgroup = zeros(1,5);
    feat_subgroup(1,1) = min(lum_dist_bound(lum_dist_bound(:)>0));
    feat_subgroup(1,2) = max(lum_dist_bound(:));
    feat_subgroup(1,3) = mean(lum_dist_bound(lum_dist_bound(:)>0));
    feat_subgroup(1,4) = median(lum_dist_bound(lum_dist_bound(:)>0));
    feat_subgroup(1,5) = std(lum_dist_bound(lum_dist_bound(:)>0));
    
    [overlap,int_idx,~] = intersect(feat_idxes,(390:394));
    feat_row(1,int_idx) = feat_subgroup(overlap-389);
end

if any(ismember(feat_idxes,(395:399)))
    
    PAS_dist_bound = double(gdist2.*double(pas_mask));
    
    feat_subgroup = zeros(1,5);
    feat_subgroup(1,1) = min(PAS_dist_bound(PAS_dist_bound(:)>0));
    feat_subgroup(1,2) = max(PAS_dist_bound(:));
    feat_subgroup(1,3) = mean(PAS_dist_bound(PAS_dist_bound(:)>0));
    feat_subgroup(1,4) = median(PAS_dist_bound(PAS_dist_bound(:)>0));
    feat_subgroup(1,5) = std(PAS_dist_bound(PAS_dist_bound(:)>0));
    
    [overlap,int_idx,~] = intersect(feat_idxes,(395:399));
    feat_row(1,int_idx) = feat_subgroup(overlap-394);
end

if any(ismember(feat_idxes,400))
    mdt = bwdist(~pas_mask);
    
    feat_row(1,find(feat_idxes==400)) = max(mdt(:));
end

if any(ismember(feat_idxes,401))
    ldt = bwdist(~lum_mask);
    
    feat_row(1,find(feat_idxes==401)) = max(ldt(:));
end

if any(ismember(feat_idxes,402))
    ndt = bwdist(~nuc_mask);
    
    feat_row(1,find(feat_idxes==402)) = max(ndt(:));
end

if any(ismember(feat_idxes,403))
    
    feat_row(1,find(feat_idxes==403)) = max(max(gdist));
end

if any(ismember(feat_idxes,(404:418)))
    
    nuc_areas = regionprops(nuc_mask,'SubArrayIdx');
    nuc_dist = gdist;
    nuc_dist(~nuc_mask) = 0;
    
    uobs = bwlabel(nuc_mask);
    stats_n = [];
    for i = 1:numel(nuc_areas)
        loc = nuc_areas(i).SubArrayIdx;
        smallmask = uobs(loc{:});
        
        dtvals = nucdist(loc{:}).*double(smallmask==i);
        if sum(dtvals(:))==0
            ovals = zeros(1,3);
        else
            ovals = [mean(dtvals(:)),min(dtvals(dtvals>0)),max(dtvals(:))];
        end
        stats_n = [stats_n;ovals];
    end

    feat_subgroup = zeros(1,15);
    if numel(nuc_areas)>0
        feat_subgroup(1,1) = max(stats_n(:,1));
        feat_subgroup(1,2) = max(stats_n(:,2));
        feat_subgroup(1,3) = max(stats_n(:,3));
        
        feat_subgroup(1,4) = mean(stats_n(:,1));
        feat_subgroup(1,5) = mean(stats_n(:,2));
        feat_subgroup(1,6) = mean(stats_n(:,3));
        feat_subgroup(1,7) = min(stats_n(:,1));
        feat_subgroup(1,8) = min(stats_n(:,2));
        feat_subgroup(1,9) = min(stats_n(:,3));
        feat_subgroup(1,10) = var(stats_n(:,1));
        feat_subgroup(1,11) = var(stats_n(:,2));
        feat_subgroup(1,12) = var(stats_n(:,3));
        feat_subgroup(1,13) = median(stats_n(:,1));
        feat_subgroup(1,14) = median(stats_n(:,2));
        feat_subgroup(1,15) = median(stats_n(:,3));
        
    end
    
    [overlap,int_idx,~] = intersect(feat_idxes,(404:418));
    feat_row(1,int_idx) = feat_subgroup(overlap-403);
end
    
if any(ismember(feat_idxes,(419:433)))
    
    [~,sat,~] = colour_deconvolution(img,'H PAS');
    sat = 1-im2double(sat);
    sat = imadjust(sat,[],[],3);
    
    boundary_w_mem = imdilate(boundary_mask,strel('disk',10));
    
    fibers = fibermetric(sat,2:4:20);
    inmem = fibers>0.6;
    inmem(tbm) = 0;
    inmem(~boundary_w_mem) = 0;
    inmem = bwareaopen(inmem,50);
    
    inmemdist = gdist;
    inmemdist(~inmem) = 0;
    inmem_areas = regionprops(inmem,'SubarrayIdx');
        
    inmemdist = gdist;
    inmemdist(~inmem) = 0;
    
    uobs = bwlabel(inmem);
    stats_inmem = [];
    for i = 1:numel(inmem_areas)
        loc = inmem_areas(i).SubArrayIdx;
        smallmask = uobs(loc{:});
        
        dtvals = nucdist(loc{:}).*double(smallmask==i);
        if sum(dtvals(:))==0
            ovals = zeros(1,3);
        else
            ovals = [mean(dtvals(:)),min(dtvals(dtvals>0)),max(dtvals(:))];
        end
        stats_inmem = [stats_inmem;ovals];
    end

    feat_subgroup = zeros(1,15);
    if numel(inmem_areas)>0
        feat_subgroup(1,1) = max(stats_inmem(:,1));
        feat_subgroup(1,2) = max(stats_inmem(:,2));
        feat_subgroup(1,3) = max(stats_inmem(:,3));
        
        feat_subgroup(1,4) = mean(stats_inmem(:,1));
        feat_subgroup(1,5) = mean(stats_inmem(:,2));
        feat_subgroup(1,6) = mean(stats_inmem(:,3));
        feat_subgroup(1,7) = min(stats_inmem(:,1));
        feat_subgroup(1,8) = min(stats_inmem(:,2));
        feat_subgroup(1,9) = min(stats_inmem(:,3));
        feat_subgroup(1,10) = var(stats_inmem(:,1));
        feat_subgroup(1,11) = var(stats_inmem(:,2));
        feat_subgroup(1,12) = var(stats_inmem(:,3));
        feat_subgroup(1,13) = median(stats_inmem(:,1));
        feat_subgroup(1,14) = median(stats_inmem(:,2));
        feat_subgroup(1,15) = median(stats_inmem(:,3));
        
    end
    
    [overlap,int_idx,~] = intersect(feat_idxes,(419:433));
    feat_row(1,int_idx) = feat_subgroup(overlap-418);
end    

if any(ismember(feat_idxes,(434:448)))
    
    [~,sat,~] = colour_deconvolution(img,'H PAS');
    sat = 1-im2double(sat);
    sat = imadjust(sat,[],[],3);
    
    boundary_w_mem = imdilate(boundary_mask,strel('disk',10));
    
    fibers = fibermetric(sat,2:4:20);
    inmem = fibers>0.6;
    inmem(tbm) = 0;
    inmem(~boundary_w_mem) = 0;
    inmem = bwareaopen(inmem,50);
    
    inmemdist = gdist;
    inmemdist(~inmem) = 0;
    inmem_areas = regionprops(inmem,'SubarrayIdx');
        
    inmemdist = gdist;
    inmemdist(~inmem) = 0;
    
    uobs = bwlabel(inmem);
    stats_inmem = [];
    for i = 1:numel(inmem_areas)
        loc = inmem_areas(i).SubArrayIdx;
        smallmask = uobs(loc{:});
        
        dtvals = nucdist(loc{:}).*double(smallmask==i);
        if sum(dtvals(:))==0
            ovals = zeros(1,3);
        else
            ovals = [mean(dtvals(:)),min(dtvals(dtvals>0)),max(dtvals(:))];
        end
        stats_inmem = [stats_inmem;ovals];
    end

    feat_subgroup = zeros(1,15);
    if numel(inmem_areas)>0
        feat_subgroup(1,1) = max(stats_inmem(:,1));
        feat_subgroup(1,2) = max(stats_inmem(:,2));
        feat_subgroup(1,3) = max(stats_inmem(:,3));
        
        feat_subgroup(1,4) = mean(stats_inmem(:,1));
        feat_subgroup(1,5) = mean(stats_inmem(:,2));
        feat_subgroup(1,6) = mean(stats_inmem(:,3));
        feat_subgroup(1,7) = min(stats_inmem(:,1));
        feat_subgroup(1,8) = min(stats_inmem(:,2));
        feat_subgroup(1,9) = min(stats_inmem(:,3));
        feat_subgroup(1,10) = var(stats_inmem(:,1));
        feat_subgroup(1,11) = var(stats_inmem(:,2));
        feat_subgroup(1,12) = var(stats_inmem(:,3));
        feat_subgroup(1,13) = median(stats_inmem(:,1));
        feat_subgroup(1,14) = median(stats_inmem(:,2));
        feat_subgroup(1,15) = median(stats_inmem(:,3));
        
    end
    
    [overlap,int_idx,~] = intersect(feat_idxes,(434:448));
    feat_row(1,int_idx) = feat_subgroup(overlap-433);
end    
    
if any(find(feat_idxes>448))
    
    custom_feat_idxes = feat_idxes(find(feat_idxes>448));
    custom_features = Extract_Custom_Features(img,comp_img,custom_feat_idxes,mpp);
    
    feat_row(1,find(feat_idxes>448)) = custom_features;
    
end



