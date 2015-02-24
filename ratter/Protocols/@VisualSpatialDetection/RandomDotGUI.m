

function [x, y] = RandomDotGUI(obj, action)

GetSoloFunctionArgs;


switch action
    
    %   ------------------------------------------------------------------
    %                INIT
    %   ------------------------------------------------------------------
    case 'init'
        
        % Create figure for setting the timing structure of the task,
        % and set it to be invisible until button is pressed
        SoloParamHandle(obj, 'random_dot_fig', 'saveable', 0); random_dot_fig.value = figure;
                name = 'Random Dot Settings';
        set(value(random_dot_fig), 'Name', name, 'Tag', name, ...
        'Position', [700   100   215   220], 'Visible', 'off',...
                    'MenuBar', 'none',    'NumberTitle', 'off',...    
            'closerequestfcn', ['RandomDotGUI(' class(obj) ',''hide'')']);
        
        x=10; y=10;
        
        % ----------------------  Timing Parameters -----------------------
                % Random Dot menu
        NumeditParam(obj, 'dotCoher', [100 39.8 15.8 6.3 0], x, y, 'TooltipString', 'Array with available coherences');next_row(y);
        NumeditParam(obj, 'dotCoherProb', [0 0 0 0 1], x, y, 'TooltipString', 'Array with coherence probabilities');next_row(y);

        NumeditParam(obj, 'dotDensity', [0.05 0.1 0.2 0.3 0.4], x, y, 'TooltipString', 'Array with available densities');next_row(y);
        NumeditParam(obj, 'dotDensityProb', [0 0 1 0 0], x, y, 'TooltipString', 'Array with density probabilities');next_row(y);

        NumeditParam(obj, 'dotSpeed', [5 15 25 40 60], x, y, 'TooltipString', 'Array with available speeds');next_row(y);
        NumeditParam(obj, 'dotSpeedProb', [0 0 1 0 0], x, y, 'TooltipString', 'Array with speed probabilities');next_row(y);

        NumeditParam(obj, 'dotSize', [0.1 0.5 1 2 3], x, y, 'TooltipString', 'Array with available sizes');next_row(y);
        NumeditParam(obj, 'dotSizeProb', [0 0 0 1 0], x, y, 'TooltipString', 'Array with size probabilities');next_row(y);

        NumeditParam(obj, 'dotLifeTime', [120 60 40 24 12], x, y, 'TooltipString', 'Array with available life times');next_row(y);
        NumeditParam(obj, 'dotLifeTimeProb', [1 0 0 0 0], x, y, 'TooltipString', 'Array with life time probabilities');next_row(y);

        %SubheaderParam(obj, 'randomDotHeader', 'Random dot settings', x, y); next_row(y,1.5);

        DeclareGlobals(obj, 'rw_args', {'dotCoher', 'dotCoherProb','dotDensity',...
            'dotDensityProb','dotSpeedProb','dotSizeProb','dotLifeTimeProb',...
        'dotSpeed','dotSize','dotLifeTime'});

        
    %% CASE show
    case 'show'
            set(value(random_dot_fig), 'Visible', 'on');
        
  	%% CASE hide
    case 'hide'
            set(value(random_dot_fig), 'Visible', 'off');
            randomDotToggle.value = false;
        
    case 'close'

        if exist('random_dot_fig', 'var') && isa(random_dot_fig, 'SoloParamHandle') && ishandle(value(random_dot_fig)),
            delete(value(random_dot_fig));
        end;        
end