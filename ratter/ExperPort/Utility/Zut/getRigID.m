% <~> Fetches the Rig ID of this machine.
%       (part of the Zut suite of code for the Brodylab).
%
%     This was written as part of the Zut suite for the Brodylab.
%
%     [iRig e m] = getRigID()
%
%     Sebastien Awwad, 2008.Sep
%
%
%     RETURNS:
%     --------
%     1. iRig          int, the rig number for this machine.
%                        If the setting [RIGS; Rig_ID] is set in a settings
%                          file (e.g. Settings/Settings_Custom.conf) and is
%                          numeric, then that number is used.
%                        Otherwise, we use the first string of consecutive
%                          digits in the hostname of this machine.
%                          The hostname is queried using get_hostname.
%                       A leading zero is stripped if it exists (and the
%                         number is not simply one zero).
%
%     2. errID           0 if there are no errors
%                       -1 for a programming error
%                        1 if unable to make a guess at the rig number
%     3. errmsg         '' if there are no errors, else a descriptive str.
%
function [rigID errID errmsg] = getRigID()
errID           = -1; %#ok<NASGU>
errmsg          = ''; %#ok<NASGU>

%     FIRST: attempt to retrieve the [RIGS;Rig_ID] setting.
[rigID e m] = Settings('get','RIGS','Rig_ID');
if ~e && isa(rigID,'double') && length(rigID)==1,
    %     If that worked, then we can just return with that rigID.
    errID       = 0;
    return;
    
else
    %     Otherwise, setting [RIGS;Rig_ID] is not set (or not set to an
    %       integer), so we will try to use the hostname.
    [trash1 trash2 trash3 strHost] = regexp(get_hostname(),'[0123456789]+');
    if isempty(strHost),
        errID   = 1;
        errmsg  = ['Zut:getRigID was unable to determine rig number. 1- The RIGS;Rig_ID setting is not set or not a number, and 2- I could not find any numbers in the machine''s hostname. Error message from attempt to retrieve RIGS;Rig_ID setting follows:   ' m];
        return;
    else
        rigID   = str2double(strHost{1});
        errID   = 0;
        errmsg  = 'getRigID used get_hostname to determine rig number because it was unable to retrieve or interpret the setting RIGS;Rig_ID. Using that setting is preferable to hostname-based guessing.';
        return;
    end; %     end if/else get_hostname returns nonempty string
end;     %     end if/else setting RIGS;Rig_ID is defined & set to an integer
error('Zut:getRigID: Programming error. This line should never be reached.');
end      %     end of function getRigID
