function btrialAfterMatch = getTrialAfterTrialPattern(dp,varargin)
% BA Nov 2013
% this function returns boolean vector of length dp.trials. 
% 1 indicates the trial follows a sequence of trials that match a specific pattern
%
% e.g. getTrialAfterTrialPattern(dp,'stimulationOnCond',[1 1 1 1],'ChoiceLeft',[1 1 1 1])
if nargin < 3
    error('Not enough arguments supplied')
end

if(~iscell(varargin{1}))
    numSortFields = length(varargin)/2;
    emptyspots = zeros(numSortFields);
    for i = 1:numSortFields
        sortfield(i) = {varargin{(i-1)*2+1}};
        sortpattern{i} = varargin{2*i};
        emptyspots(i) = ~isempty(sortfield{i});
    end
else
    numSortFields = length(varargin{1})/2;
    emptyspots = zeros(numSortFields);
    thecell = varargin{1};
    for i = 1:numSortFields
        sortfield{i} = thecell{(i-1)*2+1};
        sortpattern{i} = thecell{2*i};
        emptyspots(i) = ~isempty(sortfield{i});
    end
end
sortfield = sortfield(logical(emptyspots));
sortpattern = sortpattern(logical(emptyspots));
numSortFields = length(sortfield);

% return the index of the trial after when the squence occurs
nback = length(sortpattern{1});

bPattern = zeros(numSortFields,dp.ntrials);
for ifield = 1:numSortFields
    if nback ~= length(sortpattern{ifield})
        error('all patterns must be the same length')
    end
    array = dp.(sortfield{ifield});
    indAfter = findPattern(array, sortpattern{ifield})+nback;
    if indAfter<=dp.ntrials
        bPattern(ifield,indAfter)=1;
    end
end
% find the trials that follow matches for all the field sequence pairs
btrialAfterMatch = (sum(bPattern,1)==numSortFields);

