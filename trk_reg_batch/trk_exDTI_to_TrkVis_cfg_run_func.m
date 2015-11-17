function trk_exDTI_to_TrkVis_cfg_run_func(job)

niiFile = job.ex2trk_nii;
exTrkFile = job.ex2trk_extrk;
prefixName = job.ex2trk_prefix;

nii = load_untouch_header_only(niiFile{1}(1:end -2));

for aa = 1:numel(exTrkFile)
    [path, tit, ~] = fileparts(exTrkFile{aa});
    outputName = fullfile(path, [prefixName, tit,'.trk']);
    trk_exploreDTI_to_TrackVis(nii, exTrkFile{aa}, outputName);
end
