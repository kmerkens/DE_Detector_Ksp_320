%calculate median, quartiles and 90th-percentile
p=[0 10 25 50 75 90 100];
prcPeak = prctile(peakFr,p);

%compare with mean
meanPeak = mean(x);
stdPeak = std(x);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot histogram
vecHour=0:1:23;
hist(hour,vecHour)
% xlim([0 23])
xlabel('Time of day (GMT hour)')
ylabel('counts')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%scatter plot
scatter(x,y,'filled','k','sizedata',20)
% hold on
% plot(hour,thr)
% hold off
% xlim([0 23])
xlabel('time of day (GMT Time)')
ylabel('median peak frequency [kHz] per 75 s segment')
% ylim([20 55])
title('Median peak frequency of all segments with MHW whistles over time of day')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot concatenated spectrogram of all clicks sorted by peak frequency
%sort peak frequency and accordingly specTf
[a b]=sort(peakFr);

specClickTfSorted=[];
for i=1:length(b)
    specClickTfSorted(i,:)=specClickTf(b(i),:);
end

%Normalize to between 0 and 1 and plot (from MSS, Gram_Mean.m, 070201)
specClickTfSorted=specClickTfSorted.';

N=size(specClickTf,2)*2;
f=0:(fs/2000)/(N/2-1):fs/2000;
disk=input('What disk are you plotting? ','s');
FS=fs/1000;
FS=num2str(FS);

% NormData=[];
% LowBin = 10;
datarow=size(specClickTfSorted,2);
% for cc=1:datarow
%     NormData(:,cc)=specClickTfSorted(:,cc)-min(specClickTfSorted(:,cc));
%     NormData(:,cc)=NormData(:,cc)./max(NormData(LowBin:end,cc));
% end
% 
% % % Calculate and display spectrogram of all normalized clicks
% figure(1), imagesc(1:datarow, f, NormData); axis xy; colormap(blue)
% xlabel('Click number'), ylabel('Frequency (kHz)')
% title([disk,' - normalized clicks sorted by peak frequency'],'FontWeight','bold')
% 
% %plot data not normalized
% NormData=specClickTfSorted;

figure(2), imagesc(1:datarow, f, specClickTfSorted); axis xy; colormap(blue)
xlabel('Click number'), ylabel('Frequency (kHz)')
title([disk,' - clicks sorted by peak frequency'],'FontWeight','bold')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot mean spectra
f=0:(fs/2000)/(N/2-1):fs/2000;

meanSpecClick=mean(specClickTf);
meanSpecNoise=mean(specNoiseTf)-4;

plot(f,meanSpecClick,'LineWidth',2), hold on
plot(f,meanSpecNoise,':k','LineWidth',2), hold off
xlabel('Frequency (kHz)'), ylabel('Normalized amplitude (dB)')
ylim([60 100])
xlim([0 100])
title([disk,' - normalized mean click spectra, n=',...
    num2str(size(specClickTf,1))],'FontWeight','bold')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot mean spectra
%pick only a certain peak frequency range to calculate mean
%range 30 to 45 kHz peakFr
low=find(a>5 & a<28);
%range 45 6o 70 kHz peakFr
high=find(a>28 & a<100);

%normalize by setting peak frequency to zero
% disk=input('What disk are you plotting? ','s');
f=0:(fs/2000)/(N/2-1):fs/2000;

specClickTf=specClickTf.';
[val pos]=max(specClickTf(14:end,:));
specClickTf=specClickTf.';

pos=pos+13;

specClickTfNorm=[];
for i=1:size(specClickTf,1)
    specClickTfNorm(i,:)=specClickTf(i,:)-val(i);
end

meanSpecClickLow=mean(specClickTfNorm(low(1:end),:));
meanSpecClickHigh=mean(specClickTfNorm(high(1:end),:));

%plot mean spectra low
subplot(2,1,1), plot(f,meanSpecClickLow,'LineWidth',2)
xlabel('Frequency (kHz)'), ylabel('Normalized amplitude (dB)')
ylim([-40 0]),xlim([0 100])
title([disk,' - normalized mean click spectra, f range 5-28 kHz, n=',...
    num2str(size(low,1))],'FontWeight','bold')

%plot mean spectra high
subplot(2,1,2), plot(f,meanSpecClickHigh,'LineWidth',2)
xlabel('Frequency (kHz)'), ylabel('Normalized amplitude (dB)')
ylim([-40 0]),xlim([0 100])
title([disk,' - normalized mean click spectra, f range 28-100 kHz, n=',...
    num2str(size(high,1))],'FontWeight','bold')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot mean spectra
%pick only a certain inter-click interval to calculate mean
[e f]=sort(ici);

%range 30 to 300 ms ici
low=find(e>30 & e<300);
%range 300 to 700 ms ici
high=find(e>300 & e<700);

%normalize by setting peak frequency to zero
% disk=input('What disk are you plotting? ','s');

