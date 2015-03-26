%put all clicks of one type of signal in one file for averaging

% get directory and file names of .mat files
clear all
[matNames] = get_matNames('J:\classification\all_data_for_GMM\beaked_whales\bairds_beaked_whale\mat');

F0Total=[];
ppSignalTotal=[];
bw10dbTotal=[];
bw3dbTotal=[];
durTotal=[];
iciTotal=[];
nSamplesTotal=[];
peakFrTotal=[];
posTotal=[];
rmsSignalTotal=[];
rmsNoiseTotal=[];
snrTotal=[];
slopeTotal=[];
specClickTfTotal=[];
specNoiseTfTotal=[];
yFiltTotal=[];
yNFiltTotal=[];
clickCount=[];


for a=1:size(matNames,1)
    fEnd = strfind(matNames(a,:),'.mat');
    load(matNames(a,1:fEnd+3))
    
    F0Total=[F0Total;F0];
    ppSignalTotal=[ppSignalTotal;ppSignal];
    bw10dbTotal=[bw10dbTotal;bw10db];
    bw3dbTotal=[bw3dbTotal;bw3db];
    durTotal=[durTotal;dur];
    iciTotal=[iciTotal;ici];
    nSamplesTotal=[nSamplesTotal;nSamples];
    peakFrTotal=[peakFrTotal;peakFr];
    posTotal=[posTotal;pos];
    rmsSignalTotal=[rmsSignalTotal;rmsSignal];
    rmsNoiseTotal=[rmsNoiseTotal;rmsNoise];
    snrTotal=[snrTotal;snr];
    slopeTotal=[slopeTotal;slopeo];
    specClickTfTotal=[specClickTfTotal;specClickTf];
    specNoiseTfTotal=[specNoiseTfTotal;specNoiseTf];
    yFiltTotal=[yFiltTotal;yFilt];
    yNFiltTotal=[yNFiltTotal;yNFilt];
    clickCount=[clickCount;length(peakFr)];
end

%manually define new file name
% seq = strfind(matDir, '\');
newMatFile = 'Bairds.mat';
save(newMatFile,'F0Total','ppSignalTotal','bw10dbTotal','bw3dbTotal',...
    'durTotal','iciTotal','nSamplesTotal','peakFrTotal','posTotal','rmsSignalTotal',...
    'rmsNoiseTotal','snrTotal','slopeTotal','specClickTfTotal',...
    'specNoiseTfTotal','yFiltTotal','yNFiltTotal','offset','fs',...
    'clickCount');
