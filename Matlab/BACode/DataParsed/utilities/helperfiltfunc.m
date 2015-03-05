function dp = helperfiltfunc(dp,trial,reqLength)
% function dp = helperfiltfunc(dp,trial,reqLength)
% dp is a struct
% trial is a list of indices in fields of dp
% reqLength is the length of fields of dp that will be filtered
% (i.e. the new dp will contain only elements of trial for all fields that have  reqLength
% BA 
% modified from BA SRO and WB's filtspike
fieldList = fieldnames(dp);

% Use logical vector to extract spikestimes, trials, etc.
for i = 1:length(fieldList)
    if ismember(reqLength,size(dp.(fieldList{i})));
        try
            switch ndims(dp.(fieldList{i}))
            
            case 2
                if ismember(1,size(dp.(fieldList{i})));
                    dp.(fieldList{i}) = dp.(fieldList{i})(trial);  
                else
                    dp.(fieldList{i}) = dp.(fieldList{i})(trial,:);  
                end
            case 3
            dp.(fieldList{i}) = dp.(fieldList{i})(trial,:,:);  
             
            case 4
            dp.(fieldList{i}) = dp.(fieldList{i})(trial,:,:,:);  
             
                    % Using dynamic field names
            end
        catch
        end
    end
end


excludeField = {'analysis','qr','computed'};
fieldn1 = fieldnames(dp);
for ifld1 = 1:length(fieldn1)
    if isstruct(dp.(fieldn1{ifld1}))
        if ~ismember(fieldn1{ifld1},excludeField)
            if ~isempty(dp.(fieldn1{ifld1}))
                dp.(fieldn1{ifld1}) = helperfiltfunc(dp.(fieldn1{ifld1}),trial,reqLength);
                
                % fields inside this structure
                fieldn2 = fieldnames(dp.(fieldn1{ifld1}));
                for ifld2 = 1:length(fieldn2)
                    if isstruct(dp.(fieldn1{ifld1}).(fieldn2{ifld2}))
                        if ~isempty(dp.(fieldn1{ifld1}).(fieldn2{ifld2}))
                            % array of structs
                            len = length(dp.(fieldn1{ifld1}).(fieldn2{ifld2}));
                            for ind = 1:len
                                dp.(fieldn1{ifld1}).(fieldn2{ifld2})(ind) = helperfiltfunc(dp.(fieldn1{ifld1}).(fieldn2{ifld2})(ind),trial,reqLength);
                            end
                        end
                    end
                end
            end
        end
    end
end

%OLD WAY
% currently we only filter structures inside of video but this could be
% easily changed
% if isfield(dp,'video') 
%     if ~isempty(dp.video)
%         dp.video = helperfiltfunc(dp.video,trial,reqLength);
%         fieldn = fieldnames(dp.video);
%         for ifld = 1:length(fieldn)
%             if isstruct(dp.video.(fieldn{ifld}))
%                 if ~isempty(dp.video.(fieldn{ifld}))
%                     len = length(dp.video.(fieldn{ifld}));
%                     for ind = 1:len
%                         dp.video.(fieldn{ifld})(ind) = helperfiltfunc(dp.video.(fieldn{ifld})(ind),trial,reqLength);
%                     end
%                 end
%             end
%         end
%         
%     end
% end

if isfield(dp,'TrialNumber') % this is for dataparsed structs
    dp.absolute_trial = trial; %% keep record of absolute_trial
    dp.ntrials = length(dp.absolute_trial);
    dp.TrialNumber_lastFilter = dp.TrialNumber;
    dp.TrialNumber = [1:dp.ntrials];
    % if isnumeric(dp.IntervalSet)
%     dp = getStats_dp(dp);
end

% end