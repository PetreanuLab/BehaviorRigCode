

function [x, y] = TrialGUI(obj, action)

GetSoloFunctionArgs;


switch action
    
    %   ------------------------------------------------------------------
    %                INIT
    %   ------------------------------------------------------------------
    case 'init'
        
        % Create figure for setting the timing structure of the task,
        % and set it to be invisible until button is pressed
        SoloParamHandle(obj, 'trial_fig', 'saveable', 0); trial_fig.value = figure;
                name = 'Trial Settings';
        set(value(trial_fig), 'Name', name, 'Tag', name, ...
            'Position', [ 1116          52         215         305], 'Visible', 'off',...
                    'MenuBar', 'none',    'NumberTitle', 'off',...    
            'closerequestfcn', ['TrialGUI(' class(obj) ',''hide'')']);
          
        x=10; y=10;
        
        % ----------------------  Trial Parameters -----------------------
        % Trial menu
        ToggleParam(obj, 'treadmillStim', 0, x, y); next_row(y);
        ToggleParam(obj, 'stopLick',0,x,y); next_row(y);
        ToggleParam(obj, 'rewardWitholding', 0, x, y); next_row(y);
        ToggleParam(obj, 'punishError', 1, x, y); next_row(y);
        ToggleParam(obj, 'freeWaterAtChange', 0, x, y); next_row(y);
        ToggleParam(obj, 'visualError', 0, x, y); next_row(y);
        ToggleParam(obj, 'bCorrLoop', 0, x, y, 'OnString', 'Correction Loop', 'OffString', 'NO Correction Loop'); next_row(y);
        set_callback(bCorrLoop, {'TrialGUI', 'clear correction loop'});
        
        NumeditParam(obj, 'correctionLoopGoNogo', [3 3], x, y, 'TooltipString', ...
            'number of error trials before entering the correction loop',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'goBlockSize', [1 2], x, y, 'TooltipString', ...
            'min and max',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'nogoBlockSize', [3 6], x, y, 'TooltipString', ...
            'min and max',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'randConstr', 4, x, y, 'TooltipString', ...
            'max number in a row during random',  'labelfraction', 0.5);next_row(y);
        ToggleParam(obj, 'constrainRandom', 0, x, y, 'OnString', 'constrainRand', 'OffString', 'Real Rand'); next_row(y);
        NumeditParam(obj, 'goTrialProb', 0.8, x, y, 'TooltipString', 'Probablity that a trial will be Go with Random Trial Selection');next_row(y);
        MenuParam(obj, 'goTrialSelection', {'user', 'random', 'use blocks'},'user', x, y, 'TooltipString', '');next_row(y);
        ToggleParam(obj, 'userThisTrialGo', 1, x, y, 'OnString', 'Go' ,'OffString', 'Nogo', 'TooltipString', '...');        next_row(y,1.5);
        %SubheaderParam(obj, 'trialHeader', 'Trial Settings', x, y); next_row(y,1.5);
        DeclareGlobals(obj, 'rw_args', {'punishError','rewardWitholding',...
           'stopLick','treadmillStim','visualError','freeWaterAtChange',...
           'bCorrLoop','correctionLoopGoNogo','goBlockSize','nogoBlockSize',...
           'goTrialProb','constrainRandom','randConstr','goTrialSelection','userThisTrialGo'});
        
        
    %% CASE show
    case 'clear correction loop'      
        currCorrLoop.value = [0 0] ;
    %% CASE show
    case 'show'
            set(value(trial_fig), 'Visible', 'on');
        
  	%% CASE hide
    case 'hide'
            set(value(trial_fig), 'Visible', 'off');
            trialToggle.value = false;
            
    case 'close'
        if exist('trial_fig', 'var') && isa(trial_fig, 'SoloParamHandle') && ishandle(value(trial_fig)),
            delete(value(trial_fig));
        end;  
        
end