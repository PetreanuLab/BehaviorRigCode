

function [x, y] = MonitorGUI(obj, action)

GetSoloFunctionArgs;


switch action
    
    %   ------------------------------------------------------------------
    %                INIT
    %   ------------------------------------------------------------------
    case 'init'
        
        % Create figure for setting the timing structure of the task,
        % and set it to be invisible until button is pressed
        SoloParamHandle(obj, 'monitor_fig', 'saveable', 0); monitor_fig.value = figure;
        name = 'Monitor Settings';
        set(value(monitor_fig), 'Name', name, 'Tag', name, ...
            'Position', [700   100   215   80], 'Visible', 'off',...
                    'MenuBar', 'none',    'NumberTitle', 'off',...    
            'closerequestfcn', ['MonitorGUI(' class(obj) ',''hide'')']);
        
        x=10; y=10;
        
        % ----------------------  Timing Parameters -----------------------
        NumeditParam(obj, 'screenPx', [1920, 1080], x, y, 'TooltipString', '');next_row(y);
        NumeditParam(obj, 'diagIn', 24, x, y, 'TooltipString', '');next_row(y);
        NumeditParam(obj, 'distCm', 12, x, y, 'TooltipString', '');next_row(y);
        %SubheaderParam(obj, 'monitorHeader', 'Monitor Settings', x, y); next_row(y,1.5);
        
        DeclareGlobals(obj, 'rw_args', {'screenPx', 'diagIn','distCm'});
        
    
    %% CASE show
    case 'show'
            set(value(monitor_fig), 'Visible', 'on');
        
  	%% CASE hide
    case 'hide'
            set(value(monitor_fig), 'Visible', 'off');
            monitorToggle.value = false;

    %% CASE close
    case 'close'

        if exist('monitor_fig', 'var') && isa(monitor_fig, 'SoloParamHandle') && ishandle(value(monitor_fig)),
            delete(value(monitor_fig));
        end;

        
end