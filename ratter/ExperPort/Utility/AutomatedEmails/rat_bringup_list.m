function rat_bringup_list(session,displaytype,varargin)

try
    if nargin < 2; displaytype = 'print'; end
    if nargin < 1; session     = 1:6;     end

    [ratnames1,timeslots] = bdata('select ratname, timeslot from ratinfo.schedule where date="{S}"',datestr(now,29));
    [ratnames2,bringupats,cagemates,recovering] = bdata('select ratname, bringupat, cagemate, recovering from ratinfo.rats where extant=1');    

    bringupats(bringupats == 0) = nan;

    emptyslots = strcmp(ratnames1,'');
    ratnames1(emptyslots == 1) = [];
    timeslots(emptyslots == 1) = [];
    
    recovrats = cell(0,2);
    for r = 1:length(ratnames2)
        if recovering(r) == 1
            %This is a recovering rat
            cm = cagemates{r};
            if sum(strcmp(ratnames1,ratnames2{r})) == 0
                %He is not training
                if isempty(cm) || sum(strcmp(ratnames1,cm)) == 0  
                    %He doesn't have a cagemate or his cagemate isn't training
                    recovrats(end+1,:) = {ratnames2{r},cm}; %#ok<AGROW>
                    recovrats(end,:) = sortrows(recovrats(end,:)');
                end
            end
        end
    end
    recovrats = sortrows(recovrats,2);
    duprats = [];
    for r = 1:size(recovrats,1)-1
        if strcmp(recovrats{r,2},recovrats{r+1,2}); duprats(end+1) = r; end %#ok<AGROW>
    end
    recovrats(duprats,:) = [];

    for s = 1:6
        %R1 is the list of training rats
        R1 = ratnames1(timeslots == s);
        for r = 1:length(R1)
            temp1 = strcmp(ratnames2,R1{r,1});
            if sum(temp1 > 0); temp = cagemates{strcmp(ratnames2,R1{r,1})}; else temp = ''; end
            if ~isempty(temp); R1{r,2} = temp;
            else               R1{r,2} = '';
            end
            R1(r,:) = sortrows(R1(r,:)');
        end
        R1 = sortrows(R1,2);
        duprats = [];
        for r = 1:size(R1,1)-1
            if strcmp(R1{r,2},R1{r+1,2}); duprats(end+1) = r; end %#ok<AGROW>
        end
        R1(duprats,:) = [];
        
        %R2 is the list of non-training rats
        R2 = cell(0,2);
        if ~strcmp(datestr(now,'ddd'),'Sat') && ~strcmp(datestr(now,'ddd'),'Sun')
            temp = ratnames2(bringupats == s);
            R2(end+1:end+length(temp),1) = temp;
        end
        for r = 1:size(R2,1)
            temp = cagemates{strcmp(ratnames2,R2{r,1})};
            if ~isempty(temp); R2{r,2} = temp;
            else               R2{r,2} = '';
            end
            R2(r,:) = sortrows(R2(r,:)');
        end
        if s == 2
            %add nontraining recovering rats to bringup list 1
            R2(end+1:end+size(recovrats,1),:) = recovrats;
        end
        
        R2 = sortrows(R2,2);    
        duprats = [];
        for r = 1:size(R2,1)-1
            if strcmp(R2{r,2},R2{r+1,2}); duprats(end+1) = r; end %#ok<AGROW>
        end
        R2(duprats,:) = [];
        
        duprats = [];
        for r = 1:size(R2,1)
            if sum(strcmp(R1(:,2),R2{r,2})) > 0; duprats(end+1) = r; end %#ok<AGROW>
        end
        R2(duprats,:) = [];

        RatList{s} = [R1; R2]; %#ok<AGROW>
        LastTraining(s) = size(R1,1); %#ok<AGROW>
    end

    for s = 2:6
        duprats = [];
        for r = 1:size(RatList{s},1)
            for p = 1:s-1
                if sum(strcmp(RatList{p}(:,2),RatList{s}{r,2})) > 0; duprats(end+1)=r; end %#ok<AGROW>
            end
        end
        RatList{s}(duprats,:) = []; %#ok<AGROW>
        LastTraining(s) = LastTraining(s) - sum(duprats <= LastTraining(s));     %#ok<AGROW>
    end

    WaterList = WM_rat_water_list(0,0,'all');
    WL = cell(0); RL = cell(0);
    for i = 1:6
        WL(end+1:end+size(WaterList{i},1),:) = WaterList{i};
        RL(end+1:end+size(RatList{i},  1),:) = RatList{i};
    end
    WL = WL(:); RL = RL(:);
    RL(strcmp(RL,'')) = [];
    WL(strcmp(WL,'')) = [];

    missingrats = WL(~ismember(WL,RL));
    for s = 1:6
        for i = 1:length(missingrats)
            if sum(strcmp(WaterList{s}(:),missingrats{i})) > 0
                try %#ok<TRYNC>
                    cm = cagemates{strcmp(ratnames2,missingrats{i})};
                    temp = sortrows({missingrats{i};cm})';

                    RatList{s}(end+1,:) = temp; %#ok<AGROW>
                end
            end
        end
        R1 = RatList{s}(1:LastTraining(s),:);
        
        R2 = RatList{s}(LastTraining(s)+1:end,:);
        R2 = sortrows(R2,2);
        duprats = [];
        for r = 1:size(R2,1)-1
            if strcmp(R2{r,2},R2{r+1,2}); duprats(end+1) = r; end %#ok<AGROW>
        end
        R2(duprats,:) = [];
        
        duprats = [];
        for r = 1:size(R2,1)
            if sum(strcmp(R1(:,2),R2{r,2})) > 0; duprats(end+1) = r; end %#ok<AGROW>
        end
        R2(duprats,:) = [];

        RatList{s} = [R1; R2]; %#ok<AGROW>
    end

    for s = session
        F = ratsheet(RatList{s},s,LastTraining(s));
        for f = F
            figure(f);
            if strcmp(displaytype,'print')
                orient landscape
                pause(0.1);
                print;
                pause(0.1);
                close(f);
            else
                x = get(0,'MonitorPosition');
                set(gcf,'position',x);
                C = get(gca,'children');
                for c = 1:length(C)
                    try set(C(c),'fontsize',40); end %#ok<TRYNC>
                end
            end
        end
    end
catch %#ok<CTCH>
    senderror_report;
end