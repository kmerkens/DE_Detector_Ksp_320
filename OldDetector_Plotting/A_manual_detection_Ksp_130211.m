function A_manual_detection_Ksp

% 1) read in xls sheet with manual picks, extract project, site, deployment
% (if applicable), disk, start and end time
% 2) locate HARP disk and find appropriate .xwav files per detection
% sequence
% 3) run low/hi res click detector
% 4) calculate click parameters
% 5) calculate graphs and stats



% define what routines to calculate
lowresdet = 1; %run short time detector
highresdet = 1; %run high res detector
clickparams = 1; %run analyze HARP to calculate click parameters
graphstats = 1;

% define start of recording for binning
if graphstats == 1
%     startDepl = datenum([2007 11 11 16 0 0]); %Flip07H
%     endDepl = datenum([2008 1 4 23 0 0]); %Flip07H
%     startDepl = datenum([2008 9 15 0 0 0]); %Hoke01
%     endDepl = datenum([2009 6 7 0 0 0]); %Hoke01
%     startDepl = datenum([2006 9 3 0 0 0]); %SOCAL05E
%     endDepl = datenum([2006 10 28 0 0 0]); %SOCAL05E
%     startDepl = datenum([2007 7 24 0 0 0]); %SOCAL18H
%     endDepl = datenum([2007 9 16 0 0 0]); %SOCAL18H
%     startDepl = datenum([2008 6 5 0 0 0]); %SOCAL26H
%     endDepl = datenum([2008 7 26 0 0 0]); %SOCAL26H
%     startDepl = datenum([2008 8 3 0 0 0]); %SOCAL27E
%     endDepl = datenum([2008 9 25 0 0 0]); %SOCAL27E
%     startDepl = datenum([2008 8 4 0 0 0]); %SOCAL27H
%     endDepl = datenum([2008 9 25 0 0 0]); %SOCAL27H
%     startDepl = datenum([2008 10 19 0 0 0]); %SOCAL29E
%     endDepl = datenum([2008 12 13 0 0 0]); %SOCAL29E
%     startDepl = datenum([2008 10 20 0 0 0]); %SOCAL29H
%     endDepl = datenum([2008 12 15 0 0 0]); %SOCAL29H
%     startDepl = datenum([2009 1 13 0 0 0]); %SOCAL31E
%     endDepl = datenum([2009 3 10 0 0 0]); %SOCAL31E
%     startDepl = datenum([2009 1 13 0 0 0]); %SOCAL31M
%     endDepl = datenum([2009 3 9 0 0 0]); %SOCAL31M
%     startDepl = datenum([2009 1 14 0 0 0]); %SOCAL31N
%     endDepl = datenum([2009 2 11 0 0 0]); %SOCAL31N
%     startDepl = datenum([2009 3 12 0 0 0]); %SOCAL32C
%     endDepl = datenum([2009 5 6 0 0 0]); %SOCAL32C
%     startDepl = datenum([2009 5 17 0 0 0]); %SOCAL33CCE1
%     endDepl = datenum([2009 12 16 0 0 0]); %SOCAL33CCE1
%     startDepl = datenum([2009 5 19 0 0 0]); %SOCAL33E
%     endDepl = datenum([2009 7 13  0 0 0]); %SOCAL33E
%     startDepl = datenum([2009 5 19 0 0 0]); %SOCAL33N
%     endDepl = datenum([2009 7 13  0 0 0]); %SOCAL33N
%     startDepl = datenum([2009 5 19 0 0 0]); %SOCAL33SN
%     endDepl = datenum([2010 6 3 0 0 0]); %SOCAL33SN
%     startDepl = datenum([2009 9 25 0 0 0]); %SOCAL35M
%     endDepl = datenum([2009 11 18 0 0 0]); %SOCAL35M
%     startDepl = datenum([2009 12 6 0 0 0]); %SOCAL36N
%     endDepl = datenum([2010 1 27 0 0 0]); %SOCAL36N
%     startDepl = datenum([2010 1 31 0 0 0]); %SOCAL37N
%     endDepl = datenum([2010 3 26 0 0 0]); %SOCAL37N
%     startDepl = datenum([2010 7 22 0 0 0]);; %SOCAL40M
%     endDepl = datenum([2010 11 8 0 0 0]); %SOCAL40M
%     startDepl = datenum([2010 12 5 0 0 0]); %SOCAL41M
%     endDepl = datenum([2011 4 25 0 0 0]); %SOCAL41M
%     startDepl = datenum([2010 12 7 0 0 0]); %SOCAL41N
%     endDepl = datenum([2011 4 9 0 0 0]); %SOCAL41N
%     startDepl = datenum([2011 5 11 0 0 0]); %SOCAL44M
%     endDepl = datenum([2011 10 3 0 0 0]); %SOCAL44M
%     startDepl = datenum([2011 5 12 0 0 0]); %SOCAL44N
%     endDepl = datenum([2011 9 24 0 0 0]); %SOCAL44N
%     startDepl = datenum([2006 10 3 12 0 0]); %PS01
%     endDepl = datenum([2007 1 17 0 0 0]); %PS01

