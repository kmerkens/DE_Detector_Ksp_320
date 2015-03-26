function beaked_detail_analysis_spectral_overlay

% read in .xls file produced by logger (low, mid, hi)
% read in .mat file produced by beaked_detail_analysis
% plot mean spectra overlaying per species

outDir = 'J:\beaked_whale\geographic_distribution\UBW_extracts\SOCAL\SOCAL18H\';
clickparams = outDir;
load('J:\beaked_whale\geographic_distribution\UBW_extracts\SOCAL\SOCAL18H\SOCAL18H')
load('J:\beaked_whale\geographic_distribution\reference_spectra\meanSpecZc')
load('J:\beaked_whale\geographic_distribution\reference_spectra\meanSpecMd')
load('J:\beaked_whale\geographic_distribution\reference_spectra\meanSpecBWC')
load('J:\beaked_whale\geographic_distribution\reference_spectra\meanSpecBW43')
load('J:\beaked_whale\geographic_distribution\reference_spectra\meanSpecBW50')
load('J:\beaked_whale\geographic_distribution\reference_spectra\meanSpecBW70')
load('J:\beaked_whale\geographic_distribution\reference_spectra\meanSpecBWP')
load('J:\beaked_whale\geographic_distribution\reference_spectra\meanSpecIp')
fs = 200000;
N=512;
f=0:(fs/2000)/(N/2-1):fs/2000;
N2 = N/2;
f2=0:(fs/2000)/(N2/2-1):fs/2000;
N3 = 1024;
fs3 = 500000;
f3=0:(fs3/2000)/(N3/2-1):fs3/2000;
%%%%%%%%%%%  IMPORTANT STEP  %%%%%%%%%%%%%%%%%%
%   you must format your Excel dates/times as
%   NUMBERS.  to do this, highlight the start
%   and end date columns, right-click, select
%   'format cells', then choose 'Number', hit
%   OK, then save the spreadsheet.  You can
%   change them back to datestrings after you 
%   run this code.

%get excel file to read
[infile,inpath]=uigetfile('*.xls');
if isequal(infile,0)
    disp('Cancelled button pushed');
    return
end

cd(inpath)

