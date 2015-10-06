function cfg = trk_reg_cfg_master


temp = cfg_repeat;
temp.name = 'track registration : write';
temp.tag = 'tag_trk_reg';
temp.values = {trk_reg_cfg_func};
temp.forcestruct = true;
temp.help = {'This app is used to implement the track registration.'};

cfg = cfg_repeat;
cfg.name = 'track operation';
cfg.tag = 'tag_trk_master';
cfg.values = {temp};
cfg.forcestruct = true;
cfg.help = {'This app is used for track operation.'};
