trkFileNames = spm_select(Inf, 'trk$', 'select the trk files...');
trkFileNames = cellstr(trkFileNames);

dwiFileNames = spm_select(Inf, 'nii$', 'select the resize file...');
dwiFileNames = cellstr(dwiFileNames);

for iTrkFile = 1:numel(trkFileNames)
    trkFileName = trkFileNames{iTrkFile};
    nii = load_untouch_header_only(dwiFileNames{iTrkFile});
    [path, tit, ext] = fileparts(trkFileName);
    [header, tracks] = trk_read(trkFileName);
    header.dim = nii.dime.dim(2:4);
    header.voxel_size = nii.dime.pixdim(2:4);
    header.voxel_to_ras = nii_sform_to_quaternion(nii);
    outputTrkFileName = fullfile(path, ['resize_', tit, ext]);
    trk_write(header, tracks, outputTrkFileName);
end