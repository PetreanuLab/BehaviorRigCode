

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
            'Position', [ 881    54   215   725], 'Visible', 'off',...
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
        
        NumeditParam(obj, 'cohChg', [1 0.75 0.5 0.25], x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'cohChgProb', [1 0 0 0], x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'lumChg', [120,180,220,255], x, y, 'TooltipString', ...
            'degrees that the stimulus will change',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'lumChgProb', [0 0 0 1], x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        ToggleParam(obj, 'useLumChg', 1, x, y, 'OnString', 'USE', ...
            'OffString', 'do NOT USE' , 'TooltipString','');next_row(y);
        NumeditParam(obj, 'speedChg', [0,5,12,25], x, y, 'TooltipString', ...
            'degrees that the stimulus will change',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'speedChgProb', [0 0 0 1], x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        
        NumeditParam(obj, 'dirnDeltaChg', [0,90,180,270], x, y, 'TooltipString', ...
            'degrees that the stimulus will change',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'dirnDeltaChgProb', [0 1 0 0], x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        
        MenuParam(obj, 'targetDirection',{0,45,90,135,180,225,270,315}, 0, x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        
        MenuParam(obj, 'foilDeltaDirc_Deg',{0,45,90,135,180,225,270,315}, 0, x, y, 'TooltipString', ...
            'Difference between foil direction and Target direction',  'labelfraction', 0.5);next_row(y); %
        
        DispParam(obj, 'intStimLum', 0, x, y); next_row(y);
        SliderParam(obj, 'bckgLum', 0, 0,255, x, y, 'TooltipString', 'Brightness of background.');next_row(y);
        NumeditParam(obj, 'targetLum', [255 120 64 0], x, y, 'TooltipString', ...
            ' Brightness of target dots.',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'targetLumProb', [1 0 0 0], x, y, 'TooltipString', ...
            ' Brightness of target dots.',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'foilLum', [255 120 64 0], x, y, 'TooltipString', ...
            'Brightness of foil dots.',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'foilLumProb', [1 0 0 0], x, y, 'TooltipString', ...
            'Brightness of foil dots.',  'labelfraction', 0.5);next_row(y);
          MenuParam(obj, 'selectLumType', {'UnChange/Change', 'Foil/Target', 'Loc1/Loc2'},'Loc1/Loc2', x, y, 'TooltipString', 'pick what the fields target and Foil Lum actually refer to');next_row(y);
        
        NumeditParam(obj, 'stim1Pos', [1450 540], x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'stim2Pos', [600 540], x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'stimSizeDeg', [100 70 45 40], x, y, 'TooltipString', 'Array with available stimulus size');next_row(y);
        NumeditParam(obj, 'stimSizeDegProb', [0 1 0 0], x, y, 'TooltipString', 'Array with stimulus size probabilities');next_row(y);
        NumeditParam(obj, 'changeLocation1', 1, x, y, 'TooltipString', 'Probablity of Change at Location 1');next_row(y);
        MenuParam(obj, 'validLocationSelection', {'user', 'random'},'random', x, y, 'TooltipString', '');next_row(y);
        ToggleParam(obj, 'stimlusChangeProb', 0, x, y, 'OnString', 'change', ...
            'OffString', 'noChange' , 'TooltipString', '...');        next_row(y,1.5);
        ToggleParam(obj, 'validLocation', 0, x, y, 'OnString', '2 is VALID', ...
            'OffString', '1 is VALID' , 'TooltipString', '...');        next_row(y,1.5);
        MenuParam(obj, 'stimchangeSelector', {'changeLocation', 'validLocation'},'changeLocation', x, y, 'TooltipString', 'Either use validLocation settings or use changeLocation1 to set which stimulus will be changing');next_row(y);
        SubheaderParam(obj, 'stimHeader', 'Choose Valid/Change Location', x, y); next_row(y,1.5);
        MenuParam(obj, 'validTrialSelection', {'user', 'random'},'random', x, y, 'TooltipString', '');next_row(y);
        ToggleParam(obj, 'userThisTrialValid', 1, x, y, 'OnString', 'VALID' ,'OffString', 'invalid', 'TooltipString', '...');        next_row(y,1.5);
        NumeditParam(obj, 'validTrialProb', 0.8, x, y, 'TooltipString', 'Probablity that a trial will be Valid with Random Trial Selection');next_row(y);
        SubheaderParam(obj, 'stimHeader2', 'User: Valid Trial', x, y); next_row(y,1.5);

        DeclareGlobals(obj, 'rw_args', {'randomDotToggle','randSeed',...
            'targetDirection','flickeringError','foilDeltaDirc_Deg','intStimLum',...
            'selectLumType','useLumChg','targetLum','targetLumProb','foilLum','foilLumProb','bckgLum','stim1Pos','stim2Pos','stimSizeDeg','stimSizeDegProb',...
            'cohChg','cohChgProb','dirnDeltaChg','dirnDeltaChgProb','lumChg','lumChgProb','speedChg','speedChgProb',...
            'changeLocation1','validLocationSelection','validTrialProb','stimchangeSelector','validTrialSelection','validLocation','userThisTrialValid'...
            'stimlusChangeProb'});
        
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