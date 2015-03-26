%get rid of noisy data
peakEcho = find(peakFr > 28 & peakFr <32);

F0(peakEcho) = [];
bw10db(peakEcho,:) = [];
bw3db(peakEcho,:) = [];
dur(peakEcho) = [];
nSamples(peakEcho) = [];
peakFr(peakEcho) = [];
pos(peakEcho,:) = [];
ppSignal(peakEcho) = [];
rmsNoise(peakEcho) = [];
rmsSignal(peakEcho) = [];
slope(peakEcho,:) = [];
snr(peakEcho) = [];
specClickTf(peakEcho,:) = [];
specNoiseTf(peakEcho,:) = [];
yFilt(peakEcho,:) = [];
yNFilt(peakEcho,:) = [];

peakEcho = peakEcho-1;
ici(peakEcho) = [];

%%%%%%%%%%
%remove long duration
longDur = find(dur > 400);

F0(longDur) = [];
bw10db(longDur,:) = [];
bw3db(longDur,:) = [];
dur(longDur) = [];
nSamples(longDur) = [];
peakFr(longDur) = [];
pos(longDur,:) = [];
ppSignal(longDur) = [];
rmsNoise(longDur) = [];
rmsSignal(longDur) = [];
slope(longDur,:) = [];
snr(longDur) = [];
specClickTf(longDur,:) = [];
specNoiseTf(longDur,:) = [];
yFilt(longDur,:) = [];
yNFilt(longDur,:) = [];

longDur = longDur-1;
ici(longDur) = [];

%insert file name - copy paste
filename = 'Hawaii03_DL15_080715_173115_1.mat';
%cd into directory where files should be saved
save(filename,'F0','bw10db','bw3db','dur','nSamples','peakFr','pos',...
'ppSignal','rmsNoise','rmsSignal','slope','snr','specClickTf',...
'specNoiseTf','yFilt','yNFilt','ici','fs','rawDur','rawStart','offset');
