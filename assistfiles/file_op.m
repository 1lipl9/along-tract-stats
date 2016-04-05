
%%
lista = dir('*fa*');

for aa = 1:numel(lista)
    C = textscan(lista(aa).name, '%s', 'delimiter', '_');
    dirname = [C{1}{1}, C{1}{3}];
    mkdir(dirname);
    movefile(lista(aa).name, fullfile('.', dirname, 'FA.nii'));
end
%%
dirname_src = spm_select(1, 'dir');
trk1 = fullfile(dirname_src, 'CST_L.trk');
trk2 = fullfile(dirname_src, 'CST_R.trk');

listb = dir('*');

for bb = 3:numel(listb)
    bb
    copyfile(trk1, [listb(bb).name, '\']);
    copyfile(trk2, [listb(bb).name, '\']);
end
%%

listb = dir('*');
listb(~[listb.isdir]) = [];
for bb = 3:numel(listb)
    cd(listb(bb).name)
    movefile('FA.nii', 'dti_fa.nii');
    cd ..
end