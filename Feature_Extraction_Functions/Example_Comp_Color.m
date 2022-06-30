% --- Function to show the average color of each compartment in an image as
% well as the impact of normalization
function Example_Comp_Color(app)

if length(app.Current_Img)==1

    % Getting RGB values for each compartment
    pas_raw_rgb = app.NormColorTable.Data(1:3,1);
    pas_norm_rgb = app.NormColorTable.Data(1:3,2);
    lum_raw_rgb = app.NormColorTable.Data(4:6,1);
    lum_norm_rgb = app.NormColorTable.Data(4:6,2);
    nuc_raw_rgb = app.NormColorTable.Data(7:9,1);
    nuc_norm_rgb = app.NormColorTable.Data(7:9,2);

    % Generating example color squares
    pas_raw_square = uint8(ones(100,100,3));
    pas_norm_square = uint8(ones(100,100,3));
    lum_raw_square = uint8(ones(100,100,3));
    lum_norm_square = uint8(ones(100,100,3));
    nuc_raw_square = uint8(ones(100,100,3));
    nuc_norm_square = uint8(ones(100,100,3));

    for i = 1:3
        pas_raw_square(:,:,i) =pas_raw_rgb(i);
        pas_norm_square(:,:,i) = pas_norm_rgb(i);
        lum_raw_square(:,:,i) = lum_raw_rgb(i);
        lum_norm_square(:,:,i) = lum_norm_rgb(i);
        nuc_raw_square(:,:,i) = nuc_raw_rgb(i);
        nuc_norm_square(:,:,i) = nuc_norm_rgb(i);
    end

    % Adding squares to their respective subplots
    imshow([pas_raw_square,pas_norm_square],'Parent',app.PASExample_Axes),title(app.PASExample_Axes,'PAS Raw RGB vs. Norm Example')

    imshow([lum_raw_square,lum_norm_square],'Parent',app.LumExample_Axes),title(app.LumExample_Axes,'Lum Raw RGB vs. Norm Example')

    imshow([nuc_raw_square,nuc_norm_square],'Parent',app.NucExample_Axes),title(app.NucExample_Axes,'Nuc Raw RGB vs. Norm Example')

else

    % This case is for when comparing between multiple images
    % Getting RGB values for each compartment
    pas_raw_rgb = app.NormColorTable.Data(1:3,1);
    pas_raw_rgb = [pas_raw_rgb,app.NormColorTable.Data(1:3,3)];
    pas_norm_rgb = app.NormColorTable.Data(1:3,2);
    pas_norm_rgb = [pas_norm_rgb,app.NormColorTable.Data(1:3,4)];
    lum_raw_rgb = app.NormColorTable.Data(4:6,1);
    lum_raw_rgb = [lum_raw_rgb,app.NormColorTable.Data(4:6,3)];
    lum_norm_rgb = app.NormColorTable.Data(4:6,2);
    lum_norm_rgb = [lum_norm_rgb,app.NormColorTable.Data(4:6,4)];
    nuc_raw_rgb = app.NormColorTable.Data(7:9,1);
    nuc_raw_rgb = [nuc_raw_rgb,app.NormColorTable.Data(7:9,3)];
    nuc_norm_rgb = app.NormColorTable.Data(7:9,2);
    nuc_norm_rgb = [nuc_norm_rgb,app.NormColorTable.Data(7:9,4)];

    % Generating example color squares
    pas_raw_square = uint8(ones(100,200,3));
    pas_norm_square = uint8(ones(100,200,3));
    lum_raw_square = uint8(ones(100,200,3));
    lum_norm_square = uint8(ones(100,200,3));
    nuc_raw_square = uint8(ones(100,200,3));
    nuc_norm_square = uint8(ones(100,200,3));

    background_square = uint8(ones(100,100,3));
    background_square(:,:,:) = 255.*0.94;

    for i = 1:3
        pas_raw_square(:,1:100,i) = pas_raw_square(:,1:100,i).*pas_raw_rgb(i,1);
        pas_raw_square(:,100:end,i) = pas_raw_square(:,100:end,i).*pas_raw_rgb(i,2);

        pas_norm_square(:,1:100,i) = pas_norm_square(:,1:100,i).*pas_norm_rgb(i,1);
        pas_norm_square(:,100:end,i) = pas_norm_square(:,100:end,i).*pas_norm_rgb(i,2);

        lum_raw_square(:,1:100,i) = lum_raw_square(:,1:100,i).*lum_raw_rgb(i,1);
        lum_raw_square(:,100:end,i) = lum_raw_square(:,100:end,i).*lum_raw_rgb(i,2);
        
        lum_norm_square(:,1:100,i) = lum_norm_square(:,1:100,i).*lum_norm_rgb(i,1);
        lum_norm_square(:,100:end,i) = lum_norm_square(:,100:end,i).*lum_norm_rgb(i,2);

        nuc_raw_square(:,1:100,i) = nuc_raw_square(:,1:100,i).*nuc_raw_rgb(i,1);
        nuc_raw_square(:,100:end,i) = nuc_raw_square(:,100:end,i).*nuc_raw_rgb(i,2);

        nuc_norm_square(:,1:100,i) = nuc_norm_square(:,1:100,i).*nuc_norm_rgb(i,1);
        nuc_norm_square(:,100:end,i) = nuc_norm_square(:,100:end,i).*nuc_norm_rgb(i,2);

    end

    % Adding squares to their respective subplots
    imshow([pas_raw_square,background_square,pas_norm_square],'Parent',app.PASExample_Axes),title(app.PASExample_Axes,'PAS Raw RGB Example (Red,Blue)')

    imshow([lum_raw_square,background_square,lum_norm_square],'Parent',app.LumExample_Axes),title(app.LumExample_Axes,'Lum Raw RGB Example (Red,Blue)')

    imshow([nuc_raw_square,background_square,nuc_norm_square],'Parent',app.NucExample_Axes),title(app.NucExample_Axes,'Nuc Raw RGB Example (Red,Blue)')
end











