function [] = SetGUI(obj, action)

GetSoloFunctionArgs;

switch action,
    
    case 'init',
        
        %% Create protocol main figure
        % Make default figure. We remember to make it non-saveable; on next run
        % the handle to this figure might be different, and we don't want to
        % overwrite it when someone does load_data and some old value of the
        % fig handle was stored as SoloParamHandle "main_fig"
        SoloParamHandle(obj, 'main_fig', 'saveable', 0); main_fig.value = figure;
        
        % Make the title of the figure be the protocol name, and if someone tries
        % to close this figure, call dispatcher's close_protocol function, so it'll know
        % to take it off the list of open protocols.
        name = 'Stimulus Presentation';
        set(value(main_fig), 'Name', name, 'Tag', name, ...
            'closerequestfcn', 'dispatcher(''close_protocol'')', ...
            'MenuBar', 'none', 'NumberTitle', 'off');
        
        set(value(main_fig), 'Position', [423 396 430 380]);
        % Starting coordinates
        x=10; y=10;
        
        %
        
        %% Setup Menu
        SliderParam(obj, 'backLight', 0, 0,1, x, y, 'TooltipString', 'Level of brightness of background.');next_row(y);
        SliderParam(obj, 'stimLight', 1, 0,1, x, y, 'TooltipString', 'Level of brightness of stimulus.');next_row(y);
        NumeditParam(obj, 'centerPos', [0 0], x, y, 'TooltipString', 'Offset of screen center to eye position');next_row(y);
        NumeditParam(obj, 'viewingDistCm', 15, x, y, 'TooltipString', ...
            '...');next_row(y);
        ToggleParam(obj, 'screenOri', 1, x, y, 'OnString', 'Screen Horizontal ON', ...
            'OffString', 'Screen Vertical ON'); next_row(y);
        SubheaderParam(obj, 'setupMenu', 'Setup Configuration', x, y); next_row(y,1.5);
        
        %% Stimulus Menu
        NumeditParam(obj, 'cbTemporalPeriod', 0.2, x, y, 'TooltipString', 'Time period of checkerboard in s');next_row(y);
        NumeditParam(obj, 'cbSpatialPeriod', 30, x, y, 'TooltipString', 'Spatial period of checkerboard in degrees');next_row(y);
        ToggleParam(obj, 'cbON', 1, x, y, 'OnString', 'Checkerboard ON', ...
            'OffString', 'Checkerboard OFF'); next_row(y);
        NumeditParam(obj, 'edges', 0.1, x, y, 'TooltipString', 'Edges of stimulus for each side of the screen in %');next_row(y);
        NumeditParam(obj, 'barSizeDeg', 20, x, y, 'TooltipString', 'Width of the drifting bar in degrees');next_row(y);
        NumeditParam(obj, 'barPeriod', 12, x, y, 'TooltipString', 'Period of stimulus in seconds');next_row(y);
        NumeditParam(obj, 'stimRepetitions', 30, x, y, 'TooltipString', 'Stimulus repetitions');next_row(y);
        MenuParam(obj, 'stimOri', {'0','1'},2, x, y, 'TooltipString', '0 for horizontal bar; 1 for vertical bar');next_row(y);
        MenuParam(obj, 'stimDir', {'-1','1'},2, x, y, 'TooltipString', '1 for left or down; -1 for right or up');next_row(y);
        SubheaderParam(obj, 'setupMenu', 'Stimulus Properties', x, y); next_row(y,1.5);
        
        next_column(x); y=10;
        
        %% Saving section
        [x, y] = SavingSectionNonInteractive(obj, 'init', x, y);
        
        next_row(y,0.4);
        
        %% Submit push and restart buttons
        % Run
        PushbuttonParam(obj, 'start', x, y, 'position', [(x) y 100 25],'BackgroundColor', [0 1 0]);
        set_callback(start, {'SetGUI', 'start'}); %i, sprintf('\n')});
        % Stop
        PushbuttonParam(obj, 'stop', x, y, 'position', [(x+100) y 100 25],'BackgroundColor', [1 1 0]);next_row(y,1.5);
        set_callback(stop, {'SetGUI', 'stop'}); %i, sprintf('\n')});
        % Submit
        PushbuttonParam(obj, 'submit', x, y, 'position', [x y 100 25],'BackgroundColor', [0 0 1]);
        set_callback(submit, {'SetGUI', 'submit'}); %i, sprintf('\n')});
        % Restart
        PushbuttonParam(obj, 'restart', x, y, 'position', [(x+100) y 100 25],'BackgroundColor', [1 0 0]);next_row(y,1.5);
        set_callback(restart, {'SetGUI','restart'}); %i, sprintf('\n')});
        
        DispParam(obj, 'currStimNum', 0, x, y); next_row(y);
        SubheaderParam(obj, 'currentTrial', 'Current Trial', x, y); next_row(y,1.5);
        
        
        %% Declares global variables
        %%% Global Variables Example
        % DeclareGlobals(obj, {'rw_args','leftValve'}, {'ro_args', 'rightValve'},{'owner', class(obj)});
        %%%
        DeclareGlobals(obj, 'rw_args', {...
            'backLight','stimLight','centerPos','viewingDistCm','screenOri',...
            'cbTemporalPeriod','cbSpatialPeriod','cbON','edges','barSizeDeg',...
            'barPeriod','stimRepetitions','stimOri','stimDir','currStimNum'});
        
        %% RESET POSITION F DISPATCHER AND POKESPLOT
        a = findobj('type','figure');
        [~, c] = sort(a);
        %%% Dispatcher
        set(a(c(1)), 'position', [5 395 410 460]);
        %%% PokesPlot
        % set(a(c(3)), 'position', [0.1      0.0275     0.8       0.815]);
        
    case 'start'
        dispatcher('Run');

    case 'submit'
        SupportFunctions(obj, 'param_save');
        StateMatrixSection(obj, 'next_trial');
        
    case 'stop'
        dispatcher('Stop');
        
    case 'restart'
        dispatcher('restart_protocol');
        
    case 'close',
        if exist('main_fig', 'var') && isa(main_fig, 'SoloParamHandle') && ishandle(value(main_fig)),
            delete(value(main_fig));
        end;
        
    otherwise,
        error(['Don''t know how to deal with action ' action]);
end;

