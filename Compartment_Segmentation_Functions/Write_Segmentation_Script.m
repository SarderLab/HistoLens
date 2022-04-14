% --- Function to write segmentation procedure to new matlab script
% containing compartment segmentation script to be used in feature
% extraction and feature visualization
function Write_Segmentation_Script(app,event)
% Include "app.Seg_Script" as path to file

% Iterate through all structures
for s = 1:length(fieldnames(app.Seg_Params))
    current_structure = fieldnames(app.Seg_Params);
    current_structure = current_structure{s};
    
    % Fieldnames of app.Seg_Params will include what method of compartment
    % segmentation used

    % For colorspace segmentation
    if ismember('Colorspace',fieldnames(app.Seg_Params.(current_structure)))
        
        colorspace_opts = {'RGB (Red, Green, Blue)','HSV (Hue, Saturation, Value)',...
        'LAB'};
        colorspace_idx = find(strcmp(app.Seg_Params.(current_structure).Colorspace,colorspace_opts));
        if colorspace_idx == 1
            color_line = 'channel_img = img;';
        end
        if colorspace_idx == 2
            color_line = 'channel_img = rgb2hsv(img);';
        end
        if colorspace_idx == 3
            color_line = 'channel_img = rgb2lab(img);';
        end
        
        % Assembling segmentation script text
        seg_text = {'%--- Function to carry out custom compartment segmentation',...
            strcat('function combined_comps = Comp_Seg(img,mask)'),...
            '%','%','%',...
            '% Color Transform',...
            color_line};
        
        % Taking care of segmentation hierarchy
        order = [app.Seg_Params.(current_structure).PAS.Order,...
            app.Seg_Params.(current_structure).Luminal.Order,...
            app.Seg_Params.(current_structure).Nuclei.Order];
        [sorted,~] = sort(order,'ascend');
        [~,order_idx] = ismember(sorted,order);
        order_text = {'%','% Segmentation Hierarchy',strcat('order_idx = [',...
            num2str(order_idx(1)),',',num2str(order_idx(2)),',',num2str(order_idx(3)),'];')};
        
        seg_text = [seg_text,order_text];
        
        init_text = {'%','% Initializing compartment segmentation',...
            'combined_comps = zeros(size(img));'};
        
        seg_text = [seg_text,init_text];
        
        comps = {'PAS','Luminal','Nuclei'};
        comp_params = [app.Seg_Params.(current_structure).PAS,...
            app.Seg_Params.(current_structure).Luminal,...
            app.Seg_Params.(current_structure).Nuclei];

        for comp = order_idx(1:end-1)
            params = comp_params(comp);
            comp_seg_text = {'%','%',strcat('% ',comps{comp},' Segmentation')};
            
            mask_text = {'%','%','% Remainder mask generation',...
                'in_use_mask = combined_comps(:,:,1)|combined_comps(:,:,2)|combined_comps(:,:,3);',...
                'remainder_mask = mask & ~(in_use_mask);','%',...
                strcat('comp_mask = channel_img(:,:,',num2str(params.Channel),');'),...
                'comp_mask(~remainder_mask) = 0;'};
            
            if params.Threshold>1
                thresh_val = params.Threshold/255;
            else
                thresh_val = params.Threshold;
            end
            
            thresh_text = {strcat('comp_mask = im2bw(comp_mask,',num2str(thresh_val),');'),...
                strcat('comp_mask = bwareaopen(comp_mask,',num2str(params.MinSize),');')};
            
            if strcmp(comps{comp},'Nuclei')
                extra_text = {'%','% Extra Processing for Nuclei',...
                    "comp_mask = imfill(comp_mask,'holes');",...
                    'comp_mask = split_nuclei_functional(comp_mask);'};
                thresh_text = [thresh_text,extra_text];
            
            end
            
            combined_text = {strcat('combined_comps(:,:,',num2str(comp),') = uint8(comp_mask);')};
            
            seg_text = [seg_text,comp_seg_text,mask_text,thresh_text,combined_text];
            
        end
        
        % Now adding in the last one
        last_text = {'%','%',strcat('% ',comps{order_idx(end)},' Segmentation')};
        last_text = [last_text,...
            {'%','%','% Remainder mask generation',...
            'in_use_mask = combined_comps(:,:,1)|combined_comps(:,:,2)|combined_comps(:,:,3);'...
            'remainder_mask = mask & ~(in_use_mask);'},'%',...
            {'%',strcat('combined_comps(:,:,',num2str(order_idx(end)),') = uint8(remainder_mask);')}];
            
        seg_text = [seg_text,last_text];
        seg_text = seg_text';
            

        
