%Analyze HARP files, plot histograms

%for analysis of only first 2000 clicks
durAll=durAll(1:2000);
posAll=posAll(1:2000,:);
ici=ici(1:2000);

%delete clipped clicks out of analysis, (=clippedAmp)
peakFr(clippedAmp)=[];
F0(clippedAmp)=[];
durAll(clippedAmp)=[];
bw3db(clippedAmp,:)=[];
bw10db(clippedAmp,:)=[];
Ppp(clippedAmp)=[];
PppNoise(clippedAmp)=[];
sigNoise(clippedAmp)=[];
posAll(clippedAmp,:)=[];
ici(clippedAmp)=[];
nSamples(clippedAmp)=[];
rmsBandw(clippedAmp)=[];
rmsDuration(clippedAmp)=[];
slope(clippedAmp,:)=[];
specClickTf(clippedAmp,:)=[];
specNoiseTf(clippedAmp,:)=[];
t0(clippedAmp)=[];
timeBandw(clippedAmp)=[];
yFiltAll(clippedAmp,:)=[];
yNFiltAll(clippedAmp,:)=[];

%look at clicks with peak frequency <20 kHz / delete them from data
lowPeak=find(peakFrTotal<5);

peakFrTotal(lowPeak)=[];
F0Total(lowPeak)=[];
durTotal(lowPeak)=[];
bw3dbTotal(lowPeak,:)=[];
bw10dbTotal(lowPeak,:)=[];
ppSignalTotal(lowPeak)=[];
rmsNoiseTotal(lowPeak)=[];
rmsSignalTotal(lowPeak)=[];
snrTotal(lowPeak)=[];
posTotal(lowPeak,:)=[];
nSamplesTotal(lowPeak)=[];
slopeTotal(lowPeak,:)=[];
specClickTfTotal(lowPeak,:)=[];
specNoiseTfTotal(lowPeak,:)=[];
yFiltTotal(lowPeak,:)=[];
yNFiltTotal(lowPeak,:)=[];

iciTotal = [];
posTotal1=[posTotal(:,1);0];
posTotal2=[0;posTotal(:,1)];
iciTotal=posTotal1(2:end-1)-posTotal2(2:end-1);
iciTotal=iciTotal*1000; %inter-click interval in ms

%find all clicks with -10dB bandwidth within 90th percentile of echosounder 
%clicks (= 4 kHz) and calculate distribution
lowBw=find(bw10db(:,3)<4);
allClicks=(1:length(peakFr));
highClicks = setdiff(allClicks, lowBw);

peakFr(highClicks)=[];
F0(highClicks)=[];
durAll(highClicks)=[];
bw3db(highClicks,:)=[];
bw10db(highClicks,:)=[];
Ppp(highClicks)=[];
PppNoise(highClicks)=[];
sigNoise(highClicks)=[];
posAll(highClicks,:)=[];
ici(highClicks)=[];
nSamples(highClicks)=[];
rmsBandw(highClicks)=[];
rmsDuration(highClicks)=[];
slope(highClicks,:)=[];
specClickTf(highClicks,:)=[];
specNoiseTf(highClicks,:)=[];
t0(highClicks)=[];
timeBandw(highClicks)=[];
yFiltAll(highClicks,:)=[];
yNFiltAll(highClicks,:)=[];


N=512;
fs=200000;

%peak frequency
vec=0:(fs/2000)/(N/2-1):fs/2000;
% histPeak = histc(peakFrTotal,vec);
hist(peakFrTotal,vec)
xlim([0 100])
% ylim([0 20])
xlabel('peak frequency (kHz)')
ylabel('counts')

vec=0:(fs/2000)/(N/2-1):fs/2000;
% histCtr = histc(F0,vec);
hist(F0Total,vec)
xlim([0 100])
xlabel('center frequency (kHz)')
ylabel('counts')

% vec=0:0.1:10;
% histCtr = histc(durAll,vec);
% hist(durAll,vec)
% xlim([0 10])
% xlabel('duration (ms)')
% ylabel('counts')

vec=0:0.01:2;
% histCtr = histc(dur,vec);
hist(durTotal,vec)
xlim([0 2])
xlabel('duration (ms)')
ylabel('counts')

vec=0:10:1000;
% histCtr = histc(ici,vec);
hist(iciTotal,vec)
xlim([0 1000])
xlabel('inter-click interval (ms)')
ylabel('counts')

% vec=0:1:300;
% histCtr = histc(ici,vec);
% hist(ici,vec)
% xlim([0 100])
% xlabel('inter-click interval (ms)')
% ylabel('counts')

vec=0:(fs/2000)/(N/2-1):fs/2000;
% histCtr = histc(bw3db(:,3),vec);
hist(bw3dbTotal(:,3),vec)
xlim([0 50])
xlabel('-3dB bandwidth (kHz)')
ylabel('counts')

% vec=0:(fs/2000)/(N/2-1):fs/2000;
% histCtr = histc(bw3db(:,3),vec);
% hist(bw3db(:,3),vec)
% xlim([0 20])
% xlabel('-3dB bandwidth (kHz)')
% ylabel('counts')

vec=0:(fs/2000)/(N/2-1):fs/2000;
% histCtr = histc(bw10db(:,3),vec);
hist(bw10dbTotal(:,3),vec)
xlim([0 100])
xlabel('-10dB bandwidth (kHz)')
ylabel('counts')

% hist(bw10db(:,3),vec)
% xlim([0 20])
% xlabel('-10dB bandwidth (kHz)')
% ylabel('counts')

vec=80:1:200;
% histCtr = histc(ppSignal,vec);
hist(ppSignalTotal,vec)
xlim([120 200])
xlabel('received level signal (dB re 1uPa (pp))')
ylabel('counts')

vec=-40:1:60;
% histCtr = histc(snr,vec);
hist(snrTotal,vec)
xlim([-20 50])
xlabel('signal to noise ratio')
ylabel('counts')

