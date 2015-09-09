function [header,tracks] = trk_reg_sn(header,tracks,sn_name)
%TRK_REG_SN - used to registrit the tracks
%Inputs
%   sn_name - the file name of the deformation image.

% Author: Shaofeng Duan (duansf@ihep.ac.cn)
% Institute of High Energy Physics 
% Sep 2015
sn = load(sn_name);
intrp = [3, 3, 3, 0, 0, 0];
dim = sn.VG(1).dim;
x   = 1:dim(1);
y   = 1:dim(2);
z   = 1:dim(3);
st = size(sn.Tr);

basX = spm_dctmtx(sn.VG(1).dim(1),st(1),x-1);
basY = spm_dctmtx(sn.VG(1).dim(2),st(2),y-1);
basZ = spm_dctmtx(sn.VG(1).dim(3),st(3),z-1);

for j=1:length(z)
    
    tx = reshape( reshape(sn.Tr(:,:,:,1),st(1)*st(2),st(3)) *basZ(j,:)', st(1), st(2) );
    ty = reshape( reshape(sn.Tr(:,:,:,2),st(1)*st(2),st(3)) *basZ(j,:)', st(1), st(2) );
    tz = reshape( reshape(sn.Tr(:,:,:,3),st(1)*st(2),st(3)) *basZ(j,:)', st(1), st(2) );

%     X1 = X    + basX*tx*basY';
%     Y1 = Y    + basX*ty*basY';
%     Z1 = z(j) + basX*tz*basY';
    
    Cos(:,:,j,1) = single(basX*tx*basY'); %产生非线性的变形场
    Cos(:,:,j,2) = single(basX*ty*basY');
    Cos(:,:,j,3) = single(basX*tz*basY');

end
  
C1   = spm_diffeo('bsplinc',single(Cos(:, :, :, 1)),intrp);
C2   = spm_diffeo('bsplinc',single(Cos(:, :, :, 2)),intrp);
C3   = spm_diffeo('bsplinc',single(Cos(:, :, :, 3)),intrp);
% dat = spm_diffeo('bsplins',C,Y,intrp);
Mult = sn.Affine;%这是VG体素到VF的体素坐标对应关系。

for iTrk=1:length(tracks)
    % Translate continuous vertex coordinates into discrete voxel coordinates
    vox = tracks(iTrk).matrix(:,1:3) ./ repmat(header.voxel_size, tracks(iTrk).nPoints,1);
    
    % Index into volume to extract scalar values
    nPoints = size(tracks(iTrk).matrix,1);
    
    nSize = ceil(nthroot(nPoints,3));
    [X_trk, Y_trk, Z_trk] = ndgrid(1:nSize);
    X_trk(1:nPoints) = vox(:,1);
    Y_trk(1:nPoints) = vox(:,2);
    Z_trk(1:nPoints) = vox(:,3);
    
    dat1 = spm_diffeo('bsplins',C1,single(cat(4, X_trk, Y_trk, Z_trk)),intrp);  %获取对应位置的非线性参数值
    dat2 = spm_diffeo('bsplins',C2,single(cat(4, X_trk, Y_trk, Z_trk)),intrp);
    dat3 = spm_diffeo('bsplins',C3,single(cat(4, X_trk, Y_trk, Z_trk)),intrp);
    
    %利用非线性变形场刷新vox
    vox = vox + [dat1(1:nPoints)', dat2(1:nPoints)', dat3(1:nPoints)'];
    tracks(iTrk).matrix(:, 1:3) = affine(vox, Mult).* repmat(sqrt(sum(sn.VF.mat(1:3,1:3)).^2), nPoints, 1);
end

header.dim        = sn.VF.dim(1:3);
header.voxel_size = sqrt(sum(sn.VF.mat(1:3,1:3)).^2);

%==========================================================================
% function Def = affine(y,M)
%==========================================================================
function y_wld = affine(y_vox,M)
y_wld       = zeros(size(y_vox),'single');
y_wld(:, 1) = y_vox(:, 1)*M(1, 1) + y_vox(:, 2)*M(1, 2) + y_vox(:, 3)*M(1, 3) + M(1, 4);
y_wld(:, 2) = y_vox(:, 1)*M(2, 1) + y_vox(:, 2)*M(2, 2) + y_vox(:, 3)*M(2, 3) + M(2, 4);
y_wld(:, 3) = y_vox(:, 1)*M(3, 1) + y_vox(:, 2)*M(3, 2) + y_vox(:, 3)*M(3, 3) + M(3, 4);