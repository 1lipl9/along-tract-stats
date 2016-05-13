% 首先要进行的操作是将纤维束调整到对应的voxelsize和dim，这样都能保证结果的准确性。

close all;
clearvars;
trk1 = spm_select(Inf, 'trk', 'choose the registered space trk...');
trk1 = cellstr(trk1);
trk2 = spm_select(Inf, 'trk', 'choose the subject space trk...');
trk2 = cellstr(trk2);

s = struct;

for iTrk = 1:numel(trk1)
    trkname1 = trk1{iTrk};
    [pat, tit, ext] = fileparts(trkname1);
    namecell1 = textscan(tit, '%s', 'Delimiter',   {'_', '.'});
    temp1 = [namecell1{1}{4}, '_', namecell1{1}{5}];
    s(iTrk).trkName1 =temp1;
    
    trkname2 = trk2{iTrk};
    [pat, tit, ext] = fileparts(trkname2);
    namecell2 = textscan(tit, '%s', 'Delimiter',   {'_', '.'});
    temp2 = [namecell2{1}{3}, '_', namecell2{1}{4}];
    s(iTrk).trkName2 = temp2;
    s(iTrk).DICE = trk_compare_dice(trk1{iTrk}, trk2{iTrk});
end

tbl = struct2table(s);
% tbl.Properties.VariableNames = {'trkName1', 'trkName2', 'DICE'};