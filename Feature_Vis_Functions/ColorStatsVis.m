function color_stats_vis = ColorStatsVis(I, compMasks, w_in_range)

count = 1;
color_stats_vis = cell(18,1);
for comp = 1:size(compMasks,3)
    compImage = im2double(I);
    compImage(~repmat(compMasks(:,:,comp),[1,1,3]))=NaN;
    
    for stat = 1:2
        for ch = 1:size(compImage,3)
            if stat ==1
                mean_ch = nanmean(nanmean(compImage(:,:,ch)));

                [y_inc,x_inc] = find(compImage(:,:,ch)>=mean_ch-(w_in_range*mean_ch) & compImage(:,:,ch)<=mean_ch+(w_in_range*mean_ch));
                mask = zeros(size(compImage,1),size(compImage,2));
                for i = 1:length(x_inc)
                    mask(y_inc(i),x_inc(i))=1;
                end
            else
                img_vec = reshape(compImage(:,:,ch),[],1);
                scores = (img_vec-nanmean(img_vec))/(nanstd(img_vec));
                scores = rescale(abs(scores));
                mask = reshape(scores,size(compImage(:,:,ch)));
                
                mask(isnan(compImage(:,:,ch)))=0;
            end
            color_stats_vis{count} = mask;
            %figure, imshow(mask)
            count = count+1;
        end
    end
end
    



