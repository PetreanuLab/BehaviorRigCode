function [strc sortvector] = filtbdata(strc,options,sweepfilter,trialRelativeSweepfilter)
% function strc = filtBdata(strc,options,sweepfilter,trialRelativeSweepfilter)
%
% Filter the strc struct according to one or more property/value pairs.
%
% INPUTS
%   strc: The strc struct
%   options.bOR: 0 for AND, 1 for OR
%   options.bExcludefilter: % set to 1 to EXclude rather then INclude filter
%   sweepfilter: A cell: A property value pair used to filter the strc struct
%   according to the value of the given property for each spike. Multiple
%   property/value pairs can be used to output the strc corresponding to
%   the intersection (AND) or union (OR) of multiple conditions.
%
%   trialRelativeSweepfilter: { [relative Trials to include], property
%   value pair to filter}
% OUTPUTS
%   strc: The filtered strc struct

% e.g
% % if I want all trials that were Correct and Left Choice Where the trial
% before was not stimulated
%  filtBdata(dp,0,{'Correct', 1,'ChoiceLeft' 0},{-1,'stimulationOnCond',[0]})
% if I want all trials that were Correct and Left Choice Where
%the trial before and 2 before were both  stimulated
%  filtBdata(dp,0,{'Correct', 1,'ChoiceLeft' 0},{-1,'stimulationOnCond',[1]}{-2,'stimulationOnCond',[1]})

%   Created: 5/2013 - BA
%

bOR =0;
bExcludefilter = 0; % set to 1 to exclude filter
if isstruct(options)
    if isfield(options,'bOR')
        bOR = options.bOR;
    end
    if isfield(options,'bExcludefilter')
        bExcludefilter = options.bExcludefilter;
    end
elseif~isempty(options) % backward compatible if options is not a struct 
    bOR = options;
end
    
if nargin < 3
    error('Not enough arguments supplied')
end

sortfield = {};
sortvalue = {};
if(~iscell(sweepfilter))
    fromStruct = 0;
    if length(sweepfilter) == 1
        sw = sweepfilter;
        fromStruct = isstruct(sw);
        if fromStruct
            
            sortfield = sw.fieldnames;
            sortvalue = sw.sortvalue;
            numSortFields = length(sortfield);
            emptyspots = zeros(numSortFields,1);
            for i = 1:numSortFields
                emptyspots(i)= ~isempty(sortfield(i));
            end
        else
            error('Not enough input arguments')
        end
    else
        error('sweepfilter incorrectly specified must be a struct or cell')
    end
    
else
    numSortFields = length(sweepfilter)/2;
    emptyspots = zeros(numSortFields,1);
    thecell = sweepfilter;
    for i = 1:numSortFields
        sortfield{i} = thecell{(i-1)*2+1};
        sortvalue{i} = thecell{2*i};
        emptyspots(i) = ~isempty(sortfield{i});
    end
end

if ~isempty(sortfield)
    sortfield = sortfield(logical(emptyspots));
    sortvalue = sortvalue(logical(emptyspots));
end

% parse the sortfields that sort condition on a specific Position (n) Relative
% to a trial, 
trialRelative.n = []; trialRelative.SortField = {}; trialRelative.SortValue = {};
if exist('trialRelativeSweepfilter','var')
    if ~isempty(trialRelativeSweepfilter)
        if ~iscell(trialRelativeSweepfilter{1}) % only one conditions i.e      { ntrials, 'field',value}
            ntrialsBackConditions = 1;
            trialRelative.n = trialRelativeSweepfilter{1};
            if length(trialRelativeSweepfilter)>1
                thecell = trialRelativeSweepfilter(2:end);
                
                clear emptyspots
                for i = 1:length(thecell)/2;
                    
                    trialRelative.SortField{i} = thecell{(i-1)*2+1};
                    trialRelative.SortValue{i} =  thecell{2*i};
                    emptyspots(i) = ~isempty(trialRelative.SortField{i});
                end
                trialRelative.SortField = trialRelative.SortField(logical(emptyspots));
                trialRelative.SortValue = trialRelative.SortValue(logical(emptyspots));
   
            end
        else %     {{ntrial, 'field',value},{ntrial2,'field',value}} here    ntrialsBackConditions = 2
            ntrialsBackConditions = length(trialRelativeSweepfilter); %
            for itrialFilt = 1 : ntrialsBackConditions
                thisRelFilt = trialRelativeSweepfilter{itrialFilt};
                trialRelative(itrialFilt).n = thisRelFilt{1};
                if length(thisRelFilt)>1
                    thecell = thisRelFilt(2:end);
                    
                    clear emptyspots
                    for i = 1:length(thecell)/2;
                        
                        trialRelative(itrialFilt).SortField{i} = thecell{(i-1)*2+1};
                        trialRelative(itrialFilt).SortValue{i} =  thecell{2*i};
                        emptyspots(i) = ~isempty(trialRelative(itrialFilt).SortField{i});
                    end
                    trialRelative(itrialFilt).SortField = trialRelative(itrialFilt).SortField(logical(emptyspots));
                    trialRelative(itrialFilt).SortValue = trialRelative(itrialFilt).SortValue(logical(emptyspots));
                    
                end
            end
        end
    end
