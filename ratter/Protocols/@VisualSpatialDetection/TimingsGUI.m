

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
            'Position', [  1112         269        215         497], 'Visible', 'off',...
            'MenuBar', 'none',    'NumberTitle', 'off',...
            'closerequestfcn', ['TimingsGUI(' class(obj) ',''hide'')']);
        x=10; y=10;
        
        % ----------------------  Timing Parameters -----------------------
        SliderParam(obj, 'ITIMax', 2, 0,10, x, y, 'TooltipString', 'Inter-Trial Interval (seconds)');next_row(y);
        SliderParam(obj, 'ITIMin', 0.5, 0,10, x, y, 'TooltipString', 'Inter-Trial Interval (seconds)');next_row(y);
        MenuParam(obj, 'ITI', {'ITIMax', 'RANDOM'},'ITIMax', x, y, 'TooltipString', 'Inter-Trial Interval');next_row(y);
        
        SliderParam(obj, 'errorTimeOut', 5,0,20, x, y, 'TooltipString', 'Duration of the error punishment state.');next_row(y);
        
        SliderParam(obj, 'outDelay', 0.1,0.001,10, x, y, 'TooltipString', 'water Outcome delay after lick.');next_row(y);
        ToggleParam(obj, 'setRespWindow', 0, x, y, 'OnString', 'Resp Window', ...
            'OffString', 'Rest of stimulus'); next_row(y);
        SliderParam(obj, 'respWindow', 1,0,10, x, y, 'TooltipString', 'Duration of response window.');next_row(y);
        SliderParam(obj, 'minChgDelay', 2, 0,10, x, y, 'TooltipString', 'Minimum Delay after Stimulus before CHANGE.');next_row(y);
        SliderParam(obj, 'maxChgDelay', 3, 0,10, x, y, 'TooltipString', 'max Delay after Stimulus before CHANGE used when random with max is chosen.');next_row(y);
        MenuParam(obj, 'randomChangeDelay', {'fixed', 'random',  'random with max'},'random with max', x, y, 'TooltipString', 'Delay after Stimulus before CHANGE ');next_row(y);
        SliderParam(obj, 'maxStimLgth', 5, 0,10, x, y, 'TooltipString', 'Max stim length.');next_row(y);
        SliderParam(obj, 'meanStimLgth', 2, 0,10, x, y, 'TooltipString', 'Mean stim length.');next_row(y);
        MenuParam(obj, 'stimDist', {'exponential', 'uniform','fixed'},'fixed', x, y, 'TooltipString', 'Distribution of stimulus lengths');next_row(y);
        
        
        SliderParam(obj, 'earlyLickGP', 0.5, 0,3, x, y, 'TooltipString', 'time when early licks are forgiven. must be smaller than minChgDelay');next_row(y);
        SliderParam(obj, 'stimDelay', 0, 0,10, x, y, 'TooltipString', 'Delay after CUE before Stimulus.');next_row(y);
        SliderParam(obj, 'cueDuration', 0.5, 0,10, x, y, 'TooltipString', 'Length of visual/auditory Cue.');next_row(y);
        SliderParam(obj, 'preCue', 0.1,0,5, x, y, 'TooltipString', 'Length in seconds  before Cue presentation.');next_row(y);
        
        SubheaderParam(obj, 'timingsHeader', 'Trial timings', x, y); next_row(y,1.5);
        
        SliderParam(obj, 'rewardSoundLength', 0.1,0.001,20, x, y);next_row(y);        
        SliderParam(obj, 'errorSoundLength', 5,0.001,20, x, y);next_row(y);        
        SliderParam(obj, 'errorVisualLength', 5,0.001,20, x, y);next_row(y);    % NOTE must be less than errortime out and ITI    
        NumeditParam(obj, 'valveTime', 0.04, x, y);next_row(y);
        SubheaderParam(obj, 'eventsHeader', 'Event timings', x, y); next_row(y,1.5);
        
        
        DeclareGlobals(obj, 'rw_args', {'ITIMax', 'ITIMin','ITI',...
            'errorTimeOut','outDelay','setRespWindow',...
            'stimDist','maxStimLgth','meanStimLgth',...
            'respWindow','preCue','cueDuration','stimDelay','minChgDelay','maxChgDelay','randomChangeDelay',...
            'valveTime','rewardSoundLength','errorSoundLength','errorVisualLength','earlyLickGP'});
        
        
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