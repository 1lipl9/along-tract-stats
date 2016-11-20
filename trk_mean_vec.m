function expscalars = trk_mean_vec(header,tracks)
%TRK_MEAN_VEC - Calculate the mean scalar along a track
%Returns the mean and SD of a scalar volume (e.g. FA map) *along* a track.
%Rather than collapsing across the whole track, as in TrackVis or TRK_STATS,
%this function returns vectors corresponding to the different vertices along the
%whole track. This will allow you to localize differences within a track.
%
% Syntax: [scalar_mean,scalar_sd] = trk_mean_sc(header,tracks)
%
% Inputs:
%    header - Header information from .trk file [struc]
%    tracks - Track data struc array [1 x nTracks]
%
% Outputs:
%    expscalars - six elements of log euclidean mean of pseudo DT
%
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: TRK_READ, READ_AVW, TRK_INTERP, TRK_RESTRUC, TRK_ADD_SC
%Shaofeng Duan
%IHEP
%2016-11-20

scalars = zeros(tracks(1).nPoints, header.n_count, header.n_scalars);

for i=1:header.n_scalars
    mat_long        = cat(1, tracks.matrix);
    scalars(:,:,i)  = reshape(mat_long(:,4), tracks(1).nPoints, header.n_count, header.n_scalars);
end

%% used log-euclidean frame
logCell = cellfun(@(x) le_Log(x), num2cell(scalars, 3), 'UniformOutput', false);
logCell = cellfun(@(x) reshape(x, 1, 1, []), logCell, 'UniformOutput', false);
temp = cat(1, logCell{:});
logscalars = reshape(temp, tracks(1).nPoints, header.n_count, []);
logscalarsMean = mean(logscalars, 2);

expCell = cellfun(@(x) le_Exp(x), num2cell(logscalarsMean, 3), 'UniformOutput', false);
expCell = cellfun(@(x) reshape(x, 1, 1, []), expCell, 'UniformOutput', false);
temp = cat(1, expCell{:});
expscalars = reshape(temp, tracks(1).nPoints, []);

function logx = le_Log(x)
dxx = x(1);
dxy = x(2);
dxz = x(3);
dyy = x(4);
dyz = x(5);
dzz = x(6);

pD = [dxx, dxy, dxz; dxy, dyy, dyz; dxz, dyz, dzz];
log_pD = logm(pD);
logx = log_pD([1, 4, 7, 5, 8, 9])';

function expx = le_Exp(x)
dxx = x(1);
dxy = x(2);
dxz = x(3);
dyy = x(4);
dyz = x(5);
dzz = x(6);

log_pD = [dxx, dxy, dxz; dxy, dyy, dyz; dxz, dyz, dzz];
exp_pD = expm(log_pD);
expx = exp_pD([1, 4, 7, 5, 8, 9])';
