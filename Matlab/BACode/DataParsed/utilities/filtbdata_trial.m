function dp = filtbdata_trial(dp,trial)
% function dp = filtbdata_trial(dp,trial)
% Filter the dp struct by index of trial.
%
% INPUTS
%   dp: The dp struct
%   trial: trials to include
% OUTPUTS
%   dp: including only this trials


%   Created: 5/2013 - BA


if nargin < 2
    error('Not enough arguments supplied')
end

% Find fields that have same length as spiketimes
reqLength = size(dp.TrialAvail,2);

dp = helperfiltfunc(dp,trial,reqLength);




