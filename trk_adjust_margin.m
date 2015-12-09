function [header, tracks] = trk_adjust_margin(header, tracks)
%TRK_ADJUST_MARGIN - adjust the tracks' margin along the z-axis
%
%Syntax: [header, tracks] = TRK_ADJUST_MARGIN(header, tracks)
%
% Inputs:
%    header - Header information from .trk file [struc]
%    tracks - Track data struc array [1 x nTracks]
%
%See also: TRK_READ
% Author: Shaofeng Duan (duansf@ihep.ac.cn)
% Institute of High Energy Physics 
% Dec 2015

VoxSize = header.voxel_size(3);
ImgDim = header.dim(3);

for bb = 1:numel(tracks)
    coords = tracks(bb).matrix(:, 3);
    coords(coords <= 0) = 0.1;
    coords(coords > VoxSize*ImgDim) = VoxSize*ImgDim;
    tracks(bb).matrix(:, 3) = coords;
end