specClickTf=specClickTf.';
[val pos]=max(specClickTf(14:end,:));
specClickTf=specClickTf.';

pos=pos+13;

specClickTfIciNorm=[];
for i=1:size(specClickTf,1)
    specClickTfIciNorm(i,:)=specClickTf(i,:)-val(i);
end

specClickTfIciSorted=[];
for i=1:length(f)
    specClickTfIciSorted(i,:)=specClickTfIciNorm(f(i),:);
end

meanSpecClickLow=mean(specClickTfIciSorted(low(1:end),:));
meanSpecClickHigh=mean(specClickTfIciSorted(high(1:end),:));

%plot mean spectra low
f=0:(fs/2000)/(N/2-1):fs/2000;

subplot(2,1,2), plot(f,meanSpecClickLow,'LineWidth',2)
xlabel('Frequency (kHz)'), ylabel('Normalized amplitude (dB)')
ylim([-40 0]),xlim([0 100])
title([disk,' - normalized mean click spectra, ici range 30-300 ms, n=',...
    num2str(size(low,1))],'FontWeight','bold')

%plot mean spectra high
subplot(2,1,1), plot(f,meanSpecClickHigh,'LineWidth',2)
xlabel('Frequency (kHz)'), ylabel('Normalized amplitude (dB)')
ylim([-40 0]),xlim([0 100])
title([disk,' - normalized mean click spectra, f range 300-700 ms, n=',...
    num2str(size(high,1))],'FontWeight','bold')




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot timeseries and spectrogram of a good example click
%sort high amplitude clicks
[c d]=sort(ppSignal,'descend');

yFiltClickSorted=[];
for i=1:length(d)
    yFiltClickSorted(i,:)=yFilt(d(i),:);
end

%plot spectra
f=0:(fs/2000)/(N/2-1):fs/2000;
s=101;
e=500;
dd=e-s+1;
t=0:(dd/(fs/1000))/(dd-1):dd/(fs/1000);

for i=1:size(yFiltClickSorted,1)
    [Y,F,T,P] = spectrogram(yFiltClickSorted(i,(s:e)),40,39,40,fs);
    T = T*1000;
    F = F/1000;
    
    subplot(2,1,1), plot(t,yFiltClickSorted(i,(s:e)),'k')
    ylabel('Amplitude [counts]','fontsize',10,'fontweight','b')

    subplot(2,1,2), surf(T,F,10*log10(abs(P)),'EdgeColor','none');
    axis xy; axis tight; colormap(blue); view(0,90);
    xlabel('Time [ms]','fontsize',10,'fontweight','b')
    ylabel('Frequency [kHz]','fontsize',10,'fontweight','b');
    pause
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot timeseries and spectrogram of a good example click
%sort high amplitude clicks of a certain peak frequency range

yFiltLow=yFiltAll(low(1:end),:);
yFiltHigh=yFiltAll(high(1:end),:);

ppSignalLow=ppSignal(low(1:end));
ppSignalHigh=ppSignal(high(1:end));

[g h]=sort(ppSignalLow,'descend');
[k l]=sort(ppSignalHigh,'descend');

yFiltLowSorted=[];
yFiltHighSorted=[];
for i=1:length(h)
    yFiltLowSorted(i,:)=yFiltLow(h(i),:);
end

for i=1:length(l)
     yFiltHighSorted(i,:)=yFiltHigh(l(i),:);
end

%plot spectra
f=0:(fs/2000)/(N/2-1):fs/2000;
s=101;
e=500;
dd=e-s+1;
t=0:(dd/(fs/1000))/(dd-1):dd/(fs/1000);

for i=1:length(h)
    [Y,F,T,P] = spectrogram(yFiltLowSorted(i,(s:e)),40,39,40,fs);
    T = T*1000;
    F = F/1000;
    
    subplot(2,1,1), plot(t,yFiltLowSorted(i,(s:e)),'k')
    ylabel('Amplitude [counts]','fontsize',10,'fontweight','b')

    subplot(2,1,2), surf(T,F,10*log10(abs(P)),'EdgeColor','none');
    axis xy; axis tight; colormap(blue); view(0,90);
    xlabel('Time [ms]','fontsize',10,'fontweight','b')
    ylabel('Frequency [kHz]','fontsize',10,'fontweight','b');
    pause
end

for i=1:length(l)
    [Y,F,T,P] = spectrogram(yFiltHighSorted(i,(s:e)),40,39,40,fs);
    T = T*1000;
    F = F/1000;
    
    subplot(2,1,1), plot(t,yFiltHighSorted(i,(s:e)),'k')
    ylabel('Amplitude [counts]','fontsize',10,'fontweight','b')

    subplot(2,1,2), surf(T,F,10*log10(abs(P)),'EdgeColor','none');
    axis xy; axis tight; colormap(blue); view(0,90);
    xlabel('Time [ms]','fontsize',10,'fontweight','b')
    ylabel('Frequency [kHz]','fontsize',10,'fontweight','b');
    pause
end
