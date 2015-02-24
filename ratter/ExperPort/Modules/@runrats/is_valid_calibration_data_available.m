%IS_VALID_CALIBRATION_DATA AVAILABLE
%   Function to check if valid calibration data is available
%
%   e.g. is_valid_calibration_data_available(obj, 14) would check to see if
%   calibration data newer than 14 days is available. Returns true if it is
%   available, and false if it is not.

function rvalue = is_valid_calibration_data_available(obj, varargin) %#ok<INUSL>

%Argument checking
if nargin==1
    error('Too few arguments');
elseif nargin==2 && ~isnumeric(varargin{1})
    error('Second argument must be numeric');
elseif nargin>=3
    error('Too many arguments');
end

num_days_considered = varargin{1};

% Setting Calibration_Data_Directory
Calibration_Data_Directory = Settings('get', 'GENERAL', 'Calibration_Data_Directory');
if isnan(Calibration_Data_Directory)
    Calibration_Data_Directory = '\ratter\CNMC\Calibration';
end
Calibration_Data_Directory = strrep(Calibration_Data_Directory, '\', filesep);

% Setting hostname
[status, hostname] = system('hostname');
hostname = lower(hostname);
hostname = regexprep(hostname, '\s', '');
hostname = regexprep(hostname, '\..*', '');

%Check to see if valid calibration data exists for all valves
left1water = Settings('get', 'DIOLINES', 'left1water');     is_left_ok = false;
center1water = Settings('get', 'DIOLINES', 'center1water'); is_center_ok = false;
right1water = Settings('get', 'DIOLINES', 'right1water');   is_right_ok = false;
if isnan(left1water)
    is_left_ok = true;
end
if isnan(center1water)
    is_center_ok = true;
end
if isnan(right1water)
    is_right_ok = true;
end

if ~exist(fullfile(Calibration_Data_Directory, [hostname '_watertable.mat']), 'file')
    rvalue = false;
    return;
else
    load(fullfile(Calibration_Data_Directory, [hostname '_watertable.mat']));
    assert(isfield(wt, 'isvalid') && isfield(wt, 'date'));
    rvalue = false;
    for ctr = length(wt):-1:1
        if abs(etime(datevec(wt(ctr).date), datevec(now))) <= num_days_considered*24*3600 && wt(ctr).isvalid
            if ~isnan(left1water) && strcmp(wt(ctr).valve, 'left1water')
                is_left_ok = true;
            end
            if ~isnan(center1water) && strcmp(wt(ctr).valve, 'center1water')
                is_center_ok = true;
            end
            if ~isnan(right1water) && strcmp(wt(ctr).valve, 'right1water')
                is_right_ok = true;
            end
            rvalue = is_left_ok && is_center_ok && is_right_ok;
            if rvalue == true
                return;
            end
        end
    end
end

end
