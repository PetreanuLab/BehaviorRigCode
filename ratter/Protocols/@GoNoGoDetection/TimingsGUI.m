

function [x, y] = TimingsGUI(obj, action)

GetSoloFunctionArgs;


switch action
    
    %   ------------------------------------------------------------------
    %                INIT
    %   ------------------------------------------------------------------
    case 'init'
        
        % Create figure for setting the timing structure of the task,
        % and set it to be invisible until button is pressed
        SoloParamHandle(obj, 'timings_fig', 'saveable', 0); timings_fig.value = figure;
        name = 'Timing Settings';
        set(value(timings_fig), 'Name', name, 'Tag', name, ...
            'Position', [  1112         269        215         400], 'Visible', 'off',...
            'MenuBar', 'none',    'NumberTitle', 'off',...
            'closerequestfcn', ['TimingsGUI(' class(obj) ',''hide'')']);
        x=10; y=10;
        
        % ----------------------  Timing Parameters -----------------------
        SliderParam(obj, 'ITIMax', 2, 0,10, x, y, 'TooltipString', 'Inter-Trial Interval (seconds)');next_row(y);
        SliderParam(obj, 'ITIMin', 0.5, 0,10, x, y, 'TooltipString', 'Inter-Trial Interval (seconds)');next_row(y);
        MenuParam(obj, 'ITI', {'ITIMax', 'RANDOM'},'ITIMax', x, y, 'TooltipString', 'Inter-Trial Interval');next_row(y);       
        NumeditParam(obj, 'errorTimeOut', 5, x, y, 'TooltipString',  'Duration of the error punishment state.');next_row(y);
        SliderParam(obj, 'outDelay', 0.1,0.001,10, x, y, 'TooltipString', 'water Outcome delay after lick.');next_row(y);
        NumeditParam(obj, 'minStimLgthGo', 1, x, y, 'TooltipString', 'Min stim length.');next_row(y);
        NumeditParam(obj, 'maxStimLgthGo', 1, x, y, 'TooltipString', 'Max stim length.');next_row(y);
        NumeditParam(obj, 'adaptStimLgthGo', [0.5 3 -0.05 0.02],  x, y, 'TooltipString', 'min max correct_step error_step');next_row(y);
        NumeditParam(obj, 'minStimLgthNogo', 1, x, y, 'TooltipString', 'Min stim length.');next_row(y);
        NumeditParam(obj, 'maxStimLgthNogo', 1, x, y, 'TooltipString', 'Max stim length.');next_row(y);
        NumeditParam(obj, 'adaptStimLgthNogo', [0.5 3 0.05 -0.02], x, y, 'TooltipString', 'min max correct_step error_step');next_row(y);
        NumeditParam(obj, 'minStimDelay', 3, x, y, 'TooltipString', 'Min stim delay.');next_row(y);
        NumeditParam(obj, 'maxStimDelay', 3, x, y, 'TooltipString', 'Max stim delay.');next_row(y);

        
%         SliderParam(obj, 'earlyLickGP', 0.5, 0,3, x, y, 'TooltipString', 'time when early licks are forgiven. must be smaller than minChgDelay');next_row(y);
        
        SubheaderParam(obj, 'timingsHeader', 'Trial timings', x, y); next_row(y,1.5);
        
        NumeditParam(obj, 'rewardSoundLength', 0.1, x, y);next_row(y);        
        NumeditParam(obj, 'errorSoundLength', 1, x, y);next_row(y);        
        NumeditParam(obj, 'errorVisualLength', 1, x, y);next_row(y);    % NOTE must be less than errortime out and ITI    
        NumeditParam(obj, 'valveTime', 0.04, x, y);next_row(y);
        SubheaderParam(obj, 'eventsHeader', 'Event timings', x, y); next_row(y,1.5);
        
        
        DeclareGlobals(obj, 'rw_args', {'ITIMax', 'ITIMin','ITI',...
            'errorTimeOut','outDelay',...
            'maxStimDelay','minStimDelay',...
            'minStimLgthGo','maxStimLgthGo','adaptStimLgthGo'...
            'minStimLgthNogo','maxStimLgthNogo','adaptStimLgthNogo'...
            'valveTime','rewardSoundLength','errorSoundLength','errorVisualLength'});
        
        
        %% CASE show
    case 'show'
        set(value(timings_fig), 'Visible', 'on');
        
        %% CASE hide
    case 'hide'
        set(value(timings_fig), 'Visible', 'off');
        timingsToggle.value = false;
        
        %% CASE close
    case 'close'
        
        if exist('timings_fig', 'var') && isa(timings_fig, 'SoloParamHandle') && ishandle(value(timings_fig)),
            delete(value(timings_fig));
        end;
        
end