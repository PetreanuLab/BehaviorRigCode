function currrats = WM_rat_water_list(session,handles,output_type,day,varargin)

if nargin < 3; output_type = 'regular'; end
if nargin < 4; day = datestr(now,29);   end

[ratnames1,rigs,timeslots] = bdata('select ratname, rig, timeslot from ratinfo.schedule where date="{S}"',day);
[ratnames2,forcedeps,forcefrees,cagemates] = bdata('select ratname, forcedepwater, forcefreewater, cagemate from ratinfo.rats where extant=1');
    
for s = 1:7
    R = cell(0);
    if s < 7
        R = ratnames1(timeslots == s); R(strcmp(R,'')) = [];
        fd = ratnames2(forcedeps == s);
        %temp = fd(~ismember(fd,ratnames1));
        R(end+1:end+length(fd)) = fd;
    elseif s == 7
        R = ratnames2(forcefrees == 1);
        nd = ratnames2(forcedeps == 0);
        temp = nd(~ismember(nd,ratnames1));
        R(end+1:end+length(temp)) = temp;        
    end
        
    for r = 1:length(R)
        temp = strcmp(ratnames2,R{r,1});
        if sum(temp) ~= 0; R{r,2} = cagemates{temp};
        else               R{r,2} = '';
        end
        R(r,:) = sortrows(R(r,:)');
    end
    R = sortrows(R,2);
    duprats = [];
    for r = 1:size(R,1)-1
        if strcmp(R{r,2},R{r+1,2}); duprats(end+1) = r; end %#ok<AGROW>
    end
    R(duprats,:) = [];
    
    RatList{s} = R; %#ok<AGROW>
end

for s = 5:-1:1
    duprats = [];
    for r = 1:size(RatList{s},1)
        for p = 6:-1:s+1
            if sum(strcmp(RatList{p}(:,2),RatList{s}{r,2})) > 0; duprats(end+1)=r; end %#ok<AGROW>
        end
    end
    RatList{s}(duprats,:) = []; %#ok<AGROW>
end

duprats = [];
for r = 1:size(RatList{7},1)
    for p = 1:6
        if sum(strcmp(RatList{p}(:,2),RatList{7}{r,2})) > 0; duprats(end+1)=r; end %#ok<AGROW>
    end
end
RatList{7}(duprats,:) = [];

for s = 1:7
    badrat = [];
    for r = 1:size(RatList{s},1)
        if (~isempty(RatList{s}{r,1}) && ~isempty(str2num(RatList{s}{r,1}))) ||...
           (~isempty(RatList{s}{r,2}) && ~isempty(str2num(RatList{s}{r,2})))    %#ok<ST2NM>
            badrat(end+1) = r; %#ok<AGROW>
        end
        if ~isempty(RatList{s}{r,1}) 
            if strcmp(RatList{s}{r,1}(1:3),'sen'); badrat(end+1) = r; end %#ok<AGROW>
            if strcmp(RatList{s}{r,1}(1)  ,'0');   badrat(end+1) = r; end %#ok<AGROW>
        end
        if ~isempty(RatList{s}{r,2}) 
            if strcmp(RatList{s}{r,2}(1:3),'sen'); badrat(end+1) = r; end %#ok<AGROW>
            if strcmp(RatList{s}{r,2}(1)  ,'0');   badrat(end+1) = r; end %#ok<AGROW>
        end
    end
    RatList{s}(badrat,:) = []; %#ok<AGROW>
end

currrats = cell(0);
for s = session
    if s == 0; break; end
    currrats(end+1:end+size(RatList{s},1),:) = RatList{s};
    if strcmp(output_type,'regular'); WM_ratsheet(RatList{s},handles); end
end

currrats = unique(currrats(:));
if isempty(currrats) || isempty(currrats(1)); currrats{1} = []; end

if strcmp(output_type,'all'); currrats = RatList; end


