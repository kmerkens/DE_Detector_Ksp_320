function countHARPin1file
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


for di = 9 : 16
    peakFrMedAll=[];
    F0MedAll=[];
    durMedAll=[];
    slopeMedAll=[];
    nSamplesMedAll=[];
    clickCountAll=[];
    peakFrMed20All=[];
    F0Med20All=[];
    durMed20All=[];
    slopeMed20All=[];
    nSamplesMed20All=[];
    clickCount20All=[];
    rawStartAll=[];
    rawDurAll=[];
    matDir=[inDir(di,:),'\'];
    disp(['Put all click counts and medians per segment of ',matDir,' in one file'])
    
    d = dir(fullfile(matDir,'*.mat'));    % mat files
    matNames = char(d.name);      % file names in directory

    B=num2str(size(matNames,1));
    
    cd(matDir)
    
    peakFrMed=[];
    F0Med=[];
    durMed=[];
    slopeMed=[];
    nSamplesMed=[];
    clickCount=[];
    peakFrMed20=[];
    F0Med20=[];
    durMed20=[];
    slopeMed20=[];
    nSamplesMed20=[];
    clickCount20=[];
    rawStartDisk=[];
    rawDurDisk=[];
    for a=1:size(matNames,1)
        load(matNames(a,:))
        %count detected number of clicks per 75s segment
        
        peakFrM=[];
        F0M=[];
        durM=[];
        slopeM=[];
        nSamplesM=[];
        clickCt=[];
        for i=1:length(rawDur)
            segStart=(i-1)*rawDur(i);
            segEnd=i*rawDur(i)-1*10^-20;
            posSeg=[];
            posSeg=find(pos(:,1)>segStart & pos(:,1)<segEnd);
            peakFrM(i,1)=prctile(peakFr(posSeg(1:end)),50);
            F0M(i,1)=prctile(F0(posSeg(1:end)),50);
            durM(i,1)=prctile(dur(posSeg(1:end)),50);
            slopeM(i,1)=prctile(slope(posSeg(1:end)),50);
            nSamplesM(i,1)=prctile(nSamples(posSeg(1:end)),50);
            clickCt(i,1)=length(posSeg);
        end
        peakFrMed=[peakFrMed;peakFrM];
        F0Med=[F0Med;F0M];
        durMed=[durMed;durM];
        slopeMed=[slopeMed;slopeM];
        nSamplesMed=[nSamplesMed;nSamplesM];
        clickCount=[clickCount;clickCt];
        
        %eliminate all clicks with peak frequency below 20 kHz and
        %recalculate
        lowPeak=find(peakFr<20);
        peakFr(lowPeak)=[];
        F0(lowPeak)=[];
        dur(lowPeak)=[];
        slope(lowPeak,:)=[];
        nSamples(lowPeak)=[];
        pos(lowPeak,:)=[];
        
        peakFrM20=[];
        F0M20=[];
        durM20=[];
        slopeM20=[];
        nSamplesM20=[];
        clickCt20=[];
        for i=1:length(rawDur)
            segStart=(i-1)*rawDur(i);
            segEnd=i*rawDur(i)-1*10^-20;
            posSeg=[];
            posSeg=find(pos(:,1)>segStart & pos(:,1)<segEnd);
            peakFrM20(i,1)=prctile(peakFr(posSeg(1:end)),50);
            F0M20(i,1)=prctile(F0(posSeg(1:end)),50);
            durM20(i,1)=prctile(dur(posSeg(1:end)),50);
            slopeM20(i,1)=prctile(slope(posSeg(1:end)),50);
            nSamplesM20(i,1)=prctile(nSamples(posSeg(1:end)),50);
            clickCt20(i,1)=length(posSeg);
        end
        peakFrMed20=[peakFrMed20;peakFrM20];
        F0Med20=[F0Med20;F0M20];
        durMed20=[durMed20;durM20];
        slopeMed20=[slopeMed20;slopeM20];
        nSamplesMed20=[nSamplesMed20;nSamplesM20];
        clickCount20=[clickCount20;clickCt20];
        
        rawStartAll=[rawStartAll;rawStart];
        rawDur=rawDur.';
        rawDurAll=[rawDurAll;rawDur];
        
        disp(['clicks of file ',num2str(a),' out of ',B,' extracted']);
    end
    
    
    peakFrMedAll=[peakFrMedAll;peakFrMed];
    F0MedAll=[F0MedAll;F0Med];
    durMedAll=[durMedAll;durMed];
    slopeMedAll=[slopeMedAll;slopeMed];
    nSamplesMedAll=[nSamplesMedAll;nSamplesMed];
    clickCountAll=[clickCountAll;clickCount];
    peakFrMed20All=[peakFrMed20All;peakFrMed20];
    F0Med20All=[F0Med20All;F0Med20];
    durMed20All=[durMed20All;durMed20];
    slopeMed20All=[slopeMed20All;slopeMed20];
    nSamplesMed20All=[nSamplesMed20All;nSamplesMed20];
    clickCount20All=[clickCount20All;clickCount20];
    rawStartAll=[rawStartAll;rawStartDisk];
    rawDurAll=[rawDurAll;rawDurDisk];
    
    seq = strfind(matDir, '\');
    newMatFile = (['..\',matDir(seq(1)+1:end-1),'_count_median.mat']);
    save(newMatFile,'peakFrMedAll','peakFrMed20All','F0MedAll','F0Med20All','durMedAll',...
        'durMed20All','slopeMedAll','slopeMed20All','nSamplesMedAll','nSamplesMed20All',...
        'clickCountAll','clickCount20All','rawStartAll','rawDurAll');

    disp(['clicks of disk ',matDir(seq+1:end-1),' saved'])
end


%%%%%%%%%%%%%%%%%
%delete all empty segments and put all segments in one long array
clear all
close all

% define directory where .matlab scripts are located
str1 = 'Select Directory containing .m script files';
indir = 'D:\';
scriptDir = uigetdir(indir,str1);

cd(scriptDir)

str1 = 'Select Directory containing .mat files';
indir = 'D:\';
matDir = uigetdir(indir,str1);

[matNames] = get_matNames(matDir);

cd(matDir);

peakFrMedTotal=[];
F0MedTotal=[];
durMedTotal=[];
slopeMedTotal=[];
nSamplesMedTotal=[];
clickCountTotal=[];
rawStartTotal=[];
rawDurTotal=[];

peakFrMed20Total=[];
F0Med20Total=[];
durMed20Total=[];
slopeMed20Total=[];
nSamplesMed20Total=[];
clickCount20Total=[];
rawStart20Total=[];
rawDur20Total=[];

for a=1:size(matNames,1)
    load(matNames(a,:))
    rawStart20All=rawStartAll;
    rawDur20All=rawDurAll;
    
    noClick=find(isnan(peakFrMedAll)==1);
    peakFrMedAll(noClick)=[];
    F0MedAll(noClick)=[];
    durMedAll(noClick)=[];
    slopeMedAll(noClick)=[];
    nSamplesMedAll(noClick)=[];
    clickCountAll(noClick)=[];
    rawStartAll(noClick,:)=[];
    rawDurAll(noClick)=[];

    noClick20=find(isnan(peakFrMed20All)==1);
    peakFrMed20All(noClick20)=[];
    F0Med20All(noClick20)=[];
    durMed20All(noClick20)=[];
    slopeMed20All(noClick20)=[];
    nSamplesMed20All(noClick20)=[];
    clickCount20All(noClick20)=[];
    rawStart20All(noClick20,:)=[];
    rawDur20All(noClick20)=[];
    
    peakFrMedTotal=[peakFrMedTotal;peakFrMedAll];
    F0MedTotal=[F0MedTotal;F0MedAll];
    durMedTotal=[durMedTotal;durMedAll];
    slopeMedTotal=[slopeMedTotal;slopeMedAll];
    nSamplesMedTotal=[nSamplesMedTotal;nSamplesMedAll];
    clickCountTotal=[clickCountTotal;clickCountAll];
    rawStartTotal=[rawStartTotal;rawStartAll];
    rawDurTotal=[rawDurTotal;rawDurAll];
    
    peakFrMed20Total=[peakFrMed20Total;peakFrMed20All];
    F0Med20Total=[F0Med20Total;F0Med20All];
    durMed20Total=[durMed20Total;durMed20All];
    slopeMed20Total=[slopeMed20Total;slopeMed20All];
    nSamplesMed20Total=[nSamplesMed20Total;nSamplesMed20All];
    clickCount20Total=[clickCount20Total;clickCount20All];
    rawStart20Total=[rawStart20Total;rawStart20All];
    rawDur20Total=[rawDur20Total;rawDur20All];
end

seq = strfind(matNames(1,:), '_');
newMatFile = ([matNames(1,1:seq(1)),'count_median.mat']);
save(newMatFile,'peakFrMedTotal','peakFrMed20Total','F0MedTotal','F0Med20Total','durMedTotal',...
    'durMed20Total','slopeMedTotal','slopeMed20Total','nSamplesMedTotal','nSamplesMed20Total',...
    'clickCountTotal','clickCount20Total','rawStartTotal','rawStart20Total','rawDurTotal','rawDur20Total');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plot(peakFrMed20Total)
xlabel('segment (counts)')
ylabel('median peak frequency [kHz] per 75 s segment')
title('Median peak frequency of all segments with detected clicks','FontWeight','bold')

plot(F0Med20Total)
xlabel('segment (counts)')
ylabel('median center frequency [kHz] per 75 s segment')
title('Median center frequency of all segments with detected clicks','FontWeight','bold')

plot(durMed20Total)
xlabel('segment (counts)')
ylabel('median duration [ms] per 75 s segment')
title('Median duration of all segments with detected clicks','FontWeight','bold')

plot(slopeMed20Total)
xlabel('segment (counts)')
ylabel('median slope per 75 s segment')
title('Median slope of all segments with detected clicks','FontWeight','bold')

plot(clickCount20Total)
xlabel('segment (counts)')
ylabel('click count per 75 s segment')
title('Click count of all segments with detected clicks','FontWeight','bold')

%prepare start/end for excel
%add 75 s to start
raw=[0 0 0 0 1 15];
raw=datenum(raw);

rawStart20Total=datenum(rawStart20Total);
rawEnd20Total=rawStart20Total+raw;

%eliminate all segments with less than 5 clicks detected
lowCount=find(clickCount20Total<5);
rawStart20Total(lowCount,:)=[];

%check diel pattern
hour=rawStart20Total(:,4);
hourVec=0:1:23;
for a=1:length(hourVec)
    curHour=find(hour==hourVec(a));
    curCount=clickCount20Total(curHour);
    meanCount(a)=mean(curCount);
    stdCount(a)=std(curCount);
end


