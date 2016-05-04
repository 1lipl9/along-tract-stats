function dice = trk_compare_dice(trkName1, trkName2)
%TRK_COMPARE_DICE - used to caculate the dice value between two tracts.
%
%  Syntax: dice = TRK_COMPARE_DICE(trkName1, trkName2)
% 
%  Inputs:
%    trkName1 - the first tract to caculate
%    trkName2 - the second tract to caculate
%
%  Outputs:
%    dice - the dice value, caculated by the formula :
%        Dice = 2*numel(intersect(V1, V2)/(numel(V1) + numel(V2))
%
%See also: TRK_READ, SPM_VOL
% Author: Shaofeng Duan (duansf@ihep.ac.cn)
% Institute of High Energy Physics 
% Dec 2015


[header1, tracks1] = trk_read(trkName1);
[header2, tracks2] = trk_read(trkName2);

if ~(all(header1.dim == header2.dim) && all(header2.voxel_size == header2.voxel_size) ...
        && all(all(header1.voxel_order == header2.voxel_order)))
    error('%s is not compatible with %s', trkName1, trkName2);
end

ind1 = [];
ind2 = [];

for iTrk = 1:numel(tracks1)
    vox = ceil(tracks1(iTrk).matrix(:,1:3) ./ repmat(header1.voxel_size, tracks1(iTrk).nPoints,1));
    ind1                = union(sub2ind(header1.dim, vox(:,1), vox(:,2), vox(:,3)), ind1);
end

for iTrk = 1:numel(tracks2)
    vox = floor(tracks2(iTrk).matrix(:,1:3) ./ repmat(header2.voxel_size, tracks2(iTrk).nPoints,1));
    ind2                = union(sub2ind(header2.dim, vox(:,1), vox(:,2), vox(:,3)), ind2);
end

dice = 2*numel(intersect(ind1, ind2))/(numel(ind1) + numel(ind2));
