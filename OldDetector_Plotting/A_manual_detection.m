function A_manual_detection

% 1) read in xls sheet with manual picks, extract project, site, deployment
% (if applicable), disk, start and end time
% 2) locate HARP disk and find appropriate .xwav files per detection
% sequence
% 3) run low/hi res click detector
% 4) calculate click parameters
% 5) calculate graphs and stats


% define what routines to calculate
lowresdet = 0; %run short time detector
highresdet = 1; %run high res detector
postProc = 0;
clickparams = 0; %run analyze HARP to calculate click parameters
graphstats = 0;

% define start of recording for binning
if graphstats == 1
    
%     startDepl = datenum([2007 11 11 07 06 15]); %Flip07E
%     endDepl = datenum([2007 12 07 20 00 00]); %Flip07E

%     startDepl = datenum([2010 5 16 0 0 1]); %GofMX_GC01
%     endDepl = datenum([2010 8 28 19 16 0]); %GofMX_GC01
%     startDepl = datenum([2010 11 8 2 0 0]); %GofMX_GC02
%     endDepl = datenum([2011 2 2 16 23 0]); %GofMX_GC02
%     startDepl = datenum([2011 9 23 10 0 0]); %GofMX_GC04
%     endDepl = datenum([2012 2 17 5 27 21]); %GofMX_GC04

%     startDepl = datenum([2010 8 9 0 0 0]); %GofMX_DT01
%     endDepl = datenum([2010 10 26 10 06 0]); %GofMX_DT01
%     startDepl = datenum([2011 7 13 0 0 0]); %GofMX_DT03
%     endDepl = datenum([2011 11 14 10 06 04]); %GofMX_DT03

%     startDepl = datenum([2011 12 14 0 0 0]); %GofMX_DT04
%     endDepl = datenum([2012 1 9 8 8 00]); %GofMX_DT04

    startDepl = datenum([2010 5 16 0 0 1]); %GofMX_MC01
    endDepl = datenum([2010 8 28 19 15 0]); %GofMX_MC01
%     startDepl = datenum([2010 9 7 0 36 0]); %GofMX_MC02
%     endDepl = datenum([2010 12 19 19 11 0]); %GofMX_MC02
%     startDepl = datenum([2010 12 20 2 5 0]); %GofMX_MC03
%     endDepl = datenum([2011 3 21 14 27 0]); %GofMX_MC03
%     startDepl = datenum([2011 3 22 6 37 0]); %GofMX_MC04
%     endDepl = datenum([2011 8 13 9 48 43]); %GofMX_MC04
%     startDepl = datenum([2011 09 22 13 0 0]); %GofMX_MC05
%     endDepl = datenum([2012 1 31 12 29 34]); %GofMX_MC05
%     startDepl = datenum([2012 2 28 6 17 28]); %GofMX_MC06
%     endDepl = datenum([]); %GofMX_MC06


%     startDepl = datenum([2006 10 19 4 0 0]); %all Palmyra
%     endDepl = datenum([2010 8 26 0 0 0]); %all Palmyra


end
% sbp 5/16/2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Detector settings
% 1) Short time detector, step 1
Parameters.Ranges = [17000 75000];
Parameters.Thresholds = 14;
Parameters.MinClickSaturation = 3000;
Parameters.MaxClickSaturation = 80000;
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
FeatureType = '.czcc';
OptArgs =  {'MaxSep_s', 0.5000,'MaxClickGroup_s', 2,'GroupAnnotExt', 'gTg',...
            'FrameLength_us', 1200,'MaxFramesPerClick', 1,'FilterNarrowband',...
            [3, 35, 3]};
        
% 3) Define transfer function file
str1 = 'Select Directory containing .tf transfer function for this HARP';
indir = 'I:\Peale2Backup_20131017\Code\TF_files\';
[tfFile, tfDir] = uigetfile('*.tf',str1,indir);

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
    disp('Cancel button pushed');
    return
end

cd(inpath)

