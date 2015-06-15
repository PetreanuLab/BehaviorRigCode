function dp = loadBControlsession(nAnimal,nsession,protocol)
% function ratbase = loadsession(nAnimal,nsession,protocol)
% function ratbase = loadsession(filename)

% loadsession - transforms data format from SoloData to dataparsed
%
%   Reads data in files saved from solo system and transforms it
%   to a user-friendly 'dataparsed' data format.

%   - OUTPUT


if isunix
    slash = '/';
else
    slash = '\';
end

%%rd = brigdefs('bcontrol');
rd = visRigDefs;
rd.Dir.BControlDataBehav = rd.DIR.ratterData;
% solo_filename = fullfile('C:\ratter\data\Data\BVA\VGAT_1385','data_@Head_fixed2_BVA_VGAT_1385_141014a.mat');


% if nargin <=1,
%     behavior_only = 1; %default is use solo time (third column)
% end;
nfile = 1;
if nargin ==1 % assume input is a filename with path
    solo_filename = {nAnimal};
elseif nargin ==0
    [FileName,PathName] = uigetfile(fullfile(rd.Dir.BControlDataBehav,slash,'*.mat'),'MultiSelect','On','Select Behavior file to analyze');
    if iscell(FileName)
        
        nfile = length(FileName);
        for ifile = 1: nfile
            solo_filename{ifile} = fullfile(PathName,FileName{ifile});
        end
    else
        solo_filename{1} = fullfile(PathName,FileName);
    end
else
    % DataFolder=fullfile('C:\Users\Bass\Documents\BVA_Work\SoloData');
    DataFolder=fullfile(rd.Dir.BControlDataBehav,experimenter,nAnimal);
    
    
    f = dir([DataFolder '\*' protocol '*.mat']);
    solo_filename = {fullfile(DataFolder,f(nsession).name)};
end
%% Information about session
for ifile = 1:nfile
    load(solo_filename{ifile})
    temp_dp.FullPath = solo_filename{ifile};
    temp_dp.FileNumber = NaN;
    [temp_dp.PathName, temp_dp.FileName] = fileparts(solo_filename{ifile});
    temp_dp.Animal = saved.SavingSection_ratname;
    
    %get protocol name
    indStart = strfind(solo_filename{ifile},'@')+1;
    indEnd = strfind(solo_filename{ifile},'_');
    indEnd = indEnd(end-2)-1;
    temp_dp.Protocol = solo_filename{ifile}(indStart:indEnd);
    temp_dp.ProtocolVersion = '';
    
    
    temp_dp.Experimenter =saved.SavingSection_experimenter;
    temp_dp.Date =    datestr(datenum(saved.SavingSection_SaveTime),'YYMMDD');
    
    %% Initialize trial-based variables
    start_trial=1;
    end_trial = length(saved_history.ProtocolsSection_parsed_events);
    num_trials=end_trial-start_trial+1;
    
    temp_dp.Rev = 0;
    temp_dp.recordingSystem = 'bcontrol';
    temp_dp.Box = 1;
    temp_dp.AnimalSpecies = '';
    
    temp_dp.ntrials = num_trials;
    temp_dp.parsedEvents_history =saved_history.ProtocolsSection_parsed_events(start_trial:end_trial)';
    
    switch temp_dp.Protocol
        case 'VisualSpatialDetection'
            dp(ifile) = loadBC_VSD_helper(temp_dp,saved_history,saved);
        case 'VisualSpatialDetection_EarlyLick_delays_change'
            dp(ifile) = loadBC_VSD_helper(temp_dp,saved_history,saved);
            
        case 'Head_fixed2' % don't know if this helper function works right
            
            dp(ifile) = loadBC_goNogoWait_helper(temp_dp,saved_history);
        case 'GoNoGoDetection'
            dp(ifile) = loadBC_GoNogoDetection_helper(temp_dp,saved_history,saved);

        otherwise
            error(['unknown protocol ' temp_dp.Protocol])
    end
    
end

for ifile = 1:nfile
    dp(ifile).absolute_trial = dp(ifile).TrialNumber;
end

if nfile>1
    options.concatenateTimes =1 ;
        dp = concdp(dp,[],options);
    end
    
    