%     startDepl = datenum([2005 11 20 0 0 0]); %Cross02
%     endDepl = datenum([2006 5 12 0 0 0]); %Cross02

     startDepl = datenum([2010 7 15 0 0 0]); %GofMX_GC01
     endDepl = datenum([2010 10 11 19 52 0]); %GofMX_GC01
     
%     startDepl = datenum([2010 11 8 2 0 0]); %GofMX_GC02
%     endDepl = datenum([2011 2 2 16 23 0]); %GofMX_GC02
%      startDepl = datenum([2011 3 23 0 0 0]); %GofMX_GC03
%      endDepl = datenum([2011 8 7 22 46 02]); %GofMX_GC03
%     startDepl = datenum([2011 9 23 10 0 0]); %GofMX_GC04
%     endDepl = datenum([2012 2 17 5 27 21]); %GofMX_GC04

%     startDepl = datenum([2010 8 9 0 0 0]); %GofMX_DT01
%     endDepl = datenum([2010 10 26 10 06 0]); %GofMX_DT01
%     startDepl = datenum([2011 7 13 0 0 0]); %GofMX_DT03
%     endDepl = datenum([2011 11 14 10 06 04]); %GofMX_DT03
%     startDepl = datenum([2011 12 14 0 0 0]); %GofMX_DT04
%     endDepl = datenum([2012 1 9 8 8 00]); %GofMX_DT04

%     startDepl = datenum([2010 5 16 0 0 01]); %GofMX_MC01
%     endDepl = datenum([2010 8 28 19 15 0]); %GofMX_MC01
%     startDepl = datenum([2010 9 7 0 36 0]); %GofMX_MC02
%     endDepl = datenum([2010 12 19 19 11 0]); %GofMX_MC02
%     startDepl = datenum([2010 12 20 2 5 0]); %GofMX_MC03
%     endDepl = datenum([2011 3 21 14 27 0]); %GofMX_MC03
%     startDepl = datenum([2011 03 22 6 0 0]); %GofMX_MC04
%     endDepl = datenum([2011 8 13 20 18 00]); %GofMX_MC04
%     startDepl = datenum([2011 09 22 13 0 0]); %GofMX_MC05
%     endDepl = datenum([2012 1 31 12 29 34]); %GofMX_MC05

%     startDepl = datenum([2006 10 19 4 0 0]); %all Palmyra
%     endDepl = datenum([2010 8 26 0 0 0]); %all Palmyra
end

% sbp 5/16/2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Detector settings
% 1) Short time detector, step 1
Parameters.Ranges = [60000 100000]; %%%%CHANGED FROM 10000 MIN
Parameters.Thresholds = 10;
Parameters.MinClickSaturation = 2000; %%%%%CHANGED FROM 10000 MIN
Parameters.MaxClickSaturation = 35000; %%%%%%%%%%CHANGED FROM 10000 MAX
Parameters.WhistleMinLength_s = 0.2500;
Parameters.WhistleMinSep_s = 0.0256;
Parameters.MeanAve_s = Inf;
Parameters.WhistlePos = 0;
Parameters.ClickPos = 1;
Parameters.Enabled = 1;
Parameters.ifPlot = 1;
Parameters.class.ValidLabels = 0;
Parameters.class.PlotLabels = 0;

