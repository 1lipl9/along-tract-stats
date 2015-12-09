function trk_adjust_margin_demo
%TRK_ADJUST_MARGIN_DEMO - adjust the tracks' margin along the z-axis
%
%Syntax: TRK_ADJUST_MARGIN_DEMO
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
    [header, tracks] = trk_adjust_margin(header, tracks);
    trk_write(header, tracks, trkNames{aa});
    waitbar(aa/(numel(trkNames)), h);
end
close(h)