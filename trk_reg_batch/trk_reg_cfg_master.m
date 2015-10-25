function cfg = trk_reg_cfg_master

TrkReg = cfg_repeat;
TrkReg.name = 'track registration : write';
TrkReg.tag = 'tag_trk_reg';
TrkReg.values = {trk_reg_sn_cfg_func, trk_reg_dtitk_cfg_func};
TrkReg.forcestruct = true;
TrkReg.help = {'This app is used to implement the track registration.'};

cfg = cfg_repeat;
cfg.name = 'track operation';
cfg.tag = 'tag_trk_master';
cfg.values = {TrkReg};
cfg.forcestruct = true;
cfg.help = {'This app is used for track operation.'};