% 2) Highres detector, step 2
TimeRE = ...
'.*B(?<hr>\d+)h(?<min>\d+)m(?<s>\d+)s(?<day>\d+)(?<mon>[a-zA-Z]+)(?<yr>\d+)y.*|(?<yr>(\d\d)?\d\d)(?<mon>\d\d)(?<day>\d\d)[\._-](?<hr>\d\d)(?<min>\d\d)(?<s>\d\d)|raven[\._](?<yr>(\d\d)?\d\d)(?<mon>\d\d)(?<day>\d\d)[\._-](?<hr>\d\d)(?<min>\d\d)(?<s>\d\d)|raven[\._](?<yr>(\d\d)?\d\d)(?<mon>\d\d)(?<day>\d\d)[\._-](?<hr>\d\d)(?<min>\d\d)(?<s>\d\d)';
FeatureType = '.ccc';
OptArgs =  {'MaxSep_s', 0.5000,'MaxClickGroup_s', 2,'GroupAnnotExt', 'gTg',...
            'FrameLength_us', 1200,'MaxFramesPerClick', 1,'FilterNarrowband',...
            [0, 3]};
        
% 3) Define transfer function file for analyze HARP
if clickparams == 1
    str1 = 'Select Directory containing .tf transfer function for this HARP';
    indir = 'H:\Karlinas_data\MATLAB\Harp_TFs\GofMX\';
    [tfFile tfDir] = uigetfile('*.tf',str1,indir);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read in .xls file produced by logger
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
    h=errordlg('Please save dates in number format and click ok');
    uiwait(h)
    [num, txt, raw] = xlsread([inpath '\' infile]); %reread file
end  

excelDates = num(:,1:2);                %numeric array contains datenums

%convert excel datenums to matlab datenums (different pivot year)
matlabDates = ones(size(excelDates)).*datenum('30-Dec-1899') ...
    + excelDates;

BaseDir = uigetdir('G:\','Please select disk with xwavs');
MetaDir = ([BaseDir,'metadata']);
OutDir = ([BaseDir,'click_params']);
GraphDir = ([BaseDir,'matlab_graphs']);
mkdir(OutDir)
mkdir(GraphDir)

input_file = txt{2,1};
under = strfind(input_file, '_');
depl = input_file(1:under(1)-1);
% depl = input_file; % for Palmyra
% depl = 'Cross02'; % for Cross
% depl = 'GofMX_MC02'; %for MC02

%find folders on disk and remove those that don't belong to data
folders = dir(BaseDir);
foldersDepl = folders;
for fidx = 1:length(folders)
    true = strfind(folders(fidx).name, depl);
    if isempty(true)
        trueIdx(fidx) = 0;
    else
        trueIdx(fidx) = 1;
    end
end
keep = find(trueIdx==1);
OutDir = [];
foldernames = [];
for fidx = 1:length(keep)
    if isdir(fullfile(BaseDir,folders(keep(fidx)).name)) == 1
        foldernames = [foldernames; char(folders(keep(fidx)).name)];
        OutDir = [OutDir; char(fullfile(BaseDir,'click_params',folders(keep(fidx)).name))];
    end
end
for fidx = 1:size(OutDir, 1)
    mkdir(OutDir(fidx,:))
end
%pull out all x.wav files of all folders and combine in one long list
%together with directory information
xwavNames = [];
for fidx = 1:size(foldernames,1)
    xwavDir = [BaseDir,foldernames(fidx,:)];
    xwavs = get_xwavNames(xwavDir);
    xwavList = [];
    for s = 1:size(xwavs,1)
        xwavList(s,:) = fullfile(foldernames(fidx,:),xwavs(s,:));
    end
    xwavNames = [xwavNames;char(xwavList)];
end

meanSpecAll = zeros(size(matlabDates,1),256);
medianValueAll = zeros(size(matlabDates,1),5);
clickCountAll = zeros(size(matlabDates,1),1);
maxRLAll = zeros(size(matlabDates,1),1);
seqIdentAll = [];
%take each detection, check which xwav files are associated with the detection
for i = 1:size(matlabDates,1)
    display(['Calculate manual detection # ',num2str(i), ' out of ',...
        num2str(size(matlabDates,1))]);
    
    %parse out all dates and times for the start of each xwav file
    ds = size(xwavNames,2);
    startFile = [];
    for m = 1:size(xwavNames,1)
        file = xwavNames(m,:);
        dateFile = [str2num(['20',file(ds-18:ds-17)]),str2num(file(ds-16:ds-15)),...
            str2num(file(ds-14:ds-13)),str2num(file(ds-11:ds-10)),...
            str2num(file(ds-9:ds-8)),str2num(file(ds-7:ds-6))];
        startFile = [startFile; datenum(dateFile)];
    end
    
    %find which xwav file(s) correspond(s) with manual detection start 
    start = matlabDates(i,1);
    fileIdx = find(startFile<start);
    startIdx = find(startFile == startFile(fileIdx(end))); %check for multiple matlab files per x.wav
    
    fend = matlabDates(i,2);
    fileIdx = find(startFile>fend);
    if isempty(fileIdx)
        filetext = fullfile(BaseDir,'click_params', (sprintf('%s_%s', depl,datestr(matlabDates(i,1),30),'.txt')));
        fid = fopen(filetext,'w+');
        fprintf(fid,'%s','End time possibly on next disk');
        fclose(fid);
        
        if startIdx(end)<length(startFile)
            fileIdx = length(startFile)+1;
        end
    end
    
    if ~isempty(fileIdx)
        endIdx = find(startFile == startFile(fileIdx(1)-1));%check for multiple matlab files per x.wav
    
        fIdx = [startIdx;endIdx]; %combine all indeces of files associate with this detection
        fIdx = unique(fIdx);
        display([num2str(length(fIdx)),' file(s) to be processed'])

        clear Files
        clear Labels
        for f = 1:length(fIdx)
            Files{f} = xwavNames(fIdx(f),:);
            Labels{f} = 'unknown';
        end
        SearchType = 'Blind search';

       %run short time detector
        if lowresdet == 1
            dtST_batch(BaseDir, Files, Labels, SearchType, Parameters, ...
                     'Viewpath', {MetaDir, BaseDir});
        end

        %Files needs to have a full path for the high res detector
        clear fullFiles
        clear fullLabels
        for f = 1:length(Files)
            file = Files{f};
            fullFiles{f} = fullfile(BaseDir,file);
            [pathstr, name, ext] = fileparts(file);
            name = ([name(1:length(name)-2),'.c']);
            fullLabels{f} = fullfile(MetaDir,pathstr,name);
%             fullLabels{f} = fullfile(BaseDir,pathstr,name);
        end


        %run high res detector
        if highresdet == 1
            dtHighResClickBatch(fullFiles, fullLabels, ...
                                 'DateRegexp', TimeRE, ...
                                 'FeatureExt', FeatureType, ...
                                 'FeatureId', '', ...
                                 'ClickAnnotExt', 'cTg', ...
                                 'Viewpath', {MetaDir, BaseDir}, ...
                                 OptArgs{:});
        end

        %run analyze HARP
        if clickparams ==  1
            analyze_HARP_local_Ksp(fullLabels,fullFiles,tfFile,tfDir);
        end

        %calculate graphs and stats
        if graphstats == 1
            %calculate 5 minute bins
            bin = datenum([0 0 0 0 5 0]);
            binArray = startDepl:bin:endDepl;

            %graphs and stats
            [meanSpecClick,medianValue,clickCount,maxRL,seqIdent,params,binValues] = ...
                beaked_detail_analysis(fullLabels,start,fend,GraphDir,binArray);

            meanSpecAll(i,:) = meanSpecClick;
            medianValueAll(i,:) = medianValue;
            clickCountAll(i) = clickCount;
            maxRLAll(i) = maxRL;
            seqIdentAll(i,:) = seqIdent;
            binValuesAll{i} = binValues;
        end
    end
end

if graphstats == 1
    filename = fullfile(BaseDir,depl);
    save(filename, 'meanSpecAll','medianValueAll','clickCountAll',...
        'maxRLAll','seqIdentAll','params','binValuesAll')
end

