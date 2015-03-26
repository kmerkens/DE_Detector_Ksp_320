

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot concatenated spectrogram of all clicks sorted by peak frequency
%sort peak frequency and accordingly specTf
[a b]=sort(peakFAll);

specTfAllSorted=[];
for i=1:length(b)
    specTfAllSorted(i,:)=specTfAll(b(i),:);
end

%Normalize to between 0 and 1 and plot (from MSS, Gram_Mean.m, 070201)
specTfAllSorted=specTfAllSorted.';

N=size(specTfAll,2)*2;
f=0:(fs/2000)/(N/2-1):fs/2000;
disk=input('What disk are you plotting? ','s');
FS=fs/1000;
FS=num2str(FS);

% NormData=[];
% LowBin = 10;
datarow=size(specTfAllSorted,2);
% for cc=1:datarow
%     NormData(:,cc)=specTfAllSorted(:,cc)-min(specTfAllSorted(:,cc));
%     NormData(:,cc)=NormData(:,cc)./max(NormData(LowBin:end,cc));
% end
% 
% % % Calculate and display spectrogram of all normalized clicks
% figure(1), imagesc(1:datarow, f, NormData); axis xy; colormap(blue)
% xlabel('Click number'), ylabel('Frequency (kHz)')
% title([disk,' - normalized clicks sorted by peak frequency'],'FontWeight','bold')
% 
% %plot data not normalized
% NormData=specTfAllSorted;

figure(2), imagesc(1:datarow, f, specTfAllSorted); axis xy; colormap(gray)
xlabel('Click number'), ylabel('Frequency (kHz)')
title([disk,' - clicks sorted by peak frequency'],'FontWeight','bold')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot mean spectra
f=0:(fs/2000)/(N/2-1):fs/2000;

meanSpecClick=mean(specClickTfTotal);
meanSpecNoise=mean(specNoiseTfTotal)-3;

plot(f,meanSpecClick,'LineWidth',2), hold on
plot(f,meanSpecNoise,':k','LineWidth',2), hold off
xlabel('Frequency (kHz)'), ylabel('Normalized amplitude (dB)')
ylim([55 95])
xlim([0 100])
title([disk,' - normalized mean click spectra, n=',...
    num2str(size(specTfAll,1))],'FontWeight','bold')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot timeseries and spectrogram of a good example click
%sort high amplitude clicks
[c d]=sort(PppAll,'descend');

tsFiltAllClickSorted=[];
for i=1:length(d)
    tsFiltAllClickSorted(i,:)=tsFiltAll(d(i),:);
end

%plot spectra
f=0:(fs/2000)/(N/2-1):fs/2000;
s=57;
e=456;
dd=e-s+1;
t=0:(dd/(fs/1000))/(dd-1):dd/(fs/1000);

for i=1:size(tsFiltAllClickSorted,1)
    [Y,F,T,P] = spectrogram(tsFiltAllClickSorted(i,(s:e)),40,39,40,fs);
    T = T*1000;
    F = F/1000;
    
    subplot(2,1,1), plot(t,tsFiltAllClickSorted(i,(s:e)),'k')
    ylabel('Amplitude [counts]','fontsize',10,'fontweight','b')
    xlim([0.1 1.9])

    subplot(2,1,2), surf(T,F,10*log10(abs(P)),'EdgeColor','none');
    axis xy; axis tight; colormap(blue); view(0,90);
    xlabel('Time [ms]','fontsize',10,'fontweight','b')
    ylabel('Frequency [kHz]','fontsize',10,'fontweight','b');
    title(['Click number ',num2str(i)])
    pause
end

%%%%%%%%%%%%%%
%scatter plot
scatter(peakFrTotal,ppSignalTotal,'filled','k','sizedata',20)
% xlim([0 23])
xlabel('peak frequency (kHz)')
ylabel('received level (dB)')
% ylim([20 55])
title('Received level over peak frequency of all clicks')

%%%%%%%%%%%%%
%1D mixture model with 3 mixtures
Info.MaximumIterations = 15;
m = hmmCreateModel(1,3,peakFrTotal,Info,'Verbosity',1); 
figure; visGMM1d(m,peakFrTotal,50)