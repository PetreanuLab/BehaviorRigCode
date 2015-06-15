

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
            'Position', [ 1099         245         215        400], 'Visible', 'off',...
                    'MenuBar', 'none',    'NumberTitle', 'off',...    
            'closerequestfcn', ['TimingsGUI(' class(obj) ',''hide'')']);
        x=10; y=10;
        
        % ----------------------  Timing Parameters -----------------------
        SliderParam(obj, 'ITIMax', 1.0, 0,10, x, y, 'TooltipString', 'Inter-Trial Interval (seconds)');next_row(y);
        SliderParam(obj, 'ITIMin', 0.5, 0,10, x, y, 'TooltipString', 'Inter-Trial Interval (seconds)');next_row(y);
        MenuParam(obj, 'ITI', {'ITIMax', 'RANDOM'},'RANDOM', x, y, 'TooltipString', 'Inter-Trial Interval');next_row(y);
        SliderParam(obj, 'errorTimeOut', 5,0,20, x, y, 'TooltipString', 'Duration of the error punishment state.');next_row(y);
        SliderParam(obj, 'respWindow', 1.9,0,10, x, y, 'TooltipString', 'Duration of response window.');next_row(y);        
        SliderParam(obj, 'afterLick', 0.1,0,10, x, y, 'TooltipString', 'Duration of response window.');next_row(y);
        ToggleParam(obj, 'delayMatchStim', 0, x, y, 'OnString', 'Matching', ...
            'OffString', 'Not matching'); next_row(y);
        SliderParam(obj, 'respDelay', 0.3, 0,10, x, y, 'TooltipString', 'Delay after stimulus onset for considering a response.');next_row(y);
        SliderParam(obj, 'preStimulus', 0,0,5, x, y, 'TooltipString', 'Length in seconds of stimuli presentation.');next_row(y);
        SliderParam(obj, 'trialDuration', 3,0,10, x, y, 'TooltipString', 'Length in seconds of stimuli presentation.');next_row(y);
        NumeditParam(obj, 'stimDuration', [3 2 1 0.5 0.25], x, y, 'TooltipString', 'Array with available sound sides volume');next_row(y);
        NumeditParam(obj, 'stimDurationProb', [1 0 0 0 0], x, y, 'TooltipString', 'Array with sound sides volume probabilities');next_row(y);
        NumeditParam(obj, 'postcueLength', 0, x, y, 'TooltipString', '');next_row(y);

        NumeditParam(obj, 'cueLength', 0.5, x, y, 'TooltipString', '');next_row(y);

        SubheaderParam(obj, 'timingsHeader', 'Trial timings', x, y); next_row(y,1.5);
        
        NumeditParam(obj, 'rewardSoundLength', 0.1, x, y);next_row(y);
        NumeditParam(obj, 'errorSoundLength', 3, x, y);next_row(y);
        NumeditParam(obj, 'errorVisualLength', 3, x, y);next_row(y);        
        NumeditParam(obj, 'valveTime', 0.04, x, y);next_row(y);
        SubheaderParam(obj, 'eventsHeader', 'Event timings', x, y); next_row(y,1.5);

        
        DeclareGlobals(obj, 'rw_args', {'ITIMax', 'ITIMin','ITI',...
            'errorTimeOut','respWindow','preStimulus','respDelay','delayMatchStim',...
            'trialDuration','stimDuration','stimDurationProb','afterLick',...
            'valveTime','rewardSoundLength','errorSoundLength','errorVisualLength','cueLength','postcueLength'});

        
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