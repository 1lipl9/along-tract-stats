function [] = trk_exploreDTI_to_TrackVis(nii, explore_trk, trkvis_trk_write)
%TRK_EXPLOREDTI_TO_TRACKVIS convert trk fro exploreDTI to TrackVis 
%  For exploreDTI is compatible with RAS(i, j, k) DTI volume, so you should
%  reorient you DTI volume to RAS before you process it in exploreDTI.
%
%  Syntax: TRK_EXPLOREDTI_TO_TRACKVIS(nii, explore_trk, trkvis_trk_write)
%
%  INPUTS:
%    nii              - generate from load_untouch_header_only.m
%    explore_trk      - the tract files with explore format you want to convert
%    trkvis_trk_write - the path you want to save the converted file.
%  see also: LOAD_UNTOUCH_HEADER_ONLY, TRK_READ, TRK_WRITE.
%
% Author: Shaofeng Duan (duansf@ihep.ac.cn)
% Institute of High Energy Physics 
% Oct 2015
load(explore_trk, 'Tracts');
header = trk_default_header;
header.dim = nii.dime.dim(2:4);
header.voxel_size = nii.dime.pixdim(2:4);
header.vox_to_ras = [nii.hist.srow_x; ...
                     nii.hist.srow_y; ...
                     nii.hist.srow_z; ...
                     0 0 0 1];
header.voxel_order(1:3) = 'RAS';
header.pad2(1:3) = 'RAS';
header.image_orientation_patient = getIOP(nii);
header.n_count = numel(Tracts);

tracks = struct('nPoints', {}, 'matrix', {});

for iTrk = 1:numel(Tracts)
    tracks(iTrk).matrix = ex_cor2trk_cor(Tracts{iTrk}, header);
    tracks(iTrk).nPoints = size(Tracts{iTrk}, 1);
end

trk_write(header, tracks, trkvis_trk_write);


%==========================================================================
%function trk_cor = ex_cor2trk_cor(ex_cor, header)  
%==========================================================================
function trk_cor = ex_cor2trk_cor(ex_cor, header)
trk_cor = zeros(size(ex_cor));
trk_cor(:, 1:3) = ex_cor(:, [2, 1, 3]);
trk_cor(:, 1) = header.dim(1)*header.voxel_size(1) - trk_cor(:, 1);
trk_cor(:, 2) = header.dim(2)*header.voxel_size(2) - trk_cor(:, 2);

%==========================================================================
%function IOP = getIOP(fname)  
%==========================================================================
function IOP = getIOP(nii)

b = nii.hist.quatern_b;
c = nii.hist.quatern_c;
d = nii.hist.quatern_d;

a = sqrt(1 - sum([b, c, d].^2));

R11 = a*a + b*b - c*c -d*d;
R21 = 2*b*c + 2*a*d;
R31 = 2*b*d - 2*a*c;
R12 = 2*b*c - 2*a*d;
R22 = a*a + c*c - b*b - d*d;
R32 = 2*c*d + 2*a*b;
IOP = [-R11, -R21, R31, -R12, -R22, R32];
% 
% %==========================================================================
% %function vox_order = get_vox_order(nii)  
% %==========================================================================
% function vox_order = get_vox_order(nii) 
% 
% if nii.hist.qoffset_x > 0
%     LR = 'L';
% else
%     LR = 'R';
% end
% 
% if nii.hist.qoffset_y > 0
%     AP = 'P';
% else
%     AP = 'A';
% end
% 
% if nii.hist.qoffset_z > 0
%     SI = 'I';
% else
%     SI = 'S';
% end
% 
% vox_order = sprintf('%c%c%c ', LR, AP, SI);