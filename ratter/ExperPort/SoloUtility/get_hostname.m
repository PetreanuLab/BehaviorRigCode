% [hname] = get_hostname   Makes a system call to get a string with hostname
% 
% Returns only non-spaces before the first '.', and returns in all lowercase.
%
% If for some reason there is an error getting the hostname, returns
% 'unknown'. On PCs, if getting the hostname fails, it might be because
% we're on a directory with spaces in the name; in that case, it tried to
% cd c:\ first, get the hostname, and then cd back to whatever directory we
% were in.
% 

function [hname] = get_hostname
   
   try
     if ispc, % If on a PC, try first as normal:
       try [s, hname] = system('hostname');
       catch % If that failed, maybe our current dir has spaces in its name;
         % Try changing to c:\ first. If that fails, we'll give up.
         
         % <~> The following hack was changed because it generates an error
         %     on computers on which the C drive letter is mapped to a
         %     removable media drive with no media currently loaded.
         % currdir = cd; cd('c:\');
         % <~> to this alternative hack:
         currdir = cd;
         for i=1:20 % <~> Climb path up to 20 steps toward root dir.
             system('cd ..');
         end
         % <~> end replace hack
         
         % <~> That said, I have been unable to reproduce the error the
         %     original hack was meant to solve. Unnecessary?
         
         [s, hname] = system('hostname');
         cd(currdir);
       end;
     else % If not a PC do the normal system call:
       [s, hname] = system('hostname');
     end;
 
     u = find(hname=='.');
     if ~isempty(u), u=u(1); hname = hname(1:u-1); end;
     
     hname = lower(hname(~isspace(hname)));
     
   catch
     warning(['Couldn''t get the hostname, reporting it as "unknown."\n' ...
       'Error was %s'], lasterr);
     hname = 'unknown';
   end;
   
   