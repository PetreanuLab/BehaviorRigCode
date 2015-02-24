
function varargout=bdata(sqlstr, varargin)
%function bdata
% connects to sql server on brodylab to store some basic stats on each session
% returns 1 on error, 0 on success
% This bdata is compatible with mym 1.36 which returns a single struct output with each requested column as a fieldname.
% earlier versions of mym (<=1.0.9) will not work with this.

persistent CON_ID
mhost='host';

try

if nargin==0
	varargout{1}=CON_ID;
	return;
end

% first check that the server is there
if ~check_connection(mhost)
    warning('bdata:noserver','Server is not accessible')
    CON_ID=[];
    varargout{1}=-1;
    return;
end

action=lower(strtok(sqlstr,' '));

switch action,
    
%% connect    
	case 'connect'
		if nargin<4
			muser='user';
			mpass='pass';
		else
			mhost=varargin{1};
			muser=varargin{2};
			mpass=varargin{3};
		end	

		try

			% mym supports multiple simultaneous connections.
			% Passing -1 asks for the next available connection id.
			CON_ID=mym(-1, 'open',mhost,muser, mpass);
			mym(CON_ID,'use bdata');
			display('connected')
			varargout{1}=CON_ID;
		catch
			varargout{1}=-1;
			showerror(lasterror);
			varargout{2}=lasterror;
		end

            
%% close    
	case 'close'
		if isempty(CON_ID)
			warning('bdata:nohandle','No handle to bdata server')
		else
			varargout{1}=mym(CON_ID, 'close');
		end
		CON_ID=[];
%% status
	case 'status'
		varargout{1}=mym(CON_ID, 'status');
%% sql
	case {'select','insert','show','explain','describe','call'}  % this is an sql statment.
        % by only allowing select and insert it means that properly
        % inserted data cannot be corrupted.  
		
		if isempty(CON_ID)
			not_connected=1;
			fprintf(1,'First time connecting with bdata server since matlab start.\n');
		else
			not_connected=mym(CON_ID, 'status');
			if not_connected
				warning('bdata:lostconnection','May have lost connection with mysql server');
			end
		end
		if not_connected
			[cid]=bdata('connect');
		    
			% This prevents the code from looping endlessly if the server
		    % isn't up.
			if cid==-1
				warning('bdata:noserver','Failed to connect to bdata server');
				return;
			end
				
		end

        
%       mym can  be used like sprintf where place holders like "{S}"
%       are placed in the sql statement and those are filled by a comma
%       seperated list of variables.

        varlist='';
        if nargin>1
            vs=varargin;
            varlist=',vs{1}';
            for vx=2:numel(vs)
                varlist=[varlist ', vs{' num2str(vx) '} '];
            end
        end

%       When mym is used with no outputs it prints out a table.  However,
%       we need to contruct a varargout string for the case where outputs
%       are requested.
%
        if nargout>0
            outstr='S=';
        else
            outstr='';
        end

            
		evalstr=[outstr 'mym(CON_ID,''' sqlstr ''''  varlist ');'];
    	eval(evalstr)
	
        if nargout>0
            fn=fieldnames(S);
            for ox=1:nargout
                varargout{ox}=S.(fn{ox});
            end
        end
        
		
	otherwise
		warning('Mysql:bdata',['The interface does not support the action: ' action])

end

catch
    fprintf(2,'ERROR in bdata: %s\n',evalstr);
    showerror(lasterror)
end    
