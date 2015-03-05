function dp = sortdpByTimeRelativeTo(dp,sortfield,relativeField)
% set relativeField to ''  use absolute time
% by default relativeField is 'TrialInit' so if sortfield is in absolute
% time (in session) this functino will sort by time in trial)
if ~exist('relativeField','var')
    relativeField = 'TrialInit';
end


if ~isempty(relativeField)
    % get the relative sortFieldTime 
    timeInTrial = dp.(sortfield) - dp.(relativeField);
    
else % use absolute time
    timeInTrial= dp.(sortfield);
end

[~, sortInd] = sort(timeInTrial);

dp = filtbdata_trial(dp,sortInd);