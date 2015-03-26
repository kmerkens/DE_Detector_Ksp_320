%convert automatic detections into xls times
%make time vector with start of segments, called matlabStart
segLength=[0 0 0 0 1 15];
endShift=datenum(segLength);

matlabStart=rawStartTotal;
matlabStart=datenum(matlabStart);
matlabEnd=matlabStart+endShift;

%convert to excel
excelStart = matlabStart - ones(size(matlabStart)).*datenum('30-Dec-1899');
excelEnd =  matlabEnd - ones(size(matlabEnd)).*datenum('30-Dec-1899');


%%%%%%%%%%%%%%%%%%%%%%%%%


matlabStart = ones(size(excelStart)).*datenum('30-Dec-1899') + excelStart;
matlabEnd = ones(size(excelEnd)).*datenum('30-Dec-1899') + excelEnd;

% durDiff=matlabEnd-matlabStart;
% durDiffVec=datevec(durDiff);
% 
% hour=durDiffVec(:,4);
% min=durDiffVec(:,5);
% sec=durDiffVec(:,6);
% 
% hour=hour*3600;
% min=min*60;
% 
% time=hour+min+sec;
% time=time/3600;

matlabStart = ones(size(excelStart)).*datenum('30-Dec-1899') + excelStart;
matlabEnd = ones(size(excelEnd)).*datenum('30-Dec-1899') + excelEnd;

matlabStart=datevec(matlabStart);
matlabEnd=datevec(matlabEnd);

hourStart=matlabStart(:,4);
hourEnd=matlabEnd(:,4);

diffHour=hourEnd-hourStart+1;

