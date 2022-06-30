function feat_vis = TubProps(boundary_mask,idx)

% Function for visualizing a boundary morphology features of tubules
% Tubular compactness, tubular eccentricity, equivalent diameter of a
% circle with measured tubular area, tubule major axis length,tubule minor axis length,
% tubular perimeter, tubular fiber length, tubular fiber width, tubular
% curl, and tubular solidity

% tubule_morphology = regionprops(boundary_mask,'Area','Eccentricity',...
%     'MajorAxisLength','MinorAxisLength','Perimeter','Solidity');

convex_img = bwconvhull(boundary_mask);


if idx == 90
%% Tubule Compactness 
    % a perfect circle has compactness = 1, so this visualization should
    % capture all the areas that deviate from that
    % This ends up capturing the same thing as Solidity
    compact_vis = convex_img-boundary_mask;
    
    feat_vis = rescale(compact_vis);
end

if idx == 99
    %% Tubule Solidity
    solid_vis = convex_img-boundary_mask;
    
    feat_vis = rescale(solid_vis);
end

if ismember(idx,[91,93,94])
    %% Eccentricity, Major/Minor Axis Length
    
    % Ratio of the distance between the foci of the ellipse and its major axis
    % length, visualization is made by first generating the overlaid ellipse
    % and then taking the distance transform between circles at each of the
    % foci
    %https://blogs.mathworks.com/steve/2015/08/17/ellipse-visualization-and-regionprops/
    s = regionprops(boundary_mask,{'Centroid','MajorAxisLength',...
        'MinorAxisLength','Orientation'});

    % Generating tubule ellipse
    ellipse_img = zeros(size(boundary_mask));
    t = linspace(0,2*pi,50);
    a = s(1).MajorAxisLength/2;
    b = s(1).MinorAxisLength/2;
    Xc = s(1).Centroid(1);
    Yc = s(1).Centroid(2);
    phi = deg2rad(-s(1).Orientation);
    x = Xc+a*cos(t)*cos(phi)-b*sin(t)*sin(phi);
    y = Yc+a*cos(t)*sin(phi)+b*sin(t)*cos(phi);

    f = figure('visible','off');
    hold on
    ax = uiaxes('Parent',f);
    imshow(ellipse_img,'Parent',ax)
    plot(x,y,'w')
    hold off

    filled_ellipse = imfill(imbinarize(rgb2gray(frame2im(getframe(f)))),'holes');

    % Finding foci
    ellipse_props = regionprops(filled_ellipse,'MajorAxisLength','MinorAxisLength','Centroid','Orientation');
    f_length = ((ellipse_props(1).MajorAxisLength)^2-(ellipse_props(1).MinorAxisLength)^2)^0.5;

    % Foci
    f1 = [ellipse_props(1).Centroid(1)+(f_length*cos(ellipse_props(1).Orientation)),...
        ellipse_props(1).Centroid(2)+(f_length*sin(ellipse_props(1).Orientation))];

    f2 = [ellipse_props(1).Centroid(1)-(f_length*cos(ellipse_props(1).Orientation)),...
        ellipse_props(1).Centroid(2)-(f_length*sin(ellipse_props(1).Orientation))];

    % Plotting circles with center = each of the foci and radius =
    % MajorAxisLength/2
    f = figure('visible','off');
    t = linspace(0,2*pi,50);
    hold on
    x1 = (ellipse_props(1).MajorAxisLength/2)*cos(t)+f1(1);
    y1 = (ellipse_props(1).MajorAxisLength/2)*sin(t)+f1(2);
    plot(x1,y1,'w')
    x2 = (ellipse_props(1).MajorAxisLength/2)*cos(t)+f2(1);
    y2 = (ellipse_props(1).MajorAxisLength/2)*sin(t)+f2(2);
    plot(x2,y2,'w')
    hold off

    filled_circles = imfill(imbinarize(rgb2gray(frame2im(getframe(gca)))),'holes');
    % Distance transform between the two circles
    circ_dist = bwdist(~filled_circles);
    circ_dist = imresize(circ_dist,size(boundary_mask));
    % Constraining to tubular area
    circ_dist(~boundary_mask)=0;

    ecc_vis = rescale(circ_dist);

    feat_vis = ecc_vis;
    close(f)
end

if idx == 95
    %% Tubular perimeter
    % Dilating boundary perimeter by 3
    perim_vis = imdilate(bwperim(boundary_mask),strel('disk',3));
    
    feat_vis = perim_vis;
end
if idx == 96
    %% Tubular Fiber Length
    % linear distance from minor axis along tubule length.
    tub_skel = bwskel(boundary_mask);
    % ends of skeleton
    skel_ends = bwmorph(tub_skel,'endpoints');
    [row,col] = find(skel_ends);

    % center of skeleton, but on the skeleton points
    skel_coords = find(tub_skel);
    [row_sk, col_sk] = ind2sub(size(boundary_mask),skel_coords);
    dist_skel = (skel_coords-mean(skel_coords)).^2;
    min_point = skel_coords(find(dist_skel==min(dist_skel)));
    skel_cent = [col_sk(find(skel_coords==min_point)),row_sk(find(skel_coords==min_point))];

    % Visualization as distance from center of skeleton
    length_vis = zeros(size(boundary_mask));
    length_vis(skel_cent(2),skel_cent(1))= 1;
    dist_length = bwdist(length_vis);
    dist_length(~boundary_mask)=0;

    length_vis = rescale(dist_length);
    
    feat_vis = length_vis;
end
if idx == 97
    %% Tubular Fiber Width
    % distance transform of tubule boundary
    fib_width_vis = bwdist(~boundary_mask);
    fib_width_vis(~boundary_mask)=0;
    
    feat_vis = rescale(fib_width_vis);
end
if idx == 98
    %% Tubular Curl
    tub_skel = bwskel(boundary_mask);
    skel_coords = find(tub_skel);
    [row_sk, col_sk] = ind2sub(size(boundary_mask),skel_coords);
    skel_coords = [row_sk,col_sk];
    numberOfPoints = length(skel_coords);

    curvature = zeros(1, numberOfPoints);
    for t = 1 : numberOfPoints
      if t == 1
        index1 = numberOfPoints;
        index2 = t;
        index3 = t + 1;
      elseif t >= numberOfPoints
        index1 = t-1;
        index2 = t;
        index3 = 1;
      else
        index1 = t-1;
        index2 = t;
        index3 = t + 1;
      end
      % Get the 3 points.
      x1 = col_sk(index1);
      y1 = row_sk(index1);
      x2 = col_sk(index2);
      y2 = row_sk(index2);
      x3 = col_sk(index3);
      y3 = row_sk(index3);
      % Now call Roger's formula:
      % http://www.mathworks.com/matlabcentral/answers/57194#answer_69185
      curvature(t) = 2*abs((x2-x1).*(y3-y1)-(x3-x1).*(y2-y1)) ./ ...
      sqrt(((x2-x1).^2+(y2-y1).^2)*((x3-x1).^2+(y3-y1).^2)*((x3-x2).^2+(y3-y2).^2));
    end

    max_idx = find(curvature == max(curvature));

    curl_vis = zeros(size(boundary_mask));
    for i = 1:length(max_idx)
        point_vis = zeros(size(boundary_mask));
        point_vis(row_sk(max_idx(i)),col_sk(max_idx(i)))=1;
        curl_vis = rescale(curl_vis+bwdist(point_vis));

    end
    curl_vis = imcomplement(curl_vis);
    curl_vis(~boundary_mask)=0;
    
    feat_vis = rescale(curl_vis);
end


