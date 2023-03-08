% Function to read JSON/GeoJSON annotation files
function [bbox_coords,mask_coords] = Read_JSON_Annotations(filepath,image_id)

% Read json/geojson filepath
read_json = jsondecode(fileread(filepath));

% Checking whether the file is JSON or GeoJSON
if contains(filepath,'geojson')
    
    % Picking out classifications
    % In progress

    % Picking a specific structure according to image_id
    coordinates = squeeze(read_json.features(image_id).geometry.coordinates);
else
    
    % Picking a specific structure according to image_id
    coordinates = squeeze(read_json(image_id).coordinates);
    
end

% Getting bounding box coordinates
bbox_coords = [min(coordinates(:,1))-100,max(coordinates(:,1))+100,min(coordinates(:,2))-100,max(coordinates(:,2))+100];
% Creating mask
mask_coords = zeros(size(coordinates));
mask_coords(:,1) = coordinates(:,1)-bbox_coords(1);
mask_coords(:,2) = coordinates(:,2)-bbox_coords(3);



