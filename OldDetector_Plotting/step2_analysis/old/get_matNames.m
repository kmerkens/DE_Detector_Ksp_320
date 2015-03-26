function [matNames,matDir] = get_matNames
%
% modified from get_xwavdir
% emo 2/5/07

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the directory
%
str1 = 'Select Disk containing .mat file Directory';
indir = 'G:\';
matIndir = uigetdir(indir,str1);
if matIndir == 0	% if cancel button pushed
    return
else
    matDir = [matIndir,'\'];
end

%%%%%%%%%%%%%%%%%%%%%%
% check for empty directory
%
d = dir(fullfile(matDir,'*.mat'));    % mat files

fn = char(d.name);      % file names in directory
fnsz = size(fn);        % number of data files in directory 

% filenames
matNames = fn;
