function [ip,mac]=get_network_info
ip = ' '; mac=' ';  % Default values in case ip address cannot be determined
try
if isunix
    % if we are on linux or mac
    % get the ip address
    % [s,r]=system('netstat -n | grep -A1 Local');
    % linebreak=find(r==10);
    % ipstr=r(linebreak(1):end);
    % tout=textscan(ipstr,'%s %d %d %s');
    % ipstr=tout{4}{1};
    % if strfind(computer,'MAC')  % on new computers you can use ismac, but old computers don't have that.
        % dotidx=find(ipstr=='.');
    % else
        % dotidx=find(ipstr==':');
    % end
    % ip=ipstr(1:dotidx(end)-1);
    % now find the mac address associated with the IP address.
    
    if strfind(computer,'MAC')
        [s,r]=system(['ifconfig | grep -A1 "' ip '"']);
        macind=strfind(r,'ether');
        mac=r(macind+6:macind+22);
        
    else
        [s,r]=system(['ifconfig | grep -B1 "' ip '"']);
        macind=strfind(r,'HWaddr');
        mac=r(macind+7:macind+23);
    end
    
    
else
    % if we are on windows
    [s,r]=system('ipconfig /all');	
    macind=strfind(r,'Physical');
    for xi=1:numel(macind)
        macc{xi}=r(macind(xi)+36:macind(xi)+52);
    end
    
    ipind=strfind(r,'IP Addr');
    for xi=1:numel(ipind)
        tipc=r(ipind(xi)+35:ipind(xi)+55);
        ipc{xi}=tipc(1:find(tipc==13)-1);        
    end
    mac=strtrim(macc{1});
   % if numel(ipc)== 1
        % ip=strtrim(ipc{1});		
        
    % else
    % end
       
    
end

% Added by Praveen to fetch correct IP address:START
[sss rrr]=system('hostname');
add_1=java.net.InetAddress.getByName(strtrim(rrr));
ip=strtrim(char(add_1.getHostAddress));
% Added by Praveen to fetch correct IP address:STOP
catch
    ip='0.0.0.0';
    mac='00-00-00-00-00-00';
end