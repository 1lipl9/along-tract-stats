function [header, tracks] = trk_filter(header, tracks, expression)
%TRK_FILTER - used to select the tracks  the tracks satisfied to
%expression.
%
%Syntax: [header,tracks] = TRK_FILTER(header,tracks, expression)
%
%Inputs
%  header, tracks - the result of the trk_read.m
%  expression     - a compare formula, like '> 90'
%
% Author: Shaofeng Duan (duansf@ihep.ac.cn)
% Institute of High Energy Physics 
% Nov 2015

exprCell = textscan(expression, '%2c %d');
fieldValue = [tracks.nPoints];

switch deblank(exprCell{1})
    case '>'
        tracks = tracks(fieldValue > exprCell{2});
        ntracks = sum(fieldValue > exprCell{2});
    case '>='
        tracks = tracks(fieldValue >= exprCell{2});
        ntracks = sum(fieldValue >= exprCell{2});
    case '=='
        tracks = tracks(fieldValue == exprCell{2});
        ntracks = sum(fieldValue == exprCell{2});
    case '<='
        tracks = tracks(fieldValue <= exprCell{2});
        ntracks = sum(fieldValue <= exprCell{2});
    case '<'
        tracks = tracks(fieldValue < exprCell{2});
        ntracks = sum(fieldValue < exprCell{2});
    otherwise
            error('you should input the correct expression')
end

header.n_count = ntracks;
