%beaked whale discrimination process:
%- eliminate all clicks with peak frequency below 20 kHz
%- find slope above 60
%- find sample size (nSamples, -8dB limit) with n>40
%- find areas where 10% of clicks per minute remained after discrimination

clear all
close all

% input 
d1 = 'F:\Palmyra02\';     %input directory name

d2 = 'F:\Palmyra02\';     %input directory name

f1 = 'Palmyra02_disk';     %input folder name 

inDir = [d1 f1 '01'; d1 f1 '02'; d1 f1 '03'; d1 f1 '04';...
    d1 f1 '05'; d1 f1 '06'; d1 f1 '07'; d1 f1 '08';...
    d2 f1 '09'; d2 f1 '10'; d2 f1 '11'; d2 f1 '12';...
    d2 f1 '13'; d2 f1 '14'; d2 f1 '15'; d2 f1 '16'];

disp(inDir)

for di = 1:size(inDir,1)
    matDir=[inDir(di,:),'\'];
    disp(['Put all segments of ',matDir,' in one file'])
    
    d = dir(fullfile(matDir,'*.mat'));    % mat files
    matNames = char(d.name);      % file names in directory

    cd(matDir)
    
    peakFrMAll=[];
    F0MAll=[];
    durMAll=[];
    slopeMAll=[];
    nSamplesMAll=[];
    rawDurAll=[];
    rawStartAll=[];
    bw3dbMAll=[];
    bw10dbMAll=[];
    
    B=num2str(size(matNames,1));
    
    for a=1:size(matNames,1)
        nameSeq = strfind(matNames(a,:),'.mat');
        load(matNames(a,(1:nameSeq+3)))
        %sometimes last click was not computed if window (800 samples) around click did
        %not fit in length of wave file, yet position was still saved ->
        %number of detected clicks exceeds number of calcuted parameters ->
        %delete last entry in position, duration and inter-click interval
        if size(pos,1)>length(peakFr)
            pos(end,:)=[];
            dur(end,:)=[];
            ici(end,:)=[];
        end
        
        %count detected number of clicks per 75s segment
        peakFrM=zeros(length(rawDur),1);
        F0M=zeros(length(rawDur),1);
        durM=zeros(length(rawDur),1);
        slopeM=zeros(length(rawDur),1);
        nSamplesM=zeros(length(rawDur),1);
         bw3dbM=zeros(length(rawDur),1);
         bw10dbM=zeros(length(rawDur),1);
         
        for i=1:length(rawDur)
            segStart=(i-1)*rawDur(i);
            segEnd=i*rawDur(i)-1*10^-20;
            posSeg=[];
            posSeg=find(pos(:,1)>segStart & pos(:,1)<segEnd);
            seg(i,1)=length(posSeg);
            peakFrM(i,1)=prctile(peakFr(posSeg(1:end)),50);
            F0M(i,1)=prctile(F0(posSeg(1:end)),50);
            durM(i,1)=prctile(dur(posSeg(1:end)),50);
            slopeM(i,1)=prctile(slope(posSeg(1:end)),50);
            nSamplesM(i,1)=prctile(nSamples(posSeg(1:end)),50);
            bw3dbM(i,1)=prctile(bw3db(posSeg(1:end)),50);
            bw10dbM(i,1)=prctile(bw10db(posSeg(1:end)),50);
        end
        
 
        %eliminate all segments with median peak frequency below 20 kHz 
        findHigh = find(peakFrM > 20);
        peakFrM(findHigh) = NaN;
        F0M(findHigh) = NaN;
        durM(findHigh) = NaN;
        slopeM(findHigh) = NaN;
        nSamplesM(findHigh) = NaN;
        bw10dbM(findHigh) = NaN;
        bw3dbM(findHigh) = NaN;
        
        peakFrMAll=[peakFrMAll;peakFrM];
        F0MAll=[F0MAll;F0M];
        durMAll=[durMAll;durM];
        slopeMAll=[slopeMAll;slopeM];
        nSamplesMAll=[nSamplesMAll;nSamplesM];
        rawDur=rawDur.';
        rawDurAll=[rawDurAll;rawDur];
        rawStartAll=[rawStartAll;rawStart];
        bw10dbMAll=[bw10dbMAll;bw10dbM];
        bw3dbMAll=[bw3dbMAll;bw3dbM]; 
         
        disp(['clicks of file ',num2str(a),' out of ',B,' extracted']);
    end

    seq = strfind(matDir, '\');
    newMatFile = (['..\beakedStats\',matDir(seq(1)+1:seq(2)-1),'_',matDir(seq(2)+1:seq(3)-1),'_beaked.mat']);
    save(newMatFile,'peakFrMAll','F0MAll','durMAll','slopeMAll','segAll',...
        'nSamplesMAll','rawDurAll','rawStartAll','bw3dbMAll','bw10dbMAll');

    disp(['clicks of disk ',matDir(seq+1:end),' saved']);
end
%%%%%%%%%%%%%%%%%%%%%
% display beaked whale clicks
% L=num2str(size(yFilt,1));
% for c=1:size(yFilt,1)
%     figure(1)
%     plot(yFilt(c,(161:320)))
%     title(['Timeseries, click no. ',num2str(c),' of ',L])
%     
%     clickTest = yFilt(c,(201:320));
%     [Y,F,T,P] = spectrogram(clickTest,40,39,40,fs);
%     T = T*1000;
%     F = F/1000;
% 
%     figure(2)
%     surf(T,F,10*log10(abs(P)),'EdgeColor','none');
%     axis xy; axis tight; colormap(jet); view(0,90);
%     xlabel('Time [ms]');
%     ylabel('Frequency [kHz]');
%     title(['Spectrogram - Click ',num2str(c),' of ',L])
%     pause
%     
% end

%%%%%%%%%%%%%%%%%%%%%%

%put all variables of all disks in one file
seq=strfind(f1,'\');
beakedDir=([d1,f1(1:seq-1),'\beakedStats\']);

cd(beakedDir)

d = dir(fullfile(beakedDir,'*.mat'));    % mat files
    matNames = char(d.name);      % file names in directory

segTotal=[];
peakFrMTotal=[];
F0MTotal=[];
durMTotal=[];
slopeMTotal=[];
nSamplesMTotal=[];
rawDurTotal=[];
rawStartTotal=[];
diskNo=[];
bw3dbMTotal=[];
bw10dbMTotal=[];

for i=1:size(matNames,1)
        load(matNames(i,:))
        
        disk=ones(length(rawDurAll),1)*i;
        
        segTotal=[segTotal;segAll];
        peakFrMTotal=[peakFrMTotal;peakFrMAll];
        F0MTotal=[F0MTotal;F0MAll];
        durMTotal=[durMTotal;durMAll];
        slopeMTotal=[slopeMTotal;slopeMAll];
        nSamplesMTotal=[nSamplesMTotal;nSamplesMAll];
        rawDurTotal=[rawDurTotal;rawDurAll];
        rawStartTotal=[rawStartTotal;rawStartAll];
        diskNo=[diskNo;disk];
        bw3dbMTotal=[bw3dbMTotal;bw3dbMAll];
          bw10dbMTotal=[bw10dbMTotal;bw10dbMAll];
end

%delete segments where no clicks were detected
notaN=isnan(segTotal(:,3));
not=find(notaN==1);
segTotal(not,:)=[];
rawStartTotal(not,:)=[];
F0MTotal(not,:)=[];
durMTotal(not,:)=[];
nSamplesMTotal(not,:)=[];
peakFrMTotal(not,:)=[];
slopeMTotal(not,:)=[];
rawDurTotal(not,:)=[];
diskNo(not,:)=[];
bw3dbMTotal(not,:)=[];
bw10dbMTotal(not,:)=[];

%delete segments with <=7 clicks detected
lowCount=find(segTotal(:,1)<=7);
segTotal(lowCount,:)=[];
rawStartTotal(lowCount,:)=[];
F0MTotal(lowCount,:)=[];
durMTotal(lowCount,:)=[];
nSamplesMTotal(lowCount,:)=[];
peakFrMTotal(lowCount,:)=[];
slopeMTotal(lowCount,:)=[];
rawDurTotal(lowCount)=[];
diskNo(lowCount)=[];
bw3dbMTotal(lowCount,:)=[];
bw10dbMTotal(lowCount,:)=[];

seq = strfind(matNames(1,:), '_');
newMatFile = ([matNames(1,1:seq(1)-1),'_allDisks.mat']);
save(newMatFile,'peakFrMTotal','F0MTotal','durMTotal','slopeMTotal','segTotal',...
    'nSamplesMTotal','rawDurTotal','rawStartTotal','diskNo','bw3dbMTotal','bw10dbMTotal');

disp(['clicks of all disks saved']);

%save consecutive segments as one detection
%find time delay
segStart = datenum(rawStartTotal);
segStart1 = [0;segStart];
segStart2 = [segStart;0];
segDif = segStart2 - segStart1;
gapLength = [0 0 0 0 2 0];
gapLength = datenum(gapLength);
gap = find(segDif >= gapLength);

%find consecutive segments
seg = gap;
segEnd = gap(2:end)-1;
seg(:,2) = [segEnd;length(rawDurTotal)];

segLength=[0 0 0 0 1 15];
endShift=datenum(segLength);

matlabStart = segStart(seg(:,1));
matlabEnd = segStart(seg(:,2)) + endShift;

%convert to excel
excelStart = matlabStart - ones(size(matlabStart)).*datenum('30-Dec-1899');
excelEnd =  matlabEnd - ones(size(matlabEnd)).*datenum('30-Dec-1899');
xlsArray = [excelStart excelEnd];

%export to Excel
%write xls to disk
seq=strfind(newMatFile,'.');
file = [newMatFile(1:seq-1),'.xls'];
xlswrite(file, xlsArray)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%pull out beaked whale sequences
%delete segments where less than 10% were kept
lowSeg=find(segTotal(:,3)<0.13);
segTotal(lowSeg,:)=[];
rawStartTotal(lowSeg,:)=[];
F0MTotal(lowSeg,:)=[];
durMTotal(lowSeg,:)=[];
nSamplesMTotal(lowSeg,:)=[];
peakFrMTotal(lowSeg,:)=[];
slopeMTotal(lowSeg,:)=[];
rawDurTotal(lowSeg,:)=[];
diskNo(lowSeg,:)=[];
bw3dbMTotal(lowSeg,:)=[];
bw10dbMTotal(lowSeg,:)=[];

seq = strfind(matNames(1,:), '_');
newMatFile = ([matNames(1,1:seq(1)-1),'_allDisks_beaked.mat']);
save(newMatFile,'peakFrMTotal','F0MTotal','durMTotal','slopeMTotal','segTotal',...
    'nSamplesMTotal','rawDurTotal','rawStartTotal','diskNo','bw3dbMTotal','bw10dbMTotal');

disp(['clicks of beaked whales of all disks saved']);

%export to Excel
segStart = datenum(rawStartTotal);
segStart1 = [0;segStart];
segStart2 = [segStart;0];
segDif = segStart2 - segStart1;
gapLength = [0 0 0 0 2 0];
gapLength = datenum(gapLength);
gap = find(segDif >= gapLength);

%find consecutive segments
seg = gap;
segEnd = gap(2:end)-1;
seg(:,2) = [segEnd;length(rawDurTotal)];

segLength=[0 0 0 0 1 15];
endShift=datenum(segLength);

matlabStart = [];
matlabEnd = [];
matlabStart = segStart(seg(:,1));
matlabEnd = segStart(seg(:,2)) + endShift;

%convert to excel
excelStart = matlabStart - ones(size(matlabStart)).*datenum('30-Dec-1899');
excelEnd =  matlabEnd - ones(size(matlabEnd)).*datenum('30-Dec-1899');
xlsArray = [excelStart excelEnd];

%write xls to disk
seq=strfind(newMatFile,'.');
xlswrite(newMatFile(1:seq-1), xlsArray)


