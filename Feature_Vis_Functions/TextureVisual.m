function text_vis_cell = TextureVisual(composite, inte, comp, min_object_size, w_in_range, window)

% Getting compartment objects
%L = bwlabel(bwpropfilt(composite(:,:,comp), 'Area',[min_object_size+1, Inf]));

% Initial textural features
g = graycomatrix(inte);
s = graycoprops(g,'all');
s = table2array(struct2table(s));

% Sliding window size
%window = app.TextureWindowSizeEditField.Value;
if window>=size(composite,1) || window>=size(composite,2)
    if size(composite,1)<=size(composite,2)
        window = size(composite,1);
    else
        window = size(composite,2);
    end
end

row_coords = [1:window:size(composite,1),size(composite,1)];
col_coords = [1:window:size(composite,2),size(composite,2)];

text_vis_cell = cell(length(s),1);
for t =1:length(s)
    text_vis_cell{t} = zeros(size(composite,1), size(composite,2));
end

for i = 1:length(row_coords)-1
    for j = 1:length(col_coords)-1
        
        % Window textural features
        window_img = inte(row_coords(i):row_coords(i+1), col_coords(j):col_coords(j+1));
        window_comp = composite(:,:,comp);
        window_comp = window_comp(row_coords(i):row_coords(i+1), col_coords(j):col_coords(j+1));
        window_comp(isnan(window_comp)) = 0;
        window_L = bwlabel(bwpropfilt(logical(window_comp),'Area',[min_object_size,Inf]));
        if max(window_L)>0
            g_w = graycomatrix(window_img);
            s_w = table2array(struct2table(graycoprops(g_w,'all')));
            for t_ft= 1:length(s_w)
                
                % Binary inclusion masks
%                 if s_w(t_ft)>= s(t_ft)-w_in_range*s(t_ft) && s_w(t_ft)<= s(t_ft)+w_in_range*s(t_ft)
%                     inc_mask = window_comp;
%                     text_vis_cell{t_ft}(row_coords(i):row_coords(i)+window, col_coords(j):col_coords(j)+window) = inc_mask;
%                 end

                % Weighted inclusion masks
                text_vis_cell{t_ft}(row_coords(i):row_coords(i+1), col_coords(j):col_coords(j+1)) = window_comp.*s_w(t_ft);

            end
           
        end
        
    end
    
end


