%calculate statistics of automatic detections
% number of detected segments per hour of day

hour = rawStartTotal(:,4);
vec = 0:1:23;
hist(hour,vec);
xlim([0 23])
xlabel('hours')
ylabel('count')

% number of consecutive days with detections and days with no detections
totalContDays = [];

% start = [2007 8 11 0 0 0]; %Hawaii 01
% stop = [2007 10 4 6 16 15]; %Hawaii 01
% 
% start = [2008 4 19 6 0 0]; %Hawaii 02
% stop = [2008 7 4 14 19 45]; %Hawaii 02
% 
% start = [2008 7 8 0 0 0]; %Hawaii 03
% stop = [2008 10 15 20 48 45]; %Hawaii 03

% start = [2009 2 10 0 0 0]; %Hawaii 05
% stop = [2009 3 9 6 15 0]; %Hawaii 05

start = [2009 4 23 10 0 0]; %Hawaii 06
stop = [2009 8 18 17 48 45]; %Hawaii 06

startDay = [start(1) start(2) start(3) 0 0 0];
stopDay = [stop(1) stop(2) stop(3) 0 0 0];

startDay = datenum(startDay);
stopDay = datenum(stopDay);

dateVec = startDay:1:stopDay;

%!!!!!!!!!!!!load .mat beaked whale detections
allDays = rawStartTotal;
allDays(:,4)=0;
allDays(:,5)=0;
allDays(:,6)=0;
allDays = unique(datenum(allDays));

offDays = setdiff(dateVec,allDays);
offDays1 = [0,offDays];
offDays2 = [offDays,0];
offDaysDiff = offDays2-offDays1;
offDaysDiff = offDaysDiff(2:end-1);
offDaysDiff = offDaysDiff.';

totalContDays = [totalContDays;offDaysDiff];
vec = 1:1:19;
hist(totalContDays,vec)
xlim([0 20])
xlabel('days')
ylabel('count')
