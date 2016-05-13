function [header, tracks] = trk_cat
%TRK_CAT - merge multi trk files into one
%
% Syntax: [header,tracks] = TRK_CAT;
%
% Inputs:
%    filePath - Full path to .trk file [char]
%
% Outputs:
%    header - Header information from .trk file [struc]
%    tracks - Track data structure array [1 x nTracks]
%
% Author: Shaofeng Duan
% IHEP
% May 2016

trkNames = spm_select(Inf, 'trk', 'choose the trks you want to catenate...');
trkNames = cellstr(trkNames);

[headerC, tracksC] = cellfun(@trk_read, trkNames, 'UniformOutput',false);
tracks = [tracksC{:}];
header = headerC{1};
header.n_count = numel(tracks);
