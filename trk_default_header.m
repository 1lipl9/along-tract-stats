function header = trk_default_header

fid = fopen('trk_empty.txt','w+');
fwrite(fid, 20, 'int');
fwrite(fid, 20, 'int', 1);
fseek(fid, 4, 'bof');
CC = fread(fid, 1, '*char');
fclose(fid);
delete('trk_empty.txt');
header.id_string                 = ['TRACK',CC];
header.dim                       = zeros(1, 3);
header.voxel_size                = zeros(1, 3);
header.origin                    = [0, 0, 0];
header.n_scalars                 = 0;
header.scalar_name               = repmat(CC, 10 ,20);
header.n_properties              = 0;
header.property_name             = repmat(CC, 10 ,20);
header.vox_to_ras                = zeros(4);
header.reserved                  = repmat(CC, 444,1);
header.voxel_order               = [CC CC CC CC];
header.pad2                      = [CC CC CC CC];
header.image_orientation_patient = [1 0 0 0 1 0];
header.pad1                      = [CC CC];
header.invert_x                  = 0;
header.invert_y                  = 0;
header.invert_z                  = 0;
header.swap_xy                   = 0;
header.swap_yz                   = 0;
header.swap_zx                   = 0;
header.n_count                   = 0;
header.version                   = 2;
header.hdr_size                  = 1000;

