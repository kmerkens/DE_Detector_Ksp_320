%beaked whale discrimination process:
%- eliminate all clicks with peak frequency below 20 kHz
%- find slope above 60
%- find sample size (nSamples, -8dB limit) with n>=35
%- find areas where 10% of clicks per minute remained after discrimination

clear all
close all

% input 
d1 = 'G:\';     %input directory name

d2 = 'G:\';     %input directory name

f1 = 'SOCAL32N\SOCAL32N_disk';     %input folder name 

inDir = [d1 f1 '01'; d1 f1 '02'; d1 f1 '03'; d1 f1 '04';...
    d1 f1 '05'; d1 f1 '06'; d1 f1 '07'; d1 f1 '08';...
    d2 f1 '09'; d2 f1 '10'; d2 f1 '11'; d2 f1 '12';...
    d2 f1 '13'; d2 f1 '14'; d2 f1 '15'; d2 f1 '16'];

disp(inDir)

for di = 1 : 16
    matDir=[inDir(di,:),'\'];
    disp(['Put all clicks of ',matDir,' in one file'])
    
    d = dir(fullfile(matDir,'*.mat'));    % mat files
    matNames = char(d.name);      % file names in directory

    cd(matDir)
    
    segAll=[];
    rawStartAll=[];
    
    B=num2str(size(matNames,1));
    
    for a=1:size(matNames,1)
        
        load(matNames(a,:))
        if size(pos,1)>length(peakFr)
            pos(end,:)=[];
        end
        %count detected number of clicks per 75s segment
        seg=[];
        for i=1:length(rawDur)
            segStart=(i-1)*rawDur(i);
            segEnd=i*rawDur(i)-1*10^-20;
            posSeg=[];
            posSeg=find(pos(:,1)>segStart & pos(:,1)<segEnd);
            seg(i,1)=length(posSeg);
        end
        rawStartAll=[rawStartAll;rawStart];
         
        disp(['clicks of file ',num2str(a),' out of ',B,' extracted']);
    end

    seq = strfind(matDir, '\');
    newMatFile = (['..\..\beaked_whale_stats\',matDir(seq(1)+1:end-1),'_clickCount.mat']);
    save(newMatFile,'segAll','rawStartAll');

    disp(['clicks of disk ',matDir(seq+1:end),' saved']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%put all segments and times in one file per site
% define directory where .matlab scripts are located
str1 = 'Select Directory containing .m script files';
indir = 'E:\data\code\analyze_HARP_sbp090904\step2_analysis';
scriptDir = uigetdir(indir,str1);

cd(scriptDir);

[matNames,matDir] = get_matNames;

segTotal=[];
rawStartTotal=[];
for a=1:size(matNames,1)
    cd(matDir)
    load(matNames(a,:))
    
    segTotal=[segTotal;segAll];
    rawStartTotal=[rawStartTotal;rawStartAll];
end

null=find(segTotal==0);

segTotal(null)=[];
rawStartTotal(null,:)=[];

%delete segments with equal or less than 4 detected clicks
low=find(segTotal<4);
segTotal(low)=[];
rawStartTotal(low,:)=[];

%%%%%%%%%%%%%%%%%%%%%%%%%
%change times from vector to number

dateStart=datenum(rawStartTotal);
%add 75s for end of segment
raw=[0 0 0 0 1 15];
raw=datenum(raw);
dateEnd=dateStart+raw;


