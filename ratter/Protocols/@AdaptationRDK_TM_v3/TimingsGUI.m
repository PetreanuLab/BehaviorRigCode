

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
            'Position', [700   100   215   200], 'Visible', 'off',...
                    'MenuBar', 'none',    'NumberTitle', 'off',...    
            'closerequestfcn', ['TimingsGUI(' class(obj) ',''hide'')']);
        x=10; y=10;
        
        % ----------------------  Timing Parameters -----------------------
        NumeditParam(obj, 'ITI', 20, x, y, 'TooltipString', '');next_row(y);
        NumeditParam(obj, 'testDuration', 1.5, x, y, 'TooltipString', '');next_row(y);
        NumeditParam(obj, 'ISI', [12 8 4 2], x, y, 'TooltipString', '');next_row(y);
        NumeditParam(obj, 'ISIProb', [0 1 1 0], x, y, 'TooltipString', '');next_row(y);
        NumeditParam(obj, 'adaptationDuration', [3 1.5 1 0.75 0.5], x, y, 'TooltipString', '');next_row(y);
        NumeditParam(obj, 'adaptationDurationProb', [0 1 0 1 0], x, y, 'TooltipString', '');next_row(y);
        NumeditParam(obj, 'preAdaptation', 0.5, x, y, 'TooltipString', '');next_row(y);
        NumeditParam(obj, 'valveDuration', 0.05, x, y, 'TooltipString', '');next_row(y);
        NumeditParam(obj, 'valvePeriod', 30, x, y, 'TooltipString', '');next_row(y);
        
        DeclareGlobals(obj, 'rw_args', {'ITI', 'testDuration','preAdaptation',...
            'ISI','ISIProb','adaptationDuration','adaptationDurationProb'...
            'valveDuration','valvePeriod'});

        
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