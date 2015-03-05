function dp = addTimeRelativeTo(dp,field,relativeField,ephysTimeScalar)
% function dp = addTimeRelativeTo(dp,field,relativeField,ephysTimeScalar)
%
% creates new fields for each field specified where the time is relative to
% relativeField
% if ephysTimeScalar is entered will give time adjusted to EPhys time by the supplied scalefactor
%
% BA
syncEvent = 'TrialAvail';
% if isequal(relativeField, 'TrialInit')
%     slabel = 'TrialTime_';
% else
    slabel = ['RelativeTime_' relativeField];
% end

if exist('ephysTimeScalar','var')
    slabel = ['Ephys' slabel];
    % for EphysTime find time of field  and time of relativeField in ephys time
    %     take the difference
    relativeFieldTime = (dp.(relativeField) - dp.(syncEvent))*ephysTimeScalar; % ms
    
    for ifld = 1:length(field)        
        fieldTime = (dp.(field{ifld}) - dp.(syncEvent))*ephysTimeScalar; % ms        
        dp.([field{ifld} '_' slabel]) = fieldTime - relativeFieldTime;
    end
else
    
    
    for ifld = 1:length(field)
        if ~isempty(field{ifld})
            dp.([field{ifld} '_' slabel]) = dp.(field{ifld}) - dp.(relativeField);
        end
    end
    
end

