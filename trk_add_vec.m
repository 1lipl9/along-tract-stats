function [header,tracks] = trk_add_vec(header,tracks,volume)
%TRK_ADD_SC - Attaches a vector value to each vertex in a .trk track group
%For example, this function can look in an FA volume, and attach the
%corresponding voxel FA value to each streamline vertex.
%
% Syntax: [header,tracks] = trk_add_sc(header,tracks,volume,name)
%
% Inputs:
%    header - Header information from .trk file [struc]
%    tracks - Track data struc array [1 x nTracks]
%    volume - 4D MRI volume
%    name   - Description of the scalar to add to the header (e.g. 'FA')
%
% Outputs:
%    header - Updated header
%    tracks - Updated tracks structure
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: TRK_READ, READ_AVW
%
% See also: 

% Author: Shaofeng Duan
% IHEP
%2016-11-20

% Loop over # of tracks (slow...any faster way?)
Nscalar = size(volume, 4);

for iTrk=1:length(tracks)
    % Translate continuous vertex coordinates into discrete voxel coordinates
    vox = ceil(tracks(iTrk).matrix(:,1:3) ./ repmat(header.voxel_size, tracks(iTrk).nPoints,1));
    disp(vox(7, :));
    
    % Index into volume to extract scalar values
    inds                = sub2ind(header.dim, vox(:,1), vox(:,2), vox(:,3));
    scalarsCell         = arrayfun(@(x) ElicitValue(volume, x, inds), 1:Nscalar, 'UniformOutput', false);
    temp                = cellfun(@(x) reshape(x, 1, []), scalarsCell, 'UniformOutput', false);
    scalars             = permute(reshape(cat(1, temp{:}), Nscalar, []), [2, 1]);
    tracks(iTrk).matrix = [tracks(iTrk).matrix, scalars];
end

% Update header
n_scalars_old    = header.n_scalars;

for aa = 1:Nscalar
    header.n_scalars = n_scalars_old + 1;
    n_scalars_old = header.n_scalars;
    name = sprintf('dim%02d', num2str(aa));
    header.scalar_name(n_scalars_old + 1,1:size(name,2)) = name;
end


function scalars = ElicitValue(volume, sliceN, inds)
volume_slice = volume(:, :, :, sliceN);
scalars = volume_slice(inds);