%read the file into 3 matrices-- numeric, text, and raw cell array
[num, txt, raw] = xlsread([inpath '\' infile]);

hdr = raw(1,:);         %column headers, not used later

%error check
[~,y]=size(num);
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
inDisk = fileparts(BaseDir(1:3));
MetaDir = ([BaseDir,'metadata']);
OutDir = ([BaseDir,'click_params']);
GraphDir = ([BaseDir,'matlab_graphs']);
mkdir(OutDir)
mkdir(GraphDir)

input_file = txt{2,1};
under = strfind(input_file, '_');
depl = input_file(1:under(1)-1);
depl = 'GofMX_MC01';
% depl = input_file; % for Palmyra
% depl = 'Cross02'; % for Cross

%find folders on disk and remove those that don't belong to data
folders = dir(BaseDir);
foldersDepl = folders;
for fidx = 1:length(folders)
    true = strfind(folders(fidx).name, depl);
    decim = strfind(folders(fidx).name, 'd100');
    if isempty(true) || ~isempty(decim)
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

seqIdentAll = [];
% profile on
%take each detection, check which xwav files are associated with the detection
for i = 1:size(matlabDates,1)
    display(['Calculate manual detection # ',num2str(i), ' out of ',...
        num2str(size(matlabDates,1))]);
    
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
    
        fIdx = [startIdx:endIdx]; %combine all indices of files associate with this detection
        fIdx = unique(fIdx);
        display([num2str(length(fIdx)),' file(s) to be processed'])

        Files =[];
        Labels =[];
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
        fullFiles =[];
        fullLabels =[];
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
            dtHighResClickBatch(fullFiles, fullLabels, inDisk,...
                                 'DateRegexp', TimeRE, ...
                                 'FeatureExt', FeatureType, ...
                                 'FeatureId', '', ...
                                 'ClickAnnotExt', 'cTg', ...
                                 'snrThresh', Parameters.Thresholds,...
                                 'Viewpath', {MetaDir, BaseDir}, ...
                                 'TfPath', fullfile(tfDir,tfFile),...
                                 'BPRanges',[10000,92000],...
                                 OptArgs{:});
        end
        
        if postProc == 1
            % Load .ctg files one at a time, and throw out solo clicks, and
            % suspected pulsed calls.
            % Then save a big vector of start and end datenums, one file for each
            % disk. 
            maxNeighbor = 5; % maximum distance between clicks in seconds 
            buzzInt = .0015; % separation threshold in seconds below which 2 clicks might 
            % be part of a pulsed call
            buzzMembers = 3; % minimum number of member clicks needed before 
            % deciding it's a pulsed call (also might help throw out
            % remaining ships).
            buff = .0005; % time in seconds you're going to look on either 
            % side of the buzz interval for buzz members
            clickPProc(fullLabels, maxNeighbor, buzzInt, buzzMembers,buff);
        end
        
%         %run analyze HARP
%         if clickparams ==  1
%              analyze_HARP_local(fullLabels,fullFiles,tfFile,tfDir);
%         end
% 
%         %calculate graphs and stats
%         if graphstats == 1 %temporarily off because not enought memory to complete operation
%             %calculate 5 minute bins
%             bin = datenum([0 0 0 0 5 0]);
%             binArray = startDepl:bin:endDepl;
% 
%             %graphs and stats
%             [meanSpecClick,medianValue,clickCount,maxRL,seqIdent,params,binValues] = ...
%                 beaked_detail_analysis(fullLabels,start,fend,GraphDir,binArray);
% 
%             meanSpecAll(i,:) = meanSpecClick;
%             medianValueAll(i,:) = medianValue;
%             clickCountAll(i) = clickCount;
%             maxRLAll(i) = maxRL;
%             seqIdentAll(i,:) = seqIdent;
%             binValuesAll{i} = binValues;
%         end

    end
end
% profile viewer
% if graphstats == 1
%     filename = fullfile(BaseDir,depl);
%     save(filename, 'meanSpecAll','medianValueAll','clickCountAll',...
%         'maxRLAll','seqIdentAll','params','binValuesAll')
% end

