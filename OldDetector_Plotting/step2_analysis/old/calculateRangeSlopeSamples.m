clear all
close all

% input 
d1 = 'J:\';     %input directory name

d2 = 'J:\';     %input directory name

f1 = 'SOCAL32M\SOCAL32M_disk';     %input folder name 

inDir = [d1 f1 '01'; d1 f1 '02'; d1 f1 '03'; d1 f1 '04';...
    d1 f1 '05'; d1 f1 '06'; d1 f1 '07'; d1 f1 '08';...
    d2 f1 '09'; d2 f1 '10'; d2 f1 '11'; d2 f1 '12';...
    d2 f1 '13'; d2 f1 '14'; d2 f1 '15'; d2 f1 '16'];

disp(inDir)

for di = 1 : 16
    matDir=[inDir(di,:),'\'];
    disp(['Calculate mean range of slope and nSamples per segment and put ',matDir,' in one file'])
    
    d = dir(fullfile(matDir,'*.mat'));    % mat files
    matNames = char(d.name);      % file names in directory

    cd(matDir)
    
    rangeSlopeAll=[];
    rangeNSamplesAll=[];
    
    B=num2str(size(matNames,1));
    
    for a=1:size(matNames,1)
        cd(matDir)
        load(matNames(a,:))
        %count detected number of clicks per 75s segment
        rangeSlope=[];
        rangeNSamples=[];
        for i=1:length(rawDur)
            segStart=(i-1)*rawDur(i);
            segEnd=i*rawDur(i)-1*10^-20;
            p=[25 50 75];
            rSlope=[];
            rSamples=[];
            posSeg=find(pos(:,1)>segStart & pos(:,1)<segEnd);
            if isempty(posSeg)==0
                rSlope=prctile(slope(posSeg(1):posSeg(end)),p);
                rSamples=prctile(nSamples(posSeg(1):posSeg(end)),p);
            else
                rSlope=[NaN NaN NaN];
                rSamples=[NaN NaN NaN];
            end
            rangeSlope(i,:)=rSlope;
            rangeNSamples(i,:)=rSamples;  
        end
                
        rangeNSamplesAll=[rangeNSamplesAll;rangeNSamples];
        rangeSlopeAll=[rangeSlopeAll;rangeSlope];
        
        disp(['clicks of file ',num2str(a),' out of ',B,' extracted']);
    end
    
    seq = strfind(matDir, '\');
    newMatFile = (['..\..\beaked_whale_discrimination\',matDir(seq(1)+1:end-1),'.mat']);
    save(newMatFile,'rangeNSamplesAll','rangeSlopeAll','-append');

    disp(['clicks of disk ',matDir,' saved']);
end

