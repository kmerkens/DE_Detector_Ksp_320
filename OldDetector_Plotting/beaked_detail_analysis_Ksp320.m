function [meanSpecClick,medianValue,clickCount,maxRL,seqIdent,params,binValues] = ...
            beaked_detail_analysis(fullLabels,start,fend,GraphDir,binArray)

% 3) calculate graphs and store mean spectras for overlaying per xls sheet

% sbp 5/3/2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
peakFrSel = [];
F0Sel = [];
posSel =[];
posDateSel = [];
ppSignalSel = [];
specClickSel = [];
specNoiseSel = [];
yFiltSel = [];
clickCountSel = [];

%find which 5 minute bins are within the detection sequence
binStart = find(binArray < start);
binStart = binStart(end);
binEnd = find(binArray > fend);
binEnd = binEnd(1)-1;

binIdx = binStart:1:binEnd;
bin = datenum([0 0 0 0 5 0]);

%check which mat files have the same timing info
matNames = [];
for f = 1:length(fullLabels)
    [pathstr name ext] = fileparts(fullLabels{f});
    pathstr = strrep(pathstr,'metadata','click_params');
    d = dir(fullfile(pathstr,'*.mat'));
    matNamesAll = char(d.name);
    for m = 1:size(matNamesAll,1)
        comp = strfind(matNamesAll(m,:),name);
        if ~isempty(comp)
            matNames = [matNames; char(matNamesAll(m,:))];
        end
    end
end

for f = 1:size(matNames,1)
    %load each mat file of fIdx and check 
    load(fullfile(pathstr,matNames(f,:)));
    rawStartNum = datenum(rawStart);
    segStart = find(rawStartNum<start);
    if isempty(segStart)
        segStart = 1;
    end
    segEnd = find(rawStartNum>fend);

    if isempty(segEnd)
        segEnd = length(rawStartNum);
    else
        segEnd = segEnd(1)-1;
    end

    segIdx = [segStart(end):segEnd];

    for s=1:length(segIdx)
        segStartSec=(segIdx(s)-1)*rawDur(segIdx(s));
        segEndSec=segIdx(s)*rawDur(segIdx(s))-1*10^-20;
        posIdx=[];
        posIdx=find(pos(:,1)>segStartSec & pos(:,1)<segEndSec);
        if ~isempty(posIdx)
            %convert positions in dates
            segDate = datenum(rawStart(segIdx(s),:));
            secInFile = sum(rawDur(1:segIdx(s)-1));
            posSeg = pos(posIdx(1):posIdx(end),:);
            posSeg = posSeg - secInFile;
            
            clear posDate
            for didx = 1:size(posSeg,1)
                posDate(didx,1) = segDate + datenum([0 0 0 0 0 posSeg(didx,1)]);
                posDate(didx,2) = segDate + datenum([0 0 0 0 0 posSeg(didx,2)]);
            end
                        
            peakFrSel = [peakFrSel; peakFr(posIdx(1):posIdx(end))];
            F0Sel = [F0Sel; F0(posIdx(1):posIdx(end))];
            posSel = [posSel; pos(posIdx(1):posIdx(end),:)];
            posDateSel = [posDateSel; posDate];
            ppSignalSel = [ppSignalSel; ppSignal(posIdx(1):posIdx(end))];
            specClickSel = [specClickSel; specClickTf(posIdx(1):posIdx(end),:)];
            specNoiseSel = [specNoiseSel; specNoiseTf(posIdx(1):posIdx(end),:)];
            yFiltSel = [yFiltSel; yFilt(posIdx(1):posIdx(end),:)];
            if isempty(length(posIdx))
                click = NaN;
            else
                click = length(posIdx);
            end
            clickCountSel = [clickCountSel; click];
        end
    end
end

