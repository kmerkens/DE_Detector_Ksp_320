%convert automatic detections into xls times

%make time vector with start of segments, called matlabStart
%load .mat data generated by beakedStats
matlabStart=rawStartTotal;

segLength=[0 0 0 0 1 15];
endShift=datenum(segLength);

matlabStart=datenum(matlabStart);
matlabEnd=matlabStart+endShift;

%convert to excel
excelStart = matlabStart - ones(size(matlabStart)).*datenum('30-Dec-1899');
excelEnd =  matlabEnd - ones(size(matlabEnd)).*datenum('30-Dec-1899');


%%%%%%%%%%%%%%%%%%%%%%%%%
% Find hours and days with calls from Excel spreadsheet %%%%%%%%

clear all
% open empty array excelStart and excelEnd 
excelStart =[];
excelEnd = [];
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

