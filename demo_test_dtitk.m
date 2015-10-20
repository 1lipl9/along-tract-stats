[header, tracks] = trk_read('fengzhiyuan_refine.trk');

Affine_dtitk = [ 1.0089   -0.0336    0.0894   -0.6723
          -0.0345    0.9923    0.0626   -4.0380
          -0.1214    0.0331    0.9544    6.5742
                0         0         0    1.0000];
AA = [1.7188         0         0         0
         0    1.7188         0         0
         0         0    4.0000         0
         0         0         0    1.0000];
Affine_dtitk = inv(AA)*Affine_dtitk*AA;
diffeo_vol = spm_vol('bailixi_tensor_aff_diffeo.df.nii');
VF  = spm_vol('bailixi_eddy_mean_RAS.nii');
VF = VF(1);
VG = spm_vol('fengzhiyuan_eddy_mean_RAS.nii');
VG = VG(1);

[header,tracks] = trk_reg_dtitk(header,tracks, Affine_dtitk, diffeo_vol, VF, VG);
% [header, tracks] = trk_reg_sn(header, tracks, 'bailixi_eddy_mean_RAS_FA_sn.mat');
trk_write(header, tracks, 'test.trk');