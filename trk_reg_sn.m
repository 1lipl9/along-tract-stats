function [header,tracks] = trk_reg_sn(header,tracks,sn_name)
%TRK_REG_SN - used to registrit the tracks
%you should ensure the max(abs(sn.VF.mat)) = [1, 2, 3];
%Syntax: [header,tracks] = trk_reg_sn(header,tracks,sn_name)
%Inputs
%   sn_name - the file name of the deformation image.
%
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
voxel_size = sqrt(sum(sn.VF.mat(1:3,1:3).^2));
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
    
    tracks(iTrk).matrix(:, 1:3) = affine(vox, Mult).* repmat(voxel_size, nPoints, 1);
    
    clear('vox');
end

header.dim        = sn.VF.dim(1:3);
header.voxel_size = voxel_size;
%这个地方需要注意一下，在spm中的头文件中的mat的第四列进行了操作，与原始的头文件
%面的sform信息不一致。其转化关系是：
%nii(:, 4) = sum(mat, 2);


mat = sn.VF.mat;
mat(:, 4) = sum(mat, 2);
header.vox_to_ras = mat;
header.image_orientation_patient = getIOP(sn.VF.fname);

%==========================================================================
% function Def = affine(y,M)
%==========================================================================
function y_wld = affine(y_vox,M)
y_wld       = zeros(size(y_vox),'single');
y_wld(:, 1) = y_vox(:, 1)*M(1, 1) + y_vox(:, 2)*M(1, 2) + y_vox(:, 3)*M(1, 3) + M(1, 4);
y_wld(:, 2) = y_vox(:, 1)*M(2, 1) + y_vox(:, 2)*M(2, 2) + y_vox(:, 3)*M(2, 3) + M(2, 4);
y_wld(:, 3) = y_vox(:, 1)*M(3, 1) + y_vox(:, 2)*M(3, 2) + y_vox(:, 3)*M(3, 3) + M(3, 4);

%==========================================================================
%function IOP = getIOP(fname)  
%==========================================================================
function IOP = getIOP(fname)
nii = load_untouch_header_only(fname);

b = nii.hist.quatern_b;
c = nii.hist.quatern_c;
d = nii.hist.quatern_d;

a = sqrt(1 - sum([b, c, d].^2));

R11 = a*a + b*b - c*c -d*d;
R21 = 2*b*c + 2*a*d;
R31 = 2*b*d - 2*a*c;
R12 = 2*b*c - 2*a*d;
R22 = a*a + c*c - b*b - d*d;
R32 = 2*c*d + 2*a*b;
IOP = [-R11, -R21, R31, -R12, -R22, R32];