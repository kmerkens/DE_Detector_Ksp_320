%Analyze HARP files, plot histograms

%look at clicks with peak frequency >20 kHz / delete low clicks from data
lowPeak=find(peakFr<20);

peakFr(lowPeak)=[];
F0(lowPeak)=[];
durAll(lowPeak)=[];
bw3db(lowPeak,:)=[];
bw10db(lowPeak,:)=[];
Ppp(lowPeak)=[];
PppNoise(lowPeak)=[];
sigNoise(lowPeak)=[];
posAll(lowPeak,:)=[];
ici(lowPeak)=[];
nSamples(lowPeak)=[];
rmsBandw(lowPeak)=[];
rmsDuration(lowPeak)=[];
slope(lowPeak,:)=[];
specClickTf(lowPeak,:)=[];
specNoiseTf(lowPeak,:)=[];
t0(lowPeak)=[];
timeBandw(lowPeak)=[];
yFiltAll(lowPeak,:)=[];
yNFiltAll(lowPeak,:)=[];

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

