% ����Ҫ���еĲ����ǽ���ά����������Ӧ��voxelsize��dim���������ܱ�֤�����׼ȷ�ԡ�

close all;
clearvars;
trk1 = spm_select(Inf, 'trk');
trk1 = cellstr(trk1);
trk2 = spm_select(Inf, 'trk');
trk2 = cellstr(trk2);
temp = zeros(numel(trk1), 1);
tbl = array2table(temp);
clear temp;
tbl.Properties.VariableNames = {'DICE'};
for iTrk = 1:numel(trk1)
tbl{iTrk, 'DICE'} = trk_compare_dice(trk1{iTrk}, trk2{iTrk});
end