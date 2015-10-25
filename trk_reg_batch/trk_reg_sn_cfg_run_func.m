function out = trk_reg_sn_cfg_run_func(job)

trkFiles  = job.tag_trk;
snFiles   = job.tag_sn;
preName   = job.tag_prefix;
trkFilesToSave = {numel(trkFiles)};

for aa = 1:numel(trkFiles)
    trkFile = trkFiles{aa};
    [path, name, ext] = spm_fileparts(trkFile);
    trkFileToSave = fullfile(path, [preName, name, '.', ext]);
    trkFilesToSave{aa} = trkFileToSave;
    
    [header, tracks] = trk_read(trkFile);
    [header1, tracks1] = trk_reg_sn(header, tracks, snFiles{1});
    trk_write(header1, tracks1, trkFileToSave);
end

out = trkFilesToSave;