function putAllHARPin1file
% goes through all files of one disk and saves certain parameters into one
% complete file

clear all
close all

% input 
d1 = 'I:\';     %input directory name

d2 = 'I:\';     %input directory name

f1 = 'SOCAL32N/SOCAL32N_disk';     %input folder name 

inDir = [d1 f1 '01'; d1 f1 '02'; d1 f1 '03'; d1 f1 '04';...
    d1 f1 '05'; d1 f1 '06'; d1 f1 '07'; d1 f1 '08';...
    d2 f1 '09'; d2 f1 '10'; d2 f1 '11'; d2 f1 '12';...
    d2 f1 '13'; d2 f1 '14'; d2 f1 '15'; d2 f1 '16'];

disp(inDir)

for di = 9 : 12
    matDir=[inDir(di,:),'\'];
    disp(['Put all clicks of ',matDir,' in one file'])
    
    d = dir(fullfile(matDir,'*.mat'));    % mat files
    matNames = char(d.name);      % file names in directory

    F0All=[];
    durAll=[];
    iciAll=[];
    nSamplesAll=[];
    peakFrAll=[];
    posAll=[];
    rawDurAll=[];
    rawStartAll=[];
    slopeAll=[];
    clickCount=[];
    rawCount=[];

    B=num2str(size(matNames,1));
    
    cd(matDir)
  
    for a=1:size(matNames,1)
        load(matNames(a,:))
        F0=F0.';
        F0All=[F0All;F0];
        durAll=[durAll;dur];
        iciAll=[iciAll;ici];
        nSamplesAll=[nSamplesAll;nSamples];
        peakFrAll=[peakFrAll;peakFr];
        posAll=[posAll;pos];
        rawDur=rawDur.';
        rawDurAll=[rawDurAll;rawDur];
        rawStartAll=[rawStartAll;rawStart];
        slopeAll=[slopeAll;slope];
        clickCount=[clickCount;length(peakFr)];
        rawCount=[rawCount;length(rawDur)];

        disp(['clicks of file ',num2str(a),' out of ',B,' extracted']);
    end

    seq = strfind(matDir, '\');
    newMatFile = (['..\',matDir(seq(1)+1:end-1),'.mat']);
    save(newMatFile,'F0All','durAll','iciAll','nSamplesAll','peakFrAll',...
        'posAll','rawDurAll','rawStartAll','slopeAll','clickCount','rawCount');

    disp(['clicks of disk ',matDir(seq+1:end),' saved']);
end





