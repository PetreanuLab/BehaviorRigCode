function checktrainproblems2(outtype)

try 
    [Rigs,RatSC,Slots]                         = bdata(['select rig, ratname, timeslot from ratinfo.schedule where date="',datestr(now, 29),'"']);
    [Contacts,RatR,DepWR]                      = bdata('select contact, ratname, forceDepWater from ratinfo.rats where extant="1"');
    [Exps,Emails,LMs,SAs,TMs,TAs,TCs,Ins,Alum] = bdata('select experimenter, email, lab_manager, subscribe_all, tech_morning, tech_afternoon, tech_computer, initials, is_alumni from ratinfo.contacts');
    [StartTs,RatSS,Hosts]                      = bdata(['select starttime, ratname, hostname from sess_started where sessiondate="',datestr(now, 29),'"']);
    [RatS,EndTs]                               = bdata(['select ratname, endtime from sessions where sessiondate="',datestr(now, 29),'"']);
    [RatN,RigN,SlotN,ExpN,InN,Notes]           = bdata(['select ratname, rigid, timeslot, experimenter, techinitials, note from ratinfo.technotes where datestr="',datestr(now,29),'"']);
    [Wst Wet RatW]                             = bdata(['select starttime, stoptime, rat from ratinfo.water where date="',datestr(now,29),'"']);
    
    setpref('Internet','SMTP_Server','sonnabend.princeton.edu');
    setpref('Internet','E_mail','ScheduleMeister@Princeton.EDU');

    %Check all extant rats
    for i = 1:length(RatR)
        ratname = RatR{i};
        
        if strcmp(ratname,'sen1') || strcmp(ratname,'sen2') || ratname(1) == '0'; continue; end
        
        M = cell(0);
        train = strcmp(RatSC,ratname);
        if sum(train) > 0
            for z = 1:1 %Use a loop so its easy to break out
                %This is a training rat, check for training problems
                rig  = Rigs(train);
                slot = Slots(train);

                %Problem 1: Did the rat train? Check if a start time was logged
                temp = strcmp(RatSS,ratname);
                if sum(temp) > 0; st = StartTs(temp);
                else              M{end+1} = [ratname,' was scheduled to run in rig ',num2str(rig),' session ',num2str(slot),' but did not appear to run anywhere.'];
                                  if ~strcmp(outtype,'full'); M = cell(0); end
                                  break;
                end

                %Problem 2: Did the rat run in the correct rig? Compare hostname to schedule
                realrig = Hosts(temp); RR = zeros(size(realrig));
                for j = 1:length(realrig)
                    if length(realrig{j}) == 5; RR(j) = str2num(realrig{j}(4:5));
                    else                        RR(j) = 0;
                    end
                end
                RR = unique(RR);
                if all(RR ~= rig); M{end+1} = [ratname,' ran in rig ',num2str(RR'),' but was scheduled to run in rig ',num2str(rig),' session ',num2str(slot),'.']; end

                %Problem 3: Did the rig crashed while running the rat? Check for end time in sessions
                temp = strcmp(RatS,ratname);
                if sum(temp) > 0; ed    = EndTs(temp);
                else              ed{1} = nan;
                                  M{end+1} = [ratname,' was training in rig ',num2str(rig),' session ',num2str(slot),' but the rig crashed.'];
                end

                %Problem 4: Did the rat run for at least 1 hour? Compare start and end times
                for j=1:length(st); try runtime(j) = ceil(timediff(st{j},ed{j},2) / 60); catch; runtime(j) = nan; end; end %#ok<AGROW>
                if runtime < 60; M{end+1} = [ratname,' ran for only ',num2str(max(runtime)),' minutes today in session ',num2str(slot),'.']; end

                %Problem 5: Did the rat run in the wrong session? Compare run time to session standard
                clear inslot
                for j=1:length(st); try inslot(j) = checkruninslot(st{j},ed{j},slot); catch; inslot(j) = nan; end; end %#ok<AGROW>
                if strcmp(datestr(now,'ddd'),'Sun') == 0 && all(inslot ~= 0)
                    for j = 1:length(inslot)
                        if inslot(j) == -1; M{end+1} = [ratname,' ran from ',st{j},' to ',ed{j},' which is before his scheduled time of session ',num2str(slot)]; end
                        if inslot(j) ==  1; M{end+1} = [ratname,' ran from ',st{j},' to ',ed{j},' which is after his scheduled time of session ', num2str(slot)]; end
                    end
                end
                
                %Problem 6: Did the rat get water?
                waterpos = find(strcmp(RatW,ratname) == 1,1,'first');
                if isempty(waterpos); M{end+1} = [ratname,' trained in session ',num2str(slot),' but was not watered today.']; end
                
                %Problem 7: Did the rat get his 30 minute break between training and watering?
                if ~isempty(waterpos) && slot ~= 6
                    wst = Wst{waterpos};
                    breaktime = ceil(timediff(ed{end},wst,2) / 60);
                    if     breaktime < 0;  M{end+1} = [ratname,' was watered while training in session ',num2str(slot),'??'];
                    elseif breaktime < 20; M{end+1} = [ratname,' only had a ',num2str(breaktime),' minute break between training in session ',num2str(slot),' and watering.']; 
                    end
                end
                
                %If we are not doing a full output, remove all previous error messages
                if ~strcmp(outtype,'full'); M = cell(0); end
                
                %Check for technotes for the rats realrig
                for j = 1:length(RR)
                    n = find(RigN == RR(j));
                    for k=1:length(n)
                        if isempty(M); M{end+1} = ['Notes relevant for ',ratname]; end
                        M{end+1} = ['TechNote by ',upper(InN{n(k)}),' for Rig ',num2str(RR(j)),': ',char(Notes{n(k)})']; 
                    end
                end
                
                %Check for technotes for the rats slot
                n = find(SlotN == slot);
                for j=1:length(n)
                    if isempty(M); M{end+1} = ['Notes relevant for ',ratname]; end
                    M{end+1} = ['TechNote by ',upper(InN{n(j)}),' for Session ',num2str(slot),': ',char(Notes{n(j)})']; 
                end
                    
            end
        else
            %This is a non-training rat.
            
            %Problem 8: If he is free water, was he checked?
            regpos = find(strcmp(RatR,ratname) == 1,1,'first');
            if ~isempty(regpos) && DepWR(regpos) == 0
                if sum(strcmp(RatW,ratname))==0; M{end+1} = [ratname,' is a free water rat but was not checked today.']; end
            end
            
            %If we are not doing a full output, remove all previous error messages
            if ~strcmp(outtype,'full'); M = cell(0); end
        end
        
        %Check for technotes for the rat
        n = find(strcmp(RatN,ratname));
        for j=1:length(n); M{end+1} = ['TechNote by ',upper(InN{n(j)}),' for ',ratname,': ',char(Notes{n(j)})']; end
        
        %Check for this rat is done. Log the message if there is one
        if ~isempty(M); eval(['X.rat.',ratname,' = M;']); end
    end
    
    %check all used rigs
    UR = unique(Rigs);
    for i = 1:length(UR)
        M = cell(0);
        
        %Check for technotes for the rig
        n = find(RigN == UR(i));
        for j = 1:length(n); M{end+1} = ['TechNote by ',upper(InN{n(j)}),' for Rig ',num2str(UR(i)),': ',char(Notes{n(j)})']; end
        
        %Check for this rig is done. Log the message if there is one
        if ~isempty(M); eval(['X.rig.R',num2str(UR(i)),' = M;']); end
    end
    
    %check all used sessions
    US = unique(Slots);
    for i = 1:length(US)
        M = cell(0);
        
        %Check for technotes for the session
        n = find(SlotN == US(i));
        for j = 1:length(n); M{end+1} = ['TechNote by ',upper(InN{n(j)}),' for Session ',num2str(US(i)),': ',char(Notes{n(j)})']; end
        
        %Check for this session is done. Log the message if there is one
        if ~isempty(M); eval(['X.session.S',num2str(US(i)),' = M;']); end
    end
    
    
    %Now we loop through all the lab personel and construct each email
    if ~exist('X','var'); disp('No Problems Found'); return; end
    if isfield(X,'rat');     badrats = fields(X.rat);     else badrats = []; end
    if isfield(X,'rig');     br = fields(X.rig);     for i=1:length(br); badrigs(i)=str2num(br{i}(2:end)); end; else badrigs = []; end
    if isfield(X,'session'); bs = fields(X.session); for i=1:length(bs); badsess(i)=str2num(bs{i}(2:end)); end; else badsess = []; end
    for i = 1:length(Exps)
        M = cell(0);
        email = Emails{i}(1:find(Emails{i} == '@')-1);
        
        %Loop through the rats with problems
        didheader = 0;
        for j = 1:length(badrats)
            
            %Find out who owns the rat
            ratcontact = cell(0); RC = cell(0);
            temp = strcmp(RatR,badrats{j});
            if sum(temp) ~= 0; ratcontact = Contacts(temp); end 
            for k = 1:length(ratcontact)
                temp = ratcontact{k};
                temp(temp == ' ') = '';
                st = 1;
                for m = 2:length(temp)
                    if temp(m) == ',';    RC{end+1} = temp(st:m-1); st = m+1; end
                    if m == length(temp); RC{end+1} = temp(st:m);             end
                end
            end
            
            %If this is the owner of the rat, the lab manager, someone who has subscribed to all, 
            %carlos, or the tech who trained the rat, send them the info
            temp = find(strcmp(RatSC,badrats{j}) == 1); if ~isempty(temp); S = Slots(temp); else S = nan; end
            if sum(strcmp(email,RC)) > 0 || LMs(i) == 1 || SAs(i) == 1 || strcmp(email,'brody') ||...
                    (TMs(i) == 1 && S <= 3) || (TAs(i) == 1 && S >= 4)
                Mtemp = eval(['X.rat.',badrats{j},';']);
                for k = 1:length(Mtemp)
                    if k==1 && didheader==0; M{end+1} ='RAT ISSUES'; M{end+1} =' '; didheader=1; end
                    M{end+1} = Mtemp{k};
                end 
                if ~isempty(Mtemp); M{end+1} = ' '; end
            end
        end
        
        %Loop through the rigs with problems
        didheader = 0;
        for j = 1:length(badrigs)
            
            %If this is the lab manager, someone who has subscribed to all,
            %the computer tech, or carlos, send them the info
            if LMs(i) == 1 || SAs(i) == 1 || TCs(i) == 1 || strcmp(email,'brody')
                Mtemp = eval(['X.rig.R',num2str(badrigs(j)),';']);
                for k = 1:length(Mtemp)
                    if k==1 && didheader==0; M{end+1} =' '; M{end+1} =' '; M{end+1}='RIG ISSUES'; M{end+1} =' '; didheader=1; end
                    M{end+1} = Mtemp{k}; 
                end 
            end
        end
        
        %Loop through the sessions with problems
        didheader = 0;
        for j = 1:length(badsess)
            
            %If this is the lab manager, someone who has subscribed to all,
            % or carlos, send them the info
            if LMs(i) == 1 || SAs(i) == 1 || strcmp(email,'brody')
                Mtemp = eval(['X.session.S',num2str(badsess(j)),';']);
                for k = 1:length(Mtemp); 
                    if k==1 && didheader==0; M{end+1} =' '; M{end+1} =' '; M{end+1} ='SESSION ISSUES'; M{end+1} =' '; didheader=1; end
                    M{end+1} = Mtemp{k}; 
                end 
            end
        end
        
        %Add any technotes directed at this person
        n = find(strcmpi(ExpN,Exps{i}) == 1);
        for j = 1:length(n); 
            if j == 1; M{end+1}=' '; M{end+1}=' '; M{end+1}='PERSONAL NOTES'; M{end+1}=' '; end
            M{end+1} = ['TechNote entered by ',upper(InN{n(j)}),' for ',ExpN{n(j)},': ',char(Notes{n(j)})']; 
        end
        
        %Add any general notes
        n = find((strcmp(RatN,'') & isnan(RigN) & isnan(SlotN) & strcmp(ExpN,'')) == 1);
        for j = 1:length(n); 
            if j == 1; M{end+1}=' '; M{end+1}=' '; M{end+1}='GENERAL NOTES'; M{end+1}=' '; end
            M{end+1} = ['General TechNote entered by ',upper(InN{n(j)}),': ',char(Notes{n(j)})']; 
        end
        
        %If there is a message, and the person has initials in the contacts page (used as a subscribe to email flag), send it
        if ~isempty(M) && ~Alum(i)
            M = remove_duplicate_lines2(M);
            disp(Exps{i}); disp(' '); for j = 1:length(M); disp(M{j}); end; disp(' '); disp(' ');
            sendmail(Emails{i},'Potential Training Problems',M);  
        end
    end
    
    %save the output structure
    LTR = 'abcdefghijklmnopqrstuvwxyz';
    for ltr = 1:26
        file = ['C:\Automated Emails\Schedule\',yearmonthday,LTR(ltr),'_TrainProblem_Email.mat'];
        if ~exist(file,'file'); save(file,'X'); break; end    
    end
catch %#ok<CTCH>
    senderror_report;
end    
         


