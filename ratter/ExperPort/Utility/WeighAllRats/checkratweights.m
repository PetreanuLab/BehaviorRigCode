function checkratweights

if isempty(bdata); bdata('connect'); end
setpref('Internet','SMTP_Server','sonnabend.princeton.edu');
setpref('Internet','E_mail','brodymassutility@gmail.com');

sqlstr = 'SELECT DISTINCT ratname FROM ratinfo.rats WHERE extant=1 ORDER BY ratname;';
data = mym(bdata, sqlstr);
ratnames = data.ratname;

pname = 'D:\Brody Lab\ratter\ExperPort\Utility\WeighAllRats\';

load(pname,'sunday_dates');

emaillist = {'B','bwen@Princeton.EDU';...
             'C','brody@Princeton.EDU';...
             'K','ckopec@Princeton.EDU';...
             'J','jerlich@Princeton.EDU';...
             'M','mbialek@Princeton.EDU'};

morningtech = 'glynb@Princeton.EDU';
eveningtech = 'losorio@Princeton.EDU';

notrealrats = {'sen1';'sen2'};

missingeveningmass = cell(0);
missingmorningmass = cell(0);
         
for r = 1:length(ratnames)
    E(r) = ratnames{r}(1); %#ok<AGROW>
end
Exp = unique(E);

for e = 1:length(Exp)
    rattemp = find(E == Exp(e));
    
    message = cell(0);
    badrats = [];
    tempdata = cell(0);
    for r = 1:length(rattemp)
    
        ratname = ratnames{rattemp(r)};
        if sum(strcmp(notrealrats,ratname)) > 0; continue; end
        min_entries = 10;
        max_days    = 30;

        days  = 0:-1:-max_days+1;
        mass = []; 
        for d = days
            sqlstr = ['SELECT DISTINCT mass FROM ratinfo.mass WHERE ratname="',ratname,'" AND date="',datestr(now+d, 29),'";'];
            data = mym(bdata, sqlstr);
            if ~isempty(data.mass) && data.mass ~= 0; mass(end+1) = data.mass;  %#ok<AGROW>
            else                                      mass(end+1) = nan;        %#ok<AGROW>
            end
        end
        datetemp = datestr(now, 25);
        datetemp(datetemp == '/') = '';
        istodaysunday = sum(strcmp(datetemp,Sundays));
        
        for m = 2:length(mass)-1
            if sum(isnan(mass(m-1:m+1))) == 0
                temp = mean([mass(m-1) mass(m+1)]);
                if abs(mass(m-1) - mass(m+1)) / temp < 0.02
                    if abs(mass(m) - temp) / temp > 0.04
                        mass(m) = nan; %#ok<AGROW>
                    end
                end
            end
        end
        
        gooddata = ~isnan(mass);
        goodmass = mass(gooddata);
        gooddays = days(gooddata);
        
        slot = mym(bdata,['SELECT DISTINCT timeslot FROM ratinfo.schedule WHERE ratname="',ratname,'" AND date="',datestr(now, 29),'";']);
        if isnan(mass(1)) && istodaysunday
            if slot.timeslot < 4; missingmorningmass{end+1} = ratname; %#ok<AGROW>
            else                  missingeveningmass{end+1} = ratname; %#ok<AGROW>
            end
        end
            
        if sum(gooddata) < min_entries; continue; end
        weight_declining = 0;

        onedaychange   = (goodmass(1) - goodmass(2)) / mean(goodmass(1:10));
        multidaychange = (mean(goodmass(1:3)) - mean(goodmass(8:10))) / mean(goodmass(1:10));
        [rr pp]        = corrcoef(gooddays(1:10),goodmass(1:10));
        slope          = polyfit(gooddays(1:10),goodmass(1:10),1);
        
        if onedaychange < -0.05 || multidaychange < -0.08 || (rr(2) < 0 && pp(2) < 0.05 && slope(1) < -1);  
            weight_declining = 1; 
        end
        
        if weight_declining == 1
            message{end+1,1} = ratname;                                                       %#ok<AGROW>
            message{end+1,1} =  ' ';                                                          %#ok<AGROW>
            message{end+1,1} = ['One Day Change: ',num2str(round(onedaychange*1e3)/1e3)];     %#ok<AGROW>
            message{end+1,1} = ['Multi Day Change: ',num2str(round(multidaychange*1e3)/1e3)]; %#ok<AGROW>
            message{end+1,1} = ['Multi Day r: ',num2str(round(rr(2)*1e3)/1e3)];               %#ok<AGROW>
            message{end+1,1} = ['Multi Day p: ',num2str(round(pp(2)*1e3)/1e3)];               %#ok<AGROW>
            message{end+1,1} = ['Multi Day slope: ',num2str(round(slope(1)*1e3)/1e3)];        %#ok<AGROW>
            message{end+1,1} =  ' ';                                                          %#ok<AGROW>
            message{end+1,1} = ['Rat Mass Data: ',num2str(goodmass(10:-1:1))];                %#ok<AGROW>
            message{end+1,1} =  ' ';                                                          %#ok<AGROW>
            message{end+1,1} =  ' ';                                                          %#ok<AGROW>
            message{end+1,1} =  ' ';                                                          %#ok<AGROW>
            
            badrats = [badrats,' ',ratname];                                                  %#ok<AGROW>
            
            tempdata{end+1}.ratname = ratname;                                                %#ok<AGROW>
            tempdata{end}.mass = mass;
            
        end
    end
        
    if ~isempty(message)   
        message{end+1,1} = 'Explaination of parameters:';                                                                 %#ok<AGROW>
        message{end+1,1} = 'One Day Change is the percent change in body mass over the past 2 mass entires';              %#ok<AGROW>
        message{end+1,1} = 'Multi Day Change is the percent change in body mass over the past 10 mass entries';           %#ok<AGROW>
        message{end+1,1} = '        the average mass from entries 1:3 is compared to the average mass from entires 8:10'; %#ok<AGROW>
        message{end+1,1} = 'Multi Day r is the correlation coefficient from the linear fit to the last 10 entries';       %#ok<AGROW>
        message{end+1,1} = 'Multi Day p is the p value of the correlation coefficient';                                   %#ok<AGROW>
        message{end+1,1} = 'Rat Mass Data are the last 10 mass entries';                                                  %#ok<AGROW>
        message{end+1,1} = ' ';                                                                                          %#ok<AGROW>
        message{end+1,1} = 'Current Thresholds: ';                                                                       %#ok<AGROW>
        message{end+1,1} = 'One Day Change < -0.05 ';                                                                    %#ok<AGROW>
        message{end+1,1} = 'Multi Day Change < -0.08 ';                                                                  %#ok<AGROW>
        message{end+1,1} = 'Multi Day p < 0.05 ';                                                                        %#ok<AGROW>
        message{end+1,1} = 'Multi Day slope < -1 ';                                                                        %#ok<AGROW>
        
        if ~isempty(tempdata);
            f = figure('color','w'); set(gca,'fontsize',18); hold on;
            c = jet(length(tempdata));
            name = cell(0);
            for r = 1:length(tempdata);
                plot(0:-1:-max_days+1,tempdata{r}.mass,'-o','markerfacecolor',c(r,:),...
                    'markeredgecolor',c(r,:),'markersize',8,'color',c(r,:),'linewidth',2);
                name{r} = tempdata{r}.ratname; 
            end
            legend(gca,name,'Location','EastOutside');
            xlabel(['Days Prior to ',datestr(now,29)]);
            ylabel('Rat Mass, grams'); pause(0.1);
            
            saveas(f,[pname,'ratmassfig.pdf']); pause(0.1);
            close(f);
        end
        
        
        emailexplist = cell2mat(emaillist(:,1));
        email = emaillist(find(emailexplist == Exp(e)),2); %#ok<FNDSB>
        
        
        disp(email);
        disp([badrats,' Weight Declining']);
        for m = 1:length(message);
            disp(message{m});
        end
        disp('  ');
        disp('  ');
        disp('  ');
        disp('  ');
        disp('  ');
        
        sendmail(email,[badrats,' Weight Declining'],message,[pname,'ratmassfig.pdf']);
    end
