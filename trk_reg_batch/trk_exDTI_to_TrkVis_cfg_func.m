function cfg = trk_exDTI_to_TrkVis_cfg_func

input1 = cfg_files;
input1.name = 'nii file';
input1.tag = 'ex2trk_nii';
input1.filter = {'image'};
input1.num = [1, 1];
input1.help = {'input a path of a nii files of the tracks'};

input2 = cfg_files;
input2.name = 'exploreDTI tracks';
input2.tag = 'ex2trk_extrk';
input2.filter = {'mat'};
input2.help = {'choose the exploreDTI output trk mat files'};

input3 = cfg_entry;
input3.name = 'the output trk name';
input3.tag = 'ex2trk_prefix';
input3.strtype = 's';
input3.help = {'input the prefix you want to attach to the output file name'};

cfg = cfg_exbranch;
cfg.name = 'trk from exDTI to TrkVis';
cfg.tag = 'ex2trk';
cfg.val = {input1, input2, input3};
cfg.prog = @trk_exDTI_to_TrkVis_cfg_run_func;
cfg.help = {'this is used to transform the tracks generated from ExploreDTI', ...
    'to the TractVis compatitive format.'};


