function dp = concdp(dp,dp2,options)
% function dp = concdp(dp,dp2)
% BA concatenate dataParsed
% dp can be an dpArray


if nargin <2
    options.concatenateTimes = 0;
end

concatenateTimes = options.concatenateTimes;



% last time of the last dp (plus buffer) will be added to fields with absolute time
ndp = length(dp);
if ndp > 1 % dpArray - loop through it and concatenate
    if nargin>1 & ~isempty(dp2)
        error('if dp is an array dp2 cannot be used')
    end
    tempdp = dp(1);
    if concatenateTimes
        timeOffset = tempdp.TrialInit(end) + (tempdp.TrialInit(end) - tempdp.TrialInit(1));
        timeFields = {'TrialInit','TrialAvail'};
    end
    for idp = 2:ndp
        tempdp = concdp(tempdp,dp(idp),options);
    end
    dp = tempdp;
else
    if concatenateTimes
        timeOffset = dp.TrialInit(end) + (dp.TrialInit(end) - dp.TrialInit(1));
        timeFields = {'TrialInit','TrialAvail'};
    end
    if ~isfield(dp,'sessionFileName') %% keep track of session
        dp.sessionFileName(1:size(dp.TrialAvail,2)) = {dp.FileName};
    end
    if ~isfield(dp,'sessionDate') %% keep track of session
        dp.sessionDate(1:size(dp.TrialAvail,2)) = {dp.Date};
    end
    if ~isfield(dp,'sessionAnimal') %% keep track of session
        dp.sessionAnimal(1:size(dp.TrialAvail,2)) = {dp.Animal};
    end
    if ~isfield(dp,'sessionTrial') %% keep track of session
        dp.sessionTrial(1:size(dp.TrialAvail,2)) = dp.TrialNumber;
    end
    if concatenateTimes
        if ~isfield(dp,'sessiontimeOffset') %% keep track of session
            dp.sessiontimeOffset(1:size(dp.TrialAvail,2)) = 0;
        end
    end
    if exist('dp2','var') % for case where dpArray is just one dp
        if ~isfield(dp2,'sessionFileName') %% keep track of session
            dp2.sessionFileName(1:size(dp2.TrialAvail,2)) = {dp2.FileName};
        end
        if ~isfield(dp2,'sessionDate') %% keep track of session
            dp2.sessionDate(1:size(dp2.TrialAvail,2)) = {dp2.Date};
        end
        if ~isfield(dp2,'sessionAnimal') %% keep track of session
            dp2.sessionAnimal(1:size(dp2.TrialAvail,2)) = {dp2.Animal};
        end
        if ~isfield(dp2,'sessionTrial') %% keep track of session
            dp2.sessionTrial(1:size(dp2.TrialAvail,2)) = dp2.TrialNumber;
        end
        if concatenateTimes
            if ~isfield(dp2,'sessiontimeOffset') %% keep track of session
                dp2.sessiontimeOffset(1:size(dp2.TrialAvail,2)) = timeOffset;
            end
        end
        reqLength = size(dp2.TrialAvail,2);
        
        dp = helper(dp,dp2,reqLength);
        if isfield(dp,'video')
            if ~isempty(dp.video) % only concatenate if the FIRST field isn't empty
                if 1 % NEW VERSION conc all fields inside of video (NOT fully tested BA 0422)
                    dp.video = helper(dp.video,dp2.video,reqLength);
                    fieldn = fieldnames(dp.video);
                    for ifld = 1:length(fieldn)
                        if isstruct(dp.video.(fieldn{ifld}))
                            if ~isempty(dp.video.(fieldn{ifld}))
                                len = length(dp.video.(fieldn{ifld}));
                                for ind = 1:len
                                    if isfield(dp2.video,fieldn{ifld})
                                        dp.video.(fieldn{ifld})(ind) = helper(dp.video.(fieldn{ifld})(ind),dp2.video.(fieldn{ifld})(ind),reqLength);
                                    else % create fields and fill with NaNs
                                        fieldList = fieldnames(dp.video.(fieldn{ifld})(ind));
                                        for i = 1:length(fieldList)
                                            if ismember(reqLength,size(dp.video.(fieldn{ifld})(ind).(fieldList{i})));
                                                dp2.video.(fieldn{ifld})(ind).((fieldList{i})) = nan(size(dp.video.(fieldn{ifld})(ind).(fieldList{i}),1),reqLength);
                                            else
                                                dp2.video.(fieldn{ifld})(ind).((fieldList{i})) = nan(size(dp.video.(fieldn{ifld})(ind).(fieldList{i})));
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                else % OLD VERSION
                    dp.video = helper(dp.video,dp2.video,reqLength);
                    if isfield(dp.video,'cm')
                        if ~isempty(dp.video.cm) % only concatenate if the FIRST field isn't empty
                            
                            if isfield(dp2.video,'cm')
                                dp.video.cm = helper(dp.video.cm,dp2.video.cm,reqLength);
                            else % create fields and fill with NaNs
                                fieldList = fieldnames(dp.video.cm);
                                for i = 1:length(fieldList)
                                    if ismember(reqLength,size(dp.video.cm.(fieldList{i})));
                                        dp2.video.cm.((fieldList{i})) = nan(size(dp.video.cm.(fieldList{i}),1),reqLength);
                                    else
                                        dp2.video.cm.((fieldList{i})) = nan(size(dp.video.cm.(fieldList{i})));
                                    end
                                end
                            end
                        end
                    end
                    if isfield(dp.video,'extremes')
                        if ~isempty(dp.video.extremes) % only concatenate if the FIRST field isn't empty
                            
                            if isfield(dp2.video,'extremes')
                                dp.video.extremes = helper(dp.video.extremes,dp2.video.extremes,reqLength);
                            else % create fields and fill with NaNs
                                fieldList = fieldnames(dp.video.extremes);
                                for i = 1:length(fieldList)
                                    if ismember(reqLength,size(dp.video.extremes.(fieldList{i})));
                                        dp2.video.extremes.((fieldList{i})) = nan(size(dp.video.extremes.(fieldList{i}),1),reqLength);
                                    else
                                        dp2.video.extremes.((fieldList{i})) = nan(size(dp.video.extremes.(fieldList{i})));
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    
    dp.ntrials = length(dp.absolute_trial);
    dp.TrialNumber  = [1:dp.ntrials];
    
    fld = {'videoTrials','behaviorTrials','totalTrials'};
    for ifld = 1:length(fld)
        if isfield(dp,(fld{ifld}))
            dp.(fld{ifld}) = dp.(fld{ifld}) +dp2.(fld{ifld});
        end
    end
    
    if isfield(dp,'IntervalSet')
        dp.IntervalSet = sort(unique([dp.IntervalSet dp2.IntervalSet]) );
    end