end 
        
        
for i = 1:2;
    if i == 1; R = missingmorningmass; T = 'morning'; E = morningtech;
    else       R = missingeveningmass; T = 'evening'; E = eveningtech;
    end
    if ~isempty(R)
        message = cell(0);
        message{end+1} = ['The following rats are on the schedule to run in the ',T,' slots']; %#ok<AGROW>
        message{end+1} = 'but have been weighted less than 5 days in the past week and were';  %#ok<AGROW>
        message{end+1} = 'not weighted today.';                                                %#ok<AGROW>
        message{end+1} = '   ';                                                                %#ok<AGROW>
        for r = 1:length(R); message{end+1} = R{r}; end                                        %#ok<AGROW>
        message{end+1} = '   ';                                                                %#ok<AGROW>
        message{end+1} = 'Please remember to weigh all rats that run, every day.';             %#ok<AGROW>
        message{end+1} = '   ';                                                                %#ok<AGROW>
        message{end+1} = 'Thanks,';                                                            %#ok<AGROW>
        message{end+1} = 'The Mass Meister';                                                   %#ok<AGROW>

        sendmail(E,'Missing Rat Weights Detected',message);
        sendmail('brodymassutility@gmail.com','Missing Rat Weights Detected',message);
    end
end
    
    
    
        
        
        
        
        
        
        
        