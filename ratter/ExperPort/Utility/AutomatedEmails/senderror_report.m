function senderror_report

try %#ok<TRYNC>
    x = lasterror; %#ok<LERR>

    message = cell(0);
    message{end+1} = ['Error Report Generated: ',datestr(now,31)];
    message{end+1} = '';
    message{end+1} = x.message;
    message{end+1} = x.identifier;
    message{end+1} = '';
    
    for i = 1:length(x.stack)
        message{end+1} = ['error in ',x.stack(i).name,' at line ',num2str(x.stack(i).line)]; %#ok<AGROW>
    end

    sendmail('ckopec@princeton.edu','AES Error Report',message);
	sendmail('vkarri@princeton.edu','AES Error Report',message);
end