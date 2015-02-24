

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
            'Position', [451    38   215   180], 'Visible', 'off',...
                    'MenuBar', 'none',    'NumberTitle', 'off',...    
            'closerequestfcn', ['TrialGUI(' class(obj) ',''hide'')']);
          
        x=10; y=10;
        
        % ----------------------  Trial Parameters -----------------------
        % Trial menu
        ToggleParam(obj, 'treadmillStim', 0, x, y); next_row(y);
        ToggleParam(obj, 'stopLick',0,x,y); next_row(y);
        ToggleParam(obj, 'punishEarlyLick', 0, x, y); next_row(y);
        ToggleParam(obj, 'rewardWitholding', 0, x, y); next_row(y);
        ToggleParam(obj, 'resetITI', 0, x, y); next_row(y);
        ToggleParam(obj, 'punishError', 0, x, y); next_row(y);
        ToggleParam(obj, 'visualError', 0, x, y); next_row(y);       
        %SubheaderParam(obj, 'trialHeader', 'Trial Settings', x, y); next_row(y,1.5);
        DeclareGlobals(obj, 'rw_args', {'punishError','rewardWitholding','resetITI',...
            'punishEarlyLick','stopLick','treadmillStim','visualError'});
        
        
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