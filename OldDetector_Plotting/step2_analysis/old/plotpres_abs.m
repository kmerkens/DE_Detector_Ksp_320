% read in .xls file produced by logger (low, mid, hi)
% and produce presence/absence grid plot per species


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
    Z{j}=zeros(length(days_of_data),24);
end


% %make arrays of start & end times for each species
for n=1:length(speciesname);
    % Make a variable name from the text of the species name
    vnum{n} = genvarname([speciesname{n} 'times_num']);
    vstr{n} = genvarname([speciesname{n} 'times_str']);
    
    % Find the row numbers equal to species n
    [row{n},col{n}] = find(species_index == n);
    
    %assign dates for each species to corresponding variable
    eval([vnum{n} '= matlabDates(row{n},:);']);     %m x 2 dimensions
    spdatenums{n} =eval([vnum{n}]);                 %m x 2
    
    if ischar(matdatestr);                          %has only start dates
    eval([vstr{n} '= datestr(' vnum{n} '(:,1));']);
    spdatevecs=cell(size(speciesname));
    spdatevecs{n} = datevec(eval([vnum{n}]));
        for k=1:size(spdatenums{n},1);
            Z_rowstart=find(days_of_data== ...
                floor(spdatenums{n}(k,1)));
            Z_colstart=spdatevecs{n}(k,4);
            Z{n}(Z_rowstart, Z_colstart+1)=1; 
        end
        
    
    
    elseif iscell(matdatestr);
    spdatevecs=cell(size(speciesname,1),2);      %2 columns for start and end times
    spdatevecs{n}=cell(size(spdatenums{n}));     %create cell array for spdatevecs
    eval([vstr{n} '=cell(size(spdatenums{n}));']);  %create cell array for spdatestrings 
        for q=1:numel(spdatevecs{n});             %now fill in the cells  
            if isfinite(eval([vnum{n} '(q)']));   %datevec doesn't work on NaNs or empty strings
                spdatevecs{n}{q}=datevec(eval([vnum{n} '(q)']));
                eval([vstr{n} '{q} = datestr(' vnum{n} '(q));']);
            else spdatevecs{n}{q}=NaN;
                eval([vstr{n} '{q} = [];']);
            end
        end
    %rowfind{n}=zeros(length(spdatevecs),1);
        for k=1:size(spdatenums{n},1);
            Z_rowstart=find(days_of_data== ...
                floor(spdatenums{n}(k,1)));
            Z_rowend=find(days_of_data== ...
                floor(spdatenums{n}(k,2)));
            Z_colstart=spdatevecs{n}{k}(4);
            rar=sub2ind(size(spdatenums{n}),k,2);
            if isnan(spdatevecs{n}{rar});
                Z_colend=Z_colstart;
            else Z_colend=spdatevecs{n}{rar}(4);
            end
            
            if Z_rowstart~=Z_rowend;        %wrap over more than one day
                Z{n}(Z_rowstart, Z_colstart+1:size(Z{n},2))=1;
                Z{n}(Z_rowend, 1:Z_colend+1)=1;

                for q=2:Z_rowend-Z_rowstart; %for more than 2 days
                    Z{n}(Z_rowstart+(q-1),:)=1;
                end
                                 

            else Z{n}(Z_rowstart, Z_colstart+1:Z_colend+1)=1;
            end
        end
    end
    
    
    figure(n);
    colormap([1 1 1; 0 0 0]); %no detections=white, detection=black
    imagesc(Z{n});
    h(n)=gca;
    set(h(n), 'Title',text('String',speciesname{n}), ...
    'XTick',[min(get(h(n),'XLim')):1:max(get(h(n),'XLim'))-1], ...
    'XTickLabel', num2str([0:1:23]'), ...
    'YTick',[min(get(h(n),'YLim')):2:max(get(h(n),'YLim'))-1], ...
    'YTickLabel',datestr(days_of_data), ...
    'XLabel',text('String','hour'), ...
    'XGrid','on', 'YGrid', 'on');
end


