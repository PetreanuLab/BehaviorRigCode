

function [x, y] = StimulusGUI(obj, action)

GetSoloFunctionArgs;


switch action
    
    %   ------------------------------------------------------------------
    %                INIT
    %   ------------------------------------------------------------------
    case 'init'
              
        % Create figure for setting the timing structure of the task,
        % and set it to be invisible until button is pressed
        SoloParamHandle(obj, 'stimulus_fig', 'saveable', 0); stimulus_fig.value = figure;
                name = 'Stimulus Settings';
        set(value(stimulus_fig),'Name', name, 'Tag', name, ...
        'Position', [700   100   645   220], 'Visible', 'off',...
                    'MenuBar', 'none',    'NumberTitle', 'off',...    
            'closerequestfcn', ['StimulusGUI(' class(obj) ',''hide'')']);
        
        x=10; y=10;
        
        % ----------------------  Stimulus Parameters -----------------------
        % XXX        

        MenuParam(obj, 'randSeedAdaptation', {'random',1,2,3,4,5,6,7,8,9,10},'random', x, y, 'TooltipString', '');next_row(y);        
        MenuParam(obj, 'randSeedTest', {'random',1,2,3,4,5,6,7,8,9,10},'random', x, y, 'TooltipString', '');next_row(y);        
        
        MenuParam(obj, 'leftDirection',{0,45,90,135,180,225,270,315}, 270, x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        MenuParam(obj, 'rightDirection',{0,45,90,135,180,225,270,315}, 90, x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);

        SliderParam(obj, 'bckgLum', 0, 0,255, x, y, 'TooltipString', 'Brightness of background.');next_row(y);
        SliderParam(obj, 'stimLum', 102, 0,255, x, y, 'TooltipString', 'Brightness of dots.');next_row(y);
        
        NumeditParam(obj, 'stimPos', [960 540], x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'stimSize', [100 70 55 40], x, y, 'TooltipString', 'Array with available stimulus size');next_row(y);
        NumeditParam(obj, 'stimSizeProb', [1 0 0 0], x, y, 'TooltipString', 'Array with stimulus size probabilities');next_row(y);

        ToggleParam(obj, 'waterToggle', 1, x, y, 'OnString', 'WATER ON', ...
            'OffString', 'WATER OFF'); next_row(y);
        
        %% Changes column
        next_column(x); y=10;

        NumeditParam(obj, 'adaptationCoher', [100 39.8 15.8 6.3 0], x, y, 'TooltipString', 'Array with available coherences');next_row(y);
        NumeditParam(obj, 'adaptationCoherProb', [1 0 0 0 0], x, y, 'TooltipString', 'Array with coherence probabilities');next_row(y);

        NumeditParam(obj, 'adaptationDensity', [0.05 0.1 0.2 0.3 0.4], x, y, 'TooltipString', 'Array with available densities');next_row(y);
        NumeditParam(obj, 'adaptationDensityProb', [0 0 1 0 0], x, y, 'TooltipString', 'Array with density probabilities');next_row(y);

        NumeditParam(obj, 'adaptationSpeed', [0 15 25 40 60], x, y, 'TooltipString', 'Array with available speeds');next_row(y);
        NumeditParam(obj, 'adaptationSpeedProb', [0.125 0 1 0 0], x, y, 'TooltipString', 'Array with speed probabilities');next_row(y);

        NumeditParam(obj, 'adaptationSize', [0.1 0.5 1 2 3], x, y, 'TooltipString', 'Array with available sizes');next_row(y);
        NumeditParam(obj, 'adaptationSizeProb', [0 0 0 1 0], x, y, 'TooltipString', 'Array with size probabilities');next_row(y);

        NumeditParam(obj, 'adaptationLifeTime', [120 60 40 24 12], x, y, 'TooltipString', 'Array with available life times');next_row(y);
        NumeditParam(obj, 'adaptationLifeTimeProb', [1 0 0 0 0], x, y, 'TooltipString', 'Array with life time probabilities');next_row(y);

        SliderParam(obj, 'adaptationLeftProb', 0.5, 0,1, x, y, 'TooltipString', '');next_row(y);

        %% Changes column
        next_column(x); y=10;
     
        NumeditParam(obj, 'testCoher', [100 39.8 15.8 6.3 0], x, y, 'TooltipString', 'Array with available coherences');next_row(y);
        NumeditParam(obj, 'testCoherProb', [1 0 0 0 0], x, y, 'TooltipString', 'Array with coherence probabilities');next_row(y);

        NumeditParam(obj, 'testDensity', [0.05 0.1 0.2 0.3 0.4], x, y, 'TooltipString', 'Array with available densities');next_row(y);
        NumeditParam(obj, 'testDensityProb', [0 0 1 0 0], x, y, 'TooltipString', 'Array with density probabilities');next_row(y);

        NumeditParam(obj, 'testSpeed', [0 15 25 40 60], x, y, 'TooltipString', 'Array with available speeds');next_row(y);
        NumeditParam(obj, 'testSpeedProb', [0 0 1 0 0], x, y, 'TooltipString', 'Array with speed probabilities');next_row(y);

        NumeditParam(obj, 'testSize', [0.1 0.5 1 2 3], x, y, 'TooltipString', 'Array with available sizes');next_row(y);
        NumeditParam(obj, 'testSizeProb', [0 0 0 1 0], x, y, 'TooltipString', 'Array with size probabilities');next_row(y);

        NumeditParam(obj, 'testLifeTime', [120 60 40 24 12], x, y, 'TooltipString', 'Array with available life times');next_row(y);
        NumeditParam(obj, 'testLifeTimeProb', [1 0 0 0 0], x, y, 'TooltipString', 'Array with life time probabilities');next_row(y);
       
        SliderParam(obj, 'testLeftProb', 0.5, 0,1, x, y, 'TooltipString', '');next_row(y);
               
        DeclareGlobals(obj, 'rw_args', {'stimPos', 'stimSize','stimSizeProb',...
            'stimLum','bckgLum','leftDirection','rightDirection','randSeedAdaptation','randSeedTest',...
            'adaptationCoher','adaptationCoherProb','adaptationDensity','adaptationDensityProb',...
            'adaptationSpeed','adaptationSpeedProb','adaptationSize','adaptationSizeProb',...
            'adaptationLifeTime','adaptationLifeTimeProb','adaptationLeftProb',...
            'testCoher','testCoherProb','testDensity','testDensityProb',...
            'testSpeed','testSpeedProb','testSize','testSizeProb',...
            'testLifeTime','testLifeTimeProb','testLeftProb','waterToggle'});
        
        
        
    %% CASE show
    case 'show'
            set(value(stimulus_fig), 'Visible', 'on');
        
  	%% CASE hide
    case 'hide'
            set(value(stimulus_fig), 'Visible', 'off');
            stimulusToggle.value = false;
            
    case 'close'
        
        if exist('stimulus_fig', 'var') && isa(stimulus_fig, 'SoloParamHandle') && ishandle(value(stimulus_fig)),
            delete(value(stimulus_fig));
        end;  
        
end