function [header, tracks] = trk_add_pValue
%Syntax: TRK_ADD_PVALUE is used to add p value on a mean trk.
%
%Usage: TRK_ADD_PVALUE
%
%Shaofeng Duan
%IHEP
%2016-06-12

trkName = spm_select(1, 'trk', 'select a mean trk file.');
[header, tracks] = trk_read(trkName);

pvalFile = spm_select(1, 'csv', 'select a csv file.');
pTbl = readtable(pvalFile);

tracks(1).matrix = [tracks(1).matrix, pTbl{:,1}];

n_scalars_old    = header.n_scalars;
header.n_scalars = n_scalars_old + 1;
header.scalar_name(n_scalars_old + 1,1:size('pVal',2)) = 'pVal';

