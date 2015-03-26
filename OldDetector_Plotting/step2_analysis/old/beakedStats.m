%beaked whale discrimination process:
%- eliminate all clicks with peak frequency below 20 kHz
%- find slope above 60
%- find sample size (nSamples, -8dB limit) with n>=35
%- find areas where 10% of clicks per minute remained after discrimination

clear all
close all

% input 
d1 = 'I:\';     %input directory name

d2 = 'I:\';     %input directory name

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
    peakFrMAll=[];
    F0MAll=[];
    durMAll=[];
    slopeMAll=[];
    nSamplesMAll=[];
    rawDurAll=[];
    rawStartAll=[];
    
    B=num2str(size(matNames,1));
    
    for a=1:size(matNames,1)
        
        load(matNames(a,:))
        %count detected number of clicks per 75s segment
        seg=[];
        peakFrM=[];
        F0M=[];
        durM=[];
        slopeM=[];
        nSamplesM=[];
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
        end
                
        %eliminate all clicks with peak frequency below 20 kHz
        lowPeak=find(peakFr<20);
        F0(lowPeak)=[];
        dur(lowPeak)=[];
        nSamples(lowPeak)=[];
        peakFr(lowPeak)=[];
        pos(lowPeak,:)=[];
        slope(lowPeak,:)=[];

        %remove slope below 60
        lowSlope=find(slope(:,1)<60);
        F0(lowSlope)=[];
        dur(lowSlope)=[];
        nSamples(lowSlope)=[];
        peakFr(lowSlope)=[];
        pos(lowSlope,:)=[];
        slope(lowSlope,:)=[];

        %remove short duration samples (nSamples, -8dB limit) n<40
        lowDur=find(nSamples<40);
        F0(lowDur)=[];
        dur(lowDur)=[];
        nSamples(lowDur)=[];
        peakFr(lowDur)=[];
        pos(lowDur,:)=[];
        slope(lowDur,:)=[];

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
        
        disp(['clicks of file ',num2str(a),' out of ',B,' extracted']);
    end

    seq = strfind(matDir, '\');
    newMatFile = (['..\..\beaked_whale_stats\',matDir(seq(1)+1:end-1),'.mat']);
    save(newMatFile,'peakFrMAll','F0MAll','durMAll','slopeMAll','segAll',...
        'nSamplesMAll','rawDurAll','rawStartAll');

    disp(['clicks of disk ',matDir(seq+1:end),' saved']);
end
%%%%%%%%%%%%%%%%%%%%%%
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
%pull out beaked whale sequences
%calculateRangeSlopeSamples.m

%delete segments where less than 10% were kept
lowSeg=find(segAll(:,3)<0.1);
segAll(lowSeg,:)=[];
rawStartAll(lowSeg,:)=[];
% rangeNSamplesAll(lowSeg,:)=[];
% rangeSlopeAll(lowSeg,:)=[];

%delete segments where no clicks were detected
notaN=isnan(segAll(:,3));
not=find(notaN==1);
segAll(not,:)=[];
rawStartAll(not,:)=[];
% rangeNSamplesAll(not,:)=[];
% rangeSlopeAll(not,:)=[];

%delete segments with <=5 clicks detected
lowCount=find(segAll(:,1)<=5);
segAll(lowCount,:)=[];
rawStartAll(lowCount,:)=[];
% rangeNSamplesAll(lowCount,:)=[];
% rangeSlopeAll(lowCount,:)=[];



