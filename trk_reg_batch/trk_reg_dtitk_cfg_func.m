function trk_reg_cfg = trk_reg_dtitk_cfg_func

input1         = cfg_files;
input1.name    = 'track to reg';
input1.tag     = 'tag_trk';
input1.filter  = {'.trk'};
input1.help    = {'choose the .trk files to registrate.'};

input2         = cfg_files;
input2.name    = '_aff file';
input2.tag     = 'tag_aff';
input2.num     = [1, 1];
input2.filter  = {'.aff'};
input2.help    = {'choose the _aff file used to registrate the trk.'};

input3         = cfg_entry;
input3.name    = 'prefix';
input3.tag     = 'tag_prefix';
input3.strtype = 's';
input3.num     = [1, Inf];
input3.help    = {'the prefix of the output file'};

input4         = cfg_files;
input4.name    = 'diffeo file';
input4.tag     = 'tag_diffeo';
input4.num     = [1, 1];
input4.filter  = {'image'};
input4.help    = {'choose the nii non-linear image file'};

input5         = cfg_files;
input5.name    = 'VF file';
input5.tag     = 'tag_VF';
input5.num     = [1, 1];
input5.filter  = {'image'};
input5.help    = {'source image in dtitk'};

input6         = cfg_files;
input6.name    = 'VG file';
input6.tag     = 'tag_VG';
input6.num     = [1, 1];
input6.filter  = {'image'};
input6.help    = {'template image in dtitk'};

trk_reg_cfg       = cfg_exbranch;
trk_reg_cfg.name  = 'dtitk edition';
trk_reg_cfg.tag   = 'trk_set_dtitk_tag';
trk_reg_cfg.val   = {input1, input2, input3, input4, input5, input6};
trk_reg_cfg.prog  = @trk_reg_dtitk_cfg_run_func;
trk_reg_cfg.vout  = @trk_reg_dtitk_cfg_vout_func;
trk_reg_cfg.help  = {'this is the trk reg setting files used to reg the trks.'};

function vout = trk_reg_dtitk_cfg_vout_func(job)

vout = cfg_dep;
vout.sname = 'the registrated trk files (after trk_reg_sn)';
vout.src_output = substruct('()', {':'});