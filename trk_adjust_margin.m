function trk_adjust_margin
%TRK_ADJUST_MARGIN - adjust the tracks' margin along the z-axis
%
%Syntax: TRK_ADJUST_MARGIN
%
%
%See also: TRK_REG_DTITK
% Author: Shaofeng Duan (duansf@ihep.ac.cn)
% Institute of High Energy Physics 
% Dec 2015

trkNames = spm_select(Inf, 'trk$', 'choose the trk want to adjust the margin');
trkNames = cellstr(trkNames);

h = waitbar(0, 'processing the tracks...');
for aa = 1:numel(trkNames)
    [header, tracks] = trk_read(trkNames{aa});
    VoxSize = header.voxel_size;
    ImgDim = header.dim;
    
    for bb = 1:numel(tracks)
        coords = tracks(bb).matrix(:, 3);
        coords(coords <= 0) = 0.1;
        coords(coords > VoxSize*ImgDim) = VoxSize*ImgDim;
        tracks(bb).matrix(:, 3) = coords;
    end
    trk_write(header, tracks, trkNames{aa});
    waitbar(aa/(numel(trkNames)), h);
end
close(h);