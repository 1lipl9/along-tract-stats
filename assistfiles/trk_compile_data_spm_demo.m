function trk_compile_data_spm_demo
%TRK_COMPILE_DATA_SPM_DEMO - a simple example that does group-wise
%analysis.
%
%See also: trk_compile_data_spm, trk_compile_data
%
%Author: Shaofeng Duan (duansf@ihep.ac.cn)
%Institute of High Energy Physics 
%Nov 2015

oldPath = pwd;
exDir = uigetdir('');
cd(exDir)
dirList = dir(fullfile(exDir, '*'));
dirList(~[dirList.isdir]) = [];
dirList(1:2) = [];
subIDs = {dirList.name};
tract_info = dataset('file', fullfile(exDir, 'tract_info.txt'));
[track_means, starting_pts_out, nPts] = trk_compile_data_spm(exDir, subIDs, tract_info, [], [], 1, 1);
cd(oldPath)