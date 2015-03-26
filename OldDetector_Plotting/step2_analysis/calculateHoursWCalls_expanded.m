%calculate number of days and number of hours per deployment
clear all

% start = [2007 8 11 0 0 0]; %Hawaii 01
% stop = [2007 10 4 6 16 15]; %Hawaii 01
% 
% start = [2008 4 19 6 0 0]; %Hawaii 02
% stop = [2008 7 4 14 19 45]; %Hawaii 02
% 
% start = [2008 7 8 0 0 0]; %Hawaii 03
% stop = [2008 10 15 20 48 45]; %Hawaii 03

start = [2009 2 10 0 0 0]; %Hawaii 05
stop = [2009 3 9 6 15 0]; %Hawaii 05

% start = [2009 4 23 10 0 0]; %Hawaii 06
% stop = [2009 8 18 17 48 45]; %Hawaii 06

startDay = [start(1) start(2) start(3) 0 0 0];
stopDay = [stop(1) stop(2) stop(3) 0 0 0];

numDays = datenum(stopDay) - datenum(startDay)+1;

% number of hours in first and last day
first = 24 - start(4);
last = stop(4);

numHours = (numDays-2)*24 + first + last;

%%%%%%%%%%%%%%%%%%
%calculate number of days and hours of detections per deployment
% Find hours and days with calls from Excel spreadsheet %%%%%%%%

% open empty array excelStart and excelEnd 
%get excel file to read
[infile,inpath]=uigetfile('*.xls');
if isequal(infile,0)
    disp('Cancel button pushed');
    return
end

cd(inpath)

%read the file into 3 matrices-- numeric, text, and raw cell array
[num, txt, raw] = xlsread([inpath '\' infile]);

excelStart =num(:,1);
excelEnd = num(:,2);
%copy data into it

matlabStart = ones(size(excelStart)).*datenum('30-Dec-1899') + excelStart;
matlabEnd = ones(size(excelEnd)).*datenum('30-Dec-1899') + excelEnd;

matlabStart=datevec(matlabStart);
matlabEnd=datevec(matlabEnd);

%find hours
hourStart=matlabStart(:,4);
hourEnd=matlabEnd(:,4);

diffHour=hourEnd-hourStart+1;

%correct for day shift
neg = find(diffHour < 0);
diffHour(neg) = diffHour(neg)+24;

%minimze to hour
matlabStart(:,5)=0;
matlabStart(:,6)=0;
matlabEnd(:,5)=0;   
matlabEnd(:,6)=0;

hourNum=[];

%find hours with detections
for a=1:length(diffHour)
    hourAdd=[];
    n=diffHour(a);
    for i = 1:n;
        hourNew = matlabStart(a,:);
        hourNew(4) = hourNew(4) + (i-1);
        hourAdd(i,:) = hourNew;
    end
    hourNum = [hourNum;hourAdd];
end

hourNum = datenum(hourNum);

%eliminate multiple of hours which have multiple detections
hourNum = unique(hourNum);
hourNum = datevec(hourNum);

sumHours = size(hourNum,1);

%find days
matlabStart(:,4)=0;
matlabEnd(:,4)=0;


matlabStart = datenum(matlabStart);
matlabEnd = datenum(matlabEnd);

dates = [matlabStart;matlabEnd];
dates = unique(dates);
sumDays = length(dates);

percHours = sumHours/numHours;
percDays = sumDays/numDays;

copy = [sumHours, percHours, sumDays, percDays];

