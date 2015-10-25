function trk_reg_cfg = trk_reg_sn_cfg_func

input1         = cfg_files;
input1.name    = 'track to reg';
input1.tag     = 'tag_trk';
input1.filter  = {'.trk'};
input1.help    = {'choose the .trk files to registrate.'};

input2         = cfg_files;
input2.name    = 'sn_mat file';
input2.tag     = 'tag_sn';
input2.num     = [1, 1];
input2.filter  = {'mat'};
input2.help    = {'choose the sn_mat file used to registrate the trk.'};

input3         = cfg_entry;
input3.name    = 'prefix';
input3.tag     = 'tag_prefix';
input3.strtype = 's';
input3.num     = [1, Inf];
input3.help    = {'the prefix of the output file'};

trk_reg_cfg       = cfg_exbranch;
trk_reg_cfg.name  = 'sn edition';
trk_reg_cfg.tag   = 'trk_set_sn_tag';
trk_reg_cfg.val   = {input1, input2, input3};
trk_reg_cfg.prog  = @trk_reg_sn_cfg_run_func;
trk_reg_cfg.vout  = @trk_reg_sn_cfg_vout_func;
trk_reg_cfg.help  = {'this is the trk reg setting files used to reg the trks.'};

function vout = trk_reg_sn_cfg_vout_func(job)

vout = cfg_dep;
vout.sname = 'the registrated trk files (after trk_reg_sn)';
vout.src_output = substruct('()', {':'});
