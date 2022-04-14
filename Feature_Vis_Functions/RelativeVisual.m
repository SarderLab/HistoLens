function relative_feature_vis = RelativeVisual(composite)

pas_area = composite(:,:,1);
lum_area = composite(:,:,2);
nuc_area = composite(:,:,3);


pas_bounds = imfill(pas_area,'holes');
lum_bounds = imfill(lum_area,'holes');

nuc_ch = bwconvhull(nuc_area);

% LUM in PAS
lum_in_pas = pas_bounds & lum_area;
% NUC in PAS
nuc_in_pas = pas_bounds & nuc_area;
% PAS in LUM
pas_in_lum = lum_bounds & pas_area;
% NUC in LUM
nuc_in_lum = lum_bounds & nuc_area;
% PAS out NUC
pas_out_nuc = ~nuc_ch & pas_area;
% LUM out NUC
lum_out_nuc = ~nuc_ch & lum_area;

relative_feature_vis = {lum_in_pas, nuc_in_pas, pas_in_lum, nuc_in_lum, pas_out_nuc, lum_out_nuc};



























