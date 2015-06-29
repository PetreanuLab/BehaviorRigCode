

function [x, y] = StimulusGUI(obj, action)

GetSoloFunctionArgs;


switch action
    
    %   ------------------------------------------------------------------
    %                INIT
    %   ------------------------------------------------------------------
    case 'init'
        
        RandomDotGUI(obj,'init');
      
        % Create figure for setting the timing structure of the task,
        % and set it to be invisible until button is pressed
        SoloParamHandle(obj, 'stimulus_fig', 'saveable', 0); stimulus_fig.value = figure;
                name = 'General Stimulus Settings';
        set(value(stimulus_fig),'Name', name, 'Tag', name, ...
        'Position', [ 867   173   215   473], 'Visible', 'off',...
                    'MenuBar', 'none',    'NumberTitle', 'off',...    
            'closerequestfcn', ['StimulusGUI(' class(obj) ',''hide'')']);
        
        x=10; y=10;
        
        % ----------------------  Stimulus Parameters -----------------------
        % XXX        
        ToggleParam(obj, 'randomDotToggle', 0, x, y, 'OnString', 'Hide RD', ...
        'OffString', 'Show RD', 'TooltipString', '...'); 
        set_callback(randomDotToggle, {'StimulusGUI', 'show_hide_RD'}); 
        next_row(y); 

        MenuParam(obj, 'randSeed', {'random',1,2,3,4,5,6,7,8,9,10},'random', x, y, 'TooltipString', '');next_row(y);        
        
        MenuParam(obj, 'flickeringError', {6,12,24,30,60},12, x, y, 'TooltipString', '');next_row(y);        
        
        MenuParam(obj, 'stimShape', {'circle', 'square'},'circle', x, y, 'TooltipString', '');next_row(y);
        MenuParam(obj, 'stimType', {'RD', 'NG'},'RD', x, y, 'TooltipString', '');next_row(y);

        MenuParam(obj, 'leftDirection',{0,45,90,135,180,225,270,315}, 270, x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        MenuParam(obj, 'rightDirection',{0,45,90,135,180,225,270,315}, 90, x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        
               NumeditParam(obj, 'stimSizeDeg', [100 70 55 40], x, y, 'TooltipString', 'Array with available stimulus size');next_row(y);
        NumeditParam(obj, 'stimSizeDegProb', [1 0 0 0], x, y, 'TooltipString', 'Array with stimulus size probabilities');next_row(y);

        DispParam(obj, 'intStimLum', 0, x, y); next_row(y);
        SliderParam(obj, 'bckgLum', 0, 0,255, x, y, 'TooltipString', 'Brightness of background.');next_row(y);
        NumeditParam(obj, 'foilLum', [255 120 50], x, y, 'TooltipString', 'Brightness of dots.');next_row(y);
        NumeditParam(obj, 'foilLumProb', [1 0 0], x, y, 'TooltipString', 'Brightness of dots.');next_row(y);
        NumeditParam(obj, 'targetLum', [255 120 50], x, y, 'TooltipString', 'Brightness of dots.');next_row(y);
        NumeditParam(obj, 'targetLumProb', [1 0 0], x, y, 'TooltipString', 'Brightness of dots.');next_row(y);
        
        NumeditParam(obj, 'stimPos', [400 540], x, y, 'TooltipString', '');next_row(y);
        NumeditParam(obj, 'stim2Pos', [1500 540], x, y, 'TooltipString', '');next_row(y);
        NumeditParam(obj, 'foilDotSpeed', [25], x, y, 'TooltipString', '');next_row(y);
        NumeditParam(obj, 'foilCohProb', [1 0 0 0], x, y, 'TooltipString', '');next_row(y);
        NumeditParam(obj, 'foilCoh', [1 0.6 0.4 .2], x, y, 'TooltipString', '');next_row(y);
        NumeditParam(obj, 'probFoilMatchTarget', 1, x, y, 'TooltipString', '');next_row(y);
        NumeditParam(obj, 'probStimPos1', 1, x, y, 'TooltipString', '');next_row(y);
         MenuParam(obj, 'stimuliMode', {'one', 'two' , 'two distractor'},'one', x, y, 'TooltipString', '');next_row(y);

        
        %SubheaderParam(obj, 'stimHeader', 'Stimulus settings', x, y); next_row(y,1.5);
        
        DeclareGlobals(obj, 'rw_args', {'probStimPos1','stimPos', 'stim2Pos','stimSizeDeg','stimSizeDegProb','targetLum','targetLumProb',...
            'foilLum','foilLumProb','stimuliMode','probFoilMatchTarget','foilCoh','foilCohProb','foilDotSpeed'...
            'intStimLum','bckgLum','stimShape','stimType','randomDotToggle',...
            'leftDirection','rightDirection','flickeringError','randSeed'});
        
        case 'show_hide_RD',
            
            if value(randomDotToggle) == 1, RandomDotGUI(obj, 'show');
            else RandomDotGUI(obj, 'hide');
            end; 
        
    %% CASE show
    case 'show'
            set(value(stimulus_fig), 'Visible', 'on');
        
  	%% CASE hide
    case 'hide'
            set(value(stimulus_fig), 'Visible', 'off');
            stimulusToggle.value = false;
            
    case 'close'
        
        RandomDotGUI(obj, 'close');

        if exist('stimulus_fig', 'var') && isa(stimulus_fig, 'SoloParamHandle') && ishandle(value(stimulus_fig)),
            delete(value(stimulus_fig));
        end;  
        
end