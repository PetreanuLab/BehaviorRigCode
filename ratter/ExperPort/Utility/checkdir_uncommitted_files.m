function checkdir_uncommitted_files

RID = Settings('get','RIGS','Rig_ID');
if isnan(RID); pause((rand(1)*600)+1800); 
else           pause(RID*120);
end

D = Settings('get','GENERAL','Main_Data_Directory');
Ds = {[D,filesep,'Data'], [D,filesep,'Settings']};

if exist([D,filesep,'uncommitable_files.mat'],'file') == 0
    uncommitable = cell(1,2);
else
    load([D,filesep,'uncommitable_files.mat']);
end

for d = 1:length(Ds)
    Exp = dir(Ds{d});
    
    for e = 1:length(Exp)
        if strcmp(Exp(e).name,'.')   || strcmp(Exp(e).name,'..') ||...
           strcmp(Exp(e).name,'CVS') || strcmp(Exp(e).name,'experimenter') ||...
           ~Exp(e).isdir
            continue; 
        end
        
        ratnames = dir([Ds{d},filesep,Exp(e).name]);
        
        for r = 1:length(ratnames)
            if strcmp(ratnames(r).name,'.')   || strcmp(ratnames(r).name,'..') ||...
               strcmp(ratnames(r).name,'CVS') || strcmp(ratnames(r).name,'ratname') ||...
               ~ratnames(r).isdir
                continue; 
            end
            
            p = [Ds{d},filesep,Exp(e).name,filesep,ratnames(r).name];
            disp(['Checking: ',p]);
            
            z      = dir(p);
            files  = cell(length(z),1);
            status = cell(length(z),1);
            fcnt = 0; scnt = 0;
            cd(p); pause(0.01);

            
            F = fopen([p,filesep,'CVS',filesep,'Entries']);
            if F == -1; continue; end
            y = textscan(F,'%s','Delimiter','\n');
            y = y{1};
            fclose(F);
            for i = 1:length(y)
                if y{i} == 'D'; continue; end
                breaks = find(y{i} == '/');
                if isempty(breaks); continue; end
                fcnt = fcnt + 1; scnt = scnt + 1;
                files{fcnt}  = y{i}(breaks(1)+1:breaks(2)-1);
                status{scnt} = y{i}(breaks(2)+1:breaks(3)-1);
            end
            
            
%             [x,y] = system('cvs status');
%             startstatus = 0;
%             spc = isspace(y);
%             for i = 1:length(y)-8
%                 if y(i) == 'F' || y(i) == 'S'
%                     if strcmp(y(i:i+5),'File: ') == 1; startfile = i+6; end
%                     if strcmp(y(i:i+7),'Status: ') == 1; 
%                         fcnt=fcnt+1;
%                         files{fcnt} = y(startfile:find(spc(1:i-1) == 0,1,'last')); 
%                         startstatus = i+8;
%                     end
%                 end
%                 if y(i) ~= ' ' && spc(i) == 1 && startstatus ~= 0
%                     scnt=scnt+1;
%                     status{scnt} = y(startstatus:i-1);
%                     startstatus = 0;
%                 end
%             end
            files( fcnt+1:end) = [];
            status(scnt+1:end) = [];
            
            badfiles = cell(0);
            for i = 1:length(z)
                if z(i).isdir == 1; continue; end
                temp = strcmp(z(i).name,files);
                if sum(temp) == 0; badfiles{end+1} = z(i).name;  %#ok<AGROW>
                else
                    if status{temp}=='0'; badfiles{end+1} = z(i).name; end %#ok<AGROW>
                end
            end
%             for i = 1:length(z)
%                 if z(i).isdir == 1; continue; end
%                 temp = strcmp(z(i).name,files);
%                 if sum(temp) == 0; badfiles{end+1} = z(i).name;  %#ok<AGROW>
%                 else
%                     if ~strcmp(status{temp},'Up-to-date'); badfiles{end+1} = z(i).name; end %#ok<AGROW>
%                 end
%             end
            
            skipfile = [];
            for i = 1:length(badfiles)
                if badfiles{i}(1) ~= 's' && badfiles{i}(1) ~= 'd'
                    skipfile(end+1) = i; %#ok<AGROW>
                    continue;
                end
                if length(badfiles{i}) > 2 && ~strcmp(badfiles{i}(end-2:end),'mat')
                    skipfile(end+1) = i; %#ok<AGROW>
                    continue;
                end
                for j = 1:length(badfiles{i})-2
                    if badfiles{i}(j) == 'a' || badfiles{i}(j) == 'A'
                        if strcmp(badfiles{i}(j:j+2),'asv') || strcmp(badfiles{i}(j:j+2),'ASV');
                            skipfile(end+1) = i; %#ok<AGROW>
                            break;
                        end
                    end
                end
                temp = strcmp(badfiles{i},uncommitable(:,1));
                if sum(temp) > 0 && uncommitable{temp,2} >= 10; skipfile(end+1) = i; end %#ok<AGROW>
            end
            badfiles(skipfile) = [];
            disp(badfiles');
            
            
            
            for i = 1:length(badfiles)
                [errID errmsg] = add_and_commit(badfiles{i}); %#ok<NASGU>
                if errID ~= 0
                    temp = strcmp(badfiles{i},uncommitable(:,1));
                    if sum(temp) == 0
                        uncommitable(end+1,1) = {badfiles{i}}; %#ok<AGROW>
                        uncommitable(end  ,2) = {1};
                    else
                        uncommitable(temp ,2) = {uncommitable{temp,2} + 1};
                    end
                end
            end
        end
    end
end

save([D,filesep,'uncommitable_files.mat'],'uncommitable');
