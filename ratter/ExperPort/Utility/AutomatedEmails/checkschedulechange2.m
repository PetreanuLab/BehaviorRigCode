function checkschedulechange2(shift,varargin)

try 
    if nargin == 0; shift = [1 2]; end

    sqlstr = 'SELECT DISTINCT ratname FROM ratinfo.rats WHERE extant=1 ORDER BY ratname;';
    try 
        data = mym(bdata, sqlstr);
    catch %#ok<CTCH>
        bdata('connect');
        data = mym(bdata, sqlstr);
    end

    setpref('Internet','SMTP_Server','sonnabend.princeton.edu');
    setpref('Internet','E_mail','ScheduleMeister@Princeton.EDU');

    ratnames = data.ratname;

    X.ratsremoved = cell(0);
    X.ratsadded   = cell(0);
    X.ratsmoved   = cell(0);

    output = []; %#ok<NASGU>

    for r = 1:length(ratnames)
        ratname = ratnames{r};
        temp1 = mym(bdata,['SELECT DISTINCT timeslot FROM ratinfo.schedule WHERE ratname="',ratname,'" AND date="',datestr(now-1, 29),'";']);
        temp2 = mym(bdata,['SELECT DISTINCT timeslot FROM ratinfo.schedule WHERE ratname="',ratname,'" AND date="',datestr(now, 29),'";']);

        temp3 = mym(bdata,['SELECT DISTINCT rig FROM ratinfo.schedule WHERE ratname="',ratname,'" AND date="',datestr(now-1, 29),'";']);
        temp4 = mym(bdata,['SELECT DISTINCT rig FROM ratinfo.schedule WHERE ratname="',ratname,'" AND date="',datestr(now, 29),'";']);

        slot_yesterday = temp1.timeslot; slot_yesterday(slot_yesterday > 6) = [];
        slot_today     = temp2.timeslot; slot_today(    slot_today     > 6) = [];

        rig_yesterday  = temp3.rig;
        rig_today      = temp4.rig;

        if length(slot_yesterday) > 1 || length(slot_today) > 1 || length(rig_yesterday) > 1 || length(rig_today) > 1; 
            %Rat is on the schedule twice
            for i = 1:length(slot_yesterday)
                for j = 1:length(slot_today)
                    temp5 = find(slot_yesterday == slot_today(j));
                    temp6 = find(slot_today     == slot_yesterday(i));

                    if isempty(temp5)
                        %j is new for today
                        X.ratsadded{end+1} = [ratname,' added to rig ',num2str(rig_today(j)),' session ',num2str(slot_today(j))];

                    elseif rig_yesterday(temp5) ~= rig_today(j)
                        %j is new rig for today
                        X.ratsmoved{end+1} = [ratname,' moved from rig ',num2str(rig_yesterday(temp5)),' to rig ',num2str(rig_today(j)),' in session ',num2str(slot_today(j))];
                    end
                    if isempty(temp6)
                        %i removed for today
                        X.ratsremoved{end+1} = [ratname,' removed from session ',num2str(slot_yesterday(i))];

                    elseif rig_today(temp6) ~= rig_yesterday(i)
                        %i is new rig for today
                        X.ratsmoved{end+1} = [ratname,' moved from rig ',num2str(rig_yesterday(i)),' to rig ',num2str(rig_today(temp6)),' in session ',num2str(slot_today(temp6))];
                    end
                end
            end

            continue;
        end

        if (isempty(slot_yesterday) && isempty(slot_today)); continue; end

        if isempty(slot_today) && ~isempty(slot_yesterday)
            %Rat removed
            X.ratsremoved{end+1} = [ratname,' removed from session ',num2str(slot_yesterday)];

        elseif ~isempty(slot_today) && isempty(slot_yesterday)
            %Rat added
            X.ratsadded{end+1}   = [ratname,' added to rig ',num2str(rig_today),' session ',num2str(slot_today)];

        elseif ~isempty(slot_today) && ~isempty(slot_yesterday)
            if slot_today == slot_yesterday && rig_today == rig_yesterday; continue; end

            %Moved within session
            if slot_yesterday == slot_today; 
                X.ratsmoved{end+1}   = [ratname,' moved from rig ',num2str(rig_yesterday),' to rig ',num2str(rig_today),' in session ',num2str(slot_today)];
            end

            %Moved between sessions
            if slot_yesterday ~= slot_today
                X.ratsremoved{end+1} = [ratname,' removed from session ',num2str(slot_yesterday)];
                X.ratsadded{end+1}   = [ratname,' added to rig ',num2str(rig_today),' session ',num2str(slot_today)];
            end 
        end
    end

    for i = shift;
        if i == 1;  
            E = mym(bdata,'SELECT DISTINCT email FROM ratinfo.contacts WHERE tech_morning=1');
            E = E.email;
            S = [1 2 3 4]; 
        else
            E = mym(bdata,'SELECT DISTINCT email FROM ratinfo.contacts WHERE tech_afternoon=1');
            E = E.email;
            S = [4 5 6];
        end
        message = cell(0);
        RR = X.ratsremoved;
        RA = X.ratsadded;
        RM = X.ratsmoved;
        for r = 1:length(RR)-1; temp = []; temp(r+1:length(RR)) = strcmp(RR(r+1:end),RR{r}); RR(find(temp == 1)) = []; end %#ok<FNDSB>
        for r = 1:length(RA)-1; temp = []; temp(r+1:length(RA)) = strcmp(RA(r+1:end),RA{r}); RA(find(temp == 1)) = []; end %#ok<FNDSB>
        for r = 1:length(RM)-1; temp = []; temp(r+1:length(RM)) = strcmp(RM(r+1:end),RM{r}); RM(find(temp == 1)) = []; end %#ok<FNDSB>

        if ~isempty(RR) || ~isempty(RA) || ~isempty(RM)       
            foundaline = 0;
            for s = S
                message{end+1} = ['Session ',num2str(s),' changes:'];                                               %#ok<AGROW>
                message{end+1} = '  ';                                                                              %#ok<AGROW>
                for a = 1:length(RR); if RR{a}(end) == num2str(s); message{end+1} = RR{a}; foundaline = 1; end; end %#ok<AGROW>
                message{end+1} = '  ';                                                                              %#ok<AGROW>
                for a = 1:length(RA); if RA{a}(end) == num2str(s); message{end+1} = RA{a}; foundaline = 1; end; end %#ok<AGROW>
                message{end+1} = '  ';                                                                              %#ok<AGROW>
                for a = 1:length(RM); if RM{a}(end) == num2str(s); message{end+1} = RM{a}; foundaline = 1; end; end %#ok<AGROW>
                message{end+1} = '  ';                                                                              %#ok<AGROW>
                message{end+1} = '  ';                                                                              %#ok<AGROW>
                message{end+1} = '  ';                                                                              %#ok<AGROW>
            end
            message{end+1} = 'Thanks,';                                                                             %#ok<AGROW>
            message{end+1} = 'The Schedule Meister';                                                                %#ok<AGROW>
            message{end+1} = '  ';                                                                                  %#ok<AGROW>
            message{end+1} = '  ';                                                                                  %#ok<AGROW>
            message{end+1} = 'This email was generated by the Brody Lab Automated Email System.';                   %#ok<AGROW>
            %for m = 1:length(message); disp(message{m}); end
            
            if foundaline == 1
                for e = 1:length(E)
                    message = remove_duplicate_lines(message);
                    sendmail(E{e},'Training Schedule Changes',message);
                    expname = mym(bdata,['SELECT DISTINCT experimenter FROM ratinfo.contacts WHERE email="',E{e},'";']);
                    expname = expname.experimenter{1};
                    eval(['output.',expname,' = message;']);
                end
            end
        end
    end

    %if ~isempty(output)
        LTR = 'abcdefghijklmnopqrstuvwxyz';
        for ltr = 1:26
            file = ['C:\Automated Emails\Schedule\Changes\',yearmonthday,LTR(ltr),'.mat'];
            if ~exist(file,'file'); save(file,'output'); break; end    
        end
    %end
catch %#ok<CTCH>
    senderror_report;
end

    
    
    