function handles = init_check(handles)

global comp

RatList = WM_rat_water_list(1,handles,'all');
date_temp = datestr(now,29);    

[all_rats, all_strt, all_stop]=bdata('select rat, starttime, stoptime from ratinfo.water where date = "{S}"',date_temp); 

for s = 1:7
    disp(['Importing Data for Session ',num2str(s),'...']);
    ratnames = unique(RatList{s}(:));
    ratnames(strcmp(ratnames,'')) = [];
    
    STRT = cell(0); STP = cell(0);
    for r = 1:length(ratnames)
        if sum(strcmp(all_rats,ratnames{r})) > 0
            STRT{r} = all_strt{find(strcmp(all_rats,ratnames{r})==1,1,'first')};
            STP{r}  = all_stop{find(strcmp(all_rats,ratnames{r})==1,1,'first')};
        else
            STRT{r} = '';
            STP{r}  = '';
        end
    end
    
    %STRT = all_strt(ismember(all_rats, ratnames));
    %STP = all_stop(ismember(all_rats, ratnames));
    
    strt = unique(STRT);
    stp  = unique(STP);
    
    if length(strt) == 1 && ~isempty(strt{1})
        handles.starttime(s) = datenum([date_temp,' ',strt{1}]);
    elseif length(strt) > 1
        S = [];
        for i=1:length(strt)
            S(i)=sum(strcmp(STRT,strt{i})); %#ok<AGROW>
        end
        con_strt = strt{find(S == max(S),1,'first')};
        if ~isempty(con_strt)
            handles.starttime(s) = datenum([date_temp,' ',con_strt]);
        end
    end
    
    if length(stp) == 1 && ~isempty(stp{1}) &&...
            ((s~=7 && ~strcmp(strt{1},stp{1})) || (s==7 && strcmp(strt{1},stp{1})))
        comp(s) = 1;
    elseif length(stp) > 1
        S = [];
        for i=1:length(stp)
            S(i)=sum(strcmp(STP,stp{i})); %#ok<AGROW>
        end
        con_stp = stp{find(S == max(S),1,'first')};
        if ~isempty(con_stp)
            comp(s) = 1;
        end
    end 
    
    str1 = 'BackgroundColor'; %#ok<NASGU>
    if comp(s) == 1
        eval(['set(handles.session',num2str(s),'_toggle,str1,[0 1 1]);']);
    elseif ~isnan(handles.starttime(s))
        eval(['set(handles.session',num2str(s),'_toggle,str1,[1 1 0]);']);
        handles.start(s) = 1;
    end
end





