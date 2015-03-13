

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
            'Position', [881   136   215   593], 'Visible', 'off',...
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
        
        NumeditParam(obj, 'goCoh', [100 75 50 0], x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'goCohProb', [1 0 0 0], x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
       NumeditParam(obj, 'nogoCoh', [100 75 50 0], x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'nogoCohProb', [0 0 0 1], x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'goSpeed', [0,5,12,25], x, y, 'TooltipString', ...
            'degrees that the stimulus will change',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'goSpeedProb', [0 0 0 1], x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'nogoSpeed', [0,5,12,25], x, y, 'TooltipString', ...
            'degrees that the stimulus will change',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'nogoSpeedProb', [0 1 0 0], x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        MenuParam(obj, 'goDirection',{0,45,90,135,180,225,270,315}, 0, x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        MenuParam(obj, 'nogoDirection',{0,45,90,135,180,225,270,315}, 0, x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y); %      
        
        DispParam(obj, 'intStimLum', 0, x, y); next_row(y);
        SliderParam(obj, 'bckgLum', 0, 0,255, x, y, 'TooltipString', 'Brightness of background.');next_row(y);
        NumeditParam(obj, 'goLum', [255 120 64 0], x, y, 'TooltipString', ...
            ' Brightness of go dots.',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'goLumProb', [1 0 0 0], x, y, 'TooltipString', ...
            ' Brightness of go dots.',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'nogoLum', [255 120 64 0], x, y, 'TooltipString', ...
            'Brightness of nogo dots.',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'nogoLumProb', [1 0 0 0], x, y, 'TooltipString', ...
            'Brightness of nogo dots.',  'labelfraction', 0.5);next_row(y);
         
        NumeditParam(obj, 'stim1Pos', [1450 540], x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'stim2Pos', [600 540], x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'loc1Prob', 1, x, y, 'TooltipString', ...
            'Probability of Position 1',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'stimSizeDeg', [100 70 45 40], x, y, 'TooltipString', 'Array with available stimulus size');next_row(y);
        NumeditParam(obj, 'stimSizeDegProb', [1 0 0 0], x, y, 'TooltipString', 'Array with stimulus size probabilities');next_row(y);
        SubheaderParam(obj, 'stimHeader', 'Choose Stimulus Location', x, y); next_row(y,1.5);
        
        MenuParam(obj, 'goTrialSelection', {'user', 'random'},'user', x, y, 'TooltipString', '');next_row(y);
        ToggleParam(obj, 'userThisTrialGo', 1, x, y, 'OnString', 'Go' ,'OffString', 'Nogo', 'TooltipString', '...');        next_row(y,1.5);
        NumeditParam(obj, 'goTrialProb', 0.8, x, y, 'TooltipString', 'Probablity that a trial will be Go with Random Trial Selection');next_row(y);
        SubheaderParam(obj, 'stimHeader2', 'User: Go Trial', x, y); next_row(y,1.5);
        
        DeclareGlobals(obj, 'rw_args', {'randomDotToggle','randSeed',...
            'flickeringError','goCoh','goCohProb','nogoCoh','nogoCohProb',...
            'goSpeed','goSpeedProb','nogoSpeed','nogoSpeedProb',...
            'goDirection','nogoDirection','intStimLum','bckgLum','goLum','goLumProb',...
            'nogoLum','nogoLumProb','loc1Prob','stimSizeDegProb','stimSizeDeg','stim1Pos','stim2Pos',...
            'goTrialProb','goTrialSelection','userThisTrialGo'...
            });
        
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