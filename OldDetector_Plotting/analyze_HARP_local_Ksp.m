function analyze_HARP_local_Ksp(fullLabels,fullFiles,tfFile,tfDir)

%loads all .cTg files of a folder, takes information of
%start and end of each click, opens the corresponding wave file and saves
%all clicks of each file into one .mat file.

%detects clipped clicks, adjusts for transfer function, computes click
%paramters and finds possible slopes of pulses

%sbp 100203
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Calculate HARP click parameters')

%modify .c label files to .cTg
for f = 1:length(fullLabels)
    label = fullLabels{f};
    [pathlabel, namelabel, extlabel] = fileparts(label);
    namelabel = ([namelabel,'.cTg']);
    fullLabels{f} = fullfile(pathlabel,namelabel);
end

%compute each xwav file and its detections
for a = 1:length(fullFiles)
    %create vector of start and end times for each duty cycle
    rawStart=[];
    rawDur=[];
    file = fullFiles{a};
    [pathstr name ext] = fileparts(file);
    [rawStart,rawDur,fs] = readxwavhd([pathstr,'\'],[name,ext]);

    %load transfer function
    N=512;
    tf=[tfDir,tfFile];

    [tfFreq,tfPower] = textread(tf,'%f %f'); %load transfer function
    F=1:1:fs/2;
    Ptf = interp1(tfFreq,tfPower,F,'linear','extrap');
    PtfN = downsample(Ptf,ceil(fs/N));

    % for every .cTg file: read data
    [clStart,clEnd,clLabel] = textread(fullLabels{a},'%f %f %s');

    A=num2str(a);
    B=num2str(length(fullFiles));
    C=num2str(length(clStart));
    E=name;
    disp([C,' clicks of file ',A,'(',E,')',' out of ',B,' to be analyzed']);

    if isempty(clStart)==0

        l=length(clStart)/10000;
        l=ceil(l);
        L=num2str(l);
        for i=1:l
            I=num2str(i);
            if l==1
                clickStart=clStart(1:length(clStart));
                clickEnd=clEnd(1:length(clStart));
            else
                if i==l
                    clickStart=clStart((i-1)*10000+1:length(clStart));
                    clickEnd=clEnd((i-1)*10000+1:length(clStart));
                else
                    clickStart=clStart((i-1)*10000+1:i*10000);
                    clickEnd=clEnd((i-1)*10000+1:i*10000);
                end
            end

            %find if clickStart and clickEnd are far enough from start 
            %and end of the wavFile to extract timeseries, otherwise disgard click
            wavFile=fullFiles{a};
            [y, fs] = wavread(wavFile,[1 10]);
            siz = wavread(wavFile,'size');

            clSamples=round(clickStart*fs);

            % start 200 samples before calculated start
            offset = 200;
            n=1;
            for h=1:length(clSamples)
                % start n(offset) samples before the click
                s=clSamples(h)-(offset+1);
                % end 512 samples after start + xx extra
                e=s+799;

                % start 1050 samples before calculated click start for noise samples
                sN=clSamples(h)-1050;
                eN=clSamples(h);

                if s<=0
                    clickStart(n)=[];
                    clickEnd(n)=[];
                    n=n-1; %reduce number of clicks to one less if deleted
                end

                if sN<=0 && s>0
                    clickStart(n)=[];
                    clickEnd(n)=[];
                    n=n-1;
                end

                if e>siz(1)
                    clickStart(n)=[];
                    clickEnd(n)=[];
                    n=n-1;
                end
                n=n+1; % increment one for next click
            end

            pos=[clickStart clickEnd];
            dur=(clickEnd-clickStart)*1000; %duration in ms
            %calculate inter-click interval
            pos1=[pos(:,1);0];
            pos2=[0;pos(:,1)];
            ici=pos1(2:end-1)-pos2(2:end-1);
            ici=ici*1000; %inter-click interval in ms

            yFilt=zeros(length(clickStart),800);
            yNFilt=zeros(length(clickStart),1051);
            peakFr=zeros(length(clickStart),1);
            bw10db=zeros(length(clickStart),3);
            bw3db=zeros(length(clickStart),3);
            F0=zeros(length(clickStart),1);
            Ppp=zeros(length(clickStart),1);
            rmsSignal=zeros(length(clickStart),1);
            rmsNoise=zeros(length(clickStart),1);
            snr=zeros(length(clickStart),1);
            specClickTf=zeros(length(clickStart),N/2);
            specNoiseTf=zeros(length(clickStart),N/2);
            slope=zeros(length(clickStart),2);
            nSamples=zeros(length(clickStart),1);

            % take start of each click, extract timeseries out of wave-file   

            for n=1:length(clickStart)
                [yFiltClick, yNFiltClick]=extracFilterTimeseries ...
                    (wavFile,clickStart,a,n,fs,offset);
                if isempty(yFiltClick)==1
                    pos(n,:)=[];
                    dur(n)=[];
                    yFilt(n,:)=[];
                    yNFilt(n,:)=[];
                    peakFr(n)=[];
                    bw10db(n,:)=[];
                    bw3db(n,:)=[];
                    F0(n)=[];
                    Ppp(n)=[];
                    rmsSignal(n)=[];
                    rmsNoise(n)=[];
                    snr(n)=[];
                    specClickTf(n,:)=[];
                    specNoiseTf(n,:)=[];
                    slope(n,:)=[];
                    nSamples(n)=[];
                else
                    yFilt(n,:)=yFiltClick(1,:);
                    yNFilt(n,:)=yNFiltClick(1,:);
                end
            end

            
             %%%KPM120625 MOVED TO CALC peakfFr FIRST
            %compute spectra, add transfer function, calculate click
            %parameters
            [peakFr,bw10db,bw3db,F0,ppSignal,rmsSignal,rmsNoise,snr, ...
            specClickTf,specNoiseTf] = tfParameters(yFilt,yNFilt, ...
            dur,fs,N,PtfN);
        
            %Delete click if peakFr is below 70kHz
            deleterows = [];
            deleterows = find(peakFr <= 70);    
                 
            pos(deleterows,:) = [];
            dur(deleterows) = [];
            yFilt(deleterows,:) = [];
            yNFilt(deleterows,:) = [];
            peakFr(deleterows) = [];
            bw10db(deleterows,:) = [];
            bw3db(deleterows,:) = [];
            F0(deleterows) = [];
            ppSignal(deleterows) = [];
            rmsSignal(deleterows) = [];
            rmsNoise(deleterows) = [];
            snr(deleterows) = [];
            specClickTf(deleterows,:) = [];
            specNoiseTf(deleterows,:) = [];
            
            %to deal with ici not having top and bottom row
            if isempty(deleterows) == 1;
                ici(deleterows) = [];
            else
                if deleterows(1) == 1;
                    deleterows(1) = [];
                end
                if deleterows(end) == length(clickStart);
                   deleterows(end) = [];
                end
            end
            ici(deleterows) = [];
        

                   
            %save all extracted timeseries in file
            [pathstr name ext] = fileparts(fullLabels{a});
            pathstr = strrep(pathstr,'metadata','click_params');
%             pathstr = strrep(pathstr,'G:\','G:\click_params\');
            newMatFile = fullfile(pathstr,[name,'_',num2str(i),'.mat']);
            save(newMatFile,'pos','dur','ici','yFilt','yNFilt','fs','rawStart','rawDur','offset');

            save(newMatFile,'peakFr','bw10db','bw3db','F0','ppSignal', ...
                'rmsSignal','rmsNoise','snr','specClickTf','specNoiseTf','-append');

            %compute slope to find potential beaked whale pulses
            [slope,nSamples] = specFit(yFilt,fs);
            save(newMatFile,'slope','nSamples','-append');
            A=num2str(a);
            B=num2str(length(fullFiles));
            disp(['click parameters of file ',A,'(',E,')',', part ',I,'/',L,', out of ',B,' calculated and saved']);
        
        end
    end
end