if ~isempty(posSel)

    %calculate duration and inter-pulse interval of selected clicks
    durSel = (posSel(:,2)-posSel(:,1))*1000*1000; %duration in us

    pos1=[posSel(:,1);0];
    pos2=[0;posSel(:,1)];
    iciSel=pos1(2:end-1)-pos2(2:end-1);
    iciSel=iciSel*1000; %inter-click interval in ms

    %delete ici not relevant to real ici
    delIci=find(iciSel>50 & iciSel<1000);
    iciAdj=iciSel(delIci);

    %calculate medians;
    params = {'median peak frequency (kHz)','median ipi (ms)',...
        'median duration (us)','median received level (dB re 1 uPa)',...
        'median center frequency (kHz)'};
    medianValue(1) = prctile(peakFrSel,50);%calculate median peak frequency
    medianValue(2) = prctile(iciAdj,50);%calculate median inter-pulse interval
    medianValue(3) = prctile(durSel,50);%calculate median duration
    medianValue(4) = prctile(ppSignalSel,50);%calculate median inter-pulse interval
    medianValue(5) = prctile(F0Sel,50);%calculate median inter-pulse interval
    clickCount = sum(clickCountSel);%count number of clicks in analysis
    maxRL = max(ppSignalSel);
    
    for b = 1:length(binIdx)
      	clIdx = find(posDateSel(:,1) >= binArray(binIdx(b)) & ...
            posDateSel(:,1) < (binArray(binIdx(b)) + bin));
        
       if ~isempty(clIdx)
            pos1=[posSel(clIdx,1);0];
            pos2=[0;posSel(clIdx,1)];
            iciBin=pos1(2:end-1)-pos2(2:end-1);
            iciBin=iciBin*1000; %inter-click interval in ms

            %delete ici not relevant to real ici
            delIci=find(iciBin>50 & iciBin<1000);
            iciAdj=iciBin(delIci);
        
            binValues(b).medianValue(1) = prctile(peakFrSel(clIdx),50);%calculate median peak frequency
            binValues(b).medianValue(2) = prctile(iciAdj,50);%calculate median inter-pulse interval
            binValues(b).medianValue(3) = prctile(durSel(clIdx),50);%calculate median duration
            binValues(b).medianValue(4) = prctile(ppSignalSel(clIdx),50);%calculate median inter-pulse interval
            binValues(b).medianValue(5) = prctile(F0Sel(clIdx),50);%calculate median inter-pulse interval
            binValues(b).clickCount = length(clIdx);%count number of clicks in analysis
            binValues(b).maxRL = max(ppSignalSel);
       end
    end
    
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %plot graphs and save

    %sort spectras for peak frequency and prepare for plotting concetanated
    %spectrogram
    [a b]=sort(peakFrSel);

    specSorted=[];
    for c=1:length(b)
        specSorted(c,:)=specClickSel(b(c),:);
    end
    specSorted=specSorted.';

    N=size(specSorted,1)*2;
    f=0:(fs/2000)/(N/2-1):fs/2000;
    datarow=size(specSorted,2);

    %calculate mean spectra for click and noise
    meanSpecClick=mean(specClickSel);
    meanSpecNoise=mean(specNoiseSel);
    
    sep = strfind(pathstr,'\');
    disk = pathstr(sep(2)+1:length(pathstr));

    figure('Name', sprintf('%s %s', disk, datestr(start)),...
         'Position',([0,0,1200,800]))

    subplot(2, 2, 1);
    vec=0:1:160;
    hist(peakFrSel,vec)
    xlim([0 100])
    xlabel('peak frequency (kHz)')
    ylabel('counts')
    text(0.5,0.9,['pfr =',num2str(medianValue(1)),' kHz'],'Unit','normalized')
    text(0.5,0.8,['cfr =',num2str(medianValue(5)),' kHz'],'Unit','normalized')

    subplot(2,2,2)
    vec=0:10:1000;
    hist(iciAdj,vec)
    xlim([0 1000])
    xlabel('inter-pulse interval (ms)')
    ylabel('counts')
    text(0.5,0.9,['dur =',num2str(medianValue(3)),' us'],'Unit','normalized')
    text(0.5,0.8,['ipi =',num2str(medianValue(2)),' ms'],'Unit','normalized')

    subplot(2,2,3)
    plot(f,meanSpecClick,'LineWidth',2), hold on
    plot(f,meanSpecNoise,':k','LineWidth',2), hold off
    xlabel('Frequency (kHz)'), ylabel('Normalized amplitude (dB)')
    ylim([50 110])
    xlim([0 160])
    title(['Mean click spectra, n=',num2str(size(specClickSel,1))],'FontWeight','bold')
    text(0.5,0.9,['ppRL =',num2str(medianValue(4))],'Unit','normalized')

    subplot(2,2,4)
    imagesc(1:datarow, f, specSorted); axis xy; colormap(gray)
    xlabel('Click number'), ylabel('Frequency (kHz)')
    title(['Clicks sorted by peak frequency'],'FontWeight','bold')

    seqIdent = sprintf('%s_%s', disk, datestr(start,30));
    filename = fullfile(GraphDir,seqIdent);
    saveas(gca, filename, 'jpg')

    close
else
    sep = strfind(pathstr,'\');
    disk = pathstr(sep(2)+1:length(pathstr));
    seqIdent = sprintf('%s_%s', disk, datestr(start,30));
    
    params = {'median peak frequency (kHz)','median ipi (ms)',...
    'median duration (us)','median received level (dB re 1 uPa)',...
    'median center frequency (kHz)'};
    
    fileEmpty = fullfile(GraphDir,[sprintf('%s_%s%s', disk, datestr(start,30),'_noDetections.txt')]);
    fid = fopen(fileEmpty,'w+');
    fprintf(fid,'%s','End time possibly on next disk');
    fclose(fid);

    medianValue(1:5) = NaN;
    meanSpecClick(1:256) = NaN;
    binValues.medianValue(5) = NaN;
    binValues.clickCount = NaN;
    binValues.maxRL = NaN;
    clickCount = 0;
    maxRL = NaN;
end

