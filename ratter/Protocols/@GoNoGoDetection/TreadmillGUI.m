

function [x, y] = TreadmillGUI(obj, action)

GetSoloFunctionArgs;


switch action
    
    %   ------------------------------------------------------------------
    %                INIT
    %   ------------------------------------------------------------------
    case 'init'
        
        % Create figure for setting the timing structure of the task,
        % and set it to be invisible until button is pressed
        SoloParamHandle(obj, 'treadmill_fig', 'saveable', 0); treadmill_fig.value = figure;
                name = 'Treadmill Settings';
        set(value(treadmill_fig), 'Name', name, 'Tag', name, ...
            'Position', [700   100   215   60], 'Visible', 'off',...
                    'MenuBar', 'none',    'NumberTitle', 'off',...    
            'closerequestfcn', ['TreadmillGUI(' class(obj) ',''hide'')']);
        
        x=10; y=10;
        
        % ----------------------  Treadmill Parameters -----------------------
        SliderParam(obj, 'speedTreshold', 1, 0, 10, x, y);next_row(y);
        SliderParam(obj, 'runLength', 2, 0, 5, x, y);next_row(y);

        DeclareGlobals(obj, 'rw_args', {'speedTreshold', 'runLength'});

        
    %% CASE show
    case 'show'
            set(value(treadmill_fig), 'Visible', 'on');
        
  	%% CASE hide
    case 'hide'
            set(value(treadmill_fig), 'Visible', 'off');
            treadmillToggle.value = false;
            
    case 'close'
        if exist('treadmill_fig', 'var') && isa(treadmill_fig, 'SoloParamHandle') && ishandle(value(treadmill_fig)),
            delete(value(treadmill_fig));
        end;  
        
end