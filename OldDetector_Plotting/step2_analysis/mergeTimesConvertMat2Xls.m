%convert matlab Detections into excel sheet for database, merge consecutive
%time periods as one detection

%find time delay
segStart = datenum(rawStartTotal);
segStart1 = [0;segStart];
segStart2 = [segStart;0];
segDif = segStart2 - segStart1;
gapLength = [0 0 0 0 2 0];
gapLength = datenum(gapLength);
gap = find(segDif >= gapLength);

%find consecutive segments
seg = gap;
segEnd = gap(2:end)-1;
seg(:,2) = [segEnd;length(rawDurTotal)];

segLength=[0 0 0 0 1 15];
endShift=datenum(segLength);

matlabStart = segStart(seg(:,1));
matlabEnd = segStart(seg(:,2)) + endShift;

%convert to excel
excelStart = matlabStart - ones(size(matlabStart)).*datenum('30-Dec-1899');
excelEnd =  matlabEnd - ones(size(matlabEnd)).*datenum('30-Dec-1899');

