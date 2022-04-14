function [num_vis_cell_rho, num_vis_cell_theta] = NumberPixVis(x,y,theta,rho,mask,counts_rho,counts_theta);

    num_vis_cell_rho = cell(length(counts_rho),1);
    old_rho = 0;
    for i=1:length(counts_rho)
        
        if old_rho ~= 1000
            coord_inc = find(old_rho<rho & rho<i*100);
            x_inc = x(coord_inc);
            y_inc = y(coord_inc);
            
            inc_mask = zeros(size(mask));
            for ij = 1:length(x_inc)
                inc_mask(y_inc(ij),x_inc(ij))=1;
            end
                
            %figure, imshow(inc_mask), title(string(i))
            num_vis_cell_rho{i} = inc_mask;
            old_rho = i*100;
        else
            coord_inc = find(old_rho<rho & rho<1300);
            x_inc = x(coord_inc);
            y_inc = y(coord_inc);
            
            inc_mask = zeros(size(mask));
            for ij = 1:length(x_inc)
                inc_mask(y_inc(ij),x_inc(ij))=1;
            end
            num_vis_cell_rho{i} = inc_mask;
        end
    end
    
    %close all
    if length(counts_theta)>1
        num_vis_cell_theta = cell(length(counts_theta),1);
        theta_vals = (-pi:(2*pi/length(counts_theta)):pi);
        for i=1:length(counts_theta)

            coord_inc = find(theta_vals(i)<theta & theta<theta_vals(i+1));
            x_inc = x(coord_inc);
            y_inc = y(coord_inc);

            inc_mask = zeros(size(mask));
            for ij = 1:length(x_inc)
                inc_mask(y_inc(ij),x_inc(ij))=1;
            end
            num_vis_cell_theta{i} = inc_mask;
            %figure, imshow(inc_mask), title(string(i))

        end
    else
        num_vis_cell_theta = 'blep';
    end