end

sortvector = helper(strc,sortfield,sortvalue,bOR);

if ~isempty(trialRelative(1).n) % filter to get only the trials Relative to those matching sortvector
    ref_sortvector = sortvector;
    tempvector = zeros(size(ref_sortvector));
    sortvector = ones(size(ref_sortvector));
    ntrials = size(ref_sortvector,2);
    for itrialFilt = 1: ntrialsBackConditions % condition on for each filter (per trial relative) to the trials selected by the ref_sortvector
        trial_ind =  find(ref_sortvector)+trialRelative(itrialFilt).n;
        
        trial_ind(trial_ind<=0 | trial_ind >ntrials) = [];  % make sure no new trials are added;
        tempvector(trial_ind) = 1;
        
        if ~isempty(trialRelative(itrialFilt).SortField) % filter the trials Relative by additional sort vector
            thissortvector = zeros(size(sortvector));
            % if a trial matches the filter the refTrial is 1
            ind = find(helper(strc,trialRelative(itrialFilt).SortField,trialRelative(itrialFilt).SortValue,bOR,tempvector)) - trialRelative(itrialFilt).n;
            ind(ind<=0 | ind >ntrials) = [];
            thissortvector(ind) = 1;
            if bOR  % OR
                sortvector = sortvector | thissortvector & ref_sortvector; % note OR only applies to the trialRelativeFilter not to the Trial relative
            else    % AND
                sortvector = sortvector & thissortvector & ref_sortvector;
            end
        else
            sortvector = tempvector;
        end
    end
end

% Find fields that have same length as spiketimes
if isfield(strc,'TrialAvail')
    reqLength = size(strc.TrialAvail,2);
elseif isfield(strc,'exptFilename') % for animalLog
    reqLength = size(strc.exptFilename,2);
end
% Use logical vector to extract spikestimes, trials, etc.
if bExcludefilter
    sortvector = ~sortvector;
end
strc = helperfiltfunc(strc,find(sortvector),reqLength);

end
function sortvector = helper(strc,sortfield,sortvalue,bOR,sortvector)
numSortFields = length(sortfield);

if isempty(sortfield) && ~exist('sortvector','var')  % if not sort criteria is given all trials are included
    sortvector = ones(1,size(strc.TrialAvail,2));
end
% Make logical vector to sort strc
for i = 1:numSortFields
    
    if isfield(strc,sortfield{i})
        if(isa(sortvalue{i}, 'function_handle'))
            fcn_hand = sortvalue{i};
            tempvector = arrayfun(fcn_hand, strc.(sortfield{i}));
        else
            tempvector = ismember(strc.(sortfield{i}),sortvalue{i});     % Take trials = value
        end
        
        
        
        if ~exist('sortvector','var')
            sortvector = tempvector;
        end
        % Combine multiple conditions
        if bOR  % OR
            sortvector = sortvector | tempvector;
        else    % AND
            sortvector = sortvector & tempvector;
        end
        
    else
        error([ sortfield{i} ' does not Exist as a Field'])
    end
    
end
end



