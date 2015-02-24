function checkschedulechange

try mym(bdata,'close all'); end %#ok<TRYNC>
bdata('connect');
setpref('Internet','SMTP_Server','sonnabend.princeton.edu');
setpref('Internet','E_mail','brodymassutility@gmail.com');

sqlstr = 'SELECT DISTINCT ratname FROM ratinfo.rats WHERE extant=1 ORDER BY ratname;';
data = mym(bdata, sqlstr);
ratnames = data.ratname;

morningtech = 'glynb@Princeton.EDU';
eveningtech = 'losorio@Princeton.EDU';

morning.ratsremoved = cell(0);
morning.ratsadded   = cell(0);
morning.ratsmoved   = cell(0);

evening.ratsremoved = cell(0);
evening.ratsadded   = cell(0);
evening.ratsmoved   = cell(0);

for r = 1:length(ratnames)
    ratname = ratnames{r};
    temp1 = mym(bdata,['SELECT DISTINCT timeslot FROM ratinfo.schedule WHERE ratname="',ratname,'" AND date="',datestr(now-1, 29),'";']);
    temp2 = mym(bdata,['SELECT DISTINCT timeslot FROM ratinfo.schedule WHERE ratname="',ratname,'" AND date="',datestr(now, 29),'";']);
    
    temp3 = mym(bdata,['SELECT DISTINCT rig FROM ratinfo.schedule WHERE ratname="',ratname,'" AND date="',datestr(now-1, 29),'";']);
    temp4 = mym(bdata,['SELECT DISTINCT rig FROM ratinfo.schedule WHERE ratname="',ratname,'" AND date="',datestr(now, 29),'";']);
    
    slot_yesterday = temp1.timeslot;
    slot_today     = temp2.timeslot;
    
    rig_yesterday  = temp3.rig;
    rig_today      = temp4.rig;
    
    if length(slot_yesterday) > 1 || length(slot_today) > 1 || length(rig_yesterday) > 1 || length(rig_today) > 1; continue; end
    
    if (isempty(slot_yesterday) && isempty(slot_today)); continue; end
    
    if isempty(slot_today) && ~isempty(slot_yesterday)
        %Rat removed
        if slot_yesterday <= 3
            morning.ratsremoved{end+1} = [ratname,' removed from session ',num2str(slot_yesterday)];
        end
        if slot_yesterday >= 4
            evening.ratsremoved{end+1} = [ratname,' removed from session ',num2str(slot_yesterday)];
        end
        
    elseif ~isempty(slot_today) && isempty(slot_yesterday)
        %Rat added
        if isempty(slot_yesterday) && slot_today <= 3
            morning.ratsadded{end+1}   = [ratname,' added to rig ',num2str(rig_today),' session ',num2str(slot_today)];
        end
        if isempty(slot_yesterday) && slot_today >= 4
            evening.ratsadded{end+1}   = [ratname,' added to rig ',num2str(rig_today),' session ',num2str(slot_today)];
        end
        
    elseif ~isempty(slot_today) && ~isempty(slot_yesterday)
        if slot_today == slot_yesterday && rig_today == rig_yesterday; continue; end
        
        %Moved within session
        if slot_yesterday <= 3 && slot_today <= 3 && slot_yesterday == slot_today; 
            morning.ratsmoved{end+1}   = [ratname,' moved from rig ',num2str(rig_yesterday),' to rig ',num2str(rig_today),' in session ',num2str(slot_today)];
        end
        if slot_yesterday >= 4 && slot_today >= 4 && slot_yesterday == slot_today; 
            evening.ratsmoved{end+1}   = [ratname,' moved from rig ',num2str(rig_yesterday),' to rig ',num2str(rig_today),' in session ',num2str(slot_today)];
        end
        
        %Moved between sessions, same techs
        if slot_yesterday <= 3 && slot_today <= 3 && slot_yesterday ~= slot_today
            morning.ratsremoved{end+1} = [ratname,' removed from session ',num2str(slot_yesterday)];
            morning.ratsadded{end+1}   = [ratname,' added to rig ',num2str(rig_today),' session ',num2str(slot_today)];
        end
        if slot_yesterday >= 4 && slot_today >= 4 && slot_yesterday ~= slot_today
            evening.ratsremoved{end+1} = [ratname,' removed from session ',num2str(slot_yesterday)];
            evening.ratadded{end+1}    = [ratname,' added to rig ',num2str(rig_today),' session ',num2str(slot_today)];
        end 
        
        %Moved between session, different techs
        if slot_yesterday <= 3 && slot_today >= 4
            morning.ratsremoved{end+1} = [ratname,' removed from session ',num2str(slot_yesterday)];
            evening.ratsadded{end+1}   = [ratname,' added to rig ',num2str(rig_today),' session ',num2str(slot_today)];
        end
        if slot_yesterday >= 4 && slot_today <= 3
            evening.ratsremoved{end+1} = [ratname,' removed from session ',num2str(slot_yesterday)];
            morning.ratadded{end+1}    = [ratname,' added to rig ',num2str(rig_today),' session ',num2str(slot_today)];
        end 
    end
end

for i = 1:2;
    if i == 1; T = 'morning'; E = morningtech; S = [1 2 3];
    else       T = 'evening'; E = eveningtech; S = [4 5 6];
    end
    message = cell(0);
    eval(['RR = ',T,'.ratsremoved;']);
    eval(['RA = ',T,'.ratsadded;']);
    eval(['RM = ',T,'.ratsmoved;']);
    if ~isempty(RR) || ~isempty(RA) || ~isempty(RM)                                             %#ok<USENS>
        for s = S
            message{end+1} = ['Session ',num2str(s),' changes:'];                               %#ok<AGROW>
            message{end+1} = '  ';                                                              %#ok<AGROW>
            for a = 1:length(RR); if RR{a}(end) == num2str(s); message{end+1} = RR{a}; end; end %#ok<AGROW>
            message{end+1} = '  ';                                                              %#ok<AGROW>
            for a = 1:length(RA); if RA{a}(end) == num2str(s); message{end+1} = RA{a}; end; end %#ok<AGROW>
            message{end+1} = '  ';                                                              %#ok<AGROW>
            for a = 1:length(RM); if RM{a}(end) == num2str(s); message{end+1} = RM{a}; end; end %#ok<AGROW>
            message{end+1} = '  ';                                                              %#ok<AGROW>
            message{end+1} = '  ';                                                              %#ok<AGROW>
            message{end+1} = '  ';                                                              %#ok<AGROW>
        end
        for m = 1:length(message); disp(message{m}); end
        
        sendmail(E,'Training Schedule Changes',message);
    end
end
disp(morning)
disp(evening)
    
    
    
    
    