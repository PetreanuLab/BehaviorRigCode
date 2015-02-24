

function [x, y] = BiasGUI(obj, action)

GetSoloFunctionArgs;


switch action
    
    %   ------------------------------------------------------------------
    %                INIT
    %   ------------------------------------------------------------------
    case 'init'
        
        % Create figure for setting the timing structure of the task,
        % and set it to be invisible until button is pressed
        SoloParamHandle(obj, 'bias_fig', 'saveable', 0); bias_fig.value = figure;
                name = 'Bias Settings';
        set(value(bias_fig), 'Name', name, 'Tag', name, ...
            'Position', [700   100   215   230], 'Visible', 'off',...
                    'MenuBar', 'none',    'NumberTitle', 'off',...    
            'closerequestfcn', ['BiasGUI(' class(obj) ',''hide'')']);
        
        x=10; y=10;
        
        % ----------------------  Bias Parameters -----------------------
        MenuParam(obj, 'maxAlternSides',{'2','3','4','5'}, 3, x, y, 'TooltipString', 'Maximum number of consecutive alternations allowed.');next_row(y);
        MenuParam(obj, 'maxEqualSides',{'2','3','4','5'}, 3, x, y, 'TooltipString', 'Maximum number of consecutive equal sides allowed.');next_row(y);
        ToggleParam(obj, 'limitEqualSides', 1, x, y, 'position', [x y 100 20]);
        ToggleParam(obj, 'limitAlternSides', 1, x, y, 'position', [(x+100) y 100 20]); next_row(y);
        SliderParam(obj, 'leftProb', 0.5, 0, 1, x, y); next_row(y);
        NumeditParam(obj, 'biasSize', 20, x, y, 'TooltipString', '');next_row(y);       
        MenuParam(obj, 'sideSelection',{'random','biasCorrection'}, 'random', x, y, 'TooltipString', 'Maximum number of consecutive alternations allowed.');next_row(y);
        SubheaderParam(obj, 'biasSideHeader', 'Side Bias Settings', x, y); next_row(y,1.5);
        NumeditParam(obj, 'leftRewardMult', 1, x, y, 'TooltipString', '');next_row(y);       
        NumeditParam(obj, 'rightRewardMult', 1, x, y, 'TooltipString', '');next_row(y);               
        SubheaderParam(obj, 'biasRewardHeader', 'Reward Bias Settings', x, y); next_row(y,1.5);

        DeclareGlobals(obj, 'rw_args', {'maxAlternSides', 'maxEqualSides',...
            'limitEqualSides','limitAlternSides','leftProb','biasSize'...
            'sideSelection','leftRewardMult','rightRewardMult'});
        
        
        
    %% CASE show
    case 'show'
            set(value(bias_fig), 'Visible', 'on');
        
  	%% CASE hide
    case 'hide'
            set(value(bias_fig), 'Visible', 'off');
            biasToggle.value = false;
            
    case 'close'
        if exist('bias_fig', 'var') && isa(bias_fig, 'SoloParamHandle') && ishandle(value(bias_fig)),
            delete(value(bias_fig));
        end;  
        
end