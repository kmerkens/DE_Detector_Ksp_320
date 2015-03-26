function [yFiltClick, yNFiltClick]=extracFilterTimeseries ...
    (wavFile,clickStart,a,n,fs,offset)

clSamples=round(clickStart*fs);

% start 200 samples before calculated start
s=clSamples(n)-(offset+1);

% end 512 samples after start, + xx extra
e=s+799;

% start 1050 samples before calculated start for noise samples
sN=clSamples(n)-1050;
eN=clSamples(n);

%get 700 click samples
y = wavread(wavFile,[s e]);
y=y(:,1); %picks channel 1
y = y.';

%get 1050 noise
yN = wavread(wavFile,[sN eN]);
yN=yN(:,1);
yN = yN.';

% bandpass filter y and yN
Fc1 = 5000;   % First Cutoff Frequency
if fs<=320000;
    Fc2 = 155000;  % Second Cutoff Frequency
else
    Fc2=320000;
end
N = 10;     % Order
[B,A] = butter(N/2, [Fc1 Fc2]/(fs/2)); 
yFiltClick = filtfilt(B,A,y); %filter click
yNFiltClick = filtfilt(B,A,yN); %filter noise before click

