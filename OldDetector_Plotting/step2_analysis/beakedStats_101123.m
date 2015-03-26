%beaked whale discrimination process:
%- eliminate all clicks with peak frequency below 20 kHz
%- find slope above 60
%- find sample size (nSamples, -8dB limit) with n>40
%- find areas where 10% of clicks per minute remained after discrimination

clear all
close all

% input 
d1 = 'I:\';     %input directory name

d2 = 'I:\';     %input directory name

f1 = 'SOCAL33N\SOCAL33N_disk';     %input folder name 

inDir = [d1 f1 '01'; d1 f1 '02'; d1 f1 '03'; d1 f1 '04';...
    d1 f1 '05'; d1 f1 '06'; d1 f1 '07'; d1 f1 '08';...
    d2 f1 '09'; d2 f1 '10'; d2 f1 '11'; d2 f1 '12';...
    d2 f1 '13'; d2 f1 '14'; d2 f1 '15'; d2 f1 '16'];

disp(inDir)

for di = 1:16%size(inDir,1)
    matDir=[inDir(di,:),'\'];
    disp(['Put all clicks of ',matDir,' in one file'])
    
    d = dir(fullfile(matDir,'*.mat'));    % mat files
    matNames = char(d.name);      % file names in directory

    cd(matDir)
    
    segAll=[];
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
        seg=zeros(length(rawDur),3);
        peakFrM=zeros(length(rawDur),2);
        F0M=zeros(length(rawDur),2);
        durM=zeros(length(rawDur),2);
        slopeM=zeros(length(rawDur),2);
        nSamplesM=zeros(length(rawDur),2);
         bw3dbM=zeros(length(rawDur),2);
         bw10dbM=zeros(length(rawDur),2);
         
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
%         %eliminate all clicks with bandwidth at 3db ...
%         lowbw3db=find(bw3db(:,3)<3.5156);
%         F0(lowbw3db)=[];
%         dur(lowbw3db)=[];
%         nSamples(lowbw3db)=[];
%         peakFr(lowbw3db)=[];
%         pos(lowbw3db,:)=[];
%         slope(lowbw3db,:)=[];
%         bw3db(lowbw3db,:)=[];
%         bw10db(lowbw3db,:)=[];
%          
%         %eliminate alll clicks with bandwidth at 10db ...     
%         lowbw10db=find(bw10db(:,3)<8.5938);
%         F0(lowbw10db)=[];
%         dur(lowbw10db)=[];
%         nSamples(lowbw10db)=[];
%         peakFr(lowbw10db)=[];
%         pos(lowbw10db,:)=[];
%         slope(lowbw10db,:)=[];
%         bw3db(lowbw10db,:)=[];
%         bw10db(lowbw10db,:)=[];
        
        %eliminate all clicks with peak frequency below 32.0313 kHz 
        lowPeak=find(peakFr<32.0313);
        F0(lowPeak)=[];
        dur(lowPeak)=[];
        nSamples(lowPeak)=[];
        peakFr(lowPeak)=[];
        pos(lowPeak,:)=[];
        slope(lowPeak,:)=[];
         bw3db(lowPeak,:)=[];
        bw10db(lowPeak,:)=[];
        
%        % eliminate all clicks with center frequency below 25kHz 
%         lowF0=find(F0<25);
%         F0(lowF0)=[];
%         dur(lowF0)=[];
%         nSamples(lowF0)=[];
%         peakFr(lowF0)=[];
%         pos(lowF0,:)=[];
%         slope(lowF0,:)=[];
%           bw3db(lowF0,:)=[]; 
%         bw10db(lowF0,:)=[];
         
         
        %eliminate all clicks with duration <0.355 ms
        shortDur=find(dur<0.355);
        F0(shortDur)=[];
        dur(shortDur)=[];
        nSamples(shortDur)=[];
        peakFr(shortDur)=[];
        pos(shortDur,:)=[];
        slope(shortDur,:)=[];
        bw3db(shortDur,:)=[];
        bw10db(shortDur,:)=[];

%         %remove slope below 23.0384
%         lowSlope=find(slope(:,1)<23.0384);
%         F0(lowSlope)=[];
%         dur(lowSlope)=[];
%         nSamples(lowSlope)=[];
%         peakFr(lowSlope)=[];
%         pos(lowSlope,:)=[];
%         slope(lowSlope,:)=[];
%         bw3db(lowSlope,:)=[];
%         bw10db(lowSlope,:)=[];
        
        %remove short duration samples (nSamples, -8dB limit) n<34
        lowDur=find(nSamples<34);
        F0(lowDur)=[];
        dur(lowDur)=[];
        nSamples(lowDur)=[];
        peakFr(lowDur)=[];
        pos(lowDur,:)=[];
        slope(lowDur,:)=[];
        bw3db(lowDur,:)=[];
        bw10db(lowDur,:)=[];
        
        %calculate which percentage of clicks per 75s segment remained
        for i=1:length(rawDur)
            segStart=(i-1)*rawDur(i);
            segEnd=i*rawDur(i)-1*10^-20;
            posSeg=[];
            posSeg=find(pos(:,1)>segStart & pos(:,1)<segEnd);
            seg(i,2)=length(posSeg);
            peakFrM(i,2)=prctile(peakFr(posSeg(1:end)),50);
            F0M(i,2)=prctile(F0(posSeg(1:end)),50);
            durM(i,2)=prctile(dur(posSeg(1:end)),50);
            slopeM(i,2)=prctile(slope(posSeg(1:end)),50);
            nSamplesM(i,2)=prctile(nSamples(posSeg(1:end)),50);
             bw10dbM(i,2)=prctile(bw10db(posSeg(1:end)),50);
              bw3dbM(i,2)=prctile(bw3db(posSeg(1:end)),50);
        end
        for i=1:length(rawDur)
        	seg(i,3)=seg(i,2)/seg(i,1);
        end
        
        
        segAll=[segAll;seg];
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

%export to Excel
%make array to export
xlsArray=[diskNo,rawStartTotal,segTotal];
%write xls to disk
seq=strfind(newMatFile,'.');
xlswrite(newMatFile(1:seq-1), xlsArray)

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
%make array to export
xlsArray=[diskNo,rawStartTotal,segTotal];
%write xls to disk
seq=strfind(newMatFile,'.');
xlswrite(newMatFile(1:seq-1), xlsArray)