%read the file into 3 matrices-- numeric, text, and raw cell array
[num, txt, raw] = xlsread([inpath '\' infile]);

hdr = raw(1,:);         %column headers, not used later

%error check
[x,y]=size(num);
if y < 2;          %start and end dates not formatted as numbers
    h=errordlg('Please save dates in number format and click OK when done');
    uiwait(h)
    [num, txt, raw] = xlsread([inpath '\' infile]); %reread file
end

    

excelDates = num(:,1:2);                %numeric array contains datenums

%convert excel datenums to matlab datenums (different pivot year)
matlabDates = ones(size(excelDates)).*datenum('30-Dec-1899') ...
    + excelDates;

if any(isfinite(matlabDates(:,2)));    %if any end times were picked
    matdatestr_1=cell(size(matlabDates,1),1);
    matdatestr_2=cell(size(matlabDates,1),1);
    for a=1:size(matlabDates,1);
        matdatestr_1{a}=cellstr(datestr(matlabDates(a,1),0));
        if isfinite(matlabDates(a,2));
            matdatestr_2{a}=cellstr(datestr(matlabDates(a,2),0));
        elseif isnan(matlabDates(a,2));
            matdatestr_2{a}='';
        end
    end
    matdatestr=[matdatestr_1,matdatestr_2];    %if end times, matdatestr=cell array
    
else matdatestr=datestr(matlabDates(:,1),0);   %if only start times,
                                               %matdatestr=character array
end

    

% x=find(isfinite(matlabDates));          %get indices of real dates (no NaNs)
% matlabDates_exist=matlabDates(x);       %index to get the real dates, is going to be a vector
% matdatestr=datestr(matlabDates_exist,0); %convert dates to strings, this is
                                         %going to be a vector m X 1 (no
                                         %end times) or 2m X 1 (end times)

min_date = min(min(matlabDates));           %earliest date
max_date = max(max(matlabDates));           %latest date

days_of_data=[floor(min_date):1:round(max_date)]; %vector of all recording days


%determine what species there are, how many picks of each,
%and which species it is line by line
[speciesname, speciescount, species_index] = unique(raw(2:end,3));


%initialize a bunch of empty cell arrays with number of cells equal to # of
%unique species

vnum=cell(size(speciesname));   
vstr=cell(size(speciesname));   
row=cell(size(speciesname));    
col=cell(size(speciesname));    %won't use, but need for a 'find' later on
spdatenums=cell(size(speciesname));
Z=cell(size(speciesname));

for j=1:length(speciesname);
    Z{j}=zeros(length(days_of_data),1440);
end


% %make arrays of start & end times for each species
for n=1:length(speciesname);
    % Make a variable name from the text of the species name
    vnum{n} = genvarname([speciesname{n} 'times_num']);
    vstr{n} = genvarname([speciesname{n} 'times_str']);
    
    % Find the row numbers equal to species n
    [row{n},col{n}] = find(species_index == n);
end

%normalize min 10<f<35 (pos 26:91); max 20<f<80 (pos 52:205) for FFT 512
meanSpecBWC = meanSpecBWC - min(meanSpecBWC(26:91));
meanSpecBWC = meanSpecBWC/max(meanSpecBWC(52:205));
meanSpecMd = meanSpecMd - min(meanSpecMd(26:91));
meanSpecMd = meanSpecMd/max(meanSpecMd(52:205));
meanSpecZc = meanSpecZc - min(meanSpecZc(26:91));
meanSpecZc = meanSpecZc/max(meanSpecZc(52:205));
meanSpecBW43 = meanSpecBW43 - min(meanSpecBW43(26:91));
meanSpecBW43 = meanSpecBW43/max(meanSpecBW43(52:205));
meanSpecBW50 = meanSpecBW50 - min(meanSpecBW50(26:91));
meanSpecBW50 = meanSpecBW50/max(meanSpecBW50(52:205));
meanSpecBW70 = meanSpecBW70 - min(meanSpecBW70(26:91));
meanSpecBW70 = meanSpecBW70/max(meanSpecBW70(52:205));
meanSpecBWP = meanSpecBWP - min(meanSpecBWP(13:45));
meanSpecBWP = meanSpecBWP/max(meanSpecBWP(26:103));
%500 kHz fs; 1024 FFT
meanSpecIp = meanSpecIp - min(meanSpecIp(22:73));
meanSpecIp = meanSpecIp/max(meanSpecIp(42:165));

evalIdx = zeros(size(matlabDates,1),1);
evalIdx(:) = NaN;

cd(outDir)
%define path of disk for each manual detection

    
for n=1:length(speciesname);
    for ridx = 1:length(row{n})
        under = strfind(txt{row{n}(ridx)+1,1}, '_');
        input_file = txt{row{n}(ridx)+1,1};
%         depl = 'Cross02';
        depl = input_file(1:under(1)-1);
        diskfind = strfind(txt{row{n}(ridx)+1,1}, 'disk');
        disk = ([depl,'_',input_file(diskfind(1):diskfind(1)+5)]);
        
        meanSpecRidx = meanSpecAll(row{n}(ridx),:);
        %Normalize spectrum
        meanSpecRidx = meanSpecRidx - min(meanSpecRidx(26:91));
        meanSpecRidx = meanSpecRidx/max(meanSpecRidx(52:205));
    
        RIDX = num2str(length(row{n}));
        species = speciesname{n};
        
        graphname = fullfile(outDir, 'matlab_graphs',[disk,'_',datestr(matlabDates(row{n}(ridx),1),30),'.jpg']);
        graph4 = imread(graphname);
        figure('Name',[disk,'_',datestr(matlabDates(row{n}(ridx),1),30)],...
                'Position',([0,0,900,600]))
        image(graph4)
        seqIdentAll = char(seqIdentAll);
        figure('Name', sprintf('%s %s / %s %s', species,num2str(ridx),...
           RIDX,seqIdentAll(row{n}(ridx))),'Position',([100,500,1800,400]))
        plot(f,meanSpecBWC,'k','LineWidth',2), hold on
        plot(f,meanSpecMd,'r','LineWidth',2)
        plot(f,meanSpecZc,'g','LineWidth',2)
        plot(f,meanSpecBW43,'m','LineWidth',2)
        plot(f,meanSpecBW50,'y','LineWidth',2)
        plot(f,meanSpecBW70,'g','LineWidth',2)
        plot(f2,meanSpecBWP,'k','LineWidth',2)
        plot(f3,meanSpecIp,'c','LineWidth',2)
        
        plot(f,meanSpecRidx,'Linewidth',4), hold off
        text(0.85,0.9,['ipi =',num2str(medianValueAll(row{n}(ridx),2))],'Unit','normalized')
        text(0.85,0.85,['dur =',num2str(medianValueAll(row{n}(ridx),3))],'Unit','normalized')
        text(0.85,0.7,['# clicks =',num2str(clickCountAll(row{n}(ridx)))],'Unit','normalized')
        ylim([-0.2 1.2])
        xlim([10 60])
        legend('BWC','Md','Zc','BW43','BW50','BW70','BWP','Ip','Location','EastOutside')
        evalIdx(row{n}(ridx)) = input('1 BWC, 2 Md, 3 Zc, 4 BW43, 5 BW50, 6 BW70, 7 BWP, 8 Ip, 9 UBW, uncertain 0: ');
        %pause
        if evalIdx(row{n}(ridx)) == 0
            
            
            %define path of disk for each manual detection
            param_folder = ([clickparams, '\click_params\',disk]);

            %pull out matlab names and file start dates/times of all files in 
            %the folder with detection
            [matNames] = get_matNames(param_folder);
            ds = size(matNames,2);
            startFile = [];
            for m = 1:size(matNames,1)
                file = matNames(m,:);
                dateFile = [str2num(['20',file(ds-18:ds-17)]),str2num(file(ds-16:ds-15)),...
                    str2num(file(ds-14:ds-13)),str2num(file(ds-11:ds-10)),...
                    str2num(file(ds-9:ds-8)),str2num(file(ds-7:ds-6))];
                startFile = [startFile; datenum(dateFile)];
            end

            %find which matlab file(s) correspond(s) with manual detection start 
            start = matlabDates(row{n}(ridx),1);
            fileIdx = find(startFile<start);
            startIdx = find(startFile == startFile(fileIdx(end))); %check for multiple matlab files per x.wav

            fend = matlabDates(row{n}(ridx),2);
            fileIdx = find(startFile>fend);
            if isempty(fileIdx)
                filetext = sprintf('%s_%s%s', disk, datestr(matlabDates(row{n}(ridx),1),30),'.txt');
                cd(outDir)
                fid = fopen(filetext,'w+');
                fprintf(fid,'%s','End time possibly on next disk');
                fclose(fid);

                if startIdx(end)<length(startFile)
                    fileIdx = length(startFile)+1;
                end
                endIdx = [];
            end

            if ~isempty(fileIdx)
                endIdx = find(startFile == startFile(fileIdx(1)-1));%check for multiple matlab files per x.wav
            end

            fIdx = [startIdx;endIdx]; %combine all indeces of files associate with this detection
            fIdx = unique(fIdx);
            display([num2str(length(fIdx)),' file(s) to be processed'])

            ppSignalSel = [];
            yFiltSel = [];
            
            cd(param_folder)
            for f = 1:length(fIdx)
                %load each mat file of fIdx and check 
                load(matNames(fIdx(f),:));
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
                        ppSignalSel = [ppSignalSel; ppSignal(posIdx(1):posIdx(end))];
                        yFiltSel = [yFiltSel; yFilt(posIdx(1):posIdx(end),:)];
                    end
                end
            end

            if ~isempty(ppSignalSel)

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %plot graphs and save

                [c d]=sort(ppSignalSel,'descend');

                yFiltClickSorted=[];
                for s=1:length(d)
                    yFiltClickSorted(s,:)=yFiltSel(d(s),:);
                end

                %plot spectra
                f=0:(fs/2000)/(N/2-1):fs/2000;
                s=101;
                e=500;
                dd=e-s+1;
                t=0:(dd/(fs/1000))/(dd-1):dd/(fs/1000);
                
                for lidx = 1:98;
                    lidx = input('Would you like to have clicks displayed? yes 1, no 99: ');
                    if lidx == 99
                        break
                    else
                        figure('Name',[disk,'_',datestr(matlabDates(row{n}(ridx),1),30),'_click'],...
                        'Position',([500,0,600,400]))
                        for img=1:size(yFiltClickSorted,1)
                            [Y,F,T,P] = spectrogram(yFiltClickSorted(img,(s:e)),40,39,40,fs);
                            T = T*1000;
                            F = F/1000;

                            subplot(2,1,1), plot(t,yFiltClickSorted(img,(s:e)),'k')
                            ylabel('Amplitude [counts]','fontsize',10,'fontweight','b')
                            title(['Click detail # ',num2str(img),'/',num2str(size(yFiltClickSorted,1))])

                            subplot(2,1,2), surf(T,F,10*log10(abs(P)),'EdgeColor','none');
                            axis xy; axis tight; colormap(blue); view(0,90);
                            xlabel('Time [ms]','fontsize',10,'fontweight','b')
                            ylabel('Frequency [kHz]','fontsize',10,'fontweight','b');


                            imgIn = input('Continue 1, save & cont 2, stop 3: ');

                            if imgIn == 2
                                filename = fullfile(outDir,(sprintf('%s_%s', disk, ...
                                    datestr(matlabDates(row{n}(ridx),1),30),'_click',num2str(img))));
                                saveas(gca, filename, 'jpg')
                            elseif imgIn == 3
                                break
                            else
                                img = 0;
                            end
                        end
                    end
                end
            else
                display(['No clicks detected in sequence ',sprintf('%s_%s', disk, ...
                            datestr(matlabDates(row{n}(ridx),1)))])
            end
            close
            evalIdx(row{n}(ridx)) = input('Decision after clicks: 1 BWC, 2 Md, 3 Zc, 4 BW43, 5 BW50, 6 BW70, 7 BWP, 8 Ip, 9 UBW: ');
        end    
        
        filename = sprintf('%s_%s_overlay', disk, datestr(matlabDates(row{n}(ridx),1),30));
        saveas(gca, filename, 'jpg')
        
        close all
    end
end
