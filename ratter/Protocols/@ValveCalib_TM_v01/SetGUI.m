function [] = SetGUI(obj, action)

GetSoloFunctionArgs;

switch action,
    case 'init',

        % Creates the main window
        SoloParamHandle(obj, 'mainfig', 'saveable', 0); mainfig.value = figure;
        name = 'Valve Calibration';
        set(value(mainfig), 'Name', name, 'Tag', name, ...
            'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
        
        set(value(mainfig), 'Position', [423 660 215 200]);
        % Starting coordinates
        x=10; y=10;
        
        %% Submit, run, stop and restart buttons
        % Run
        PushbuttonParam(obj, 'start', x, y, 'position', [(x) y 100 25],'BackgroundColor', [0 1 0]);
        set_callback(start, {'SetGUI', 'start'}); %i, sprintf('\n')});
        % Stop
        PushbuttonParam(obj, 'stop', x, y, 'position', [(x+100) y 100 25],'BackgroundColor', [1 1 0]);next_row(y,1.5);
        set_callback(stop, {'SetGUI', 'stop'}); %i, sprintf('\n')});
        % Submit
        PushbuttonParam(obj, 'submit', x, y, 'position', [x y 100 25],'BackgroundColor', [0 0 1]);
        set_callback(submit, {'StateMatrixSection', 'init'}); %i, sprintf('\n')});
        % Restart
        PushbuttonParam(obj, 'restart', x, y, 'position', [(x+100) y 100 25],'BackgroundColor', [1 0 0]);next_row(y,1.5);
        set_callback(restart, {'SetGUI','restart'}); %i, sprintf('\n')});
        
        %% Parameters menu
        
        NumeditParam(obj, 'valveTimeRight', 0.05, x, y, 'TooltipString',...
            '...');next_row(y);
        NumeditParam(obj, 'valveTimeLeft', 0.05, x, y, 'TooltipString',...
            '...');next_row(y);

        NumeditParam(obj, 'ITI', 1, x, y, 'TooltipString',...
            '...');next_row(y);

        NumeditParam(obj, 'nTrials', 100, x, y, 'TooltipString',...
            '...');next_row(y);

        
        MenuParam(obj, 'valves',{'LEFT','RIGHT','BOTH'}, 'BOTH', x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        
        DispParam(obj, 'trialNum', 1, x, y); next_row(y,1);
                    
        
        
        % Declares global variables
        %%% Global Variables Example
        % DeclareGlobals(obj, {'rw_args','leftValve'}, {'ro_args', 'rightValve'},{'owner', class(obj)});
        %%%
        DeclareGlobals(obj, 'rw_args', {...
            'valveTimeRight', 'valveTimeLeft', 'ITI', 'nTrials','valves','trialNum'});
        
        
        % RESET POSITION F DISPATCHER AND POKESPLOT
        a = findobj('type','figure');
        [~, c] = sort(a);
        %%% Dispatcher
        set(a(c(1)), 'position', [5 395 410 460]);
        
    case 'start'
        dispatcher('Run');
    case 'stop'
        dispatcher('Stop');   
    case 'restart'
        SetGUI(obj, 'close');
        dispatcher('restart_protocol');     
    case 'close',
            if exist('mainfig', 'var') && isa(mainfig, 'SoloParamHandle') && ishandle(value(mainfig)),
                delete(value(mainfig));
            end;
  
    otherwise,
        error(['Don''t know how to deal with action ' action]);
end;

