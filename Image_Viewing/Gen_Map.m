% --- Function to generate feature visualizations according to user
% selections
function Gen_Map(app,event)

if ~strcmp(inputname(1),'dummy_app')
    Get_Feat(app,event)
end

% Using the appropriate feature visualization code.
Feature_Vis_Gen(app,event)

if strcmp(inputname(1),'dummy_app')
    app.sep_feat_map = load('all_feature_vis.mat');
end


% Controlling for single feature values where you can't scroll through
% ranks.

if length(app.map_idx)>1
    if ~isempty(app.weighted_encodings)
        app.Rank_Slide.Enable = 'on';
        Relative_Ranks(app,event)
    else
        app.Rank_Slide.Enable = 'off';
        app.Rank_Slide.MajorTicks = [];
    end
else
    app.Rank_Slide.Enable = 'off';
end

% If a file is provided for feature ranking, weight feature maps according
% to pre-determined rank, otherwise, just add them together and weight
% according to where there is overlap.
if ~isempty(app.weighted_encodings)
    if ~app.Comparing || strcmp(app.Image_Name_Label.Visible,'on')
        % app.map_idx contains list of indices corresponding to order of
        % feature in app.feature_encodings table
        %final_map = zeros(size(app.sep_feat_map{1}));
        
        for i=1:length(app.map_idx)
            map_feat = app.feature_encodings.Feature_Names{app.map_idx(i)};
            map_feat_rank = find(strcmp(map_feat, app.weighted_encodings.Feature_Names));

            % Matlab, in it's infinite wisdom, truncates strings greater than 
            % 63 characters when they are in a table
            if isempty(map_feat_rank)
                map_feat = map_feat(1:namelengthmax);
                map_feat_rank = find(strcmp(map_feat, app.weighted_encodings.Feature_Names));
            end

            if ~isnan(max(app.sep_feat_map{i}))
                try
                    final_map = final_map+(1/map_feat_rank).*app.sep_feat_map{i};
                catch
                    final_map = zeros(size(app.sep_feat_map{i}));
                    final_map = final_map+(1/map_feat_rank).*app.sep_feat_map{i};
                end
            end
        end
        %final_map = rescale(final_map);        
        app.map = final_map;
       
    else
           
        final_map = cell(1,2);
        %final_map{1,1} = zeros(size(app.sep_feat_map{1,1}));
        %final_map{1,2} = zeros(size(app.sep_feat_map{1,2}));

        for i = 1:length(app.map_idx)
            map_feat = app.feature_encodings.Feature_Names{app.map_idx(i)};
            map_feat_rank = find(strcmp(map_feat, app.weighted_encodings.Feature_Names));

            % Matlab, in it's infinite wisdom, truncates strings greater than 
            % 63 characters when they are in a table
            if isempty(map_feat_rank)
                map_feat = map_feat(1:namelengthmax);
                map_feat_rank = find(strcmp(map_feat, app.weighted_encodings.Feature_Names));
            end
            
            if ~isnan(max(app.sep_feat_map{i,1}))
                try
                    final_map{1,1} = final_map{1,1}+(1/map_feat_rank).*app.sep_feat_map{i,1};
                catch
                    final_map{1,1} = zeros(size(app.sep_feat_map{i,1}));
                    final_map{1,1} = final_map{1,1}+(1/map_feat_rank).*app.sep_feat_map{i,1};
                end
            end
            if ~isnan(max(app.sep_feat_map{i,2}))
                try
                    final_map{1,2} = final_map{1,2}+(1/map_feat_rank).*app.sep_feat_map{i,2};
                catch
                    final_map{1,2} = zeros(size(app.sep_feat_map{i,2}));
                    final_map{1,2} = final_map{1,2}+(1/map_feat_rank).*app.sep_feat_map{i,2};
                end
            end
        end
        %both_maps{1} = rescale(final_map{1,1});
        %both_maps{2} = rescale(final_map{1,2});
        both_maps{1} = final_map{1,1};
        both_maps{2} = final_map{1,2};
           
        app.map = both_maps;
    end
        
else
    
    if ~app.Comparing
        
        %final_map = zeros(size(app.Current_Img{1},1),size(app.Current_Img{1},2));
        
        for i=1:length(app.map_idx)  
            if ~isnan(max(app.sep_feat_map{i}))
                try
                    final_map = final_map+app.sep_feat_map{i};
                catch
                    final_map = zeros(size(app.sep_feat_map{i}));
                    final_map = final_map+app.sep_feat_map{i};
                end
            end
        end
        %final_map = rescale(final_map);
                
        app.map = final_map;
    else
        
        final_map = cell(1,2);
        %final_map{1,1} = zeros(size(app.sep_feat_map{1,1}));
        %final_map{1,2} = zeros(size(app.sep_feat_map{1,2}));
        
        for i = 1:length(app.map_idx)
            if ~isnan(max(app.sep_feat_map{i}))
                try
                    final_map{1,1} = final_map{1,1}+app.sep_feat_map{i,1};
                catch
                    final_map{1,1} = zeros(size(app.sep_feat_map{i,1}));
                    final_map{1,1} = final_map{1,1}+app.sep_feat_map{i,1};
                end
                try
                    final_map{1,2} = final_map{1,2}+app.sep_feat_map{i,2};
                catch
                    final_map{1,2} = zeros(size(app.sep_feat_map{i,2}));
                    final_map{1,2} = final_map{1,2}+app.sep_feat_map{i,2};
                end
            end
        end
        %both_maps{1} = rescale(final_map{1,1});
        %both_maps{2} = rescale(final_map{1,2});
        both_maps{1} = final_map{1,1};
        both_maps{2} = final_map{1,2};
        
        app.map = both_maps;
    end
end

if strcmp(inputname(1),'dummy_app')
    figure, imshow(app.Comp_Img{1})
end





