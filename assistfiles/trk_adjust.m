function [header, tracks] = trk_adjust(varargin)
%TRK_ADJUST - adjust the tracks' coordinats along the x-axis
%
%Syntax: [header,tracks] = TRK_ADJUST(varargin)
%
%Inputs
%  header, tracks - the result of the trk_read.m
%  filename   - optional, the name of dtitk format file generated from
%  command fsl_to_dtitk
%
%
%See also: TRK_READ
% Author: Shaofeng Duan (duansf@ihep.ac.cn)
% Institute of High Energy Physics 
% Dec 2015
header = varargin{1};
tracks = varargin{2};
if (nargin > 2)
    filename = varargin{3};
    nii = load_untouch_header_only(filename);
    header.dim = nii.dime.dim(2:4);
    header.vox_to_ras = [nii.hist.srow_x; ...
                        nii.hist.srow_y; ...
                        nii.hist.srow_z; ...
                        [0 0 0 1]];

    header.image_orientation_patient = getIOP(nii);
    header.voxel_size = nii.dime.pixdim(2:4);
end
%the follow parts is to adjust the x-axis coordinates.
for iTrk = 1:numel(tracks)  
    coords = tracks(iTrk).matrix(:,1:3);
%     coords(:, 1) = coords(:, 1) - 2*header.voxel_size(1); % translate along x-axis
    coords(:, 1) = header.dim(1)*header.voxel_size(1) - coords(:,1); % flip left-right.
    tracks(iTrk).matrix(:,1:3) = coords;
end

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