%         if exist(app.Seg_Script.(current_structure),'file')~=2
%             addpath(fileparts(app.Seg_Script.(current_structure)))
%         end
        app.Seg_Script.(current_structure) = seg_text;

        % Opening the 
        script_path = strcat(pwd,filesep,current_structure,'_Comp_Seg.m');
        fid = fopen(script_path,'w+');
        if fid<0
            error('Error accessing %s',app.Seg_Script.(current_structure))
        end
        fid = fopen(script_path,'a');
        for line = 1:length(seg_text) 
            current_line = seg_text{line};
            with_newline = strcat(current_line,'\n');
            fprintf(fid,with_newline);
        end
        fclose(fid);

    end
    
    if ismember('Stain',fieldnames(app.Seg_Params.(current_structure)))
        
        stain_line = {strcat("[stain1,stain2,stain3] = colour_deconvolution(img,'",...
            app.Seg_Params.(current_structure).Stain,"');"),...
            'channel_img = cat(3,imcomplement(stain1),imcomplement(stain2),imcomplement(stain3));'};
        
        % Assembling segmentation script text
        seg_text = horzcat({'%--- Function to carry out custom compartment segmentation',...
            strcat('function combined_comps = Comp_Seg(img,mask)'),...
            '%','%','%',...
            '% Stain Deconvolution'},...
            stain_line);
        
        % Taking care of segmentation hierarchy
        order = [app.Seg_Params.(current_structure).PAS.Order,...
            app.Seg_Params.(current_structure).Luminal.Order,...
            app.Seg_Params.(current_structure).Nuclei.Order];
        [sorted,~] = sort(order,'ascend');
        [~,order_idx] = ismember(sorted,order);
        order_text = {'%','% Segmentation Hierarchy',strcat('order_idx = [',...
            num2str(order_idx(1)),',',num2str(order_idx(2)),',',num2str(order_idx(3)),'];')};
        
        seg_text = [seg_text,order_text];
        
        init_text = {'%','% Initializing compartment segmentation',...
            'combined_comps = zeros(size(img));'};
        
        seg_text = [seg_text,init_text];
        
        comps = {'PAS','Luminal','Nuclei'};
        comp_params = [app.Seg_Params.(current_structure).PAS,...
                    app.Seg_Params.(current_structure).Luminal,...
                    app.Seg_Params.(current_structure).Nuclei];
        for comp = order_idx(1:end-1)
            params = comp_params(comp);
            comp_seg_text = {'%','%',strcat('% ',comps{comp},' Segmentation')};
            
            mask_text = {'%','%','% Remainder mask generation',...
                'in_use_mask = combined_comps(:,:,1)|combined_comps(:,:,2)|combined_comps(:,:,3);',...
                'remainder_mask = mask & ~(in_use_mask);','%',...
                strcat('comp_mask = channel_img(:,:,',num2str(params.Channel),');'),...
                'comp_mask(~remainder_mask) = 0;'};
            
            if params.Threshold>1
                thresh_val = params.Threshold/255;
            else
                thresh_val = params.Threshold;
            end
            
            thresh_text = {strcat('comp_mask = im2bw(comp_mask,',num2str(thresh_val),');'),...
                strcat('comp_mask = bwareaopen(comp_mask,',num2str(params.MinSize),');')};
            
            if strcmp(comps{comp},'Nuclei')
                extra_text = {'%','% Extra Processing for Nuclei',...
                    "comp_mask = imfill(comp_mask,'holes');",...
                    'comp_mask = split_nuclei_functional(comp_mask);'};
                thresh_text = [thresh_text,extra_text];
            
            end
            
            combined_text = {strcat('combined_comps(:,:,',num2str(comp),') = comp_mask;')};
            
            seg_text = [seg_text,comp_seg_text,mask_text,thresh_text,combined_text];
            
        end
        
        % Now adding in the last one
        last_text = {'%','%',strcat('% ',comps{order_idx(end)},' Segmentation')};
        last_text = [last_text,...
            {'%','%','% Remainder mask generation',...
            'in_use_mask = combined_comps(:,:,1)|combined_comps(:,:,2)|combined_comps(:,:,3);'...
            'remainder_mask = mask & ~(in_use_mask);'},'%',...
            {'%',strcat('combined_comps(:,:,',num2str(order_idx(end)),') = remainder_mask;')}];
            
        seg_text = [seg_text,last_text];
        seg_text = seg_text';
        
        % Opening the 
        script_path = strcat(pwd,filesep,current_structure,'_Comp_Seg.m');
        fid = fopen(script_path,'w+');
        if fid<0
            error('Error accessing %s',script_path)
        end
        fid = fopen(script_path,'a');
        for line = 1:length(seg_text) 
            current_line = seg_text{line};
            if contains(current_line,'%')
                fprintf(fid,'%s',current_line);
                fprintf(fid,'\n');
            else
                fprintf(fid,strcat(current_line,'\n'));
            end
        end
        fclose(fid);
        
%         if exist(app.Seg_Script.(current_structure),'file')~=2
%             addpath(fileparts(app.Seg_Script.(current_structure)))
%         end
%         
        % Add function handle to app struct
        app.Seg_Script.(current_structure) = seg_text;
    end
    
    % Using custom segmentation script
    if ismember('CustomPath',fieldnames(app.Seg_Params.(current_structure)))
        % Segmentation parameters include path to compartment segmentation
        % script
        addpath(fileparts(app.Seg_Params.(current_structure).CustomPath))

        % Writing file from which to call segmentation script
        file = strcat(pwd,filesep,'Run_',current_structure,'_Comp_Seg.m');
        fid = fopen(file,'w+');
        fprintf(fid,'function get_comp(img,mask)')
        fprintf(fid,strcat('comp_img =',current_structure,'_Comp_Seg(img,mask);'));
        fclose(fid)

    end
    
    % Using CNN
    if ismember('ModelFile',fieldnames(app.Seg_Params.(current_structure)))
       msgbox('Not yet implemented') 
    end
end
