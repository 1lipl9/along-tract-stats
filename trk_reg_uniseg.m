function [header,tracks] = trk_reg_uniseg(header,tracks,res)
%TRK_REG_UNISEG - used to registrit the tracks
%you should ensure the max(abs(sn.VF.mat)) = [1, 2, 3];
%Inputs
%   sn_name - the file name of the deformation image.

% Author: Shaofeng Duan (duansf@ihep.ac.cn)
% Institute of High Energy Physics 
% Oct 2015

% Read essentials from tpm (it will be cleared later)
tpm = res.tpm;
if ~isstruct(tpm) || ~isfield(tpm, 'bg1'),
    tpm = spm_load_priors8(tpm);
end
d1        = size(tpm.dat{1});
d1        = d1(1:3);
M1        = tpm.M;

prm     = [3 3 3 0 0 0];
Coef    = cell(1,3);
Coef{1} = spm_bsplinc(res.Twarp(:,:,:,1),prm);
Coef{2} = spm_bsplinc(res.Twarp(:,:,:,2),prm);
Coef{3} = spm_bsplinc(res.Twarp(:,:,:,3),prm);

M = M1\res.Affine*res.image(1).mat;%这是VG体素到VF的体素坐标对应关系。


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
    
    [t1,t2,t3] = defs(Coef, res.MT, prm, X_trk, Y_trk, Z_trk, M);
 
    
    tracks(iTrk).matrix(:, 1:3) = [t1(1:nPoints)'; t2(1:nPoints)'; t3(1:nPoints)'].* repmat(voxel_size, nPoints, 1);
end
voxel_size = sqrt(sum(M1(1:3,1:3)).^2);
header.dim        = d1;
header.voxel_size = voxel_size;
mat = M1;
mat(:, 4) = sum(mat, 2);
header.vox_to_ras = mat;
header.image_orientation_patient = getIOP(tpm.V(1).fname);

%==========================================================================
% function [x1,y1,z1] = defs(sol,z,MT,prm,x0,y0,z0,M)
%==========================================================================
function [x1,y1,z1] = defs(sol,MT,prm,x0,y0,z0,M)
iMT = inv(MT);
x1  = x0*iMT(1,1)+iMT(1,4);
y1  = y0*iMT(2,2)+iMT(2,4);
z1  = z0*iMT(3,3)+iMT(3,4);
x1a = x0    + spm_bsplins(sol{1},x1,y1,z1,prm);
y1a = y0    + spm_bsplins(sol{2},x1,y1,z1,prm);
z1a = z0    + spm_bsplins(sol{3},x1,y1,z1,prm);
x1  = M(1,1)*x1a + M(1,2)*y1a + M(1,3)*z1a + M(1,4);
y1  = M(2,1)*x1a + M(2,2)*y1a + M(2,3)*z1a + M(2,4);
z1  = M(3,1)*x1a + M(3,2)*y1a + M(3,3)*z1a + M(3,4);
return;
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
