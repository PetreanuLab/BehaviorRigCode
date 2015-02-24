function r=getRats(exprmtr_name)
olddir=cd;
try
   

    dd=Settings('get','GENERAL','Main_Data_Directory');

    if isnan(dd)
        dd=['..' filesep 'SoloData'];
    end
    
    if dd(end)~=filesep
        dd(end+1)=filesep;
    end
    
    dd=[dd 'Settings' filesep exprmtr_name];
    cd(dd);
    fname=dir;

    r={};
    for xi=1:numel(fname)
        if strcmp(upper(fname(xi).name), 'CVS') || fname(xi).name(1)=='.'
			continue;
		end
		if fname(xi).isdir
			try
				cd(fname(xi).name);
				try
					ignore_file=dir('ex_runrats');
					if isempty(ignore_file)
						mf=dir('*.mat');
						if ~isempty(mf)
							r(end+1)={fname(xi).name};
						end
					end
					cd('..')
				catch
					cd('..')
				end
			catch
				warning(['Your directory "' fname(xi).name '" may have a special character']);
			end

		end
    end
    r=r';
catch
    r={''};
end
if isempty(r)
	
    r={''};
end

cd(olddir)