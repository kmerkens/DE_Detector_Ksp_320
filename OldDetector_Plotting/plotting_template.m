%Analyze HARP files, plot histograms

%look at clicks with peak frequency >20 kHz / delete low clicks from data
lowPeak=find(peakFr<20);

peakFr(lowPeak)=[];
F0(lowPeak)=[];
dur(lowPeak)=[];
bw3db(lowPeak,:)=[];
bw10db(lowPeak,:)=[];
ppSignal(lowPeak)=[];
rmsSignal(lowPeak)=[];
rmsNoise(lowPeak)=[];
snr(lowPeak)=[];
pos(lowPeak,:)=[];
nSamples(lowPeak)=[];
slope(lowPeak,:)=[];
specClickTf(lowPeak,:)=[];
specNoiseTf(lowPeak,:)=[];
yFilt(lowPeak,:)=[];
yNFilt(lowPeak,:)=[];

pos1=[pos(:,1);0];
pos2=[0;pos(:,1)];
ici=pos1(2:end-1)-pos2(2:end-1);
ici=ici*1000; %inter-click interval in ms

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N=512;
fs=200000;

%peak frequency
vec=0:(fs/2000)/(N/2-1):fs/2000;
histPeak = histc(peakFr,vec);
hist(peakFr,vec)
xlim([0 100])
% ylim([0 20])
xlabel('peak frequency (kHz)')
ylabel('counts')

vec=0:(fs/2000)/(N/2-1):fs/2000;
histCtr = histc(F0,vec);
hist(F0,vec)
xlim([0 100])
xlabel('center frequency (kHz)')
ylabel('counts')

vec=0:0.01:2;
histCtr = histc(dur,vec);
hist(dur,vec)
xlim([0 2])
xlabel('duration (ms)')
ylabel('counts')

vec=0:10:1000;
histCtr = histc(ici,vec);
hist(ici,vec)
xlim([0 1000])
xlabel('inter-click interval (ms)')
ylabel('counts')

%delete ici not relevant to real ici
delIci=find(ici>50 & ici <700);

iciAdj=ici(delIci);

vec=0:10:1000;
histCtr = histc(iciAdj,vec);
hist(iciAdj,vec)
xlim([0 1000])
xlabel('inter-click interval (ms)')
ylabel('counts')

vec=0:(fs/2000)/(N/2-1):fs/2000;
histCtr = histc(bw3db(:,3),vec);
hist(bw3db(:,3),vec)
xlim([0 50])
xlabel('-3dB bandwidth (kHz)')
ylabel('counts')

vec=0:(fs/2000)/(N/2-1):fs/2000;
histCtr = histc(bw10db(:,3),vec);
hist(bw10db(:,3),vec)
xlim([0 100])
xlabel('-10dB bandwidth (kHz)')
ylabel('counts')

vec=80:1:200;
histCtr = histc(ppSignal,vec);
hist(ppSignal,vec)
xlim([120 200])
xlabel('received level signal (dB re 1uPa (pp))')
ylabel('counts')

vec=-40:1:60;
histCtr = histc(snr,vec);
hist(snr,vec)
xlim([-20 50])
xlabel('signal to noise ratio')
ylabel('counts')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p=[10 50 90];
prcPeak = prctile(peakFr,p);

%%%%%%%%%%%%%%
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

specClickTfSorted=specClickTfSorted.';

N=size(specClickTf,2)*2;
f=0:(fs/2000)/(N/2-1):fs/2000;
disk=input('What are you plotting? ','s');
FS=fs/1000;
FS=num2str(FS);

datarow=size(specClickTfSorted,2);

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\

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