%     dp = getStats_dp(dp); % BA this causes problems with non TAFC dp s 
    
    dp.Date = [dp.Date '_' dp2.Date];
    dp.FileName = 'multiple';
    dp.FullPath = 'multiple';
    dp.PathName = 'multiple';
end


    function dp =  helper(dp,dp2,reqLength)
        
        if concatenateTimes
            timefldDefault = fieldnames(dp);
            tempind = ~cellfun(@isempty,(regexp(timefldDefault,'^time')));
            timeFields = {timeFields{:} timefldDefault{tempind}};           
        end
            
        fieldList = fieldnames(dp);
        if isempty(dp2) % if the struct is empty creat NaN fields
            for i = 1:length(fieldList)
                if ismember(reqLength,size(dp.(fieldList{i})));
                    dp2.((fieldList{i})) = nan(size(dp.(fieldList{i}),1),reqLength);
                else
                    dp2.((fieldList{i})) = nan(size(dp.(fieldList{i})));
                end
            end
            fieldList2 = fieldList;
        else
            fieldList2 = fieldnames(dp2);
        end
        
        ind = ~ismember(fieldList2,fieldList);
        if any(ind)
            warning(['fields not found in dp1 ' cell2mat(fieldList2(ind))])
        end
        
        ind = ~ismember(fieldList,fieldList2);
        if any(ind)
            warning(['fields not found in dp2 ' cell2mat(fieldList(ind))])
        end
        
        for i = 1:length(fieldList)
            if ~ismember(fieldList{i},fieldList2) % catch case where field does not exist in dp2
                dp2.(fieldList{i}) = nan(1,reqLength);
            end
            if  concatenateTimes & ismember(fieldList{i},timeFields) % when concatenating sessions correct times by adding an offset
                dp2.(fieldList{i}) = dp2.(fieldList{i})+timeOffset;
            end
            if ismember(reqLength,size(dp2.(fieldList{i})));
                switch ndims(dp2.(fieldList{i}))
                    
                    case 2
                        if ismember(1,size(dp.(fieldList{i})));
                            dp.(fieldList{i})(end+1:end+length(dp2.(fieldList{i}))) = dp2.(fieldList{i});
                        else
                            dp.(fieldList{i})(end+1:end+size(dp2.(fieldList{i}),1),:) = dp2.(fieldList{i});
                        end
                    case 3
                        dp.(fieldList{i})(end+1:end+size(dp2.(fieldList{i}),1),:,:) = dp2.(fieldList{i});
                        
                    case 4
                        dp.(fieldList{i})(end+1:end+size(dp2.(fieldList{i}),1),:,:,:) = dp2.(fieldList{i});
                        
                        % Using dynamic field names
                end
            end
            
          
        end
        
    end
end