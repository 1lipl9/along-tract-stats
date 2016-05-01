function trk_adjust_demo

trkNames = spm_select(Inf, 'trk', 'choose the trk want to adjust...');
trkNames = cellstr(trkNames);
[header, tracks] = trk_read(trkNames{1});
tracks_interp = trk_interp(tracks, 100);
tracks_interp_str = trk_restruc(tracks_interp);

[pat, tit, ext] = fileparts(trkNames{1});
filename1 = fullfile(pat, [tit, '_interp', ext]);
filename2 = fullfile(pat, [tit, '_interp_flip', ext]);
[header_flip, tracks_flip] = trk_adjust(header, tracks_interp_str);

trk_write(header, tracks_interp_str, filename1);
trk_write(header_flip, tracks_flip, filename2);
