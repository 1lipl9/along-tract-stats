function [] = trk_refine(header, tracks, volume)
%TRK_REFINE - Refine the tracks connected two brain regions to construct 
%the network
%
% Syntax: trk_refine(header, tracks, volume)
%
% Inputs:
%    header   - Header information for .trk file [struc]
%    tracks   - Track data struc array [1 x nTracks]
%      nPoints  - # of points in each track
%      matrix   - XYZ coordinates (in mm) and associated scalars [nPoints x 3+nScalars]
%      props    - Properties of the whole tract
%    volume  -  The scalar image of AAL labels.
%
% Output:
%    The new header and tracks for .trk files
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%


% Author: Shaofeng Duan (duansf@ihep.ac.cn)
% Institute of High Energy Physics
% Oct 2015


%---------------------------------------------------------
%使用aal模板标记纤维束经过的脑区
%---------------------------------------------------------
[header, tracks] = trk_add_sc(header, tracks, volume, 'label');

labels_head = [];
labels_end  = [];
ITRK = [];

%----------------------------------------------------------
%剃除头尾在同一个脑区或者头尾不在灰质脑区中的纤维束
%----------------------------------------------------------
for iTrk = 1:numel(tracks)
    labels = tracks(iTrk).matrix(:, 4);
    if labels(1) == labels(end) || any([~labels(1), ~labels(end)])
        ITRK = [ITRK, iTrk];
    end
end
tracks(ITRK) = [];
%----------------------------------------------------------

%----------------------------------------------------------
%Reorder the tracts.
%----------------------------------------------------------
for iTrk = 1:numel(tracks)
    labels      = tracks(iTrk).matrix(:, 4);
    a_head = labels(1);
    a_end  = labels(end);
    if a_end < a_head
        temp    = a_end;
        a_end   = a_head;
        a_head  = temp;
    end
    labels_head = [labels_head, a_head];
    labels_end  = [labels_end, a_end];        
end

T_labels = table(labels_head', labels_end', 'VariableNames', ...
    {'lables_head', 'lables_end'});

[tblB, index] = sortrows(T_labels);

tracks_new = tracks(index);

%Update the header
header_new = header;
for iTrk = 1:numel(tracks_new)
    code_property = prop_encode(tblB{iTrk, 1}, tblB{iTrk, 2});
    if isfield(tracks, 'props')
        tracks_new(iTrk).props = [tracks_new(iTrk).props code_property];
    else
        tracks_new(iTrk).props = code_property;
    end
end

new_prop_names = 'label';
header_new.n_count = numel(tracks_new);
n_properties_old = header_new.n_properties;
header_new.n_properties = n_properties_old + 1;
header_new.property_name(n_properties_old + 1, 1:size(new_prop_names, 2)) = new_prop_names;

trk_write(header_new, tracks_new, 'trk_tmp.trk'); %To generate the temp files for the next step, but will delete after be read.

%----------------------------------------------------------
%label the regions which the track linked
%----------------------------------------------------------
function code_prop = prop_encode(label_head, label_end)

code_prop = label_head*100 + label_end;

function [label_head, label_end] = prop_decode(code_prop)

label_head = floor(code_prop/100);
label_end  = rem(code_prop, 100);




