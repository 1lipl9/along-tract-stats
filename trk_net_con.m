function [] = trk_net_con(trkFileName, volume_sc, label_sc)

[header, tracks] = trk_read(trkFileName);




%----------------------------------------------------------
%label the regions which the track linked
%----------------------------------------------------------
function code_prop = prop_encode(label_head, label_end)

code_prop = label_head*100 + label_end;

function [label_head, label_end] = prop_decode(code_prop)

label_head = floor(code_prop/100);
label_end  = rem(code_prop, 100);

