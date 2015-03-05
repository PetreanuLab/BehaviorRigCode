function [dpout skipped]= getTrialWOI(dp,triggerTrials,WOI)
% function [dpout skipped]= getTrialWOI(dp,triggerTrials,WOI)
% to do Padd NAN trials rather than skip
% BA

skipped = zeros(size(triggerTrials));
iadded = 1;
for itrig = 1:length(triggerTrials)
    if triggerTrials(itrig)+WOI(2)> dp.ntrials 
        skipped(itrig) = 1;
    elseif triggerTrials(itrig)-WOI(1)< 1 
         skipped(itrig) = 2;
    end
    if ~skipped(itrig) %  check is in the same session
        if isfield(dp,'sessionFileName')
            if any(~ismember(dp.sessionFileName(triggerTrials(itrig)-WOI(1):triggerTrials(itrig)+WOI(2)),...
                    dp.sessionFileName(triggerTrials(itrig))))
                skipped(itrig) = 3;
            end
        end
    end
    if ~skipped(itrig)  
        dpout(iadded) = filtbdata_trial(dp,[triggerTrials(itrig)-WOI(1):triggerTrials(itrig)+WOI(2)]);
        iadded = iadded+1;
    end
end

if ~exist('dpout','var')
    dpout = [];
end
